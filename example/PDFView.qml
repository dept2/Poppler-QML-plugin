import QtQuick 2.11
import QtQuick.Controls 2.4

import org.docviewer.poppler 1.0

Item {
  id: root

  property alias path: poppler.path
  property real zoom: 1.0

  Poppler {
    id: poppler
  }

  ListView {
    id: pagesView
    anchors.fill: parent
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    spacing: 20

    boundsBehavior: Flickable.StopAtBounds

    model: poppler.pages
    delegate: pagesDelegate
    ScrollBar.vertical: ScrollBar {
      minimumSize: 0.04
    }
  }

  Component {
    id: pagesDelegate

    Item {
      id: pdfImageItem
      anchors.horizontalCenter: parent.horizontalCenter
      clip: true
      height: pdfImage.implicitHeight
      width: pdfImage.implicitWidth
      Image {
        id: pdfImage

        cache: false // Rendered pages may have the same source address for different opened PDF files

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        source: modelData
        sourceSize.width: 800 * root.zoom
        height: parent.height
        width: parent.width
      }
    }
  }

  Slider {
    id: zoomSlider

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 16
    from: 0.5
    to: 2
    stepSize: .1
    value: 1

    onValueChanged: root.zoom = value
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: {
      if (wheel.modifiers & Qt.ControlModifier) {
        if (wheel.angleDelta.y > 0) {
          zoomSlider.increase()
        } else {
          zoomSlider.decrease()
        }
      } else {
        wheel.accepted = false
      }
    }
  }

  Keys.onPressed: {
    if (event.modifiers & Qt.ControlModifier) {
      if (event.key === Qt.Key_Minus) {
        zoomSlider.decrease()
      } else if (event.key === Qt.Key_Plus) {
        zoomSlider.increase()
      } else if (event.key === Qt.Key_0) {
        zoomSlider.value = 1
      }
    }
  }
}
