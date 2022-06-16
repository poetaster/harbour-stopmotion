import QtQuick 2.5
import Sailfish.Silica 1.0

CoverBackground {
    id: coverPage

    property string imageSource: ""
    property bool slideshowRunning: false

    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Stopmotion")
    }
    CoverPlaceholder {
        icon.source: "image://theme/icon-m-camera"
        text: "Timelapse"
    }
    // Slideshow image.
    Image {
        id: slideshowImage
        anchors.fill: parent
        anchors.margins: 5
        source: imageSource
        asynchronous: true
        autoTransform: true
        cache: false
        clip: true
        fillMode: Image.PreserveAspectFit
        sourceSize.width: coverPage.width
        sourceSize.height: coverPage.height
    }

    // Slot to set current image.
    function setImage(source)
    {
        if (imageSource !== source) {
            imageSource = source
        }
        slideshowRunning = imageSource !== ""
    }

    // Slot to follow slideshow running status
    function toggleSlideshowRunning(runningStatus) {
        slideshowRunning = runningStatus
    }

    function toggleSlideshow() {
        mainWinConnections.target.toggleSlideshow()
    }
    //    CoverActionList {
    //        id: coverAction

    //        CoverAction {
    //            iconSource: "image://theme/icon-m-camera"
    //            onTriggered:{

    //            }
    //        }


    //    }
}


