import QtQuick 2.5
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Nemo.Thumbnailer 1.0

import "../components"
import "../utils/localdb.js" as Database
//import "../utils/constants.js" as Constants

Page
{
    id: slideshowDialog

    QtObject {
        id:slides
        property real cDOCK_PANEL_SIZE: 800
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    //property alias oCamera

    property var iniFolder
    property bool editMode: false
    property int slideshowId: -1

    property string slideshowName: ""
    property int imageWidth: Math.floor(slideshowDialog.width / 5)
    property var slideshow

    property var playSlideshowPage

    // NOTE: used to translate context menu items.
    property bool translationToggle: false

    property Item remorse

    property bool debug: false

    // python / export specific vars

    property string tempMediaFolderPath: StandardPaths.home + '/.cache/de.poetaster/stopmotion'
    property string tempMediaType : "mkv"
    property string ffmpeg_staticPath : "/usr/bin/ffmpeg"
    property string outputPathPy
    property string homeDirectory: StandardPaths.home
    //property string inputPathPy : decodeURIComponent( "/" + idMediaPlayer.source.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") )
    //property string saveMediaFolderPath : StandardPaths.home + '/Videos'
    property bool finishedLoading: true
    property int processedPercent: 0
    property int undoNr: 0
    property string portrait: "1080"
    property int saveFps:5
    property int fpsMode: 0
    property int loop: 1

    onStatusChanged: {
        if(status === PageStatus.Activating)
        {
            // Connection to Video display from window page
            cameraState.slidesShow(true)

        } else if(status === PageStatus.Deactivating) // Deactivating, set defaults.
        {
        }
    }

    Component.onDestruction: {
        // Connection to Video display from window page
        cameraState.slidesShow(false)
    }

    Component.onCompleted: {
        /*      if (editMode && slideshowId > 0) {
            var show = DB.getSlideshow(slideshowId)
            if (show) {
                backgroundMusicModel.clear()
                imageListModel.clear()

                slideshowNameField.text = show.name

                for (var mi = 0; mi < show.music.length; ++mi) {
                    var mus = show.music[mi]
                    backgroundMusicModel.append({'fileName': mus.fileName, 'url': mus.url})
                }

                for (var ii = 0; ii < show.images.length; ++ii) {
                    var img = show.images[ii]
                    imageListModel.append({'fileName': img.fileName, 'url': img.url})
                }
            }

            slideshowNameField.focus = false
        }
    */
    }

    /*    onDone: {
        if (result == DialogResult.Accepted) {
            slideshowName = slideshowNameField.text
            var show = {'id': editMode ? slideshowId : -1, 'name': slideshowName, 'music': [], 'images': []}

            for (var mi = 0; mi < backgroundMusicModel.count; ++mi) {
                var mf = backgroundMusicModel.get(mi)
                var music = {'fileName': mf.fileName, 'url': mf.url, 'slideshowId': editMode ? slideshowId : -1}
                show.music.push(music)
            }

            for (var ii = 0; ii < imageListModel.count; ++ii) {
                var img = imageListModel.get(ii)
                var image = {'fileName': img.fileName, 'url': img.url, 'slideshowId': editMode ? slideshowId : -1}
                show.images.push(image)
            }

            slideshow = show
        }
    }
    canAccept: slideshowNameField.text.trim().length > 0

*/

    /*
    ListModel {
        id: backgroundMusicModel
    }
*/


    ListModel {
        id: imageListModel
    }

    SilicaFlickable {
        id: listView
        anchors.fill: parent

        PullDownMenu {
            /*            MenuItem {
                id: menuSettings
                text: qsTrId("menu-settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }

            MenuItem {
                id: menuMusic
                text: qsTrId("menu-add-music")
                onClicked: pageStack.push(multiMusicPickerDialog)
            }

            MenuItem {
                id: menuFolderPictures
                text: qsTrId("menu-add-files-folder")
                onClicked: pageStack.push(folderPickerDialog)
            }

            MenuItem {
                id: menuFilesystemPictures
                text: qsTrId("menu-add-files-filesystem")
                onClicked: pageStack.push(filesystemImagePickerDialog)
            }
*/
            MenuItem {
                id: aboutPage
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
            MenuItem {
                id: menuPictures
                text: qsTr("Add files")
                onClicked: pageStack.push(multiImagePickerDialog)
            }

        }

        PushUpMenu {
            MenuItem {
                id: menuStartSlideshow
                text: qsTr("Start slideshow")
                enabled: imageListModel.count > 0
                onClicked: {
                    if (debug) console.log("Start slideshow...")
                    //playSlideshowPage = pageStack.push(Qt.resolvedUrl("PlaySlideshowPage.qml"), {'imageModel': imageListModel, 'musicModel': backgroundMusicModel, 'slideshowOrderArray': getSlideshowOrder()})
                    playSlideshowPage = pageStack.push(Qt.resolvedUrl("PlaySlideshowPage.qml"), {'imageModel': imageListModel, 'fpsMode':fpsMode,  'slideshowOrderArray': getSlideshowOrder(), 'loop':loop})
                    mainWinConnections.target = playSlideshowPage
                }
            }
            MenuItem {
                id: menuCanvasStartSlideshow
                text: qsTr("Start canvas slideshow")
                enabled: imageListModel.count > 0
                onClicked: {
                    if (debug) console.log("Start slideshow...")
                    pageStack.push(Qt.resolvedUrl("CanvasSlideshowPage.qml"), {'imageModel': imageListModel, 'fpsMode':fpsMode,  'slideshowOrderArray': getSlideshowOrder(), 'loop':loop})
                }
            }
            /*
            MenuItem {
                id: menuSlideviewStartSlideshow
                text: qsTr("Start sView slideshow")
                enabled: imageListModel.count > 0
                onClicked: {
                    if (debug) console.log("Start slideshow...")
                    pageStack.push(Qt.resolvedUrl("SlideshowViewPage.qml"), {'imageModel': imageListModel, 'fpsMode':fpsMode,  'slideshowOrderArray': getSlideshowOrder(), 'loop':loop})
                }
            }
            */

        }

        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {id: header}

            TextField {
                id: slideshowNameField
                focus: false
                label: qsTr("Slideshow filename")
                placeholderText: qsTr("File to save")
                text: slideshowName
                Keys.onEnterPressed: {
                    focus = false
                }
                Keys.onReturnPressed: {
                    focus = false
                    py.createFilmstripFunction(text,imageListModel,saveFps,fpsMode)
                }
                width: parent.width - Theme.paddingMedium
            }
            Slider {
                id: sFps
                label: "FPS/SPF"
                width: parent.width - Theme.paddingLarge
                minimumValue: 1
                maximumValue: 30
                value: 5
                stepSize: 1
                valueText: sliderValue
                onReleased: {
                    Database.setProp('saveFps',String(sliderValue))
                    saveFps = sFps.sliderValue
                }
                Component.onCompleted: {
                    value = Database.getProp('saveFps')
                    saveFps = value
                }
            }
            Row {
                width: parent.width
                ComboBox {
                    id:fpsModeSelector
                    width: parent.width * .66
                    menu: ContextMenu {
                        MenuItem { text: "Frames per second" ;
                            onClicked: fpsMode = "fps" }
                        MenuItem { text: "Seconds per frame" ;
                            onClicked: fpsMode = "spf" }

                    }
                    onCurrentIndexChanged: {
                        console.log(currentIndex)
                        Database.setProp('fpsMode',String(currentIndex))
                    }
                    Component.onCompleted: {
                        fpsMode = Database.getProp('fpsMode')
                        fpsModeSelector.currentIndex = fpsMode
                    }
                }

                 ComboBox{
                    id: loopSwitch
                    width: parent.width * .33
                    menu: ContextMenu {
                        MenuItem { text: "Loop off" ;
                            onClicked: loop = 0 }
                        MenuItem { text: "Loop on" ;
                            onClicked: loop = 1 }

                    }
                    onCurrentIndexChanged: {
                        console.log(currentIndex)
                        Database.setProp('loop',String(currentIndex))
                    }
                    Component.onCompleted: {
                        loop = Database.getProp('loop')
                        loopSwitch.currentIndex = loop
                    }
                }
            }

            /*
            CollapsingHeader {
                id: slideshowBackgroundMusicCollapsingHeader
                text: qsTrId("slideshow-background-music") + "(" + backgroundMusicModel.count + ")"
                collapsingItem: musicList
                collapsingItemMaxHeight: musicList.contentHeight
                interactive: backgroundMusicModel.count > 0
                menuItems: [clearMusic]
                MenuItem {
                    id: clearMusic
                    text: qsTrId("menu-clear")
                    onClicked: {
                        console.log("Clearing music...");
                        slideshowDialog.remorse = Remorse.popupAction(slideshowDialog, qsTrId("action-clearing-music"), function() {backgroundMusicModel.clear()})
                    }
                }
            }
*/
            /*
            SilicaListView {
                id: musicList
                width: parent.width
                height: contentHeight
                model: backgroundMusicModel
                clip: true

                Behavior on height { SmoothedAnimation { duration: 300 } }

                delegate: ListItem {
                    id: musicDelegate
                    width: parent.width
                    contentHeight: Theme.itemSizeExtraSmall

                    Label {
                        text: model.fileName
                        font.pixelSize: Theme.fontSizeSmall
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingMedium
                    }

                    menu: ContextMenu {
                        MenuItem {
                            property bool translationToggle: page.translationToggle

                            text: qsTrId("slideshow-menu-remove")
                            onClicked: {
                                console.log("Remove music from the slideshow...")
                                console.log("Music index:", index)
                                backgroundMusicModel.remove(index)
                            }

                            onTranslationToggleChanged: {
                                text = qsTrId("slideshow-menu-remove")
                            }
                        }
                    }
                }
            }
*/

            CollapsingHeader {
                id: slideshowImagesCollapsingHeader
                text: qsTrId("slideshow-images") + "(" + imageListModel.count + ")"
                collapsingItem: imageGrid
                collapsingItemMaxHeight: imageGrid.contentHeight
                interactive: imageListModel.count > 0
                menuItems: [clearImages]

                MenuItem {
                    id: clearImages
                    text: qsTrId("menu-clear")
                    onClicked: {
                        console.log("Clearing images...")
                        slideshowDialog.remorse = Remorse.popupAction(slideshowDialog, qsTrId("action-clearing-images"), function() {imageListModel.clear()})
                    }
                }
            }

            SilicaGridView
            {
                id: imageGrid

                property Item expandedItem

                width: parent.width
                height: contentHeight
                model: imageListModel
                clip: true
                cellWidth: slideshowDialog.imageWidth
                cellHeight: slideshowDialog.imageWidth

                Behavior on height { SmoothedAnimation { duration: 300 } }

                delegate: Item {
                    id: dummy
                    width: slideshowDialog.imageWidth
                    height: thumbnail.isExpanded ? thumbnail.height + gridContextMenu.height : thumbnail.height
                    z: thumbnail.isExpanded ? 1000 : 1

                    Thumbnail {
                        id: thumbnail

                        property bool isExpanded: imageGrid.expandedItem == thumbnail

                        anchors {
                            left: parent.left
                            top: parent.top
                        }

                        source: url
                        width: slideshowDialog.imageWidth
                        height: slideshowDialog.imageWidth
                        sourceSize.width: width
                        sourceSize.height: height
                        onStatusChanged: {
                            infoLoad.source = url
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressAndHold: {
                                imageGrid.expandedItem = thumbnail
                                gridContextMenu.index = index
                                gridContextMenu.open(dummy)
                            }
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("ImagePage.qml"), {'imageUrl': url})
                            }
                        }
                    }
                }
                /* we need this to obtain the orientation to pass to ffmpeg */
                Image {
                    id: infoLoad
                    visible: false
                    asynchronous: true
                    autoTransform: true
                    fillMode: Image.PreserveAspectFit
                    onStatusChanged: {
                        if (status == Image.Ready) {
                           if (debug) console.log('Loaded: sourceSize ==', sourceSize);
                           if (debug) console.log('Loaded: Height ==', height);
                           if (debug) console.log('Loaded: implicitHeight ==', implicitHeight);
                            if (height === 1920)  portrait = "1920"
                        }
                    }
                }

                ContextMenu {
                    id: gridContextMenu

                    property int index: -1

                    MenuItem {
                        text: qsTr("Remove image")
                        onClicked: {
                            if (debug) console.log("Remove image from the slideshow...")
                            if (debug) console.log("Image index:", gridContextMenu.index)
                            imageListModel.remove(gridContextMenu.index)
                            gridContextMenu.index = -1
                        }

                    }
                }
            }
        }
    }
    Rectangle
    {
        id: progressDisplay
        visible: (finishedLoading === false)
        anchors.right: parent.right
        height: 20
        width: parent.width / 100 * (100 - processedPercent)
        color: Theme.rgba(Theme.highlightDimmerColor, 0.5)
    }
    /*
    Component {
        id: multiMusicPickerDialog
        MultiMusicPickerDialog {
            onAccepted: {
                var urls = []
                var index = 0;
                for (var i = 0; i < selectedContent.count; ++i) {
                    var url = selectedContent.get(i).url
                    var fileName = selectedContent.get(i).fileName
                    // Handle selection
                    backgroundMusicModel.append({'fileName': fileName, 'url': url})
                }
            }
        }
    }
*/
    // File pickers
    Component
    {
        id: multiImagePickerDialog
        MultiImagePickerDialog {
            onAccepted: {
                var urls = []
                var index = 0;
                for (var i = 0; i < selectedContent.count; ++i) {
                    var url = selectedContent.get(i).url
                    //if (debug) console.log(url)
                    var fileName = selectedContent.get(i).fileName
                    // Handle selection
                    imageListModel.append({'fileName': fileName, 'url': url})
                }
            }
        }
    }

    Component
    {
        id: filesystemImagePickerDialog
        MultiFilePickerDialog {
            nameFilters: imageFileFilters
            onAccepted: {
                if (debug) console.log("File system image picker accepted...")
                var urls = []
                for (var i = 0; i < selectedContent.count; ++i) {
                    var url = selectedContent.get(i).url
                    var fileName = selectedContent.get(i).fileName
                    // Handle selection
                    imageListModel.append({'fileName': fileName, 'url': url})
                }
            }
        }
    }
    /*
    Component {
        id: folderPickerDialog
        FolderPickerDialog {
            id: imageFolderDialog
            path: Settings.getBooleanSetting(Constants.selectFolderFromRootKey, false) ? "/" : StandardPaths.home
            title: qsTrId("Select Folder")
            onAccepted: {
                console.log("Add pictures from the selected folder:", selectedPath)
                folderLoader.readFilesInFolder(selectedPath)
            }
        }
    }
*/

    function getSlideshowOrder() {
        var count = imageListModel.count
        var arr = Array(count)
        for (var j = 0; j < arr.length; ++j) {
          arr[j] = j
        }
        return arr
    }


    // *********************************************** useful functions *********************************************** //

    function openWithPath() {
        // only apply if app is opened with file
        if (openingArguments.length === 2) {
            idMediaPlayer.stop()
            origMediaFilePath = (openingArguments[1])
            var origMediaPathArray = (origMediaFilePath.toString()).split("/")
            origMediaFileName = (origMediaPathArray[origMediaPathArray.length - 1])
            origMediaFolderPath = (origMediaFilePath.replace(origMediaFileName, ""))
            var origMediaFileNameArray = origMediaFileName.split(".")
            origMediaName = (origMediaFileNameArray.slice(0, origMediaFileNameArray.length-1)).join(".")
            origMediaType = origMediaFileNameArray[origMediaFileNameArray.length - 1]
            idMediaPlayer.source = ""
            idMediaPlayer.source = encodeURI(origMediaFilePath)
            py.deleteAllTMPFunction()
            py.getVideoInfo( inputPathPy, "true" )
            undoNr = 0
            noFile = false
            //finishedLoading = false
        }
    }

    function checkThemechangeAdjustMarkerPadding() {
        // Patch: sliderwidth makes a different
        if ((Theme.primaryColor).toString() === "#ffffff" ) { // -> white font on dark themes, slider is wider as of SF 3.4
            addThemeSliderPaddingSides = 0
        }
        else { // "#000000" -> black font on light themes, slider is smaller as of SF 3.4
            addThemeSliderPaddingSides = Theme.paddingMedium
        }
    }

    function preparePathAndUndo() {
        idMediaPlayer.stop()
        finishedLoading = false
        undoNr = undoNr + 1
        outputPathPy = tempMediaFolderPath + "video" + ".tmp" + undoNr + "." + tempMediaType
        console.debug("pyPath: "+ outputPathPy)
    }

    function undoBackwards() {
        idMediaPlayer.stop()
        finishedLoading = false
        brandNewFile = false // Patch: size warning banner will not show again when going backwards to original image
        undoNr = undoNr - 1
        lastTmpMedia2delete = decodeURIComponent( "/" + idMediaPlayer.source.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") )
        if (undoNr <= 0) {
            undoNr = 0
            idMediaPlayer.source = encodeURI(origMediaFilePath)
        }
        else {
            idMediaPlayer.source = idMediaPlayer.source.toString().replace(".tmp"+(undoNr+1), ".tmp"+(undoNr))
        }
        py.deleteLastTMPFunction()
        py.getVideoInfo(decodeURIComponent( "/" + idMediaPlayer.source.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") ), "false" )
    }
}
