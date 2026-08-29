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
}
