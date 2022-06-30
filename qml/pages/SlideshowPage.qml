import QtQuick 2.5
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Nemo.Thumbnailer 1.0

import "../components"
import "../utils/localdb.js" as Database
import "../utils/constants.js" as Constants
import io.thp.pyotherside 1.5

Page {
    id: slideshowDialog

    QtObject
    {
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

    property bool debug: true

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

    Banner {
        id: banner
    }

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
                    py.createFilmstripFunction()
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

                 ComboBox
                 {
                    id: loopSwitch
                    width: parent.width * .33
                    menu: ContextMenu
                    {
                        MenuItem { text: "Loop off" ;
                            onClicked: loop = 0 }
                        MenuItem { text: "Loop on" ;
                            onClicked: loop = 1 }

                    }
                    onCurrentIndexChanged:
                    {
                        console.log(currentIndex)
                        Database.setProp('loop',String(currentIndex))
                    }
                    Component.onCompleted:
                    {
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

            CollapsingHeader
            {
                id: slideshowImagesCollapsingHeader
                text: qsTrId("slideshow-images") + "(" + imageListModel.count + ")"
                collapsingItem: imageGrid
                collapsingItemMaxHeight: imageGrid.contentHeight
                interactive: imageListModel.count > 0
                menuItems: [clearImages]

                MenuItem
                {
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

                delegate: Item
                {
                    id: dummy
                    width: slideshowDialog.imageWidth
                    height: thumbnail.isExpanded ? thumbnail.height + gridContextMenu.height : thumbnail.height
                    z: thumbnail.isExpanded ? 1000 : 1

                    Thumbnail
                    {
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

                        MouseArea
                        {
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
                Image
                {
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

                ContextMenu
                {
                    id: gridContextMenu

                    property int index: -1

                    MenuItem
                    {
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
    Component
    {
        id: multiImagePickerDialog
        MultiImagePickerDialog
        {
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
        MultiFilePickerDialog
        {
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
    /*
    function translateUi() {
        menuSettings.text = qsTrId("menu-settings")
        menuMusic.text = qsTrId("menu-add-music")
        menuFolderPictures.text = qsTrId("quick-folderpicker-title")
        menuFilesystemPictures.text = qsTrId("menu-add-files-filesystem")
        menuPictures.text = qsTrId("menu-add-files")
        menuStartSlideshow.text = qsTrId("menu-start-slideshow")
        slideshowNameField.label = qsTrId("slideshow-name-label")
        slideshowNameField.placeholderText = qsTrId("slideshow-name-placeholder")

        // Use Qt.binding to maintain translation binding with item count changes.
        slideshowImagesCollapsingHeader.text = Qt.binding(function() {return qsTrId("slideshow-images") + "(" + imageListModel.count + ")"})
        clearImages.text = qsTrId("menu-clear")

        // Use Qt.binding to maintain translation binding with item count changes.
        slideshowBackgroundMusicCollapsingHeader.text = Qt.binding(function() {return qsTrId("slideshow-background-music") + "(" + backgroundMusicModel.count + ")"})
        clearMusic.text = qsTrId("menu-clear")
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


    // These are ALL the functions from clipper (Videoworks).
    Python {
        id: py
        Component.onCompleted:
        {
            addImportPath(Qt.resolvedUrl('../py'));
            importModule('videox', function () {});

            // Handlers do something to QML with received infos from Pythonfile (=pyotherside.send)
            setHandler('homePathFolder', function( homeDir ) {
                tempMediaFolderPath = homeDir + "/.cache/de.poetaster/stopmotion/"
                //tempMediaFolderPath =  StandardPaths.temporary
                saveMediaFolderPath =  homeDir + "/Videos"
                homeDirectory = homeDir
                py.createTmpAndSaveFolder()
                py.deleteAllTMPFunction()
            });
            setHandler('loadTempMedia', function( newFilePath ) {
                idMediaPlayer.source = ""
                idMediaPlayer.source = encodeURI( newFilePath )
                py.getVideoInfo( newFilePath, "false" )
                brandNewFile = false
            });
            setHandler('extractedAudio', function( targetPath ) {
                finishedLoading = true
                banner.notify( qsTr("Audio extracted to") + "\n" + " " + targetPath + " ", Theme.highlightDimmerColor, 10000 )
            });
            setHandler('finishedSavingRenaming', function( newFilePath, newFileName, newFileType ) {
                idMediaPlayer.source = ""
                idMediaPlayer.source = newFilePath
                origMediaFilePath = newFilePath
                origMediaFileName = newFileName + "." + newFileType
                origMediaFolderPath = origMediaFilePath.replace(origMediaFileName, "")
                var origMediaFileNameArray = origMediaFileName.split(".")
                origMediaName = (origMediaFileNameArray.slice(0, origMediaFileNameArray.length-1)).join(".")
                origMediaType = origMediaFileNameArray[origMediaFileNameArray.length - 1]
                py.getVideoInfo( inputPathPy, "true" )
                undoNr = 0
                noFile = false
                idTimerDelaySetCropmarkers.start()
            });
            setHandler('deletedFile', function() {
                origMediaFilePath = ""
                origMediaFileName = ""
                origMediaFolderPath = ""
                origMediaName = ""
                origMediaType = "none"
                origVideoWidth = 0
                origVideoHeight = 0
                origCodecVideo = "none"
                origCodecAudio = "none"
                origFrameRate = 0
                origFileSize = 0
                idMediaPlayer.source = ""
                undoNr = 0
                noFile = true
            });
            setHandler('deletedLastTmp', function() {
                finishedLoading = true
            });
            setHandler('sourceVideoInfo', function( videoResolution, videoCodec, audioCodec, frameRate, pixelFormat, audioSamplerate, audioLayout, isOriginal, estimatedSize, videoRotation, playbackDuration, sampleAspectRatio, displayAspectRatio ) {
                videoResolution = videoResolution.toString()
                var videoResolutionArray= videoResolution.split("x")
                sourceVideoWidth = parseInt(videoResolutionArray[0])
                sourceVideoHeight = parseInt(videoResolutionArray[1])
                sourceSampleAspectRatio = sampleAspectRatio.toString()
                sourceDisplayAspectRatio = displayAspectRatio.toString()
                origVideoRotation = parseInt(videoRotation)
                if (origVideoRotation !== 90 && origVideoRotation !== -90 ) { origVideoRotation = 0 } // Patch: if no EXIF tag = 0
                if (isOriginal === "true") {
                    origFileSize =  ( parseInt(estimatedSize) / 1024 / 1024 ).toFixed(2)
                    origVideoWidth = sourceVideoWidth
                    origVideoHeight = sourceVideoHeight
                    origCodecVideo = videoCodec.toString()
                    origFrameRate = frameRate.toString()
                    origPixelFormat = pixelFormat.toString()
                    origCodecAudio = audioCodec.toString()
                    origSAR = sourceSampleAspectRatio
                    origDAR = sourceDisplayAspectRatio
                    if (origCodecAudio === "vorbis") { origCodecAudio = "libvorbis" } // Patch: vorbis is experimental, use libvorbis instead
                    origAudioLayout = audioLayout.toString()
                    origAudioSamplerate = audioSamplerate.toString()
                    origVideoDuration = new Date( (parseFloat(playbackDuration)*1000) ).toISOString().substr(11,8)
                    if ( (origVideoWidth >= warningLargeSize || origVideoHeight >= warningLargeSize) && brandNewFile === true ) {
                        banner.notify( qsTr("This seems to be a large file.") + "\n" + qsTr("For speed convenience you may scale it down first." ), Theme.highlightDimmerColor, 5000 )
                    }
                }
                tmpVideoFileSize =  ( parseInt(estimatedSize) / 1024 / 1024 ).toFixed(2)
            });
            setHandler('overlayVideoInfo', function( videoResolution ) {
                videoResolution = videoResolution.toString()
                var videoResolutionArray= videoResolution.split("x")
                previewVideoWidth = parseInt(videoResolutionArray[0])
                previewVideoHeight = parseInt(videoResolutionArray[1])
                croppingRatio = previewRatioFileVideo
                setCropmarkersRatio()
                idPreviewOverlayImage.source = ""
                idPreviewOverlayImage.source = overlayThumbnailPath
            });
            setHandler('errorOccured', function( messageWarning ) {
                finishedLoading = true
                undoNr = undoNr - 1
                banner.notify( qsTr("ERROR!") + "\n" + messageWarning, Theme.errorColor, 10000 )
            });
            setHandler('clearOverlayFilename', function() {
                clearOverlayFunction()
            });

            setHandler('progressPercentage', function( percentDone ) {
                processedPercent = percentDone
            });
            setHandler('previewImageCreated', function() {
                idThumbnailOverlay.source = ""
                idThumbnailOverlay.source = thumbnailPath
                thumbnailVisible = true // show thumbnail preview
            });
            setHandler('switchToAlphaFullScreen', function() {
                idComboBoxImageOverlayAlphaStretch.currentIndex = 0
            });

            setHandler('exportClipCreated', function( newFilePath ) {
                py.deleteAllTMPFunction(tempMediaFolderPath)
                finishedLoading = true
                banner.notify( qsTr("Exported to") + "\n" + " " + newFilePath + " ", Theme.highlightDimmerColor, 10000 )
            });


            setHandler('newClipCreated', function( newFilePath, newFileName ) {
                idMediaPlayer.stop()
                brandNewFile = true
                origMediaFilePath = newFilePath.toString()
                origMediaFileName = newFileName.toString()
                origMediaFolderPath = origMediaFilePath.replace(origMediaFileName.fileName, "")
                var origMediaFileNameArray = origMediaFileName.split(".")
                origMediaName = (origMediaFileNameArray.slice(0, origMediaFileNameArray.length-1)).join(".")
                origMediaType = origMediaFileNameArray[origMediaFileNameArray.length - 1]
                idMediaPlayer.source = ""
                idMediaPlayer.source = encodeURI( newFilePath )
                py.deleteAllTMPFunction()
                py.getVideoInfo( newFilePath, "true" )
                undoNr = 0
                noFile = false
                brandNewFile = true
                finishedLoading = true
                subtitleModel.clear()
            });
            setHandler('playbackDurationParsed', function( playbackDuration, targetName ) {
                if ( targetName === "previewAudioFile" ) {
                    filePreviewDuration = parseFloat(playbackDuration) * 1000 // needs milliseconds
                }
                else if ( targetName === "addStorylineModel" ) {
                    storylineAddFileDuration = (parseFloat(playbackDuration)).toFixed(1) // needs seconds
                }
            });
            setHandler('subtitleFileParsed', function( subtitleText ) {
                //console.log(subtitleText)
            });
            setHandler('imagesExtracted', function() {
                finishedLoading = true
                banner.notify( qsTr("Extracted to") + "\n" + " " + origMediaFolderPath + " ", Theme.highlightDimmerColor, 10000 )
            });
        }



        // file operations
        function getHomePath() {
            call("videox.getHomePath", [])
        }
        function createTmpAndSaveFolder() {
            call("videox.createTmpAndSaveFolder", [ tempMediaFolderPath, saveMediaFolderPath ])
        }
        function deleteAllTMPFunction() {
            undoNr = 0
            call("videox.deleteAllTMPFunction", [ tempMediaFolderPath ])
        }
        function deleteLastTMPFunction() {
            call("videox.deleteLastTmpFunction", [ lastTmpMedia2delete ])
        }
        function deleteFile() {
            idMediaPlayer.stop()
            py.deleteAllTMPFunction()
            call("videox.deleteFile", [ origMediaFilePath ])
        }
        function renameOriginal() {
            idMediaPlayer.stop()
            py.deleteAllTMPFunction()
            var newFilePath = origMediaFolderPath + idToolsRowFileRenameText.text + "." + origMediaType
            var newFileName = idToolsRowFileRenameText.text
            var newFileType = origMediaType
            call("videox.renameOriginal", [ origMediaFilePath, newFilePath, newFileName, newFileType ])
        }
        function getVideoInfo( pathToFile, isOriginal ) {
            var thumbnailSec = "0.25"
            if (undoNr === 0) { isOriginal = "true" } // Patch for undo when back to first
            call("videox.getVideoInfo", [ pathToFile, isOriginal, thumbnailPath, thumbnailSec ])
        }
        function getOverlayVideoInfo( pathToFile ) {
            var overlayPath = "/" + pathToFile.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            call("videox.getOverlayVideoInfo", [ overlayPath, overlayThumbnailPath, "1" ])
        }
        function createPreviewImage() {
            var thumbnailSec = new Date(idMediaPlayer.position).toISOString().substr(11,12)
            call("videox.createPreviewImage", [ inputPathPy, thumbnailPath, thumbnailSec ])
        }
        function getPlaybackDuration( pathToFile, targetName ) {
            call("videox.getPlaybackDuration", [ pathToFile, targetName ])
        }


        // cut manipulations
        function trimFunction() {
            if (idComboBoxCutTrimWhere.currentIndex === 0) {var trimWhere = "inside" }
            else if (idComboBoxCutTrimWhere.currentIndex === 1) {trimWhere = "outside" }
            if (idComboBoxCutTrimHow.currentIndex === 0) { var trimType = "fast_copy_noKeyframe" }
            else if (idComboBoxCutTrimHow.currentIndex === 1) { trimType = "fast_copy_Keyframe" }
            else if (idComboBoxCutTrimHow.currentIndex === 2) { trimType = "slow_reencode_createKeyframe" }
            var encodeCodec = origCodecVideo // "ffv1"
            var encodeFramerate = origFrameRate.toString() // usually "25"
            var endTimestampPy = new Date(idMediaPlayer.duration).toISOString().substr(11,12)
            // if any marker is too close to start or end, just use the outmost positions
            if ( (fromPosMillisecond <= minTrimLength) && ( (idMediaPlayer.duration - toPosMillisecond) <= minTrimLength ) ) { var removeInsideCase = "remove_start_end" }
            if ( (fromPosMillisecond <= minTrimLength) && ( (idMediaPlayer.duration - toPosMillisecond) > minTrimLength ) ) { removeInsideCase = "remove_start_mid" }
            if ( (fromPosMillisecond > minTrimLength) && ( (idMediaPlayer.duration - toPosMillisecond) > minTrimLength ) ) { removeInsideCase = "remove_mid_mid" }
            if ( (fromPosMillisecond > minTrimLength) && ( (idMediaPlayer.duration - toPosMillisecond) <= minTrimLength ) ) { removeInsideCase = "remove_mid_end" }
            if ( ((fromPosMillisecond <= minTrimLength) && (toPosMillisecond <= minTrimLength )) || (( (idMediaPlayer.duration - fromPosMillisecond) <= minTrimLength) && ( (idMediaPlayer.duration - toPosMillisecond) <= minTrimLength )) ) {
                removeInsideCase = "remove_too_small" // if both markers are either at start or at end
            }

            if ( removeInsideCase === "remove_too_small" ) {
                banner.notify( qsTr("Both sliders are too close to the same end." + "\n" + "< " + minTrimLength + " ms" ), Theme.errorColor, 10000 )
            }
            else if ( removeInsideCase === "remove_start_end" ) {
                banner.notify( qsTr("Would you like to delete the track?" + "\n" + qsTr("Use 'delete' in file menu.") ), Theme.errorColor, 10000 )
            }
            else {
                preparePathAndUndo()
                var fromSec = ((fromPosMillisecond/1000)).toString()
                var toSec = ((toPosMillisecond/1000)).toString()
                call("videox.trimFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, tempMediaFolderPath, fromTimestampPy, toTimestampPy, fromSec, toSec, trimWhere, trimType, encodeCodec, encodeFramerate, removeInsideCase, endTimestampPy ])
            }
        }
        function speedFunction() {
            preparePathAndUndo()
            var speedVideoFactor = (1/(idToolsCutDetailsColumnCut3SpeedSlider.value)).toString()
            var speedAudioFactor = idToolsCutDetailsColumnCut3SpeedSlider.value.toString()
            call("videox.speedFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, speedVideoFactor, speedAudioFactor ])
        }
        function cropAreaFunction() {
            preparePathAndUndo()
            generateCroppingPixelsFromHandles()
            call("videox.cropAreaFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, cropX, cropY, cropWidth, cropHeight, scaleDisplayFactorCrop ])
        }
        function padAreaFunction() {
            if ( sourceVideoWidth / sourceVideoHeight > padRatio ) {
                var padWhere = "vertical"
                if (idComboBoxCutPadUpDown.currentIndex === 0) { // size+
                    var outWidth = sourceVideoWidth
                    var outHeight = Math.round( sourceVideoWidth / padRatio )
                }
                else { // size-
                    outHeight = sourceVideoHeight
                    outWidth = Math.round( sourceVideoHeight * padRatio )
                }
            }
            else {
                padWhere = "horizontal"
                if (idComboBoxCutPadUpDown.currentIndex === 0) { // size+
                    outHeight = sourceVideoHeight
                    outWidth = Math.round( sourceVideoHeight * padRatio )
                }
                else {
                    outWidth = sourceVideoWidth
                    outHeight = Math.round( sourceVideoWidth / padRatio )
                }
            }
            var padColor = "black"
            if ( outWidth > 1920 || outHeight > 1920) {
                banner.notify( qsTr("WARNING!") + "\n"
                              + qsTr("Large output resolution detected:") + " " + outWidth + "x" + outHeight + " px.\n"
                              + qsTr("Please reduce to max 1920x1920 pixels.")
                              , Theme.errorColor, 10000 )
            }
            else {
                preparePathAndUndo()
                call("videox.padAreaFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, padRatioText, padWhere, padColor, outWidth, outHeight ])
            }
        }
        function addTimeFunction() {
            var atTimestamp = new Date(idMediaPlayer.position).toISOString().substr(11,12)
            var addLength = (idToolsRowCutAddSlider.value).toString()
            var origContainer = origMediaType
            var addVideoPath = "/" + addFilePath.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            if ( idComboBoxCutAddColor.currentIndex === 0 ) {
                var addColor = "black"
                var addClipType = "blank_clip"
            }
            else if ( idComboBoxCutAddColor.currentIndex === 1 ) {
                addColor = "white"
                addClipType = "blank_clip"
            }
            else if ( idComboBoxCutAddColor.currentIndex === 2 ) {
                addColor = "black"
                addClipType = "freeze_frame"
            }
            else if ( idComboBoxCutAddColor.currentIndex === 3 ) {
                addColor = "black"
                addClipType = "video_clip"
            }
            if (idProgressSlider.value === idProgressSlider.minimumValue ) { var whereInVideo = "start" }
            else if (idProgressSlider.value >= idProgressSlider.maximumValue * 0.99) { whereInVideo = "end" } // Patch: if it does not fully reach the end
            else { whereInVideo = "middle" }
            // Patch: make sure to have a file loaded when adding a video
            if ( idComboBoxCutAddColor.currentIndex === 0 || idComboBoxCutAddColor.currentIndex === 1 || idComboBoxCutAddColor.currentIndex === 2 || (idComboBoxCutAddColor.currentIndex === 3 && addFileLoaded === true ) ) {
                preparePathAndUndo() // Patch: call this after reading idMediaPlayer.value, otherwise slider position = idMediaPlayer.stop() = 0 = "start"
                call("videox.addTimeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, tempMediaFolderPath, whereInVideo, atTimestamp, addLength, addColor, sourceVideoWidth.toString(), sourceVideoHeight.toString(), origFrameRate.toString(), origContainer, origCodecVideo, origCodecAudio, origAudioSamplerate, origAudioLayout, origPixelFormat, sourceSampleAspectRatio, addClipType, addVideoPath ])
            }
        }
        function resizeFunction() {
            preparePathAndUndo()
            var newWidth = idToolsCutDetailsColumn3Width.text
            var newHeight = idToolsCutDetailsColumn3Height.text
            if (idComboBoxCutResizeMaindimension.currentIndex === 0) {
                var autoScale = "fixWidth"
                var applyStretch ="false"
            }
            else if (idComboBoxCutResizeMaindimension.currentIndex === 1) {
                autoScale = "fixHeight"
                applyStretch ="false"
            }
            else if (idComboBoxCutResizeMaindimension.currentIndex === 2) {
                autoScale = "fixBoth"
                applyStretch = "pad"
            }
            else if (idComboBoxCutResizeMaindimension.currentIndex === 3 ) {
                autoScale = "fixBoth"
                applyStretch = "stretch"
            }
            call("videox.resizeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, newWidth, newHeight, autoScale, applyStretch ])
        }
        function repairFramesFunction() {
            preparePathAndUndo()
            call("videox.repairFramesFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy ])
        }
        function removeBWframesFunction( colorRemove ) {
            preparePathAndUndo()
            var amountBW = (idToolsRowImageEffectsFrameDetectionBW_amount.value).toString()  // percentage of pixels in image that have to be below threshold; default = 98.
            var thresholdBW = (idToolsRowImageEffectsFrameDetectionBW_treshold.value).toString() // threshold below which a pixel value is considered black; default = 32.
            call("videox.removeBWframesFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, colorRemove, amountBW, thresholdBW ])
        }


        // image manipulations
        function imageFadeFunction() {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            if (idComboBoxImageEffectsFade.currentIndex === 0) {var fadeDirection = "in"; var fadeCase = "cursor0" }
            else if (idComboBoxImageEffectsFade.currentIndex === 1) {fadeDirection = "out"; fadeCase = "cursor1" }
            else if (idComboBoxImageEffectsFade.currentIndex === 2) {fadeDirection = "in"; fadeCase = "marker0" }
            else if (idComboBoxImageEffectsFade.currentIndex === 3) {fadeDirection = "out"; fadeCase = "marker1" }
            if (fadeCase === "cursor0" ) { //in
                var fadeFrom = "0"
                var fadeLength = ((idMediaPlayer.position)/1000).toString()
            }
            if (fadeCase === "cursor1") { //out
                fadeFrom = (idMediaPlayer.position/1000).toString()
                fadeLength = ((idMediaPlayer.duration - idMediaPlayer.position)/1000).toString()
            }
            if (fadeCase === "marker0") { //in-marker
                fadeFrom = ((fromPosMillisecond/1000)).toString()
                fadeLength = ((toPosMillisecond - fromPosMillisecond)/1000).toString()
            }
            if (fadeCase === "marker1" ) { //out-marker
                fadeFrom = ((fromPosMillisecond/1000)).toString()
                fadeLength = ((toPosMillisecond - fromPosMillisecond)/1000).toString()
            }
            call("videox.imageFadeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fadeFrom , fadeLength, fadeDirection, fadeCase, fromSec, toSec ])
        }
        function imageRotateFunction() {
            preparePathAndUndo()
            if ( idComboBoxImageGeometryRotate.currentIndex === 0 ) {var rotateDirection = "1" } // +90°
            else if ( idComboBoxImageGeometryRotate.currentIndex === 1 ) {rotateDirection = "2" } // -90°
            call("videox.imageRotateFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, rotateDirection ])
        }
        function imageMirrorFunction() {
            preparePathAndUndo()
            if ( idComboBoxImageGeometryMirror.currentIndex === 0 ) {var mirrorDirection = "hflip" }
            else if ( idComboBoxImageGeometryMirror.currentIndex === 1 ) {mirrorDirection = "vflip" }
            call("videox.imageMirrorFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, mirrorDirection ])
        }
        function imageGrayscaleFunction() {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.imageGrayscaleFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fromSec, toSec ])
        }
        function imageNormalizeFunction() {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.imageNormalizeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fromSec, toSec ])
        }
        function imageStabilizeFunction() {
            preparePathAndUndo()
            console.log("now")
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.imageStabilizeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fromSec, toSec ])
        }
        function imageDeshakeFunction() { // deshake does not work in latest git ffmpeg, since there is an internal error with vid.stab as of Jan21 -> use older version
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.imageDeshakeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, tempMediaFolderPath, fromSec, toSec ])
        }
        function imageReverseFunction() {
            preparePathAndUndo()
            call("videox.imageReverseFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy  ])
        }
        function imageVibranceFunction() {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            var newValue = idToolsRowImageColorsVibranceSlider.value.toString()
            call("videox.imageVibranceFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, newValue, fromSec, toSec  ])
        }
        function imageCurveFunction( applyCurve ) {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.imageCurveFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, applyCurve, fromSec, toSec ])
        }
        function imageLUT3dFunction( attribute, fileType ) {
            preparePathAndUndo()
            if (attribute === "extern") {
                var cubeFile = cubeFilePath
            }
            else {
                cubeFile = filterFolder + attribute // load a preset .cube file
            }
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.imageLUT3dFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, cubeFile, fromSec, toSec ])
        }
        function imageBlurFunction() {
            preparePathAndUndo()
            generateCroppingPixelsFromHandles()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            var blurIntensity = (idToolsRowImageEffectsBlurSlider.value).toString()
            if ( idComboBoxImageEffectsBlurDirection.currentIndex === 0 ) { var blurWhere = "inside" }
            else if (idComboBoxImageEffectsBlurDirection.currentIndex === 1 ) { blurWhere = "outside" }
            call("videox.imageBlurFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fromSec, toSec, cropX, cropY, cropWidth, cropHeight, scaleDisplayFactorCrop, blurIntensity, blurWhere ])
        }
        function imageGeneralEffectFunction( effectName ) {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            if ( effectName === "unsharp" ) { // =sharpen effect
                var someValue1 = (idToolsRowImageEffectsSharpenSlider.value).toString() // luma value
                var someValue2 = "0" // (idToolsRowImageEffectsSharpenSlider2.value).toString() //chroma value
            }
            else {
                someValue1 = "0"
                someValue2 = "0"
            }
            call("videox.imageGeneralEffectFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, effectName, fromSec, toSec, someValue1, someValue2 ])
        }
        function imageColorFunction( targetAttribute ) {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            if ( targetAttribute === "brightness" ) { var targetValue = (idToolsRowImageColorsBrightnessSlider.value).toString() }
            if ( targetAttribute === "contrast" ) { targetValue = (idToolsRowImageColorsContrastSlider.value).toString() }
            if ( targetAttribute === "saturation" ) { targetValue = (idToolsRowImageColorsSaturationSlider.value).toString() }
            if ( targetAttribute === "gamma" ) { targetValue = (idToolsRowImageColorsGammaSlider.value).toString() }
            call("videox.imageColorFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, targetValue, targetAttribute, fromSec, toSec ])
        }
        function imageFrei0rFunction( ) {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            if (idComboBoxImageEffectsFrei0r.currentIndex === 0) {
                var applyEffect = "pixeliz0r"
                var useParams = "true"
                var applyParams = "0.02|0.02"
            }
            else if (idComboBoxImageEffectsFrei0r.currentIndex === 1) {
                applyEffect = "lenscorrection"
                useParams = "false"
                applyParams = "0.5|0.5|0.5|0.5"
            }
            else if (idComboBoxImageEffectsFrei0r.currentIndex === 2) {
                applyEffect = "vertigo"
                useParams = "true"
                applyParams = "0.2"
            }
            else if (idComboBoxImageEffectsFrei0r.currentIndex === 3) {
                applyEffect = "posterize"
                useParams = "false"
                applyParams = "0.2"
            }
            else if (idComboBoxImageEffectsFrei0r.currentIndex === 4) {
                applyEffect = "glow"
                useParams = "false"
                applyParams = "0"
            }
            else if (idComboBoxImageEffectsFrei0r.currentIndex === 5) {
                applyEffect = "glitch0r"
                useParams = "true"
                applyParams = "0.5" // how often appears
            }
            else if (idComboBoxImageEffectsFrei0r.currentIndex === 6) {
                applyEffect = "colgate"
                useParams = "false"
                applyParams = " #7f7f7f|0.433333" // color that should be white | colorTemperature
            }
            call("videox.imageFrei0rFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, applyEffect, applyParams, fromSec, toSec, useParams, origCodecVideo ])
        }


        //audio manipulations
        function audioFadeFunction() {
            preparePathAndUndo()
            if ( idComboBoxAudioFade.currentIndex === 0 ) {var fadeDirection = "in" }
            else if ( idComboBoxAudioFade.currentIndex === 1 ) {fadeDirection = "out" }
            if (fadeDirection === "in") {
                var fadeFrom = "0"
                var fadeLength = ((idMediaPlayer.position)/1000).toString()
            }
            if (fadeDirection === "out") {
                fadeFrom = (idMediaPlayer.position/1000).toString()
                fadeLength = ((idMediaPlayer.duration - idMediaPlayer.position)/1000).toString()
            }
            call("videox.audioFadeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fadeFrom , fadeLength, fadeDirection ])
        }
        function audioVolumeFunction() {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            if ( idComboBoxAudioVolume.currentIndex === 0 ) {var actionDB = "slider" }
            else if ( idComboBoxAudioVolume.currentIndex === 1 ) {actionDB = "normalize" }
            else if ( idComboBoxAudioVolume.currentIndex === 2 ) {actionDB = "mute" }
            var addVolumeDB = (idToolsRowAudioVolumeSlider.value).toString()
            call("videox.audioVolumeFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, actionDB, addVolumeDB, fromSec, toSec ])
        }
        function audioExtractFunction() {
            finishedLoading = false // since no preparePathAndUndo() we need to activate the waiting icon
            if ( idComboBoxAudioExtract.currentIndex === 0 ) {var targetCodec = "original" }
            else if ( idComboBoxAudioExtract.currentIndex === 1 ) {targetCodec = "flac" }
            else if ( idComboBoxAudioExtract.currentIndex === 2 ) {targetCodec = "wav" }
            else if ( idComboBoxAudioExtract.currentIndex === 3 ) {targetCodec = "mp3" }
            else if ( idComboBoxAudioExtract.currentIndex === 4 ) {targetCodec = "aac" }
            var targetFolderPath = origMediaFolderPath
            if (targetCodec !== "original") {
                var targetPath = origMediaFolderPath + origMediaName + "_audio" + "." + targetCodec
            }
            else {
                targetCodec = origCodecAudio.toString()
                if ( targetCodec !== "flac" && targetCodec !== "wav" && targetCodec !== "mp3" && targetCodec !== "aac" ) {
                    targetCodec = "flac"
                }
                targetPath = origMediaFolderPath + origMediaName + "_audio" + "." + targetCodec // origCodecAudio.toString()
            }
            var helperPathWav = origMediaFolderPath + origMediaName + "_audio" + ".flac"
            var mp3CompressBitrateType = "-V2"
            call("videox.audioExtractFunction", [ ffmpeg_staticPath, inputPathPy, targetPath, targetFolderPath, targetCodec, helperPathWav, mp3CompressBitrateType, fromTimestampPy, toTimestampPy ])
        }
        function audioMixerFunction() {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            var overlayDuration = (toPosMillisecond/1000 - fromPosMillisecond/1000).toString()
            var volumeFactorBase = (idToolsRowAudioMixerVolumeSliderBase.value).toString()
            var volumeFactorOver = (idToolsRowAudioMixerVolumeSliderOver.value).toString()
            var audioDelayMS = (fromPosMillisecond).toString()
            var fadeDurationIn = (idToolsAudioMixereFadeIn.text).toString()
            var fadeDurationOut = (idToolsAudioMixereFadeOut.text).toString()
            var currentPosition = (idMediaPlayer.position/1000).toString()
            var currentFileLength = (idMediaPlayer.duration/1000).toString()
            if ( idComboBoxAudioNewLength.currentIndex === 0 ) { var getLengthFrom = "newFile" }
            else if ( idComboBoxAudioNewLength.currentIndex === 1 ) { getLengthFrom = "betweenMarkers" }
            call("videox.audioMixerFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, addAudioPath, origCodecAudio, fromSec, toSec, overlayDuration, volumeFactorBase, volumeFactorOver, audioDelayMS, fadeDurationIn, fadeDurationOut, currentPosition, getLengthFrom, currentFileLength ])
        }
        function recordAudioFunction() {
            preparePathAndUndo()
            var currentFileLength = (idMediaPlayer.duration/1000).toString()
            var currentPosition = recordingOverlayStart // get info from idWatchdog_recordAudio
            var volumeFactorBase = (idToolsRowAudioMixerVolumeSliderBase.value).toString()
            var volumeFactorOver = (idToolsRowAudioMixerVolumeSliderOver.value * 2).toString()
            var fadeDurationIn = "0.25" // (idToolsAudioMixereFadeIn.text).toString()
            var fadeDurationOut = "0.25" // (idToolsAudioMixereFadeOut.text).toString()
            call("videox.recordAudioFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, recordAudioPath, currentFileLength, currentPosition, origCodecAudio, fadeDurationIn, fadeDurationOut, volumeFactorBase, volumeFactorOver ])
        }
        function audioEffectsFilters( filterType ) {
            preparePathAndUndo()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            if ( filterType === "denoise" ) {
                if (idComboBoxAudioFiltersDenoise.currentIndex === 0) { var effectTypeValue = "afftdn=nt=w:om=o" } // ToDo: more options, see documentation
                else if (idComboBoxAudioFiltersDenoise.currentIndex === 1) { effectTypeValue = "anlmdn=o=o" } // ToDo: more options, see documentation
            }
            else if (filterType === "highpass") {
                effectTypeValue = "highpass=f=" + (idToolsAudioFiltersFrequencyHighpass.text).toString()
            }
            else if (filterType === "lowpass") {
                effectTypeValue = "lowpass=f=" + (idToolsAudioFiltersFrequencyLowpass.text).toString()
            }
            else if (filterType === "echo") {
                if (idComboBoxAudioFiltersEcho.currentIndex === 0) { // standard
                    var in_gain = "0.6"
                    var out_gain = "0.3"
                    var delays = "1000"
                    var decays = "0.5"
                }
                else if (idComboBoxAudioFiltersEcho.currentIndex === 1) { // double instruments
                    in_gain = "0.8"
                    out_gain = "0.88"
                    delays = "60"
                    decays = "0.4"
                }
                else if (idComboBoxAudioFiltersEcho.currentIndex === 2) { // mountain concert
                    in_gain = "0.8"
                    out_gain = "0.9"
                    delays = "1000"
                    decays = "0.3"
                }
                else if (idComboBoxAudioFiltersEcho.currentIndex === 3) { // robot style
                    in_gain = "0.8"
                    out_gain = "0.88"
                    delays = "6"
                    decays = "0.4"
                }
                effectTypeValue = "aecho=in_gain=" + in_gain + ":out_gain=" + out_gain + ":delays=" + delays + ":decays=" + decays
            }
            console.log(filterType)
            console.log(effectTypeValue)
            call("videox.audioEffectsFilters", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fromSec, toSec, effectTypeValue, origCodecAudio, filterType ])
        }


        //adding manipulations
        function addTextFunction() {
            preparePathAndUndo()
            var placeX = rectDragText.x + rectDragText.width/2 - idPaintTextPreview.width/2
            var placeY = rectDragText.y + rectDragText.width/2  - idPaintTextPreview.height/3.5
            var addText = idToolsImageTextInput.text
            var addTextSize = Math.round( idPaintTextPreview.font.pixelSize * scaleDisplayFactorCrop )
            if (addTextboxColor === "transparent") { var addBox = "0" } else {addBox = "1" }
            if (fontFileLoaded === false) { var fontPath = "/usr/share/fonts/sail-sans-pro/SailSansPro-Light.ttf" } else { fontPath = "/" + localFont.source.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") }
            var addBoxBorderWidth = Math.round((idPaintTextPreviewBox.width - idPaintTextPreview.width) / 2)
            var addBoxOpacity = (idToolsRowImageTextboxOpacity.value).toString()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            call("videox.addTextFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, fontPath, addText, addTextColor, addTextSize , addBox, addTextboxColor, addBoxOpacity, addBoxBorderWidth, placeX, placeY, scaleDisplayFactorCrop, fromSec, toSec ])
        }
        function overlayOldMovieFunction() {
            preparePathAndUndo()
            var origContainer = origMediaType
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            var overlayDuration = (toPosMillisecond/1000 - fromPosMillisecond/1000).toString()
            var pathOverlayVideo = overlaysFolder + "oldOverlay.mp4"
            call("videox.overlayOldMovieFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, tempMediaFolderPath, origVideoWidth, origVideoHeight, origContainer, pathOverlayVideo, fromSec, toSec, overlayDuration ])
        }
        function overlayFileFunction() {
            preparePathAndUndo()
            generateCroppingPixelsFromHandles()
            var fromSec = ((fromPosMillisecond/1000)).toString()
            var toSec = ((toPosMillisecond/1000)).toString()
            var overlayDuration = (toPosMillisecond/1000 - fromPosMillisecond/1000).toString()
            var overlayOpacity = ( idComboBoxImageOverlayType.currentIndex === 3 ) ? "1" : ( (idToolsRowImageOverlayOpacitySlider.value).toString() )
            var overlayPath = "/" + overlayFilePath.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            if ( idComboBoxImageOverlayType.currentIndex === 0 ) { var overlayType = "image" }
            else if ( idComboBoxImageOverlayType.currentIndex === 1 ) { overlayType = "video" }
            else if ( idComboBoxImageOverlayType.currentIndex === 2 ) {
                overlayType = "rectangle"
                drawRectangleThickness = "fill"
            }
            else if ( idComboBoxImageOverlayType.currentIndex === 3 ) {
                overlayType = "rectangle"
                drawRectangleThickness =  (Math.round( idPreviewOverlayRectangle.border.width * scaleDisplayFactorCrop)).toString()
            }
            call("videox.overlayFileFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, overlayPath, fromSec, toSec, cropX, cropY, cropWidth, cropHeight, scaleDisplayFactorCrop, overlayOpacity, overlayType, overlayDuration, drawRectangleColor, drawRectangleThickness ])
        }
        function overlayAlphaClipFunction( pathOverlayVideo, partFull, colorKey ) {
            if (debug) console.debug("path:" + pathOverlayVideo + ' partFull:' + partFull + " colorKey:" + colorKey)
            preparePathAndUndo()
            generateCroppingPixelsFromHandles()
            var overlayOpacity = "1"
            if (partFull === "part") {
                var fromSec = ((fromPosMillisecond/1000)).toString()
                var toSec = ((toPosMillisecond/1000)).toString()
                var overlayDuration = (toPosMillisecond/1000 - fromPosMillisecond/1000).toString()
            }
            else { // "full" clip
                fromSec = "0"
                toSec = ((idMediaPlayer.duration)/1000).toString()
                overlayDuration = ((idMediaPlayer.duration)/1000).toString()
            }
            // replace ColorKey and Path when needed
            if (colorKey === "manual") {  // colorKey = "black:0.3:0.2" // colorToAlpha:similarity(0=exact/1=everything):blendEdges(higher=semi transparent pixels are closer to keycolor)
                colorKey = colorToAlpha + ":" + (idToolsRowImageOverlayAlphaSlider_Similarity.value).toString() + ":" + (idToolsRowImageOverlayAlphaSlider_Blend.value).toString()
                pathOverlayVideo = overlayFilePath.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            }
            // stretch if needed
            if ( idComboBoxImageOverlayAlphaStretch.currentIndex === 0 ) { var applyStretch = "stretch" }
            else { applyStretch = "noStretch" }
            call("videox.overlayAlphaClipFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, pathOverlayVideo, origVideoWidth, origVideoHeight, colorKey, overlayOpacity, fromSec, toSec, overlayDuration, applyStretch, cropX, cropY, cropWidth, cropHeight, scaleDisplayFactorCrop, previewAlphaType ])
        }


        //collage manipulations
        function splitscreenFunction() {
            preparePathAndUndo()
            var secondClipPath = overlayFilePath.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            if (idComboBoxCollageSplitscreen.currentIndex === 0) { var stackDirection = "above" }
            else if (idComboBoxCollageSplitscreen.currentIndex === 1) { stackDirection = "below" }
            else if (idComboBoxCollageSplitscreen.currentIndex === 2) { stackDirection = "left" }
            else if (idComboBoxCollageSplitscreen.currentIndex === 3) { stackDirection = "right" }
            if (idComboBoxCollageSplitscreenAudio.currentIndex === 0) { var useAudioFrom = "first" }
            else if (idComboBoxCollageSplitscreenAudio.currentIndex === 1) { useAudioFrom = "second" }
            else if (idComboBoxCollageSplitscreenAudio.currentIndex === 2) { useAudioFrom = "none" }
            else if (idComboBoxCollageSplitscreenAudio.currentIndex === 3) { useAudioFrom = "both" }
            var sizeDevider = 2
            call("videox.splitscreenFunction", [ ffmpeg_staticPath, inputPathPy, outputPathPy, sourceVideoWidth, sourceVideoHeight, sizeDevider, secondClipPath, stackDirection, useAudioFrom ])
        }

        // create filmstrip
        // currently, exports to flat out 10 fps which differs form acquire, but is ok for demo
        function createFilmstripFunction() {
            finishedLoading = false
            // var newFileName = "slideshow_" + new Date().toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd_HH-mm-ss") + "." + tempMediaTypea
            var newFileName = slideshowNameField.text + '.mp4'
            // this should move to the dir the images came from?
            outputPathPy = homeDirectory + "/Videos/" + newFileName
            if (debug) console.log(outputPathPy)
            if (debug) console.log(tempMediaFolderPath)
            var allSelectedPathsSlideshow = ""
            for(var i = 0; i < imageListModel.count; ++i) {
                var addPath = (imageListModel.get(i).url).toString().replace(/^(file:\/{2})|(qrc:\/{2})|(http:\/{2})/,"")
                allSelectedPathsSlideshow = allSelectedPathsSlideshow + addPath + ";;"
            }
            // need to add potrait flag.
            call("videox.createFilmstripFunction", [ ffmpeg_staticPath, outputPathPy, tempMediaFolderPath, allSelectedPathsSlideshow, newFileName, portrait, saveFps.toString() ])
        }

        function createSlideshowFunction() {
            //idMediaPlayer.stop()
            finishedLoading = false
            var newFileName = "slideshow_" + new Date().toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd_HH-mm-ss") + "." + tempMediaType
            outputPathPy = homeDirectory + "/Videos/" + newFileName
            allSelectedPathsSlideshow = ""
            allSelectedDurationsSlideshow = ""
            allSelectedTransitionsSlideshow = ""
            allSelectedTransitionDurationsSlideshow = ""
            for(var i = 0; i < slideshowModel.count; ++i) {
                var addPath = (slideshowModel.get(i).path).toString()
                var addDuration = (slideshowModel.get(i).duration).toString()
                var addTransition = (slideshowModel.get(i).transition).toString()
                var addTransitionDuration = (slideshowModel.get(i).transitionDuration).toString()

                allSelectedPathsSlideshow = allSelectedPathsSlideshow + addPath + ";;"
                allSelectedDurationsSlideshow = allSelectedDurationsSlideshow + addDuration + ";;"
                allSelectedTransitionsSlideshow = allSelectedTransitionsSlideshow + addTransition + ";;"
                allSelectedTransitionDurationsSlideshow = allSelectedTransitionDurationsSlideshow + addTransitionDuration + ";;"
            }
            var targetWidth = (idToolsCollageTargetWidth.text).toString()
            var targetHeight = (idToolsCollageTargetHeight.text).toString()

            if (idComboBoxCollageSlideshowEffect.currentIndex === 0 ) { var panZoom = "still_images" }
            else if (idComboBoxCollageSlideshowEffect.currentIndex === 1 ) { panZoom = "pan_and_zoom" }

            call("videox.createSlideshowFunction", [ ffmpeg_staticPath, outputPathPy, allSelectedPathsSlideshow, allSelectedDurationsSlideshow, allSelectedTransitionsSlideshow, allSelectedTransitionDurationsSlideshow, targetWidth, targetHeight, newFileName, panZoom ])
        }
        function createStorylineFunction() {
            idMediaPlayer.stop()
            finishedLoading = false
            var newFileName = "story_" + new Date().toLocaleString(Qt.locale("de_DE"), "yyyy-MM-dd_HH-mm-ss") + "." + tempMediaType
            outputPathPy = homeDirectory + "/Videos/"  + newFileName
            allSelectedPathsStoryline = ""
            allSelectedTransitionsStoryline = ""
            allSelectedTransitionDurationsStoryline = ""
            for(var i = 0; i < storylineModel.count; ++i) {
                var addPath = (storylineModel.get(i).path).toString()
                var addTransition = (storylineModel.get(i).transition).toString()
                var addTransitionDuration = (storylineModel.get(i).transitionDuration).toString()
                allSelectedPathsStoryline = allSelectedPathsStoryline + addPath + ";;"
                allSelectedTransitionsStoryline = allSelectedTransitionsStoryline + addTransition + ";;"
                allSelectedTransitionDurationsStoryline = allSelectedTransitionDurationsStoryline + addTransitionDuration + ";;"
            }
            var targetWidth = (idToolsCollageTargetWidth.text).toString()
            var targetHeight = (idToolsCollageTargetHeight.text).toString()
            call("videox.createStorylineFunction", [ ffmpeg_staticPath, outputPathPy, allSelectedPathsStoryline, allSelectedTransitionsStoryline, allSelectedTransitionDurationsStoryline, targetWidth, targetHeight, newFileName ])
        }
        function overlaySubtitleFunction() {
            preparePathAndUndo()
            showHintSavingSubtitles = true
            if ( idComboBoxCollageSubtitleMethod.currentIndex === 0 ) { var addMethod = "burn" }
            else if ( idComboBoxCollageSubtitleMethod.currentIndex === 1 ) { addMethod = "selectable" }
            var textFileText = ""
            if (idComboBoxCollageSubtitleAdd.currentIndex === 0) { // get from file
                var createTextfile = "false"
                var subtitlePath = "/" + addSubtitlePath.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            }
            else if (idComboBoxCollageSubtitleAdd.currentIndex === 1) { // get from manual input
                createTextfile = "true"
                subtitlePath = subtitleTempPath
                for(var i = 0; i < subtitleModel.count; ++i) {
                    var addSceneNr = (i+1).toString()
                    var addDuration = (subtitleModel.get(i).timestamp).toString()
                    var addText = (subtitleModel.get(i).text).toString()
                    textFileText = textFileText + addSceneNr + "\n" + addDuration + "\n" + addText + "\n"
                }
                addSubtitleContainer = "srt"
            }
            call("videox.overlaySubtitleFunction", [ ffmpeg_staticPath, inputPathPy, tempMediaFolderPath, outputPathPy, subtitlePath, addSubtitleContainer, addMethod, createTextfile, textFileText ])
        }
        function parseSubtitleFile( pathToFile ) {
            var subtitlePath = "/" + pathToFile.toString().replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            call("videox.parseSubtitleFile", [ ffmpeg_staticPath, subtitlePath ])
        }
        function extractImagesFunction() {
            idMediaPlayer.stop()
            finishedLoading = false
            var thumbnailSec = new Date(idMediaPlayer.position).toISOString().substr(11,12)
            var thumbnailSecFileName = thumbnailSec//.replace(":", "-").replace(":", "-").replace(".", "-")
            var imageInterval = (idToolsRowCollageImageExtractIntervall.value).toString()
            if ( idComboBoxCollageImageExtract.currentIndex === 0 ) { var modeExtractImg = "thumbnails" }
            else if ( idComboBoxCollageImageExtract.currentIndex === 1 ) { modeExtractImg = "iFrames" }
            else if ( idComboBoxCollageImageExtract.currentIndex === 2 ) { modeExtractImg = "singleImage" }
            call("videox.extractImagesFunction", [ ffmpeg_staticPath, inputPathPy, modeExtractImg, thumbnailSec, thumbnailSecFileName, imageInterval, origMediaFolderPath ])
        }
        onError: {
            // when an exception is raised, this error handler will be called
            if (debug) {
                console.log('python error: ' + traceback);
                banner.notify( qsTr("Pthon Error") + "\n" + " " + traceback + " ", Theme.highlightDimmerColor, 100000 )
            }
        }
        onReceived: {
            // asychronous messages from Python arrive here via pyotherside.send()
            if (debug) console.log('got message from python: ' + data);
        }
    } // end python

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
