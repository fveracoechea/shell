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

  function test_morph_starts_at_bar_trigger() {
    const frame = DropdownGeometry.morphFrame({
      x: 460,
      width: 92
    }, {
      x: 124,
      y: 48,
      width: 752,
      height: 680,
      radius: 16
    }, 40, 0);
    compare(frame.x, 460);
    compare(frame.y, 0);
    compare(frame.width, 92);
    compare(frame.height, 40);
    compare(frame.radius, 20);
  }

  function test_morph_ends_at_panel() {
    const frame = DropdownGeometry.morphFrame({
      x: 460,
      width: 92
    }, {
      x: 124,
      y: 48,
      width: 752,
      height: 680,
      radius: 16
    }, 40, 1);
    compare(frame.x, 124);
    compare(frame.y, 48);
    compare(frame.width, 752);
    compare(frame.height, 680);
    compare(frame.radius, 16);
  }

  function test_morph_clamps_interrupted_progress() {
    const panel = {
      x: 124,
      y: 48,
      width: 752,
      height: 680,
      radius: 16
    };
    compare(DropdownGeometry.morphFrame({
      x: 460,
      width: 92
    }, panel, 40, -1).x, 460);
    compare(DropdownGeometry.morphFrame({
      x: 460,
      width: 92
    }, panel, 40, 2).x, 124);
  }
}
