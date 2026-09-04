pragma Singleton
import QtQuick

QtObject {
  id: root

  property color accent: "#89b4fa"
  property color muted: "#a6adc8"
  property color background: "#181825"
  property color foreground: "#cdd6f4"

  property color blue: "#89b4fa"
  property color red: "#f38ba8"
  property color green: "#a6e3a1"
  property color yellow: "#f9e2af"

  property int radius: 10

  // Derived colors
  property color surface: Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.1)
  property color borderColor: Qt.rgba(root.muted.r, root.muted.g, root.muted.b, 0.4)
}
