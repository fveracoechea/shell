pragma ComponentBehavior: Bound

import QtQuick

import qs.Components as Components
import qs.Models as Models
import "../../Models/Weather.js" as Weather

// Current conditions and a compact seven-day Open-Meteo forecast.
Rectangle {
  id: root

  property var current: null
  property var daily: []
  property string status: "loading"

  readonly property bool hasCurrent: current !== null
  readonly property var forecastDays: Array.isArray(daily) ? daily.slice(0, 7) : []
  readonly property string conditionIcon: hasCurrent ? Weather.describe(current.code).iconKey : "cloud"

  implicitWidth: 296
  implicitHeight: content.implicitHeight + 32

  color: Models.Theme.surface
  radius: Models.Theme.radius

  Column {
    id: content

    anchors.fill: parent
    anchors.margins: 16
    spacing: 10

    Components.SectionLabel {
      label: "Weather"
    }

    Item {
      width: parent.width
      height: 64

      Components.Icon {
        id: currentIcon

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        name: root.conditionIcon
        size: 42
        color: root.hasCurrent ? Models.Theme.accent : Models.Theme.muted
      }

      Text {
        id: temperature

        anchors.left: currentIcon.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.hasCurrent ? Weather.formatTemp(root.current.temperatureC) : "--"
        font.pixelSize: 38
        font.family: "JetBrains Mono"
        font.weight: Font.DemiBold
        color: Models.Theme.foreground
      }

      Column {
        anchors.left: temperature.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
          width: parent.width
          text: {
            if (root.hasCurrent) {
              return Weather.describe(root.current.code).label;
            }
            return root.status === "unavailable" ? "Weather unavailable" : "Waiting for weather";
          }
          font.pixelSize: 12
          elide: Text.ElideRight
          color: Models.Theme.foreground
        }

        Text {
          width: parent.width
          text: root.hasCurrent ? `Feels ${Weather.formatTemp(root.current.apparentC)}` : "Retrying automatically"
          font.pixelSize: 10
          elide: Text.ElideRight
          color: Models.Theme.muted
        }
      }
    }

    Item {
      width: parent.width
      height: 18
      visible: root.hasCurrent

      Text {
        anchors.left: parent.left
        text: root.hasCurrent ? `${Math.round(root.current.humidity)}% humidity` : ""
        font.pixelSize: 11
        color: Models.Theme.foreground
      }

      Text {
        anchors.right: parent.right
        text: root.hasCurrent ? `${Math.round(root.current.windKph)} km/h wind` : ""
        font.pixelSize: 11
        color: Models.Theme.foreground
      }
    }

    Column {
      width: parent.width
      spacing: 4

      Repeater {
        model: root.forecastDays

        delegate: Item {
          id: day

          required property int index
          required property var modelData

          width: parent.width
          height: 22

          Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            text: day.index === 0 ? "Today" : Weather.dayName(day.modelData.date)
            font.pixelSize: 11
            font.weight: day.index === 0 ? Font.DemiBold : Font.Normal
            color: day.index === 0 ? Models.Theme.accent : Models.Theme.foreground
          }

          Components.Icon {
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            name: Weather.describe(day.modelData.code).iconKey
            size: 17
            color: Models.Theme.foreground
          }

          Text {
            anchors.right: rain.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: `${Weather.formatTemp(day.modelData.maxC)} / ${Weather.formatTemp(day.modelData.minC)}`
            font.pixelSize: 11
            font.family: "JetBrains Mono"
            color: Models.Theme.foreground
          }

          Text {
            id: rain

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            text: `${Math.round(day.modelData.precipProbMax)}%`
            font.pixelSize: 10
            horizontalAlignment: Text.AlignRight
            color: day.modelData.precipProbMax >= 50 ? Models.Theme.blue : Models.Theme.muted
          }
        }
      }
    }

    Text {
      width: parent.width
      visible: (root.status === "unavailable" || root.status === "stale") && root.hasCurrent
      text: root.status === "stale" ? "Forecast update is delayed" : "Showing the last update while retrying"
      font.pixelSize: 10
      wrapMode: Text.WordWrap
      color: Models.Theme.muted
    }
  }
}
