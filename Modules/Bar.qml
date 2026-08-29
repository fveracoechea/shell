import Quickshell
import QtQuick

import qs.Components

Scope {
  id: root
  property string time

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

      Clock {
        anchors.centerIn: parent
      }
    }
  }
}
