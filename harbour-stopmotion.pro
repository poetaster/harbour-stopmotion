# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-stopmotion

CONFIG += sailfishapp

SOURCES += \
        src/harbour-stopmotion.cpp \
        src/nemoimagemetadata.cpp
HEADERS += \
        src/IconProvider.h \
        src/ImageProvider.h \
        src/nemoimagemetadata.h

DISTFILES += qml/harbour-stopmotion.qml \
    qml/components/Banner.qml \
    qml/components/CollapsingHeader.qml \
    qml/cover/CoverPage.qml \
    qml/cover/harbour-stopmotion.png \
    qml/pages/CanvasSlideshowPage.qml \
    qml/pages/ShootScreen.qml \
    qml/pages/CameraButton.qml \
    qml/pages/ImagePage.qml \
    qml/pages/SlideShowPage.qml \
    qml/pages/PlaySlideShowPage.qml \
    qml/img/*.png \
    qml/utils/localdb.js \
    qml/utils/constants.js \
    qml/sound/*.wav \
    qml/py/videox.py \
    rpm/harbour-stopmotion.spec \
    rpm/harbour-stopmotion.changes.in \
    rpm/harbour-stopmotion.changes.run.in \
    translations/*.ts \
    harbour-stopmotion.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-stopmotion-de.ts
