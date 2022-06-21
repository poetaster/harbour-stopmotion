import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    objectName: "AboutPage"

    allowedOrientations: Orientation.All

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium

        PageHeader {
            title: qsTr("About Stopmotion")
        }

        Item {
            width: 1
            height: 3 * Theme.paddingLarge
        }

        Image {
            width: parent.width / 5
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../cover/harbour-stopmotion.png"
            smooth: true
            asynchronous: true
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.primaryColor
            text: qsTr("A Stopmotion Animation app.")
        }

        Item {
            width: 1
            height: Theme.paddingLarge
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.secondaryColor
            text: qsTr(" © 2022 Mark Washeim \n" ) +
                  qsTr("some parts inspired by Joni Korhonen: \n ") +
                  qsTr("https://github.com/pinniini/harbour-slideshow")
        }

        Item {
            width: 1
            height: 2 * Theme.paddingLarge
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Stopmotion is licensed under the terms of ") + "\n"
                  + qsTr("the GNU General Public License v3.")
        }

        Item {
            width: 1
            height: 2 * Theme.paddingLarge
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: Theme.paddingSmall
            color: Theme.secondaryColor
            textFormat: Text.StyledText
            linkColor: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: "<a href=\"https://github.com/poetaster/harbour-stopmotion\">Source: github</a>"
            /*text: "<style>a:link{color: " + Theme.highlightColor + ";}</style>" +  "<a href=\"https://github.com/poetaster/harbour-stopmotion\">Source: github</a>" */
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
        /*
        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("View license")
            onClicked: {
                pageStack.push(Qt.resolvedUrl("LicensePage.qml"));
            }
        }*/

    }
}
