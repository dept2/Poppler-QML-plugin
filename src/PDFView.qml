import QtQuick 2.9

import org.docviewer.poppler 1.0


ListView {
  id: pagesView

  property alias path: poppler.path
  property alias loaded: poppler.loaded
  property real zoom: 1.0

  property int count: poppler.pages.length
  property int currentPage: -1

  property color searchHighlightColor: Qt.rgba(1, 1, .2, .4)

  signal error(string errorMessage)

  function search(text) {
    if (!poppler.loaded) return

    if (text.length === 0) {
      __currentSearchTerm = ''
      __currentSearchResultIndex = -1
      __currentSearchResults = []
    } else if (text === __currentSearchTerm) {
      if (__currentSearchResultIndex < __currentSearchResults.length - 1) {
        __currentSearchResultIndex++
        __scrollTo(__currentSearchResult)
      } else {
        var page = __currentSearchResult.page
        __currentSearchResultIndex = -1
        __currentSearchResults = []
        if (page < count - 1) {
          __search(page + 1, __currentSearchTerm)
        } else {
          pagesView.searchRestartedFromTheBeginning()
          __search(0, __currentSearchTerm)
        }
      }
    } else {
      __currentSearchTerm = text
      __currentSearchResultIndex = -1
      __currentSearchResults = []
      __search(currentPage, text)
    }
  }

  signal searchNotFound
  signal searchRestartedFromTheBeginning

  property string __currentSearchTerm
  property int __currentSearchResultIndex: -1
  property var __currentSearchResults
  property var __currentSearchResult: __currentSearchResultIndex > -1 ? __currentSearchResults[__currentSearchResultIndex] : { page: -1, rect: Qt.rect(0,0,0,0) }

  function __search(startPage, text) {
    if (startPage >= count) throw new Error('Start page index is larger than number of pages in document')

    function resultFound(page, result) {
      var searchResults = []
      for (var i = 0; i < result.length; ++i) {
        searchResults.push({ page: page, rect: result[i] })
      }
      __currentSearchResults = searchResults
      __currentSearchResultIndex = 0
      __scrollTo(__currentSearchResult)
    }

    var found = false
    for (var page = startPage; page < count; ++page) {
      var result = poppler.search(page, text)

      if (result.length > 0) {
        found = true
        resultFound(page, result)
        break
      }
    }

    if (!found) {
      for (page = 0; page < startPage; ++page) {
        result = poppler.search(page, text)

        if (result.length > 0) {
          found = true
          pagesView.searchRestartedFromTheBeginning()
          resultFound(page, result)
          break
        }
      }
    }

    if (!found) {
      pagesView.searchNotFound()
    }
  }


  Poppler {
    id: poppler
    onLoadedChanged: {
      __updateCurrentPage()
      __currentSearchTerm = ''
      __currentSearchResultIndex = -1
      __currentSearchResults = []
    }
    onError: (errorMessage) => pagesView.error(errorMessage)
  }

  // Current page
  function __updateCurrentPage () {
    var p = pagesView.indexAt(pagesView.width / 2, pagesView.contentY + pagesView.height / 2)
    if (p === -1)
      p = pagesView.indexAt(pagesView.width / 2, pagesView.contentY + pagesView.height / 2 + pagesView.spacing)
    currentPage = p
  }

  Connections {
    target: pagesView
    function onContentYChanged() {
      __updateCurrentPage()
    }
  }

  function __goTo (destination) {
    pagesView.positionViewAtIndex(destination.page, ListView.Beginning)
    var pageHeight = poppler.pages[destination.page].size.height * zoom
    var scroll = Math.round(destination.top * pageHeight)
    pagesView.contentY += scroll
  }

  function __scrollTo(destination) {
    if (destination.page !== currentPage) {
      pagesView.positionViewAtIndex(destination.page, ListView.Beginning)
    }

    var i = pagesView.itemAt(pagesView.width / 2, pagesView.contentY + pagesView.height / 2)
    if (i === null)
      i = pagesView.itemAt(pagesView.width / 2, pagesView.contentY + pagesView.height / 2 + pagesView.spacing)

    var pageHeight = poppler.pages[destination.page].size.height * zoom
    var pageY = i.y - pagesView.contentY

    var bottomDistance = pagesView.height - (pageY + Math.round(destination.rect.bottom * pageHeight))
    var topDistance = pageY + Math.round(destination.rect.top * pageHeight)
    if (bottomDistance < 0) {
      // The found term is lower than the bottom of viewport
      pagesView.contentY -= bottomDistance - pagesView.spacing
    } else if (topDistance < 0) {
      pagesView.contentY += topDistance - pagesView.spacing
    }
  }

  spacing: 20

  boundsBehavior: Flickable.StopAtBounds

  model: poppler.pages

  header: Item { height: 10 }
  footer: Item { height: 10 }
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

      Repeater {
        model: modelData.links
        delegate: MouseArea {
          x: Math.round(modelData.rect.x * parent.width)
          y: Math.round(modelData.rect.y * parent.height)
          width: Math.round(modelData.rect.width * parent.width)
          height: Math.round(modelData.rect.height * parent.height)

          cursorShape: Qt.PointingHandCursor
          onClicked: __goTo(modelData.destination)
        }
      }

      Rectangle {
        visible: __currentSearchResult.page === index
        color: pagesView.searchHighlightColor
        x: Math.round(__currentSearchResult.rect.x * parent.width)
        y: Math.round(__currentSearchResult.rect.y * parent.height)
        width: Math.round(__currentSearchResult.rect.width * parent.width)
        height: Math.round(__currentSearchResult.rect.height * parent.height)
      }
    }
  }
}
