import QtQuick
import Quickshell

import qs.Models as Models
import "../Models/Dropdown.js" as DropdownState

// Surface Manager for one screen. Owns the lifetime of every surface on
// that screen: the bar surface and the dropdown surface. It holds the
// dropdown state (normalized through Models/Dropdown.js), wires platform
// state from the Feature Services into the dashboard composition, and
// wires the reduced-motion flag from the session environment. Bar widgets
// never touch windows, masks, or animation; they call open, close, or
// toggle with their trigger item and read current.
Scope {
  id: root

  property ShellScreen screen
  property int barHeight: 40

  // Distance between the bar bottom edge and the dropdown top edge, and
  // the minimum distance between panel and screen edges.
  property int screenMargin: 8

  property var dropdownState: DropdownState.initial()

  // The open dropdown's name, or null when closed. The reuse contract for
  // bar widgets: open(name, triggerRect), close(), toggle(name,
  // triggerRect), and readonly current.
  readonly property var current: root.dropdownState.current

  function open(name: string, triggerItem: Item): void {
    root.dropdownState = DropdownState.open(root.dropdownState, name, root.triggerRect(triggerItem));
  }

  function close(): void {
    root.dropdownState = DropdownState.close(root.dropdownState);
  }

  function toggle(name: string, triggerItem: Item): void {
    root.dropdownState = DropdownState.toggle(root.dropdownState, name, root.triggerRect(triggerItem));
  }

  // Maps a trigger item into the bar-local trigger rectangle the pure
  // state and geometry models expect. The mapToItem call must name the
  // origin explicitly: the single-argument form is ambiguous for the
  // engine and throws at runtime (pinned by tests/unit/tst_trigger_map.qml).
  function triggerRect(triggerItem: Item): var {
    const origin = triggerItem.mapToItem(barSurface.contentItem, 0, 0);
    return {
      x: origin.x,
      width: triggerItem.width
    };
  }

  Component.onCompleted: {
    Models.Motion.reduce = Quickshell.env("SHELL_REDUCED_MOTION") === "1";
  }

  BarSurface {
    id: barSurface

    manager: root
  }

  DropdownSurface {
    id: dropdownSurface

    manager: root
  }
}
