import QtQuick

import qs.Components as Components
import qs.Models as Models
import "../../Models/SystemInfo.js" as SystemInfo

// Fastfetch-like identity and live performance. Platform state is injected
// by the dashboard composition; this card only formats and presents it.
Rectangle {
  id: root

  property string distro: ""
  property string hostname: ""
  property string kernel: ""
  property string desktop: ""
  property string compositorVersion: ""
  property real cpuUsage: -1
  property real cpuTempC: -1
  property real memoryUsed: -1
  property real memoryUsedKb: -1
  property real memoryTotalKb: -1
  property real diskUsed: -1
  property real diskUsedKb: -1
  property real diskTotalKb: -1
  property int uptimeSeconds: -1
  property string userName: ""
  property string userFacePath: ""

  implicitWidth: 352
  implicitHeight: content.implicitHeight + 32

  color: Models.Theme.surface
  radius: Models.Theme.radius

  Column {
    id: content

    anchors.fill: parent
    anchors.margins: 16
    spacing: 10

    Components.SectionLabel {
      label: "System"
    }

    Item {
      width: parent.width
      height: 76

      Rectangle {
        id: face

        objectName: "profilePicture"

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 72
        height: 72
        radius: 36
        color: Models.Theme.surface
        clip: true

        Components.Icon {
          anchors.centerIn: parent
          name: "person"
          size: 34
          color: Models.Theme.foreground
        }

        Image {
          id: faceImage

          anchors.fill: parent
          source: root.userFacePath === "" ? "" : "file://" + root.userFacePath
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          visible: status === Image.Ready
        }
      }

      Column {
        anchors.left: face.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Text {
          width: parent.width
          text: root.userName === "" ? "User" : root.userName
          font.pixelSize: 18
          font.weight: Font.DemiBold
          elide: Text.ElideRight
          color: Models.Theme.foreground
        }

        Text {
          width: parent.width
          text: root.hostname
          visible: text !== ""
          font.pixelSize: 11
          font.family: "JetBrains Mono"
          elide: Text.ElideRight
          color: Models.Theme.muted
        }

        Text {
          width: parent.width
          text: "Up " + SystemInfo.describeUptime(root.uptimeSeconds)
          font.pixelSize: 12
          color: Models.Theme.foreground
        }
      }
    }

    Column {
      width: parent.width
      spacing: 5

      DetailRow {
        width: parent.width
        label: "OS"
        value: root.distro
      }

      DetailRow {
        width: parent.width
        label: "Kernel"
        value: root.kernel === "" ? "" : "Linux " + root.kernel
      }

      DetailRow {
        width: parent.width
        label: "Session"
        value: root.desktop + (root.compositorVersion === "" ? "" : " " + root.compositorVersion)
      }
    }

    Components.Meter {
      width: parent.width
      label: "CPU"
      fraction: root.cpuUsage
      valueKnown: root.cpuUsage >= 0 || root.cpuTempC >= 0
      value: root.cpuUsage >= 0 ? SystemInfo.formatPercent(root.cpuUsage) + (root.cpuTempC < 0 ? "" : " · " + SystemInfo.formatTempC(root.cpuTempC)) : SystemInfo.formatTempC(root.cpuTempC)
    }

    Components.Meter {
      width: parent.width
      label: "Memory"
      fraction: root.memoryUsed
      value: SystemInfo.formatKibPair(root.memoryUsedKb, root.memoryTotalKb) + (root.memoryUsed < 0 ? "" : " · " + SystemInfo.formatPercent(root.memoryUsed))
    }

    Components.Meter {
      width: parent.width
      label: "Disk"
      fraction: root.diskUsed
      value: SystemInfo.formatKibPair(root.diskUsedKb, root.diskTotalKb) + (root.diskUsed < 0 ? "" : " · " + SystemInfo.formatPercent(root.diskUsed))
    }
  }

  component DetailRow: Item {
    required property string label
    required property string value

    height: 16
    visible: value !== ""

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: parent.label
      font.pixelSize: 11
      color: Models.Theme.muted
    }

    Text {
      anchors.left: parent.left
      anchors.leftMargin: 72
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: parent.value
      font.pixelSize: 11
      font.family: "JetBrains Mono"
      horizontalAlignment: Text.AlignRight
      elide: Text.ElideLeft
      color: Models.Theme.foreground
    }
  }
}
