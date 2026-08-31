/**
 * User identity normalization for the dashboard greeting.
 *
 * The display name comes from the environment; a missing or blank USER
 * falls back to LOGNAME before giving up. Views hide the greeting section
 * when the result is empty.
 */

/**
 * Picks the display name from the user environment.
 *
 * @param {string|null} user - USER environment value
 * @param {string|null} logname - LOGNAME environment value
 * @returns {string} trimmed USER, else trimmed LOGNAME, else ""
 */
function displayName(user, logname) {
  const fromUser = trim(user);
  if (fromUser !== "") {
    return fromUser;
  }
  return trim(logname);
}

/**
 * Trims a string, or yields the empty string for non-strings.
 *
 * @param {string|null} value - untrusted environment value
 * @returns {string} the trimmed string, or "" when the value is not one
 */
function trim(value) {
  return typeof value === "string" ? value.trim() : "";
}
