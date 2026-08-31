import QtQuick
import QtTest

import "../../Models/Dropdown.js" as Dropdown

TestCase {
  name: "DropdownState"

  function test_initial_state_is_closed() {
    const state = Dropdown.initial();
    compare(state.current, null);
  }

  function test_open_sets_current_and_trigger() {
    const state = Dropdown.open(Dropdown.initial(), "dashboard", {
      x: 100,
      width: 60
    });
    compare(state.current, "dashboard");
    compare(state.x, 100);
    compare(state.width, 60);
  }

  function test_toggle_same_name_closes() {
    let state = Dropdown.open(Dropdown.initial(), "dashboard", {
      x: 10,
      width: 40
    });
    state = Dropdown.toggle(state, "dashboard", {
      x: 20,
      width: 100
    });
    compare(state.current, null);
  }

  function test_toggle_other_name_switches() {
    let state = Dropdown.open(Dropdown.initial(), "dashboard", {
      x: 10,
      width: 40
    });
    state = Dropdown.toggle(state, "clock", {
      x: 300,
      width: 80
    });
    compare(state.current, "clock");
    compare(state.x, 300);
    compare(state.width, 80);
  }

  function test_close_keeps_trigger_geometry() {
    let state = Dropdown.open(Dropdown.initial(), "dashboard", {
      x: 10,
      width: 80
    });
    state = Dropdown.close(state);
    compare(state.current, null);
    compare(state.x, 10);
    compare(state.width, 80);
  }

  function test_close_from_initial_is_safe() {
    const state = Dropdown.close(Dropdown.initial());
    compare(state.current, null);
  }
}
