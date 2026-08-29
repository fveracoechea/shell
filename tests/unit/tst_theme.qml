import QtQuick
import QtTest

import qs.Models

TestCase {
  name: "Theme"

  /**
   * Verifies the Theme singleton loads as a pure QtQuick object. Adding a
   * Quickshell dependency to the module makes this file fail to load.
   *
   * @returns {void}
   */
  function test_loads_pure_singleton() {
    verify(Qt.isQtObject(Theme));
    verify(Theme.accent !== undefined);
    verify(Theme.background !== undefined);
  }
}
