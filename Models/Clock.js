/**
 * Formats a date for the clock display as `h:mm AP - dddd, MMMM dd`.
 *
 * The pattern is the single source of truth for the clock display. The
 * result depends on the process locale, so deterministic callers pin the
 * locale before asserting on the output.
 *
 * @param {Date} date - the date to format
 * @returns {string} the formatted display string, or an empty string when
 *   the date is invalid
 */
function format(date) {
  if (!(date instanceof Date) || isNaN(date.getTime())) {
    return "";
  }

  return Qt.formatDateTime(date, "h:mm AP - dddd, MMMM dd");
}

/**
 * Splits a date into the stacked hero clock parts: the unpadded 12-hour
 * hour, the zero-padded minute, and the meridiem suffix.
 *
 * @param {Date} date - the date to split
 * @returns {{hour: string, minute: string, meridiem: string}} display
 *   parts, all empty strings when the date is invalid
 */
function heroTime(date) {
  if (!(date instanceof Date) || isNaN(date.getTime())) {
    return {
      hour: "",
      minute: "",
      meridiem: ""
    };
  }

  return {
    hour: `${date.getHours() % 12 === 0 ? 12 : date.getHours() % 12}`,
    minute: Qt.formatDateTime(date, "mm"),
    meridiem: Qt.formatDateTime(date, "AP")
  };
}

/**
 * Formats the time-of-day part of the clock display as `h:mm AP`.
 *
 * @param {Date} date - the date to format
 * @returns {string} the formatted time string, or "" for an invalid date
 */
function formatTime(date) {
  if (!(date instanceof Date) || isNaN(date.getTime())) {
    return "";
  }
  return Qt.formatDateTime(date, "h:mm AP");
}

/**
 * Formats the weekday and calendar date part of the clock display.
 *
 * @param {Date} date - the date to format
 * @returns {string} the formatted display string, or "" for an invalid
 *   date
 */
function formatLongDate(date) {
  if (!(date instanceof Date) || isNaN(date.getTime())) {
    return "";
  }

  return Qt.formatDateTime(date, "dddd, MMMM dd");
}
