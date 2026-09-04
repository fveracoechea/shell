import QtQuick

import qs.Models as Models

// One performance meter row: label left, value right, thin bar underneath.
// The bar fill uses the accent, warning yellow from 70 percent, and red
// from 90 percent.
Column {
  id: root

  // The meter label, for example "CPU".
  property string label: ""

  // Pre-formatted value text, for example "43%".
  property string value: "--"

  // Usage fraction in [0, 1]; negative means "no sample yet".
  property real fraction: -1

  // Some measurements, such as CPU temperature, remain useful while the
  // usage fraction is still waiting for a second sample.
  property bool valueKnown: known

  readonly property real clamped: Math.min(1, Math.max(0, fraction))
  readonly property bool known: fraction >= 0
  readonly property color fillColor: fraction >= 0.9 ? Models.Theme.red : fraction >= 0.7 ? Models.Theme.yellow : Models.Theme.accent

  spacing: 4

  Item {
    width: parent.width
    height: 14

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: root.label
      font.pixelSize: 12
      color: Models.Theme.muted
    }

    Text {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: root.valueKnown ? root.value : "--"
      font.pixelSize: 12
      font.family: "JetBrains Mono"
      color: root.valueKnown ? Models.Theme.foreground : Models.Theme.muted
    }
  }

  Rectangle {
    width: parent.width
    height: 6
    radius: 3
    color: Models.Theme.foreground
    opacity: 0.12

    Rectangle {
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      width: root.known ? parent.width * root.clamped : 0
      radius: 3
      color: root.fillColor

      Behavior on width {
        NumberAnimation {
          duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Models.Motion.curves.effects
        }
      }

      Behavior on color {
        ColorAnimation {
          duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
        }
      }
    }
  }
}
