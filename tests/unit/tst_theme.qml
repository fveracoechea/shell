import QtQuick
import QtTest

import qs.Models as Models

TestCase {
  name: "Theme"

  function test_loads_pure_singleton() {
    verify(Qt.isQtObject(Models.Theme));
    verify(Models.Theme.accent !== undefined);
    verify(Models.Theme.background !== undefined);
  }
}
