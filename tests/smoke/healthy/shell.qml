import QtQuick
import Quickshell

import qs.Components
import qs.Models
import qs.Modules

Scope {
  id: root

  Icon {
    name: "notifications"
  }

  Clock {
    date: Time.now
  }

  Component.onCompleted: {
    console.log("SHELL_HEALTHY");
  }
}
