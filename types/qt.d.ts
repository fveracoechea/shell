/**
 * Ambient declaration for the QML runtime global object, as provided to
 * QML JavaScript resources and QML documents.
 *
 * Only members used by this repository are declared.
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

  /**
   * Formats a date with the given Qt date format pattern in the process
   * default locale.
   *
   * @param date - the date to format
   * @param format - the Qt date format pattern
   * @returns the formatted display string
   */
  function formatDate(date: Date, format: string): string;
}
