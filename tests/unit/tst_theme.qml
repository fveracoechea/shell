import QtQuick
import QtTest

import qs.Models as Models

TestCase {
  name: "Theme"

  /**
   * Verifies the Theme singleton loads as a pure QtQuick object. Adding a
   * Quickshell dependency to the module makes this file fail to load.
   *
   * @returns {void}
   */
  function test_loads_pure_singleton() {
    verify(Qt.isQtObject(Models.Theme));
    verify(Models.Theme.accent !== undefined);
    verify(Models.Theme.background !== undefined);
  }
}
