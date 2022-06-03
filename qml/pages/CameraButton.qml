import QtQuick 2.2
import QtQuick.LocalStorage 2.0
import Sailfish.Pickers 1.0 // File-Loader
import Sailfish.Silica 1.0

IconButton {
    id: recordButton
    icon.source: Qt.resolvedUrl("../img/play-button.png")
    width: 50
    height: 50
    anchors {
        bottom: parent.bottom
        margins: 10
        //padding: 30
        //horizontalCenter: parent.horizontalCenter
    }

    visible: !pStopmotion.busyEncoding

    onClicked: {
        if (mA.state==="Ready"){
            camera.searchAndLock();
            pStopmotion.start()
            mA.state = "Recording";
        } else {
            pStopmotion.stop();
            camera.unlock();
            mA.state= "Ready";
            // reset counter
            counter = 0;
            // inc series
            seriesCounter ++;
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
