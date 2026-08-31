pragma Singleton

import QtQuick
import Quickshell

import "../Models/Identity.js" as IdentityModel

// User identity Feature Service. Reads the login name and the optional
// face image path once from the session environment; both stay "" when
// absent, and views hide the affected sections instead of guessing.
Singleton {
  id: root

  // Login display name; "" when the environment provides none.
  readonly property string name: IdentityModel.displayName(Quickshell.env("USER"), Quickshell.env("LOGNAME"))

  // Path to the user's ~/.face image; "" when HOME is unset.
  readonly property string facePath: home === "" ? "" : home + "/.face"

  readonly property string home: {
    const value = Quickshell.env("HOME");
    return typeof value === "string" ? value : "";
  }
}
