import QtQuick 2.5
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "components"
import "pages"

// Icon
//<a href="https://www.flaticon.com/free-icons/timelapse" title="timelapse icons">Timelapse icons created by Freepik - Flaticon</a>

ApplicationWindow
{
    property bool debug:false

    Banner {
        id: banner
    }
    initialPage: Component
    {
        id : sscr
        ShootScreen
        {
            id:shootScr
            Component.onCompleted:
            {
                videoOutput.source=oCamera;
            }
        }
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All

    // not using yet, but might add
    Connections
    {
        id: mainWinConnections
        target: null
        ignoreUnknownSignals: true
        onImageChanged:
        {
            if (debug) console.log("Image changed, current image:", url)
            //coverPage.setImage(url)
        }
        onSlideshowRunningToggled:
        {
            if (debug) console.log("Slideshow running:", runningStatus)
            //coverPage.toggleSlideshowRunning(runningStatus)
        }
    }

    PythonHandler {
      id: py
    }


    QtObject
    {
        id: cameraState
        signal slidesShow(bool slideshowRunning)
    }

    Connections
    {
        target: cameraState
        onSlidesShow:
        {
            if (debug) console.log("cameraState:", slideshowRunning)
            videoOutput.visible = !slideshowRunning
        }
    }
    VideoOutput
    {
        id:videoOutput
        anchors.fill: parent
        z : -1
        focus : visible // to receive focus and capture key events when visible
        visible: true
    }
}


