import QtQuick 2.5
import Sailfish.Silica 1.0
import Nemo.KeepAlive 1.2
import QtMultimedia 5.6
import QtQuick.Layouts 1.0
import "../utils/localdb.js" as Database

//import QtGraphicalEffects 1.0
//import "../constants.js" as Constants

Page {
    id: playSlideshowPage

    showNavigationIndicator: !slideshowRunning
    backNavigation: !slideshowRunning

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // Properties.
    property string imageSource: ""
    property string imageSource2: ""
    property int imageIndex: -1
    property bool slideshowRunning:true
    property ListModel imageModel
    property ListModel musicModel
    property var slideshowOrderArray: []
    property bool firstLoaded: false

    // Settings.
    property int slideshowInterval: 200 //Settings.getIntSetting(Constants.intervalKey, 5) * 1000
    property bool loop: true //Settings.getBooleanSetting(Constants.loopKey, true)
    property bool loopMusic: false //Settings.getBooleanSetting(Constants.loopMusicKey, true)
    property int fpsMode
    property int saveFps
    property bool debug: true
    property var portrait
    property int dx: 0
    property int dy: 0

    // Signals.
    // Notify cover about image change.
    signal imageChanged(string url)

    onOrientationChanged:
    {

        if (orientation===Orientation.Landscape){
            console.log(orientation)
        } else if (orientation === Orientation.Portrait){
            console.log(orientation)
        }
    }


    // React on status changes.
    onStatusChanged:
    {
        if(status === PageStatus.Activating)
        {
            if (debug) console.log("Page activating...")
            if (debug) console.log(slideshowOrderArray)

            fpsMode = Database.getProp('fpsMode')
            loop = Database.getProp('loop')
            saveFps = Database.getProp('saveFps')

            if (debug) console.log('fps: ' + fpsMode)
            if (debug) console.log('saveps:' + saveFps)
            if (debug) console.log('loop:' + loop)

            if (fpsMode == 0) {
                slideshowInterval = 1000 / saveFps
                if (debug) console.debug("interval: " + slideshowInterval)
            } else {
                slideshowInterval = 1000 * saveFps
                if (debug) console.debug("interval: "+ slideshowInterval)

            }
            if (slideshowOrderArray.length != imageModel.count) {
                if (debug) console.error("Order array's and image model's sizes does not match. Expect wonky behavior...")
            }

            if (slideshowOrderArray.length == 0) {
                for (var j = 0; j < imageModel.count; ++j) {
                    slideshowOrderArray.push(j)
                }
                if (debug) console.log(slideshowOrderArray)
            }

            if (imageModel.count > 0) {
                imageIndex = 0;
                imageSource = imageModel.get(slideshowOrderArray[imageIndex]).url
                if (debug) console.debug(imageSource)
            }
            /*if (musicModel.count > 0) {
                backgroundPlaylist.clear()
                for (var i = 0; i < musicModel.count; ++i) {
                    console.log("Add music file to playlist: " + musicModel.get(i).url)
                    backgroundPlaylist.addItem(musicModel.get(i).url)
                }
            }*/

        }
        else if(status === PageStatus.Deactivating) // Deactivating, set defaults.
        {
            if (debug) console.log("Page deactivating...")
            imageIndex = -1;
            imageChanged("")
        }
    }

    Component.onDestruction:
    {
        if (debug) console.log("PlaySlideshowPage destroyed...")
    }

   /* Audio {
        id: backgroundMusic
        autoPlay: false
        audioRole: Audio.MusicRole
        playlist: Playlist {
            id: backgroundPlaylist
            playbackMode: loopMusic ? Playlist.Loop : Playlist.Sequential
        }
    }*/

    PageHeader
    {
        id: header
        title: ""
        visible: !slideshowRunning
    }

    Rectangle
    {
        id: background
        anchors.fill: parent
        color: Theme.colorScheme == Theme.LightOnDark ? "black" : "white"
    }
    /* we need this to obtain the orientation to pass to ffmpeg */
    Image
    {
        id: infoLoad
        visible: false
        asynchronous: true
        autoTransform: true
        fillMode: Image.PreserveAspectFit
        onStatusChanged:
        {
            if (status == Image.Ready) {
               if (debug) console.log('Loaded: sourceSize ==', sourceSize);
               if (debug) console.log('Loaded: Height ==', height);
               if (debug) console.log('Loaded: implicitHeight ==', implicitHeight);
               if (debug) console.log('Loaded: width ==', width);
               if (debug) console.log('Loaded: impwidth ==', implicitWidth);
                if (height === 1920)  portrait = "1920"
                drawingCanvas.width = width
                drawingCanvas.height = height
            }
        }
    }
    Canvas
    {
        id: drawingCanvas
        anchors
        {
            centerIn: parent
        }

        width:1080
        height:1920

        renderTarget: Canvas.Image

        Component.onCompleted:  {
            // preload images.
            var img = ""
            for (var i=0;i<imageModel.count; i++)
            {
                img = imageModel.get(i).url
                if (i==0)
                    infoLoad.source = img
                var insertImagePath = "image://paintImage/" + img
                loadImage(insertImagePath);
            }
        }
    }

    /*
      Pause indicators.
      */
    IconButton
    {
        id: recordButton
        icon.source: Qt.resolvedUrl("../img/play-button.png")
        scale: 0.75
        visible: !slideshowRunning
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 50
            //horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            toggleSlideshow()
        }
        states:
            [
            State
            {
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
    // Handle start/stop by click.
    MouseArea
    {
        id: slideshowToggleArea
        anchors {
            left: parent.left
            top: parent.top
            right: nextImageArea.left
            bottom: parent.bottom
        }

        // Toggle slideshow start/stop.
        onClicked: {
            if(debug) console.log("onClicked...")
            toggleSlideshow()
        }
    }

    MouseArea
    {
        id: nextImageArea
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width / 5
        onClicked: {
            if (debug) console.log("Move to next image...")
            if (slideshowRunning)
                slideshowTimer.restart()
            nextPicture()
        }
    }

    // Timer to trigger image change.
    Timer
    {
        id: slideshowTimer
        interval: slideshowInterval
        repeat: true
        running: slideshowRunning

        // Change image when timer triggers.
        onTriggered: {
            nextPicture()
        }
    }


    /* Functions. */

    function toggleSlideshow()
    {
        slideshowRunning = !slideshowRunning
        //blanking.preventBlanking = slideshowRunning
    }

    function nextPicture()
    {
        ++imageIndex

        if((imageIndex) === imageModel.count)
            imageIndex = 0

        //blanking.preventBlanking = true
        if (imageIndex == imageModel.count)
        {
            imageIndex = 0;
            if (!loop) {
                slideshowRunning = false;
                //blanking.preventBlanking = slideshowRunning
                return;
            }
        }

        imageSource = "image://paintImage/" + imageModel.get(slideshowOrderArray[imageIndex]).url
        imageChanged(imageModel.get(slideshowOrderArray[imageIndex]).url)

        var ctx = drawingCanvas.getContext('2d')
        if (drawingCanvas.isImageLoaded(imageSource))
        {
            //ctx.drawImage( imageSource, 0, 0, drawingCanvas.width, drawingCanvas.height )
            ctx.drawImage( imageSource, 0, 0)
            drawingCanvas.requestPaint()
        }
    }



}
