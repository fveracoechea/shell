import QtQuick

import qs.Components as Components
import qs.Models as Models
import "../../Models/Weather.js" as Weather

// Weather section card: current conditions on top, the seven day strip
// underneath. All inputs are injected model properties; the card never
// touches platform state.
Rectangle {
  id: root

  // Normalized current conditions from Models/Weather.parse, or null.
  property var current: null

  // Normalized daily entries, today first.
  property var daily: []

  // "loading", "ready", "unavailable", or "stale" from the Weather Feature
  // Service.
  property string status: "loading"

  readonly property bool hasCurrent: current !== null
  readonly property string conditionIcon: root.hasCurrent ? Weather.describe(root.current.code).iconKey : "cloud"

  implicitWidth: 296
  implicitHeight: content.implicitHeight + 2 * 16

  color: Models.Theme.surface0
  radius: 12

  Column {
    id: content

    anchors.fill: parent
    anchors.margins: 16
    spacing: 8

    Components.SectionLabel {
      label: "Weather"
    }

    Row {
      width: parent.width
      spacing: 8

      Components.Icon {
        anchors.verticalCenter: parent.verticalCenter
        name: root.conditionIcon
        size: 30
        color: root.hasCurrent ? Models.Theme.accent : Models.Theme.overlay0
      }

      Column {
        width: parent.width - 30 - 8
        spacing: 0

        Text {
          text: root.hasCurrent ? Weather.formatTemp(root.current.temperatureC) : "--"
          font.pixelSize: 26
          font.family: "JetBrains Mono"
          color: Models.Theme.foreground
        }

        Text {
          text: {
            if (root.hasCurrent) {
              return Weather.describe(root.current.code).label;
            }
            if (root.status === "unavailable") {
              return "Weather unavailable · Retrying every 30 minutes";
            }
            return "Waiting for data";
          }
          font.pixelSize: 12
          color: root.hasCurrent ? Models.Theme.foreground : Models.Theme.overlay0
        }

        Text {
          visible: root.hasCurrent
          text: root.hasCurrent ? `${Math.round(root.current.humidity)}% humidity · ${Math.round(root.current.windKph)} km/h wind` : ""
          font.pixelSize: 10
          color: Models.Theme.overlay0
        }
      }
    }

    Text {
      visible: root.status === "unavailable" && root.hasCurrent
      text: "Showing the last good update · Retrying every 30 minutes"
      font.pixelSize: 10
      color: Models.Theme.overlay0
    }

    Text {
      visible: root.status === "stale" && root.hasCurrent
      text: "Stale data"
      font.pixelSize: 10
      color: Models.Theme.overlay0
    }

    Row {
      id: forecast

      width: parent.width
      spacing: 4

      Repeater {
        model: root.hasCurrent ? root.daily : []

        delegate: Column {
          id: day

          required property var modelData

          width: (parent.width - 6 * 4) / 7
          spacing: 2

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Weather.dayName(day.modelData.date)
            font.pixelSize: 9
            color: Models.Theme.overlay0
          }

          Components.Icon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: Weather.describe(day.modelData.code).iconKey
            size: 16
            color: Models.Theme.subtext0
          }

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Weather.formatTemp(day.modelData.maxC)
            font.pixelSize: 10
            font.family: "JetBrains Mono"
            color: Models.Theme.subtext0
          }
        }
      }
    }
  }
}
