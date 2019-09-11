import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.11

import Qt.labs.platform 1.0


Window {
  visible: true
  width: 1024
  height: 768
  title: qsTr("Poppler plugin example")

  color: "#eee"

  PDFView {
    id: pdfView
    anchors.fill: parent
    path: fileDialog.file.toString().substring(6)
  }

  Button {
    anchors {
      left: parent.left
      top: parent.top
      margins: 16
    }

    text: qsTr("Open")

    onClicked: fileDialog.open()

    FileDialog {
      id: fileDialog
      folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
      nameFilters: [ qsTr("PDF files (*.pdf)") ]

      onFileChanged: pdfView.forceActiveFocus()
    }
  }

}
