import QtQuick
import QtTest

import qs.Models

TestCase {
  name: "ClockFormat"

  /**
   * Supplies fixed dates with their expected display strings.
   *
   * @returns {Array<object>} rows of `{tag: string, date: Date, expected: string}`
   */
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

  /**
   * Verifies the formatter against one worked literal.
   *
   * @param {object} data - the row from `test_format_data`
   * @param {Date} data.date - the fixed input date
   * @param {string} data.expected - the expected display string
   * @returns {void}
   */
  function test_format(data) {
    compare(ClockFormat.format(data.date), data.expected);
  }
}
