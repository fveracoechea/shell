/**
 * Ambient declaration for the QML runtime global object, as provided to
 * QML JavaScript resources and QML documents.
 *
 * Only members used by this repository are declared. `Models/Clock.js` is
 * excluded from tsc because QML-only directives are not valid JavaScript;
 * qmllint owns its syntax checking.
 */
declare namespace Qt {
  /**
   * Formats a date with the given Qt datetime format pattern in the
   * process default locale.
   *
   * @param date - the date to format
   * @param format - the Qt datetime format pattern
   * @returns the formatted display string
   */
  function formatDateTime(date: Date, format: string): string;
}
