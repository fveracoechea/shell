import QtQuick
import QtTest

import "../../Models/Clock.js" as ClockFormat

TestCase {
  name: "ClockFormat"

  function test_format_data() {
    return [
      {
        tag: "late afternoon",
        date: new Date(2026, 7, 29, 15, 5),
        expected: "3:05 PM - Saturday, August 29"
      },
      {
        tag: "midnight",
        date: new Date(2026, 0, 1, 0, 0),
        expected: "12:00 AM - Thursday, January 01"
      },
      {
        tag: "noon",
        date: new Date(2026, 0, 1, 12, 0),
        expected: "12:00 PM - Thursday, January 01"
      },
      {
        tag: "invalid date",
        date: new Date(NaN),
        expected: ""
      }
    ];
  }

  function test_format(data: var) {
    compare(ClockFormat.format(data.date), data.expected);
  }

  function test_hero_time_data() {
    return [
      {
        tag: "afternoon",
        date: new Date(2026, 7, 29, 15, 5),
        hour: "3",
        minute: "05",
        meridiem: "PM"
      },
      {
        tag: "midnight",
        date: new Date(2026, 0, 1, 0, 7),
        hour: "12",
        minute: "07",
        meridiem: "AM"
      }
    ];
  }

  function test_hero_time(data: var) {
    const parts = ClockFormat.heroTime(data.date);
    compare(parts.hour, data.hour);
    compare(parts.minute, data.minute);
    compare(parts.meridiem, data.meridiem);
  }

  function test_hero_time_invalid_date() {
    const parts = ClockFormat.heroTime(new Date(NaN));
    compare(parts.hour, "");
    compare(parts.minute, "");
    compare(parts.meridiem, "");
  }

  function test_format_long_date() {
    compare(ClockFormat.formatLongDate(new Date(2026, 7, 29, 15, 5)), "Saturday, August 29");
    compare(ClockFormat.formatLongDate(new Date(NaN)), "");
  }
}
