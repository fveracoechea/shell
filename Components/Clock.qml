import QtQuick
import QtQuick.Layouts

import qs.Modules

RowLayout {
  spacing: 6

  Icon {
    name: "notifications"
    variant: Icon.Variant.Filled
  }

  Text {
    text: Time.time
    font.pixelSize: 18
    color: Theme.foreground
  }
}
