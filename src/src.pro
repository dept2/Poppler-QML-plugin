TARGET = popplerPlugin

QT += qml quick
CONFIG += qt plugin
TEMPLATE = lib

LIBS += -lpoppler-qt6

# Input
SOURCES += \
    plugin.cpp \
    pdfModel.cpp \
    pageImageProvider.cpp

HEADERS += \
    plugin.h \
    pdfModel.h \
    pageImageProvider.h

OTHER_FILES += ../README.md

qmlFiles.files = \
    qmldir \
    popplerPlugin.qmltypes \
    PDFView.qml

# Add 'make qmltypes' command to generate popplerPlugin.qmltypes
load(resolve_target)
qmltypes.target = qmltypes
qmltypes.commands = $$[QT_INSTALL_BINS]/qmlplugindump org.docviewer.poppler 1.0 $$QMAKE_RESOLVED_TARGET > $$PWD/popplerPlugin.qmltypes
qmltypes.depends = $$QMAKE_RESOLVED_TARGET
QMAKE_EXTRA_TARGETS += qmltypes

isEmpty(INSTALL_PREFIX) {
  INSTALL_PREFIX = $$[QT_INSTALL_QML]
}
installPath = $${INSTALL_PREFIX}/org/docviewer/poppler/
qmlFiles.path = $$installPath
target.path = $$installPath
INSTALLS += target qmlFiles
