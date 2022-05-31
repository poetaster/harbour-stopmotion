import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import "pages"

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

    Connections {
        target: UILink
        onRequestedReplacePage:{
            pageStack.clear();
            pageStack.replace(Qt.resolvedUrl(page));
        }
    }


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


