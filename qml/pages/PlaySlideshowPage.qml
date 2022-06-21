import QtQuick 2.6
import QtQuick 2.5
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2
import QtMultimedia 5.6
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.0

//import "../constants.js" as Constants

Page {
    id: playSlideshowPage

    showNavigationIndicator: !slideshowRunning
    backNavigation: !slideshowRunning

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // Properties.
    property string imageSource: ""
    property string imageSource2: ""
    property int imageIndex: -1
    property bool slideshowRunning:true
    property bool debug: false

    onOrientationChanged: {

        if (orientation===Orientation.Landscape){
        } else if (orientation === Orientation.Portrait){
        }
    }
    onSlideshowRunningChanged: {
        if (debug) console.log("SlideshowRunning status changed: " + slideshowRunning)
        if (slideshowRunning) {
            //backgroundMusic.play()
        } else {
            //backgroundMusic.pause()
        }

        slideshowRunningToggled(slideshowRunning)
    }

    property ListModel imageModel
    property ListModel musicModel
    property var slideshowOrderArray: []
    property bool firstLoaded: false

    // Settings.
    property int slideshowInterval: 200 //Settings.getIntSetting(Constants.intervalKey, 5) * 1000
    property bool loop: true //Settings.getBooleanSetting(Constants.loopKey, true)
    property bool loopMusic: false //Settings.getBooleanSetting(Constants.loopMusicKey, true)

    // Signals.
    // Notify cover about image change.
    signal imageChanged(string url)
    // Notify about slideshow running status change.
    signal slideshowRunningToggled(bool runningStatus)

    // React on status changes.
    onStatusChanged: {
        if(status === PageStatus.Activating)
        {
            console.log("Page activating...")
            console.log(slideshowOrderArray)

            if (slideshowOrderArray.length != imageModel.count) {
                console.error("Order array's and image model's sizes does not match. Expect wonky behavior...")
            }

            if (slideshowOrderArray.length == 0) {
                for (var j = 0; j < imageModel.count; ++j) {
                    slideshowOrderArray.push(j)
                }
                console.log(slideshowOrderArray)
            }

            if (imageModel.count > 0) {
                imageIndex = 0;
                imageSource = imageModel.get(slideshowOrderArray[imageIndex]).url
                if (imageModel.count > 1) {
                    imageSource2 = imageModel.get(slideshowOrderArray[imageIndex + 1]).url
                }
            }

            if (musicModel.count > 0) {
                backgroundPlaylist.clear()
                for (var i = 0; i < musicModel.count; ++i) {
                    console.log("Add music file to playlist: " + musicModel.get(i).url)
                    backgroundPlaylist.addItem(musicModel.get(i).url)
                }
            }

            slideshowRunning = true
            blanking.preventBlanking = true
            slideshowRunningToggled(slideshowRunning)
        }
        else if(status === PageStatus.Deactivating) // Deactivating, set defaults.
        {
            if (debug) console.log("Page deactivating...")
            imageIndex = -1;
            imageChanged("")
            slideshowRunning = false
            blanking.preventBlanking = false
        }
    }

    Component.onDestruction: {
        if (debug) console.log("PlaySlideshowPage destroyed...")
        blanking.preventBlanking = false
    }

    DisplayBlanking {
        id: blanking
    }

    Audio {
        id: backgroundMusic
        autoPlay: false
        audioRole: Audio.MusicRole
        playlist: Playlist {
            id: backgroundPlaylist
            playbackMode: loopMusic ? Playlist.Loop : Playlist.Sequential
        }
    }

    PageHeader {
        id: header
        title: ""
        visible: !slideshowRunning
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.colorScheme == Theme.LightOnDark ? "black" : "white"
    }

    // Image.
    Image {
        id: slideshowPicture
        anchors.fill: parent
        asynchronous: true
        autoTransform: true
        cache: false
        clip: true
        fillMode: Image.PreserveAspectFit
        sourceSize.width: playSlideshowPage.width
        sourceSize.height: playSlideshowPage.height

        source: imageSource

        visible: true
        opacity: visible ? 1.0 : 0.0
        //Behavior on opacity { FadeAnimation { duration: 1000 } }

        onStatusChanged: {
            if(status == Image.Ready && !firstLoaded)
            {
                if (debug) console.log("Image ready, start timer...")
                firstLoaded = true
                imageChanged(imageSource)
                slideshowTimer.start()
            }
        }

        Label {
            id: infoLabel
            anchors.centerIn: parent
            width: parent.width - Theme.horizontalPageMargin*2
            wrapMode: Text.WordWrap
            text: qsTr("info") + " " + imageSource
            visible: slideshowPicture.status == Image.Error
        }
    }

    // Second image.
    Image {
        id: slideshowPicture2
        anchors.fill: parent
        asynchronous: true
        autoTransform: true
        cache: false
        clip: true
        fillMode: Image.PreserveAspectFit
        sourceSize.width: playSlideshowPage.width
        sourceSize.height: playSlideshowPage.height

        source: imageSource2

        visible: false
        opacity: visible ? 1.0 : 0.0
        //Behavior on opacity { FadeAnimation { duration: 1000 } }

        Label {
            id: infoLabel2
            anchors.centerIn: parent
            width: parent.width - Theme.horizontalPageMargin*2
            wrapMode: Text.WordWrap
            text: qsTr("info") + " " + imageSource
            visible: slideshowPicture2.status == Image.Error
        }
    }

    /*
      Pause indicators.
      */
    IconButton {
        id: recordButton
        icon.source: Qt.resolvedUrl("../img/play-button.png")
        scale: 0.75
        visible: !slideshowRunning
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 50
            //horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            toggleSlideshow()
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

    // -------------------------------------------

    // Handle start/stop by click.
    MouseArea {
        id: slideshowToggleArea
        anchors {
//            left: previousImageArea.right
            left: parent.left
            top: parent.top
            right: nextImageArea.left
            bottom: parent.bottom
        }

        // Toggle slideshow start/stop.
        onClicked: {
            if(debug) console.log("onClicked...")
            toggleSlideshow()
        }
    }

    MouseArea {
        id: nextImageArea
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width / 5

        onClicked: {
            if (debug) console.log("Move to next image...")

            // If slideshow is running then restart timer on picture change.
            if (slideshowRunning) {
                slideshowTimer.restart()
            }

            nextPicture()
        }
    }

    // Timer to trigger image change.
    Timer {
        id: slideshowTimer
        interval: slideshowInterval
        repeat: true
        running: slideshowRunning

        // Change image when timer triggers.
        onTriggered: {
            if (debug) console.log("Change picture...")
            nextPicture()
        }
    }

    /*
      Functions.
      */

    function toggleSlideshow() {
        slideshowRunning = !slideshowRunning
        blanking.preventBlanking = slideshowRunning
    }

    function nextPicture() {
        if (debug) console.log("nextPicture()")
        ++imageIndex

        blanking.preventBlanking = true

        if (imageIndex == imageModel.count) {
            imageIndex = 0;
            if (!loop) {
                slideshowRunning = false;
                blanking.preventBlanking = slideshowRunning
                return;
            }
        }

//        imageChanged(imageModel.get(imageIndex).url)
        imageChanged(imageModel.get(slideshowOrderArray[imageIndex]).url)

        // Set picture visibilities.
        if(slideshowPicture.visible)
        {
            slideshowPicture.visible = false
            slideshowPicture2.visible = true

            // Load next to first picture.
            if((imageIndex + 1) === imageModel.count)
                imageSource = imageModel.get(slideshowOrderArray[0]).url
            else
                imageSource = imageModel.get(slideshowOrderArray[imageIndex + 1]).url
        }
        else
        {
            slideshowPicture.visible = true
            slideshowPicture2.visible = false

            // Load next to first picture.
            if((imageIndex + 1) === imageModel.count)
                imageSource2 = imageModel.get(slideshowOrderArray[0]).url
            else
                imageSource2 = imageModel.get(slideshowOrderArray[imageIndex + 1]).url
        }
    }



}
