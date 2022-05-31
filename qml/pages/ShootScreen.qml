
import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Pickers 1.0 // File-Loader
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import org.nemomobile.notifications 1.0
import "../utils/localdb.js" as Database

Page {
    id: page
    allowedOrientations: Orientation.All

    property alias oCamera: camera
    property var pStopmotion
    property var savePath: Database.getProp('path')
    property var seriesName
    property int seriesCounter: 0
    property int counter: 0

    function pad(n, width) {
        n = n + '';
        return n.length >= width ? n :
            new Array(width - n.length + 1).join('0') + n;
    }

    QtObject {
        id:d
        property real cDOCK_PANEL_SIZE: 800
    }
    property string recordPath : StandardPaths.pictures+"/Stopmotion"
    Camera {
        id: camera

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto

        exposure {
            //            exposureCompensation: -1.0
            exposureMode: Camera.ExposureAuto
        }
        captureMode: Camera.CaptureStillImage
        flash.mode: Camera.FlashOff

    }
    onOrientationChanged: {
        if (orientation==Orientation.LandscapeInverted){
            console.log("inverted image");
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
           onAccepted: savePath = selectedPath
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

        IconButton {
            id: recordButton
            icon.source: Qt.resolvedUrl("../img/play-button.png")
            anchors {
                bottom: parent.bottom
                margins: 30

                horizontalCenter: parent.horizontalCenter
            }
            visible: !pStopmotion.busyEncoding
            onClicked: {
                if (mA.state==="Ready"){
                    camera.searchAndLock();
                    pStopmotion.start()
                    mA.state = "Recording";
                    //                    console.log(camera.cameraStatus);
                    //                    camera.videoRecorder.setOutputLocation(selectedPath.text+Date.now().toString()+".mp4");
                    //                    camera.videoRecorder.record();
                    //                    console.log("started record");
                } else {
                    pStopmotion.stop();
                    camera.unlock();
                    mA.state= "Ready";
                    counter = 0;
                    seriesCounter ++;
                    //                    camera.videoRecorder.stop();
                    //                    console.log("stopped record");
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
            color: Theme.secondaryColor
            anchors{
                left: parent.left
                right: parent.right
                top : busyIndicator.bottom

                //                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            wrapMode: "WrapAtWordBoundaryOrAnywhere"
            visible: pStopmotion.busyEncoding
        }

        state : "Ready"
        states:[
            State {
                name:"Ready"
                //                when:camera.videoRecorder.recorderStatus === CameraRecorder.LoadedStatus
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
                            selectedPath.text = savePath
                        }
                    }
                }
                MenuItem { text: "SD card"
                    //visible:UILink.sdAvailable
                    onClicked: {
                        pageStack.push(externalPicker)
                        if (savePath !== ""){
                            selectedPath.text = savePath
                        }
                        //selectedPath.text=UILink.getSDPath()+"/Stopmotion/";
                    }
                }
            }

            onCurrentIndexChanged: Database.setProp('path_type',String(currentIndex));
        }
        TextField {
            id:selectedPath
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
        } /*
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
            console.log(selectedPath.text);
            notification.path = selectedPath.text+"/"+moviePath;
            notification.publish();
        }
    }

*/

    Timer {
       id: pStopmotion
       interval: 1000;
       running: false
       repeat: true

      onTriggered: {
          if ( ! savePath || savePath === "") {
              savePath = StandardPaths.pictures+"/Stopmotion/"
          }
          counter++
           //var date = new Date()
           var filename = savePath.text + seriesName + pad(counter, 6) ;
            //date.toISOString().split('T')[0];
            //notification.body = moviePath;
            //notification.previewBody = moviePath;

            console.log(savePath.text);
            console.log(filename);

            //notification.path = selectedPath.text+"/"+moviePath;
            //notification.publish();
           camera.imageCapture.captureToLocation(filename)
      }
    }

    Component.onCompleted: {

        console.log("completed");

        console.log("delay "+Database.getProp('delay'));

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
            selectedPath.text = Database.getProp('path');
        else
            selectedPath.text=StandardPaths.pictures+"/Stopmotion/";

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
        console.log("state changed to "+page.state);
        console.log("record state : "+mA.state);
        if (page.state=="active"){
            camera.start();
        } else if (page.state=="deactivated") {
            camera.stop();
        }
    }

}


