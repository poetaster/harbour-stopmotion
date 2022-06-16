import QtQuick 2.5
import Sailfish.Silica 1.0

Item {
    id: collapsingHeader

    width: parent.width
    height: Theme.itemSizeSmall

    Behavior on height {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    property string text: ""
    property Item collapsingItem: null
    property real collapsingItemMaxHeight: 0
    property bool interactive: false
    property variant menuItems
    property real contextMenuHeight: 0

    Component.onCompleted: {
        var sum = 0;
        var count = menuItems.length
        if (menuItems && count > 0) {
            for (var i = 0; i < count; ++i) {
                var menuItem = menuItems[i]
                menuItem.parent = headerMenu._contentColumn
                sum += menuItem.height
            }
        }
        contextMenuHeight = sum
    }

    RemorseItem { id: headerRemorse }

    Row {
        spacing: Theme.paddingMedium
        layoutDirection: Qt.RightToLeft
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }

        Image {
            id: imagesHeaderDown
            source: "image://theme/icon-s-down"
            height: Theme.iconSizeSmallPlus
            width: height
            rotation: collapsingItem.height != 0 ? 180 : 0
            anchors {
                top: parent.top
                topMargin: Theme.paddingMedium - 5
            }

            Behavior on rotation {
                NumberAnimation {duration: 300; easing.type: Easing.InOutQuad }
            }
        }

        Label {
            height: Theme.itemSizeSmall
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            color: palette.highlightColor
            text: collapsingHeader.text
            anchors {
                top: parent.top
                topMargin: Theme.paddingMedium
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: interactive

        onClicked: {
            console.log("CollapsingHeader clicked...")
            if (collapsingItem.height == 0) {
                collapsingItem.height = collapsingItemMaxHeight
            } else if (collapsingItem.height === collapsingItemMaxHeight) {
                collapsingItem.height = 0
            }
        }

        onPressAndHold: {
            collapsingHeader.height += contextMenuHeight
            headerMenu.open(collapsingHeader)
        }
    }

    ContextMenu {
        id: headerMenu
        onActiveChanged: {
            console.log("Context menu active changed...")
            if (!active) {
                collapsingHeader.height = Theme.itemSizeSmall
            }
        }

        onActivated: {
            console.log("Context menu activating item...")
            collapsingHeader.height = Theme.itemSizeSmall
        }
    }

    function executeRemorse(description, action) {
        headerRemorse.execute(collapsingHeader, description, action)
    }
}
