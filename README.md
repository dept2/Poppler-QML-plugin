# Poppler QML plugin

Extremely basic plugin for rendering PDF files using [Poppler](https://poppler.freedesktop.org/) in QML apps.

Based on discontinued [poppler-qml-plugin](https://launchpad.net/poppler-qml-plugin) by Canonical (GPL v3).

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

# Usage

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
