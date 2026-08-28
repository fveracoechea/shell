import Quickshell
import QtQuick

import "../components" as Components

Scope {
  id: root
  property string time

  Variants {
    model: Quickshell.screens

    PanelWindow {
      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      Components.Clock {
        anchors.centerIn: parent
      }
    }
  }
}
