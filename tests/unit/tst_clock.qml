import QtQuick
import QtTest

import qs.Components as Components

TestCase {
  name: "ClockView"

  Components.Clock {
    id: clock
  }

  /**
   * Verifies the view renders the formatter's display for an injected date.
   *
   * @returns {void}
   */
  function test_displays_injected_date() {
    clock.date = new Date(2026, 7, 29, 15, 5);
    compare(clock.text, "3:05 PM - Saturday, August 29");
  }

  /**
   * Verifies the text binding reacts when the injected date changes.
   *
   * @returns {void}
   */
  function test_updates_text_when_date_changes() {
    clock.date = new Date(2026, 0, 1, 0, 0);
    compare(clock.text, "12:00 AM - Thursday, January 01");
  }
}
