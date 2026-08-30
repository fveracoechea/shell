import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.Components as Components
import qs.Models as Models
import qs.Modules as Modules

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData

      screen: modelData
      property bool open: false

      color: 'transparent'
      implicitHeight: 284
      exclusiveZone: 40

      anchors {
        top: true
        left: true
        right: true
      }

      mask: Region {
        item: strip
        Region {
          item: popout
        }
      }

      Item {
        id: strip
        width: parent.width
        height: 40

        Rectangle {
          anchors.fill: parent
          color: Models.Theme.background
        }

        MouseArea {
          anchors.fill: parent
          onClicked: bar.open = !bar.open
        }

        RowLayout {
          anchors.centerIn: parent
          spacing: 6

          Components.Icon {
            name: "notifications"
            variant: Components.Icon.Variant.Filled
          }

          Components.Clock {
            instant: Modules.Time.now
          }
        }
      }

      Item {
        id: popout
        x: (bar.width - width) / 2
        y: 44
        width: 320
        height: bar.open ? 240 : 0
        clip: true
        visible: height > 0

        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          height: 240
          radius: 12
          color: Models.Theme.background
          border.width: 1
          border.color: Models.Theme.muted

          Text {
            anchors.centerIn: parent
            color: Models.Theme.foreground
            text: "Popout content"
          }
        }

        Behavior on height {
          NumberAnimation {
            duration: 500
            easing.type: Easing.OutExpo
          }
        }
      }
    }
  }
}
