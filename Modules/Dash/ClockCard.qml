import QtQuick

import qs.Models as Models
import "../../Models/Clock.js" as ClockFormat

// Optional large clock. The card stays visually still while the surrounding
// dropdown morphs, with only the seconds indicator updating in place.
Rectangle {
  id: root

  property date now: new Date(NaN)
  property date preciseNow: new Date(NaN)
  property bool stacked: true

  readonly property bool validNow: !isNaN(now.getTime())
  readonly property var hero: ClockFormat.heroTime(now)
  readonly property real secondsFraction: validNow && !isNaN(preciseNow.getTime()) ? preciseNow.getSeconds() / 60 : 0

  implicitWidth: 240
  implicitHeight: stacked ? 180 : 118

  color: Models.Theme.surface
  radius: Models.Theme.radius

  Column {
    anchors.centerIn: parent
    width: Math.min(parent.width - 32, 280)
    spacing: root.stacked ? 8 : 4

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 6

      Text {
        id: timeText

        text: root.validNow ? `${root.hero.hour}:${root.hero.minute}` : ""
        font.pixelSize: root.stacked ? 64 : 48
        font.family: "JetBrains Mono"
        font.weight: Font.DemiBold
        color: Models.Theme.foreground
      }

      Text {
        anchors.baseline: timeText.baseline
        text: root.hero.meridiem
        font.pixelSize: 13
        font.weight: Font.Medium
        color: Models.Theme.muted
      }
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.validNow ? Qt.formatDate(root.now, "dddd") : ""
      font.pixelSize: root.stacked ? 18 : 14
      font.weight: Font.Medium
      color: Models.Theme.foreground
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.validNow ? Qt.formatDate(root.now, "MMMM d, yyyy") : ""
      font.pixelSize: 12
      color: Models.Theme.muted
    }

    Rectangle {
      width: parent.width
      height: 3
      radius: 2
      color: Models.Theme.muted

      Rectangle {
        width: parent.width * root.secondsFraction
        height: parent.height
        radius: 2
        color: Models.Theme.accent

        Behavior on width {
          NumberAnimation {
            duration: Models.Motion.reduce ? 0 : 1000
          }
        }
      }
    }
  }
}
