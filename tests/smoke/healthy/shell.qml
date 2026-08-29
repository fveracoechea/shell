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
    date: Modules.Time.now
  }

  Component.onCompleted: {
    console.log("SHELL_HEALTHY");
  }
}
