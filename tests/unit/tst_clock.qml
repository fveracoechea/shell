import QtQuick
import QtTest

import qs.Components as Components

TestCase {
  name: "ClockView"

  Components.Clock {
    id: clock
  }

  function test_displays_injected_date() {
    clock.instant = new Date(2026, 7, 29, 15, 5);
    compare(clock.text, "3:05 PM - Saturday, August 29");
  }

  function test_updates_text_when_date_changes() {
    clock.instant = new Date(2026, 0, 1, 0, 0);
    compare(clock.text, "12:00 AM - Thursday, January 01");
  }
}
