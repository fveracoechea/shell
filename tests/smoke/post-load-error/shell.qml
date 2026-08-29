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
