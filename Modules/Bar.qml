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
      color: Models.Theme.background

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40

      RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Components.Icon {
          name: "notifications"
          variant: Components.Icon.Variant.Filled
        }

        Components.Clock {
          date: Modules.Time.now
        }
      }
    }
  }
}
