import QtQuick

import qs.Models as Models

Text {
  id: root

  // The section label text; rendered as small caps with letter spacing.
  property string label: ""

  font.pixelSize: 10
  font.letterSpacing: 1.2
  font.capitalization: Font.AllUppercase
  color: Models.Theme.muted
  text: root.label
}
