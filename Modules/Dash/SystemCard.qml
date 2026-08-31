import QtQuick

import qs.Components as Components
import qs.Models as Models
import "../../Models/SystemInfo.js" as SystemInfo

// System identity and performance section card: user and host identity on
// top, one meter per resource underneath. All inputs are injected model
// properties; the card never touches platform state.
Rectangle {
  id: root

  // Identity strings, "" when unknown; the greeting row hides itself when
  // both the user name and the hostname are missing.
  property string distro: ""
  property string hostname: ""
  property string kernel: ""
  property string desktop: ""

  // Performance values; -1 means "no sample yet".
  property real cpuUsage: -1
  property real cpuTempC: -1
  property real memoryUsed: -1
  property real diskUsed: -1
  property int uptimeSeconds: -1

  // User identity; empty strings hide the identity row.
  property string userName: ""
  property string userFacePath: ""

  readonly property string identityLine: [distro, desktop, kernel !== "" ? "Linux " + kernel : ""].filter(part => part !== "").join(" · ")

  implicitWidth: 352
  implicitHeight: content.implicitHeight + 2 * 16

  color: Models.Theme.surface0
  radius: 12

  Column {
    id: content

    anchors.fill: parent
    anchors.margins: 16
    spacing: 8

    Components.SectionLabel {
      label: "System"
    }

    Item {
      width: parent.width
      height: 20
      visible: root.userName !== "" || root.hostname !== ""

      Rectangle {
        id: face

        visible: root.userFacePath !== ""
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20
        radius: 10
        color: Models.Theme.surface1
        clip: true

        Image {
          anchors.fill: parent
          source: root.userFacePath === "" ? "" : "file://" + root.userFacePath
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
        }
      }

      Text {
        anchors.left: parent.left
        anchors.leftMargin: face.visible ? 28 : 0
        anchors.verticalCenter: parent.verticalCenter
        text: root.userName !== "" && root.hostname !== "" ? `${root.userName}@${root.hostname}` : root.userName === "" ? root.hostname : root.userName
        font.pixelSize: 12
        color: Models.Theme.foreground
      }

      Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: SystemInfo.describeUptime(root.uptimeSeconds)
        font.pixelSize: 12
        font.family: "JetBrains Mono"
        color: Models.Theme.subtext0
      }
    }

    Text {
      width: parent.width
      visible: root.distro !== "" || root.desktop !== "" || root.kernel !== ""
      text: root.identityLine
      font.pixelSize: 12
      elide: Text.ElideRight
      color: Models.Theme.subtext0
    }

    Components.Meter {
      width: parent.width
      label: "CPU"
      fraction: root.cpuUsage
      value: root.cpuUsage >= 0 ? `${SystemInfo.formatPercent(root.cpuUsage)}${root.cpuTempC >= 0 ? " · " + SystemInfo.formatTempC(root.cpuTempC) : ""}` : "--"
    }

    Components.Meter {
      width: parent.width
      label: "Memory"
      fraction: root.memoryUsed
      value: SystemInfo.formatPercent(root.memoryUsed)
    }

    Components.Meter {
      width: parent.width
      label: "Disk"
      fraction: root.diskUsed
      value: SystemInfo.formatPercent(root.diskUsed)
    }
  }
}
