.pragma library

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
