import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.Components as Components
import qs.Models as Models
import qs.Modules as Modules

// The bar surface for one screen: a top-anchored strip with the clock
// trigger. Lifetime and exclusive zone are owned by the Surface Manager;
// the trigger only reports clicks with its geometry.
PanelWindow {
  id: root

  required property var manager

  readonly property int barHeight: manager.barHeight

  screen: manager.screen
  color: Models.Theme.background
  implicitHeight: root.barHeight
  exclusiveZone: root.barHeight
  WlrLayershell.namespace: "shell-bar"

  anchors {
    top: true
    left: true
    right: true
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 1
    color: Models.Theme.borderColor
  }

  RowLayout {
    id: clockTrigger

    anchors.centerIn: parent
    spacing: 6

    Components.Icon {
      name: "notifications"
      size: 20
      variant: Components.Icon.Variant.Filled
    }

    Components.Clock {
      instant: Modules.Time.now
    }
  }

  // The trigger affordance: an accent underline while the dropdown is open.
  Rectangle {
    anchors.horizontalCenter: clockTrigger.horizontalCenter
    anchors.bottom: root.contentItem.bottom
    width: clockTrigger.width
    height: 2
    radius: 1
    color: Models.Theme.accent
    visible: root.manager.current !== null
  }

  MouseArea {
    anchors.fill: clockTrigger
    cursorShape: Qt.PointingHandCursor
    onClicked: root.manager.toggle("dashboard", clockTrigger)
  }
}
