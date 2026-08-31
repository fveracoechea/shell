import QtQuick

import qs.Models as Models
import "../../Models/Clock.js" as ClockFormat

// The optional large clock card. Stacked hero (hour over minute, mono
// semibold) with a seconds progress line, or a horizontal hero with the
// time left and the date right in the single-column fallback. Absorbs the
// remaining width of its row.
Rectangle {
  id: root

  // The bar date at Minutes precision drives the hero text.
  property date now: new Date(NaN)

  // The precise Seconds date drives the seconds line.
  property date preciseNow: new Date(NaN)

  // Stacked hero when true, horizontal hero when false.
  property bool stacked: true

  readonly property bool validNow: !isNaN(root.now.getTime())
  readonly property var hero: ClockFormat.heroTime(root.now)
  readonly property real secondsFraction: validNow && !isNaN(preciseNow.getTime()) ? root.preciseNow.getSeconds() / 60 : 0

  implicitWidth: 240
  implicitHeight: 160

  color: Models.Theme.surface0
  radius: 12

  Column {
    id: stackedHero

    visible: root.stacked
    anchors.centerIn: parent
    spacing: 8

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.validNow ? root.hero.hour : ""
      font.pixelSize: 56
      font.family: "JetBrains Mono"
      font.weight: Font.DemiBold
      color: Models.Theme.foreground
    }

    // The meridiem aligns its baseline with the minute text through
    // sibling baseline anchoring inside a plain Item; a Row positioner
    // would only top-align items of different heights.
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      width: minuteText.width + meridiemText.width + 4
      height: minuteText.height

      Text {
        id: minuteText

        anchors.left: parent.left
        anchors.top: parent.top
        text: root.validNow ? root.hero.minute : ""
        font.pixelSize: 56
        font.family: "JetBrains Mono"
        font.weight: Font.DemiBold
        color: Models.Theme.foreground
      }

      Text {
        id: meridiemText

        anchors.baseline: minuteText.baseline
        anchors.left: minuteText.right
        anchors.leftMargin: 4
        text: root.hero.meridiem
        font.pixelSize: 14
        color: Models.Theme.subtext0
      }
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 160
      height: 2
      radius: 1
      color: Models.Theme.foreground
      opacity: 0.12

      Rectangle {
        width: parent.width * root.secondsFraction
        height: parent.height
        radius: 1
        color: Models.Theme.accent

        Behavior on width {
          NumberAnimation {
            duration: Models.Motion.reduce ? 0 : 1000
          }
        }
      }
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: ClockFormat.formatLongDate(root.now)
      font.pixelSize: 12
      color: Models.Theme.subtext0
    }
  }

  Row {
    visible: !root.stacked
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.right: parent.right
    anchors.rightMargin: 16
    spacing: 16

    Text {
      text: root.validNow ? ClockFormat.formatTime(root.now) : ""
      font.pixelSize: 40
      font.family: "JetBrains Mono"
      color: Models.Theme.foreground
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.validNow ? ClockFormat.formatLongDate(root.now) : ""
      font.pixelSize: 12
      color: Models.Theme.subtext0
    }
  }
}
