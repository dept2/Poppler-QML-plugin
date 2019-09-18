# Poppler QML plugin

Extremely basic plugin for rendering PDF files using [Poppler](https://poppler.freedesktop.org/) in QML apps.

Supported features:
* Rendering PDF pages in any resolution (controlled by `Image` item `sourceSize` property)
* Parsing document links
* Document search

Based on discontinued [poppler-qml-plugin](https://launchpad.net/poppler-qml-plugin) by Canonical (GPL v3).

![Example application screenshot](example/screenshot.png?raw=true)

## Requirements
* Qt 5.11+
* Poppler-Qt5 0.31+
* Qt Quick Controls 2 (only for an example app)

## Build and install

```sh
qmake
make
make install
```

## Example

See example app sources in [example directory](example/).

## Debugging

Set `POPPLERPLUGIN_DEBUG` environment variable to `1` before starting application.

---
# Using `PDFView` QML component

`PDFView` is pure QML component, utilizing `Poppler` native component from this plugin.
It serves as a good start when you just need to display PDF document.

If it doesn't suit your purposes very well, take a look at it source and implement the
view more suiting your target functionality.

This component is an extended ListView (with custom delegate and some other logic inside),
so you can simply add scroll bar or customize page spacing from your application code.

```qml
import org.docviewer.poppler 1.0

...

PDFView {
  anchors.fill: parent
  path: "path_to_file.pdf"
}
```

## Properties

### string path

Local file path to open.

### bool loaded

### real zoom

Zoom level. Defaults to `1.0`, at this component show document at 72 dpi.

### int count

Number of pages in opened document

### int currentPage

Number of page currently shown in a center of viewport, starting with 0.

### color searchHighlightColor

Color of found search term highlight. Defaults to `Qt.rgba(1, 1, .2, .4)`.

## Methods

### search(string text)

Starts search for a passed substring. When found, scrolls view to show the string found. Repeating calls to this method passing the same string will result in moving to next occurance of the text.

## Signals

### error(string errorMessage)

Sent when there was a problem opening a document

### searchNotFound

Sent when recently started search haven't found any occurences of string requested.

### searchRestartedFromTheBeggining

Sent when search reached the end of a document and was started from the beginning of a document.

---

# Using `Poppler` object

## Opening PDF document


```qml
import org.docviewer.poppler 1.0

...

Poppler {
  id: poppler
  path: "path_to_file.pdf"
}

ListView {
  anchors.fill: parent
  model: poppler.pages
  delegate: Image {
    cache: false
    fillMode: Image.Pad

    source: modelData.image
    sourceSize.width: modelData.size.width
    sourceSize.height: modelData.size.height

    width: sourceSize.width
    height: sourceSize.height
  }
}

```

## Properties

### string path

Local file path to open.

### bool loaded

### array pages

List of document pages.

Each page contains several properties

* `image` - url of image to be used in Image QML element. Page image will be rendered by image provider based on Image `sourceSize` property
* `size` - document page size in points (i.e. 1/72th of inch). Could be used to determine Image element size before asyncronous rendering is finished
* `links` - array of page links
  * `rect` - active link rectangle as a proportion of page size (width being .5 means 50% of page width etc.)
  * `destination` - link destination
    * `page` - page index
    * `top` - top coordinate of link destination (relative to page size, same as rect property)
    * `left` - left coordinate of link destination (relative to page size)

## Methods

### array[rect] search(int page, string text)

Returns list of text highlight rectangles for the `page`. May return empty array.

## Signals

### error(string errorMessage)

Sent when there was a problem opening a document.
