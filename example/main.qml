import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.11

import QtQuick.Controls.Material 2.3

import Qt.labs.platform 1.0


ApplicationWindow {
  visible: true
  width: 1024
  height: 768
  title: qsTr("Poppler plugin example")

  color: "#eee"

  header: ToolBar {
    leftPadding: 8
    rightPadding: 8
    RowLayout {
      anchors.fill: parent
      spacing: 16

      Button {
        text: qsTr("Open")
        flat: true

        onClicked: fileDialog.open()

        FileDialog {
          id: fileDialog
          folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
          nameFilters: [ qsTr("PDF files (*.pdf)") ]

          onFileChanged: pdfView.forceActiveFocus()
        }
      }

      Slider {
        id: zoomSlider

        from: 0.5
        to: 2
        stepSize: .1
        value: 1

        onValueChanged: pdfView.zoom = value
      }

      Item {
        Layout.fillWidth: true
      }

      TextField {
        id: searchField
        placeholderText: qsTr("Search")
        Material.theme: Material.Dark

        onTextChanged: searchTimer.restart()
        Keys.onReturnPressed: {
          searchTimer.stop()
          pdfView.search(searchField.text)
        }

        Timer {
          id: searchTimer
          interval: 1000
          onTriggered: pdfView.search(searchField.text)
        }
      }
    }
  }

  PDFView {
    id: pdfView
    anchors.fill: parent
    focus: true
    path: fileDialog.file.toString().substring(6)

    onSearchRestartedFromTheBeginning: {
      notifyLabel.text = qsTr("Search restarted from the beginning")
      notifyAnimation.start()
    }

    onSearchNotFound: {
      notifyLabel.text = qsTr('"%1" not found').arg(searchField.text)
      notifyAnimation.start()
    }

    Keys.onPressed: {
      if (event.modifiers === Qt.ControlModifier) {
        if (event.key === Qt.Key_Minus) {
          zoomSlider.decrease()
          event.accepted = true
        } else if (event.key === Qt.Key_Plus) {
          zoomSlider.increase()
          event.accepted = true
        } else if (event.key === Qt.Key_0) {
          zoomSlider.value = 1
          event.accepted = true
        } else if (event.key === Qt.Key_F) {
          searchField.forceActiveFocus()
        }
      } else if (event.modifiers === Qt.NoModifier) {
        if (event.key === Qt.Key_Home) {
          pagesView.positionViewAtBeginning()
          event.accepted = true
        } else if (event.key === Qt.Key_End) {
          pagesView.positionViewAtEnd()
          event.accepted = true
        }
      }
    }
  }

  Pane {
    id: notifyPane
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 16
    Material.theme: Material.Dark
    Material.elevation: 2
    opacity: 0
    Label {
      id: notifyLabel
    }

    SequentialAnimation {
      id: notifyAnimation

      NumberAnimation {
        target: notifyPane
        property: "opacity"
        duration: 250
        easing.type: Easing.InOutQuad
        from: 0; to: 1
      }

      PauseAnimation {
        duration: 2000
      }

      NumberAnimation {
        target: notifyPane
        property: "opacity"
        duration: 250
        easing.type: Easing.InOutQuad
        from: 1; to: 0
      }
    }
  }

  Label {
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.margins: 16
    text: pdfView.currentPage + 1 + " / " + pdfView.count
  }
}
