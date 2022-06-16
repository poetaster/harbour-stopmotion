import QtQuick 2.5
import Sailfish.Silica 1.0
//import "../constants.js" as Constants

Page {
    id: imagePage
    allowedOrientations: Orientation.All

    // Properties.
    property string imageUrl: ""
    property real scaleFactor: 1.0
    property real zoomLevel: 2
    property bool hiresImages: true//Settings.getBooleanSetting(Constants.hiresImagesKey, true)

    SilicaFlickable {
        id: viewerFlick
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: pageImage.height
        contentWidth: pageImage.width

        Item {
            id: placeholder
            height: pageImage.height > imagePage.height ? pageImage.height : imagePage.height
            width: pageImage.width > imagePage.width ? pageImage.width : imagePage.width

            Image {
                id: pageImage
                source: imageUrl
                anchors.centerIn: parent
                cache: false
                autoTransform: true
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                width: imagePage.width * scaleFactor
                height: width / (sourceSize.width / sourceSize.height)
                sourceSize {
                    width: hiresImages ? undefined : imagePage.width
                    height: hiresImages ? undefined : imagePage.height
                }

                Behavior on width {
                    id: zoomBehavior
                    enabled: false
                    NumberAnimation {duration: 300; easing.type: Easing.InOutQuad }
                }
            }

            PinchArea {
                anchors.fill: parent
                pinch.target: pageImage
                onPinchUpdated: {
                    var delta = pinch.scale - pinch.previousScale
                    imagePage.scaleFactor += delta

                    if (imagePage.scaleFactor < 1) {
                        imagePage.scaleFactor = 1
                    } else if (imagePage.scaleFactor > 5) {
                        imagePage.scaleFactor = 5
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        zoomBehavior.enabled = true
                        if (imagePage.scaleFactor == 1.0) {
                            imagePage.scaleFactor = imagePage.zoomLevel
                        } else {
                            imagePage.scaleFactor = 1.0
                        }
                        zoomBehavior.enabled = false
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: busyInd
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: pageImage.status == Image.Loading
    }

    Label {
        id: infoLabel
        anchors.centerIn: parent
        width: parent.width - Theme.horizontalPageMargin*2
        wrapMode: Text.WordWrap
        text: qsTrId("image-info-error") + " " + imageUrl
        visible: pageImage.status == Image.Error
    }
}
