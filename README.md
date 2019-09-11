# Poppler QML plugin

Extremely basic plugin for rendering PDF files using [Poppler](https://poppler.freedesktop.org/) in QML apps.

Based on discontinued [poppler-qml-plugin](https://launchpad.net/poppler-qml-plugin) by Canonical (GPL v3).

## Build and install

```sh
qmake
make
make install
```

## Usage

```qml
import org.docviewer.poppler 1.0

...

Poppler {
  id: poppler
  path: "path_to_file.md"
}

ListView {
  anchors.fill: parent
  model: poppler.pages
  spacing: 16

  delegate: Image {
    cache: false
    source: modelData
    sourceSize.width: 800
  }
}

```

## Example

See example app sources in [example directory](example/).