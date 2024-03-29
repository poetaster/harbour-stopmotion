import QtQuick 2.2
import Sailfish.Silica 1.0

MouseArea {
    id: popup
    anchors.top: parent.top
    anchors.topMargin: 0
    width: parent.width
    height: message.paintedHeight + (Theme.paddingLarge * 2)
    property alias title: message.text
    property alias timeout: hideTimer.interval
    property alias background: bg.color
    visible: opacity > 0
    opacity: 0.0
    z: 10

    Behavior on opacity {
        FadeAnimation {}
    }

    Rectangle {
        id: bg
        anchors.fill: parent
    }

    Timer {
        id: hideTimer
        triggeredOnStart: false
        repeat: false
        interval: 5000
        onTriggered: popup.hide()
    }

    function hide() {
        if (hideTimer.running)
            hideTimer.stop()
        popup.opacity = 0.0
    }

    function show() {
        popup.opacity = 1.0
        hideTimer.restart()
    }

    function notify(text, color, intervall, upperMargin) {
        popup.title = text
        if (color && (typeof(color) != "undefined"))
            bg.color = color
        else
            bg.color = Theme.rgba(Theme.secondaryHighlightColor, 0.9)
        if (intervall && (typeof(intervall) != "undefined"))
            hideTimer.interval = intervall
        else
            hideTimer.interval = 5000

        if (upperMargin && (typeof(upperMargin) != "undefined"))
            popup.anchors.topMargin = upperMargin
        else
            popup.anchors.topMargin = 0

        show()
    }

    Label {
        id: message
        anchors.verticalCenter: popup.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        wrapMode: Text.Wrap
    }

    onClicked: hide()
}

