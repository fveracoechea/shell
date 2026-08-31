import QtQuick
import QtTest

import "../../Models/DropdownGeometry.js" as DropdownGeometry

TestCase {
  name: "DropdownGeometry"

  function test_centers_on_trigger() {
    const x = DropdownGeometry.panelX({
      x: 400,
      width: 80
    }, 600, 1920, 16);
    compare(x, 140);
  }

  function test_clamps_to_left_margin() {
    const x = DropdownGeometry.panelX({
      x: 0,
      width: 60
    }, 600, 1000, 16);
    compare(x, 16);
  }

  function test_clamps_to_right_edge() {
    const x = DropdownGeometry.panelX({
      x: 990,
      width: 30
    }, 600, 1000, 16);
    compare(x, 384);
  }

  function test_panel_wider_than_bar_uses_margin() {
    const x = DropdownGeometry.panelX({
      x: 40,
      width: 40
    }, 1200, 1000, 16);
    compare(x, 16);
  }

  function test_tiny_bar_returns_margin() {
    const x = DropdownGeometry.panelX({
      x: 10,
      width: 20
    }, 600, 0, 8);
    compare(x, 8);
  }
}
