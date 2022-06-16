import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "pages"

// Icon
//<a href="https://www.flaticon.com/free-icons/timelapse" title="timelapse icons">Timelapse icons created by Freepik - Flaticon</a>

ApplicationWindow
{
    Connections {
        id: mainWinConnections
        target: null
        ignoreUnknownSignals: true
        onImageChanged: {
            console.log("Image changed, current image:", url)
            //coverPage.setImage(url)
        }
        onSlideshowRunningToggled: {
            console.log("Slideshow running:", runningStatus)
            //coverPage.toggleSlideshowRunning(runningStatus)
        }
    }

    QtObject {
        id: cameraState
        signal slidesShow(bool slideshowRunning)
    }

    Connections {
        target: cameraState
        onSlidesShow: {
            console.log("cameraState:", slideshowRunning)
            videoOutput.visible = !slideshowRunning
        }
    }

    initialPage: Component {
        id : sscr
        ShootScreen {
            id:shootScr
            Component.onCompleted: {
                videoOutput.source=oCamera;
            }
        }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    VideoOutput {
        id:videoOutput
        anchors.fill: parent
        z : -1
        focus : visible // to receive focus and capture key events when visible
        visible: true
        /*
        source:  shootScr.oCamera
        autoOrientation : true
        autoori
        */
    }
}


