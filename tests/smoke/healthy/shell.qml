import QtQuick
import Quickshell

import qs.Components as Components
import qs.Modules as Modules

Scope {
  id: root

  Components.Icon {
    name: "notifications"
  }

  Components.Clock {
    instant: Modules.Time.now
  }

  Component.onCompleted: {
    console.log("SHELL_HEALTHY");
  }
}
