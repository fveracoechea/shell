import QtQuick
import Quickshell
import Quickshell.Wayland

import "../Models/DropdownGeometry.js" as DropdownGeometry
import qs.Models as Models
import qs.Modules as Modules
import qs.Modules.Dash as Dash

// The dropdown surface for one screen: a fullscreen transparent layer
// window that keeps input for exactly the animated panel area. Lifetime,
// mask, input, placement, and open/close animation policy live here; the
// dashboard is pure composition injected by the Surface Manager.
//
// Input mask: the fullscreen root region keeps input for the whole window
// so the dismiss layer catches clicks anywhere outside the box; the bar
// strip is subtracted so bar clicks pass through to the bar surface
// underneath, and the box region is combined so the panel consumes its own
// clicks.
PanelWindow {
  id: root

  required property var manager

  readonly property bool open: manager.current !== null
  readonly property int barHeight: manager.barHeight
  readonly property int panelWidth: Math.min(752, Math.max(dash.implicitWidth, 720), width - 2 * manager.screenMargin)
  readonly property int panelHeight: Math.min(dash.implicitHeight, height - barHeight - 3 * manager.screenMargin)
  readonly property int boxX: DropdownGeometry.panelX({
    x: manager.dropdownState.x,
    width: manager.dropdownState.width
  }, panelWidth, width, manager.screenMargin)
  readonly property var frame: DropdownGeometry.morphFrame({
    x: manager.dropdownState.x,
    width: manager.dropdownState.width
  }, {
    x: boxX,
    y: barHeight + manager.screenMargin,
    width: panelWidth,
    height: panelHeight,
    radius: Models.Theme.radius
  }, barHeight, reveal)
  property real reveal: open ? 1 : 0

  onOpenChanged: {
    if (open) {
      box.forceActiveFocus();
    }
  }

  screen: manager.screen
  color: "transparent"

  anchors {
    top: true
    left: true
    right: true
    bottom: true
  }

  WlrLayershell.namespace: "shell-dropdown"
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

  visible: open || reveal > 0

  mask: Region {
    item: dismissArea

    Region {
      item: box
      radius: box.radius
      intersection: Intersection.Combine
    }

    Region {
      x: 0
      y: 0
      width: root.width
      height: root.barHeight
      intersection: Intersection.Subtract
    }
  }

  MouseArea {
    id: dismissArea

    anchors.fill: parent
    z: 0
    onClicked: root.manager.close()
  }

  Rectangle {
    id: box

    x: root.frame.x
    y: root.frame.y
    width: root.frame.width
    height: root.frame.height
    radius: root.frame.radius
    color: Models.Theme.background
    border.width: 1
    border.color: Models.Theme.borderColor
    clip: true
    visible: root.reveal > 0
    focus: root.open
    z: 1

    Keys.onEscapePressed: root.manager.close()

    // Consumes clicks on the panel itself so they never reach the dismiss
    // layer; unhandled clicks inside the Flickable fall through to here.
    MouseArea {
      anchors.fill: parent
      z: -1
    }

    Flickable {
      id: scroll

      x: (box.width - width) / 2
      width: root.panelWidth
      height: root.panelHeight
      contentWidth: width
      contentHeight: dash.implicitHeight
      interactive: contentHeight > height
      boundsBehavior: Flickable.StopAtBounds
      z: 1

      Dash.Dashboard {
        id: dash

        width: scroll.width
        now: Modules.Time.now
        preciseNow: Modules.Time.preciseNow
        weatherStatus: Modules.Weather.status
        weatherCurrent: Modules.Weather.current
        weatherDaily: Modules.Weather.daily
        distro: Modules.System.distro
        hostname: Modules.System.hostname
        kernel: Modules.System.kernel
        desktop: Modules.System.desktop
        compositorVersion: Modules.System.compositorVersion
        cpuUsage: Modules.System.cpuUsage
        cpuTempC: Modules.System.cpuTempC
        memoryUsed: Modules.System.memoryUsed
        memoryUsedKb: Modules.System.memoryUsedKb
        memoryTotalKb: Modules.System.memoryTotalKb
        diskUsed: Modules.System.diskUsed
        diskUsedKb: Modules.System.diskUsedKb
        diskTotalKb: Modules.System.diskTotalKb
        uptimeSeconds: Modules.System.uptimeSeconds
        userName: Modules.Identity.name
        userFacePath: Modules.Identity.facePath
      }
    }
  }

  Behavior on reveal {
    NumberAnimation {
      duration: Models.Motion.reduce ? 0 : root.open ? Models.Motion.duration.spatialOpen : Models.Motion.duration.spatialClose
      easing.type: Easing.BezierSpline
      easing.bezierCurve: root.open ? Models.Motion.curves.emphasizedDecel : Models.Motion.curves.emphasizedAccel
    }
  }
}
