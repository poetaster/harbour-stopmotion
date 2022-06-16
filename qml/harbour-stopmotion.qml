import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "pages"

// Icon
//<a href="https://www.flaticon.com/free-icons/timelapse" title="timelapse icons">Timelapse icons created by Freepik - Flaticon</a>

ApplicationWindow
{
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

    //        anchors.rightMargin: 20
    VideoOutput {
        id:videoOutput
        anchors.fill: parent
        z : -1
//        source:  shootScr.oCamera
        //            autoOrientation : true
        //            autoori
        //            focus : visible // to receive focus and capture key events when visible
    }
}


