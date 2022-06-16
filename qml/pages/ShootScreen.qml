import QtQuick 2.5
import QtQuick.LocalStorage 2.0
import Sailfish.Pickers 1.0 // File-Loader
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import Nemo.Notifications 1.0

import "../utils/localdb.js" as Database

Page {
    id: page

    allowedOrientations: Orientation.All
    property bool debug: true
    property alias oCamera: camera
    property var pStopmotion
    property var savePath: Database.getProp('path')
    property var seriesName
    property int seriesCounter: 0
    property int counter: 0
    property string recordPath : StandardPaths.pictures+"/Stopmotion"

    QtObject {
        id:d
        property real cDOCK_PANEL_SIZE: 800
    }
    // used for target slide show and send signals to the container
    property var slideshowPage

    property bool slideshowRunning: false
    signal slideshowRunningToggled(bool slideshowRunning)
    onSlideshowRunningChanged: {
        if (debug) console.log("shoot to show: " + slideshowRunning)
        slideshowRunningToggled(slideshowRunning)
    }
    // function to pad image/series names with leading 0s
    function pad(n, width) {
        n = n + '';
        return n.length >= width ? n :
                                   new Array(width - n.length + 1).join('0') + n;
    }
    onStatusChanged: {
        if(status === PageStatus.Activating)
        {

         } else if(status === PageStatus.Deactivating) // Deactivating, set defaults.
            slideshowRunning = true
            slideshowRunningToggled(slideshowRunning)
         {
         }
    }

    Camera {
        id: camera

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto
        exposure {
            exposureMode: Camera.ExposureAuto
        }
        captureMode: Camera.CaptureStillImage
        flash.mode: Camera.FlashOff
        focus.focusMode: Camera.FocusContinuous
    }

    onOrientationChanged: {
        if (orientation==Orientation.LandscapeInverted){
            if (debug) console.log("inverted image");
            camera.imageCapture.setMetadata("Orientation",0);
        }
    }

    Component {
        id: internalPicker
        FolderPickerDialog {
            id: folderiDialog
            title: "Save to:"
            onAccepted: savePath = selectedPath
            onRejected: savePath = StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        }
    }
    Component {
        id: externalPicker
        FolderPickerDialog {
            id: foldereDialog
            path: "/run/media/defaultuser"
            title: "Save to:"
            onAccepted: savePath = selectedPath + "/"
            onRejected: savePath = StandardPaths.pictures
        }
    }

    PropertyAnimation { id: closeDockAnimation;
        target: panel;
        property: "x";
        to: -panel.width;
        duration: 300
    }
    PropertyAnimation {
        id: openDockAnimation;
        target: panel;
        property: "x";
        to: 0;
        duration: 300
    }

    MouseArea {
        id : mA
        anchors.fill: parent
        property real downX : 0
        property string gesture : "none"

        drag.target: panel
        drag.axis: Drag.XAxis
        drag.minimumX: -panel.width;
        drag.maximumX: 0
        drag.threshold: 3.0
        onPressed: {
            downX = mouse.x
            gesture = "none"
        }

        onMouseXChanged: {
            if (Math.abs(downX-mouse.x)>3.0){
                if (downX<mouse.x)
                    gesture = "swiperight"
                else
                    gesture = "swipeleft"
                downX = mouse.x
            }
        }

        onReleased: {
            if (gesture=="swiperight") {
                if (panel.x < 0)
                    openDockAnimation.running=true;
                //                else
                //                    panel.open=true;
            }
            if (gesture=="swipeleft") {
                if (panel.x > -panel.width)
                    closeDockAnimation.running=true;
                //                else
                //                    panel.open=false;
            }
            if (gesture=="none"){
                //                    camera.focus.setFocusMode()
            }
        }
        //        }
        /*CameraButton {
            text: "Capture"
            visible: camera.imageCapture.ready
            onClicked: camera.imageCapture.capture()
        }*/
        IconButton {
            id: recordButton
            icon.source: Qt.resolvedUrl("../img/play-button.png")
            scale: 0.75
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: 70
                //horizontalCenter: parent.horizontalCenter
            }

            visible: !pStopmotion.busyEncoding

            onClicked: {
                if (mA.state==="Ready"){
                    pStopmotion.start()
                    mA.state = "Recording";
                    // use autofocus
                    //camera.searchAndLock();
                } else {
                    pStopmotion.stop();
                    mA.state= "Ready";
                    // reset counter
                    counter = 0;
                    // inc series
                    seriesCounter ++;
                    // use autofocus
                    //camera.searchAndLock();
                    //camera.unlock();
                }

            }

            states:[
                State {
                    name:"Horizontal"
                    when:orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted

                    AnchorChanges {
                        target: recordButton
                        anchors {
                            bottom: undefined
                            right: parent.right
                            horizontalCenter:undefined
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }


            ]

        }
        BusyIndicator {
            id:busyIndicator
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent

            running: pStopmotion.running
        }

        Label {
            id : busyText
            //text: qsTr("Processing video encoding\nYou can hide app now, we inform you when it finished");
            text: counter
            color: Theme.secondaryColor
            anchors{
                left: recordButton.left
                right: recordButton.right
                top : busyIndicator.bottom
                //horizontalCenter: recordButton.horizontalCenter
            }
            horizontalAlignment: Text.AlignRight
            wrapMode: "WrapAtWordBoundaryOrAnywhere"
            //visible: pStopmotion.busyEncoding
        }

        state : "Ready"
        states:[
            State {
                name:"Ready"
                PropertyChanges {
                    target: recordButton
                    icon.source : Qt.resolvedUrl("../img/play-button.png")
                }
            },
            State {
                name:"Recording"
                //                when:camera.videoRecorder.recorderStatus === CameraRecorder.RecordingStatus
                PropertyChanges {
                    target: recordButton
                    icon.source : Qt.resolvedUrl("../img/stop-button.png")
                }
            }
        ]
    }

    Rectangle {
        id: panel
        height: parent.height
        anchors {
            top:parent.top
            bottom: parent.bottom
        }
        width: d.cDOCK_PANEL_SIZE<(parent.width*0.8)?d.cDOCK_PANEL_SIZE:(parent.width*0.8);
        x: 0
        opacity: Theme.highlightBackgroundOpacity
        color: Theme.highlightBackgroundColor
        MouseArea {
            id :dockMA
            anchors.fill: parent
            property real dockDownX : 0;
            property string gesture : "none";

            drag.target: panel
            drag.axis: Drag.XAxis
            drag.minimumX: -panel.width;
            drag.maximumX: 0
            drag.threshold: 3.0
            onPressed: {
                dockDownX = panel.x;
                gesture = "none"
            }

            onMouseXChanged: {
                if (Math.abs(dockDownX-panel.x)>1.0){
                    if (dockDownX<panel.x)
                        gesture = "swiperight";
                    else
                        gesture = "swipeleft";
                }
                if (Math.abs(dockDownX-panel.x)>7.0)
                    dockDownX = panel.x
            }

            onReleased: {
                if (gesture=="swiperight")
                    if (panel.x < 0)
                        openDockAnimation.running=true;
                //                    else
                //                        panel.open=true;
                if (gesture=="swipeleft")
                    if (panel.x > -panel.width)
                        closeDockAnimation.running=true;
                //                    else
                //                        panel.open=false;
            }
            //            Drag.active:
        }
    }
    Column {
        id:leftPanelCol
        anchors.fill: panel
        //            visible: false
        ComboBox {
            id:delaySelector
            anchors {
                left: parent.left
                right:parent.right
            }

            label: "Delay"
            menu: ContextMenu {
                MenuItem { text: "1 min" ;
                    onClicked: pStopmotion.interval = 60*1000 }
                MenuItem { text: "20 sec" ;
                    onClicked: pStopmotion.interval = 20*1000 }
                MenuItem { text: "10 sec"
                    onClicked: pStopmotion.interval = 10*1000 }
                MenuItem { text: "4 sec"
                    onClicked: pStopmotion.interval = 4*1000 }
                MenuItem { text: "1 sec" ;
                    onClicked: pStopmotion.interval = 1000 }

            }
            onCurrentIndexChanged: Database.setProp('delay',String(currentIndex))
        }
        ComboBox {
            id:  pathSelector
            anchors {
                left: parent.left
                right:parent.right
            }

            label: "Save path"
            menu: ContextMenu {

                MenuItem { text: "Internal" ;
                    onClicked: {
                        pageStack.push(internalPicker)
                        if (savePath !== ""){
                            //selectedPath.text=StandardPaths.pictures+"/Stopmotion/";
                            selectPath.text = savePath
                        }
                    }
                }
                MenuItem { text: "SD card"
                    //visible:UILink.sdAvailable
                    onClicked: {
                        pageStack.push(externalPicker)
                        if (savePath !== ""){
                            if (debug) console.debug(savePath)
                            selectPath.text = savePath
                        }
                        //selectedPath.text=UILink.getSDPath()+"/Stopmotion/";
                    }
                }
            }

            onCurrentIndexChanged: Database.setProp('path_type',String(currentIndex));
        }
        TextField {
            id:selectPath
            anchors {
                left: parent.left
                right:parent.right
            }
            //                text : StandardPaths.pictures+"/Stopmotion"
            height:Theme.itemSizeMedium
            placeholderText: "Enter path"
            label: "Selected path"
            onTextChanged: {
                savePath = text
                //pStopmotion.setSavePath(text);
                Database.setProp('path',text);
            }
        }
        TextField {
            id:sName
            anchors {
                left: parent.left
                right:parent.right
            }
            text : "series" + seriesCounter
            height:Theme.itemSizeMedium
            placeholderText: "Enter series name"
            label: "Series name"
            onTextChanged: {
                seriesName = text
                //pStopmotion.setSavePath(text);
                //Database.setProp('path',text);
            }
        }
        ComboBox {
            id:flashModeSelector
            anchors {
                left: parent.left
                right:parent.right
            }

            label: "Flash mode"
            menu: ContextMenu {
                MenuItem { text: "Off" ;
                    onClicked: camera.flash.mode = Camera.FlashOff}
                MenuItem { text: "On" ;
                    onClicked: camera.flash.mode = Camera.FlashOn}
                MenuItem { text: "Auto"
                    onClicked: camera.flash.mode = Camera.FlashAuto}
                MenuItem { text: "Red eye reduction"
                    onClicked: camera.flash.mode = Camera.FlashRedEyeReduction}
                MenuItem { text: "Slow sync front" ;
                    onClicked: camera.flash.mode = Camera.FlashSlowSyncFrontCurtain}

            }
            onCurrentIndexChanged: Database.setProp('flash_type',String(currentIndex));
        }

        Button {
            id: slideshowShowSlideshow
            anchors {
                left: parent.left
                right:parent.right
            }
            text: qsTr("Slideshow")
            onClicked: {
                cameraState.slidesShow(true)
                slideshowRunning = true
                slideshowPage = pageStack.push(Qt.resolvedUrl("SlideshowPage.qml", {'editMode': true, 'iniFolder': savePath, 'slideshowRunning': true}))
                cameraControl.target =  slideshowPage
                //dialog.accepted.connect(function() { //addSlideshow(dialog.slideshow); }
                //   )
            }
        }

        /*
        Item {
            IconButton {
                id: buttonImage
                anchors.fill: parent
                source: "img/play-button.png"
                width: button.width; height: button.height
                onClicked: {
                    if (camera.lockStatus == Camera.Unlocked) {
                        camera.searchAndLock();
                        btnText.text = "Focus";
                    } else if (camera.lockStatus == Camera.Searching) {
                        btnText.text = "Focusing";
                    } else {
                        camera.unlock();
                        btnText.text = "Unlock";
                    }
                }
            }
            Text {
                id: btnText
                text: "unlock"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: true
            }
        }*/

    }


    /*
    // this is pending python ffmpeg implmentation
    Notification {
        id: notification
        property string path: ""
        category: "video"
        summary: qsTr("Encoding finished")
        body: qsTr("Press to open")
        appName: qsTr("Stopmotion")
        //                        appIcon: "image://theme/icon-lock-information"
        previewSummary: qsTr("Encoding finished")
        previewBody: qsTr("Press to open")
        //                itemCount: 5
        onClicked: {
            //            if (reason==2){
            console.log("open:"+notification.path);
            Qt.openUrlExternally(notification.path);
            //                Notification
            //            }
        }
        //                onClosed: console.log("Closed, reason: " + reason)
    }

    Connections {
        target: pStopmotion

        onRequestRunNotify: {

            notification.body = moviePath;
            notification.previewBody = moviePath;

            if (debug) console.log(selectedPath.text);
            notification.path = selectedPath.text+"/"+moviePath;
            notification.publish();
        }
    }*/


    // simple click on Timer start
    SoundEffect {
        id: playClick
        source: Qt.resolvedUrl("../sound/click.wav")
    }

    // drives the repeated capture of images
    Timer {
        id: pStopmotion
        interval: 1000;
        running: false
        repeat: true

        onTriggered: {
            if ( ! savePath || savePath === "") {
                savePath = StandardPaths.pictures+"/Stopmotion/"
            }
            playClick.play()
            // increment on start
            counter++

            //var date = new Date()
            //date.toISOString().split('T')[0];
            var filename = savePath +"/" + seriesName + pad(counter, 4) ;

            if (debug) console.log(filename);

            camera.imageCapture.captureToLocation(filename)
        }
    }

    Component.onCompleted: {

        if (debug) console.log("completed");

        if (debug) console.log("delay " + Database.getProp('delay'));

        delaySelector.currentIndex = parseInt(Database.getProp('delay'));
        if (delaySelector.currentIndex==0)
            //pStopmotion.setTimeout(60);
            pStopmotion.interval = 60*1000;
        if (delaySelector.currentIndex==1)
            pStopmotion.interval = 20*1000;
        if (delaySelector.currentIndex==2)
            pStopmotion.interval = 10*1000;
        if (delaySelector.currentIndex==3)
            pStopmotion.interval = 4*1000;
        if (delaySelector.currentIndex==4)
            pStopmotion.interval = 1*1000;

        pathSelector.currentIndex = parseInt(Database.getProp('path_type'));

        if (Database.getProp('path')!=="")
            selectPath.text = Database.getProp('path');
        else
            selectPath.text=StandardPaths.pictures+"/Stopmotion/";

        flashModeSelector.currentIndex = parseInt(Database.getProp('flash_type'));

        if (flashModeSelector.currentIndex==0)
            camera.flash.mode = Camera.FlashOff;
        if (flashModeSelector.currentIndex==1)
            camera.flash.mode = Camera.FlashOn;
        if (flashModeSelector.currentIndex==2)
            camera.flash.mode =Camera.FlashAuto;
        if (flashModeSelector.currentIndex==3)
            camera.flash.mode =Camera.FlashRedEyeReduction;
        if (flashModeSelector.currentIndex==4)
            camera.flash.mode =Camera.FlashSlowSyncFrontCurtain;

    }

    states: [
        State {
            name:"active"
            when : Qt.application.state === Qt.ApplicationActive || sView.state=== "Recording"
        },
        State {
            name:"deactivated"
            when : Qt.application.state === Qt.ApplicationInactive &&  mA.state === "Ready"
        }

    ]
    onStateChanged: {

        if (debug) console.log("state changed to "+page.state);
        if (debug) console.log("record state : "+mA.state);

        if (page.state=="active"){
            //camera.focus.isFocusModeSupported(Camera.FocusAuto)
            camera.start();
        } else if (page.state=="deactivated") {
            camera.stop();
        }
    }

}


