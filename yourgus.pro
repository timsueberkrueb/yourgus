TEMPLATE = app

QT += qml quick xml svg

qtHaveModule(webview) {
    QT += webview
    DEFINES = USE_DEFAULT_QT_WEBVIEW
    message("Using default Qt WebView module")
}

greaterThan(QT_MAJOR_VERSION, 4) {
    greaterThan(QT_MINOR_VERSION, 5) {
        DEFINES += ENABLE_HIGH_DPI_SCALING
        message("Using high-dpi scaling")
    }
}

CONFIG += c++11

SOURCES += src/main.cpp \
    src/settings.cpp \
    src/cache.cpp

HEADERS += \
    src/settings.h \
    src/cache.h


RESOURCES += src/qml/qml.qrc


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Include Quey UI
include(quey-ui/quey-ui.pri)

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/res/drawable-ldpi/splash.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

# Ubuntu
UBUNTU_DEPLOYMENT = $$find(QMAKESPEC, "ubuntu")
count(UBUNTU_DEPLOYMENT, 1){
    load(ubuntu-click)
    UBUNTU_MANIFEST_FILE=ubuntu/manifest.json
    config_files.path = /ubuntu
    config_files.files = ubuntu/yourgus.desktop \
                         ubuntu/yourgus.apparmor \
                         ubuntu/icon.png

    # lib files
    LIB_FILES = $$files(lib/*,true)
    lib_files.path = /lib
    lib_files.files += $${LIB_FILES}

    config_files.files += $${CONF_FILES}

    INSTALLS+=config_files lib_files
    include(ubuntu.pri)
    target.path = $${UBUNTU_CLICK_BINARY_PATH}
}
