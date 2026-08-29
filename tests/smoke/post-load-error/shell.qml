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
    root.raiseReferenceError();
  }

  /**
   * Deliberately raises a ReferenceError after the health sentinel so the
   * smoke harness can observe a source diagnostic despite a clean exit.
   *
   * @returns {void}
   */
  function raiseReferenceError() {
    return missingSymbol();
  }
}
