pragma Singleton
import QtQuick

QtObject {
  id: root

  property color accent: "#89b4fa"
  property color muted: "#585b70"
  property color background: "#1e1e2e"
  property color foreground: "#cdd6f4"

  property color blue: "#89b4fa"
  property color red: "#f38ba8"
  property color green: "#a6e3a1"
  property color yellow: "#f9e2af"

  // Surface roles for layered compositions: cards sit on panels, panels on
  // the screen. surface0 fills cards on a background panel, surface1 draws
  // the panel border, overlay0 and subtext0 are muted text roles.
  property color surface0: "#313244"
  property color surface1: "#45475a"
  property color overlay0: "#6c7086"
  property color subtext0: "#a6adc8"
}
