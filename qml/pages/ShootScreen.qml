﻿import QtQuick 2.5
import QtQuick.LocalStorage 2.0
import Sailfish.Pickers 1.0 // File-Loader
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Nemo.Notifications 1.0

import "../utils/localdb.js" as Database

Page {
    id: page

    allowedOrientations: Orientation.All
    property alias oCamera: camera
    property var pStopmotion
    property var savePath: Database.getProp('path')
    property int seriesCounter: 0
    property int counter: 0
    property string recordPath : StandardPaths.pictures

    property bool latch: true

    property bool debug: false

    QtObject
    {
        id:d
        property real cDOCK_PANEL_SIZE: 800
    }
    // used for target slide show and send signals to the container
    property var slideshowPage

    // function to pad image/series names with leading 0s
    function pad(n, width)
    {
        n = n + '';
        return n.length >= width ? n :
                                   new Array(width - n.length + 1).join('0') + n;
    }


    onStatusChanged:
    {
        if(status === PageStatus.Active)
        {
            // not quite! but sometimes
            if (debug) console.log(camera.supportedViewfinderResolutions())

         } else if(status === PageStatus.Deactivating) // Deactivating, set defaults.
         {
         }
    }

    onOrientationChanged: {

        if (orientation===Orientation.Landscape){
            if (debug) console.log("inverted image");
            camera.imageCapture.setMetadata("Orientation",0);
            //portrait = 0
            // we don't need to
            //camera.imageCapture.resolution = "1920X1080"
            //camera.viewfinder.resolution = "1920x1080"
        } else if (orientation === Orientation.Portrait){
            camera.imageCapture.setMetadata("Orientation",270);
            //portrait = 1
            //we don't need to
            //camera.imageCapture.resolution = "1080X1920"
            //camera.viewfinder.resolution = "1080x19 -select_streams v:0 -show_entries 20"
            //look at piggz getNearestViewFinderResolution();

        }
    }

    Camera
    {
        id: camera
        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto
        exposure {
            exposureMode: Camera.ExposureAuto
        }
        captureMode: Camera.CaptureStillImage
        flash.mode: Camera.FlashOff
        focus.focusMode: Camera.FocusContinuous
        imageCapture {
            resolution: "1920x1080"
        }

    }

    Component
    {
        id: internalPicker
        FolderPickerDialog {
            id: folderiDialog
            title: "Save to:"
            onAccepted:{
                savePath = selectedPath
                selectPath.text = savePath
            }
            onRejected: savePath = StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        }
    }

    Component
    {
        id: externalPicker
        FolderPickerDialog {
            id: foldereDialog
            path: "/run/media/defaultuser"
            title: "Save to:"
            onAccepted: {
                savePath = selectedPath + "/"
                selectPath.text = savePath
            }
            onRejected: savePath = StandardPaths.pictures
        }
    }

    PropertyAnimation
    {
        id: closeDockAnimation;
        target: panel;
        property: "x";
        to: -panel.width;
        duration: 300
    }
    PropertyAnimation
    {
        id: openDockAnimation;
        target: panel;
        property: "x";
        to: 0;
        duration: 300
    }

    MouseArea
    {
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
                rightMargin: 42
                bottomMargin: 42
                //horizontalCenter: parent.horizontalCenter
            }

            visible: !pStopmotion.busyEncoding

            onClicked: {
                if (mA.state==="Ready"){
                    if (latch === true) {
                        pStopmotion.start()
                        mA.state = "Recording";
                        // use autofocus
                        //camera.searchAndLock();
                    } else {
                        playClick.play()
                        counter++
                        var filename = savePath +"/" + seriesName + pad(counter, 4) ;
                        camera.imageCapture.captureToLocation(filename)
                    }
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
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeTiny
            anchors{
                horizontalCenter:recordButton.horizontalCenter
                verticalCenter: recordButton.verticalCenter
            }
            //horizontalAlignment: Text.AlignRight
            //wrapMode: "WrapAtWordBoundaryOrAnywhere"
            //visible: pStopmotion.busyEncoding
            /*
            states:[
                State {
                    name:"Horizontal"
                    when:orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted
                    AnchorChanges {
                        target: busyText

                        anchors {
                            bottom:undefined
                            right: recordButton.right
                            top: recordButton.bottom
                            topMargin: 70
                            horizontalCenter:undefined
                        }
                    }
                }
            ]
            */

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

    Rectangle
    {
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
        Slider {
            id:delaySelector
            label: "Delay"
            anchors {
                left: parent.left
                right:parent.right
            }
            //width: parent.width - Theme.paddingLarge
            minimumValue: 1
            maximumValue: 120
            value: 1
            stepSize: 1
            valueText: sliderValue
            onReleased: {
                pStopmotion.interval = value * 1000
                Database.setProp('delay',String(sliderValue))
            }
            Component.onCompleted: {
                value = Database.getProp('delay')
                if (value < 1 )
                    value = 1
                pStopmotion.interval = value * 1000
            }
        }
        ComboBox {
            id:  latchSelector
            anchors {
                left: parent.left
                right:parent.right
            }

            label: "Shutter latch"
            menu: ContextMenu {

                MenuItem { text: "On Interval" ;
                    onClicked: { latch = true }
                }
                MenuItem { text: "Single snap"
                    onClicked: { latch = false }
                }
            }

            Component.onCompleted: {
                currentIndex = Database.getProp('latch')
            }
            onCurrentIndexChanged: Database.setProp('latch',String(currentIndex));
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
                            selectPath.text = savePath
                        }
                    }
                }
                MenuItem { text: "SD card"
                    onClicked: {
                        pageStack.push(externalPicker)
                        if (savePath !== ""){
                            if (debug) console.debug(savePath)
                            selectPath.text = savePath
                        }
                    }
                }
            }

            onCurrentIndexChanged: Database.setProp('path_type',String(currentIndex));
        }
        TextField
        {
            id:selectPath
            anchors {
                left: parent.left
                right:parent.right
            }
            text : StandardPaths.pictures+"/Stopmotion"
            height:Theme.itemSizeMedium
            placeholderText: "Enter path"
            label: "Selected path"
            onTextChanged: {
                savePath = text
                //pStopmotion.setSavePath(text);
                Database.setProp('path',text);
            }
            Component.onCompleted: {
                text = Database.getProp('path')
            }
        }
        TextField
        {
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
        ComboBox
        {
            id:flashModeSelector
            anchors {
                left: parent.left
                right:parent.right
            }

            label: qsTr("Flash mode")
            menu: ContextMenu {
                MenuItem { text: qsTr("Off")
                    onClicked: camera.flash.mode = Camera.FlashOff}
                MenuItem { text: qsTr("On")
                    onClicked: camera.flash.mode = Camera.FlashOn}
                MenuItem { text: qsTr("Auto")
                    onClicked: camera.flash.mode = Camera.FlashAuto}
                MenuItem { text: qsTr("Red eye reduction")
                    onClicked: camera.flash.mode = Camera.FlashRedEyeReduction}
                MenuItem { text: qsTr("Slow sync front")
                    onClicked: camera.flash.mode = Camera.FlashSlowSyncFrontCurtain}

            }

            onCurrentIndexChanged: Database.setProp('flash_type',String(currentIndex));

            Component.onCompleted: {
                currentIndex = Database.getProp('flash_type')
            }
        }

        ComboBox
        {
            id:cameraSelector
            label: qsTr("Select Camera")
            anchors {
                left: parent.left
                right:parent.right
            }
            menu: ContextMenu {
                MenuItem
                {
                    text: qsTr("One")
                    onClicked: camera.deviceId = 0
                }
                MenuItem
                {
                    text: qsTr("Two")
                    onClicked: {
                        camera.deviceId = 1
                        console.log(QtMultimedia.availableCameras[0])
                    }

                }
            }
            onCurrentIndexChanged: Database.setProp('deviceId',String(currentIndex));
            Component.onCompleted: {
                currentIndex = Database.getProp('deviceID')
            }
        }
        Button
        {
            id: slideshowShowSlideshow
            anchors {
                left: parent.left
                right:parent.right
            }
            text: qsTr("Slideshow")
            onClicked: {
                camera.unlock()
                cameraState.slidesShow(true)
                slideshowPage = pageStack.push(Qt.resolvedUrl("SlideshowPage.qml", {'editMode': true, 'iniFolder': savePath, 'slideshowRunning': true }))
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
    SoundEffect
    {
        id: playClick
        source: Qt.resolvedUrl("../sound/click.wav")
    }

    // drives the repeated capture of images
    Timer
    {
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
            var filename = savePath +"/" + seriesName + pad(counter, 4) ;
            if (debug) console.log(filename);
            camera.imageCapture.captureToLocation(filename)
        }
    }

    Component.onCompleted: {

        camera.viewfinder.resolution = "1920x1080"//getNearestViewFinderResolution();
        camera.imageCapture.resolution = "1920x1080"
       if (debug) console.log(camera.supportedViewfinderResolutions(1,20))

         if (debug) console.log(QtMultimedia.defaultCamera.deviceId)
         if (debug) console.log(QtMultimedia.availableCameras)
        if (debug) console.log("completed");

        if (debug) console.log("delay " + Database.getProp('delay'));

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
        State
        {
            name:"active"
            when : Qt.application.state === Qt.ApplicationActive || sView.state=== "Recording"
        },
        State
        {
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


