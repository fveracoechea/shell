import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.Components
import qs.Models
import qs.Modules

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      color: Theme.background

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 40

      RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Icon {
          name: "notifications"
          variant: Icon.Variant.Filled
        }

        Clock {
          date: Time.now
        }
      }
    }
  }
}
