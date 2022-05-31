import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Stopmotion")
    }
    CoverPlaceholder {
        icon.source: "image://theme/icon-m-camera"
        text: "Timelapse"
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


