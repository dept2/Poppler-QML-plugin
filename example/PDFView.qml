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

  function goTo(destination) {
    pagesView.positionViewAtIndex(destination.page, ListView.Beginning)
    var pageHeight = poppler.pages[destination.page].size.height * zoom
    var scroll = Math.round(destination.top * pageHeight)
    pagesView.contentY += scroll
  }

  ListView {
    id: pagesView
    anchors.fill: parent
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    spacing: 20

    boundsBehavior: Flickable.StopAtBounds

    model: poppler.pages
    delegate: Item {
      width: parent.width
      height: pageImage.height
      Image {
        id: pageImage
        x: Math.round((parent.width - sourceSize.width) / 2)

        cache: false
        fillMode: Image.Pad

        sourceSize.width: Math.round(modelData.size.width * zoom)
        sourceSize.height: Math.round(modelData.size.height * zoom)
        source: modelData.image

        width: sourceSize.width
        height: sourceSize.height

//        Rectangle {
//          color: "transparent"
//          border.color: "red"
//          border.width: 1
//          anchors.fill: parent
//        }

        Repeater {
          model: modelData.links
          delegate: MouseArea {
            z: 100
            x: Math.round(modelData.rect.x * pageImage.width)
            y: Math.round(modelData.rect.y * pageImage.height)
            width: Math.round(modelData.rect.width * pageImage.width)
            height: Math.round(modelData.rect.height * pageImage.height)

            cursorShape: Qt.PointingHandCursor
            onClicked: goTo(modelData.destination)

//            Rectangle {
//              anchors.fill: parent
//              color: "transparent"
//              border.color: "blue"
//              border.width: 1
//            }
          }
        }
      }
    }

    ScrollBar.vertical: ScrollBar {
      minimumSize: 0.04
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

//  MouseArea {
//    anchors.fill: parent
//    acceptedButtons: Qt.NoButton
//    hoverEnabled: false
//    onWheel: {
//      if (wheel.modifiers & Qt.ControlModifier) {
//        if (wheel.angleDelta.y > 0) {
//          zoomSlider.increase()
//        } else {
//          zoomSlider.decrease()
//        }
//      } else {
//        wheel.accepted = false
//      }
//    }
//  }

  Keys.onPressed: {
    if (event.modifiers & Qt.ControlModifier) {
      if (event.key === Qt.Key_Minus) {
        zoomSlider.decrease()
        event.accepted = true
      } else if (event.key === Qt.Key_Plus) {
        zoomSlider.increase()
        event.accepted = true
      } else if (event.key === Qt.Key_0) {
        zoomSlider.value = 1
        event.accepted = true
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
