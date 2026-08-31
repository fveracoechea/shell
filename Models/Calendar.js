/**
 * Calendar grid building for the dashboard month view.
 *
 * The grid always has exactly six week rows of exactly seven day cells, so
 * panel height never changes between months. Cells outside the month stay
 * in the grid and are marked `inMonth: false` so views can dim them.
 */

/**
 * Builds the six-week grid for one month.
 *
 * @param {number} year - full year, for example 2026
 * @param {number} month - zero-based month, 0 for January
 * @param {Date} now - reference date for the today marker; an invalid date
 *   marks nothing
 * @param {number} [firstDayOfWeek] - 0 for Sunday, 1 for Monday; default 1
 * @returns {Array<Array<{isoDate: string, dayOfMonth: number, inMonth: boolean, isToday: boolean, isWeekend: boolean}>>}
 *   six weeks, each of exactly seven day cells, padded with adjacent-month
 *   days
 */
function buildMonthGrid(year, month, now, firstDayOfWeek) {
  const firstDow = firstDayOfWeek === undefined ? 1 : firstDayOfWeek;
  const offset = (firstOfMonth(year, month).getDay() - firstDow + 7) % 7;
  const weeks = [];
  for (let week = 0; week < 6; week++) {
    const row = [];
    for (let day = 0; day < 7; day++) {
      const cell = new Date(year, month, 1 - offset + week * 7 + day);
      const dayOfWeek = cell.getDay();
      row.push({
        isoDate: Qt.formatDate(cell, "yyyy-MM-dd"),
        dayOfMonth: cell.getDate(),
        inMonth: cell.getMonth() === month,
        isToday: sameDay(cell, now),
        isWeekend: dayOfWeek === 0 || dayOfWeek === 6
      });
    }
    weeks.push(row);
  }
  return weeks;
}

/**
 * Builds the six-week grid for one month flattened into 42 sequential day
 * cells, row-major from the top-left cell. Views that place cells with a
 * flat index use this instead of walking the nested grid.
 *
 * @param {number} year - full year, for example 2026
 * @param {number} month - zero-based month, 0 for January
 * @param {Date} now - reference date for the today marker; an invalid date
 *   marks nothing
 * @param {number} [firstDayOfWeek] - 0 for Sunday, 1 for Monday; default 1
 * @returns {Array<{isoDate: string, dayOfMonth: number, inMonth: boolean, isToday: boolean, isWeekend: boolean}>}
 *   exactly 42 day cells, padded with adjacent-month days
 */
function buildMonthCells(year, month, now, firstDayOfWeek) {
  const weeks = buildMonthGrid(year, month, now, firstDayOfWeek);
  const cells = [];
  for (let week = 0; week < weeks.length; week++) {
    for (let day = 0; day < 7; day++) {
      cells.push(weeks[week][day]);
    }
  }
  return cells;
}

/**
 * Builds the navigation title for one month, for example "August 2026".
 *
 * @param {number} year - full year
 * @param {number} month - zero-based month
 * @returns {string} display title
 */
function monthTitle(year, month) {
  return Qt.formatDate(new Date(year, month, 1), "MMMM yyyy");
}

/**
 * Builds the weekday header row for a grid that starts on the given day.
 *
 * @param {number} firstDayOfWeek - 0 for Sunday, 1 for Monday
 * @returns {string[]} seven locale weekday abbreviations
 */
function weekdayNames(firstDayOfWeek) {
  const firstDow = firstDayOfWeek === undefined ? 1 : firstDayOfWeek;
  const names = [];
  for (let i = 0; i < 7; i++) {
    names.push(Qt.formatDate(new Date(2000, 0, 2 + ((firstDow + i) % 7)), "ddd"));
  }
  return names;
}

/**
 * Creates the first day of one month as a local Date.
 *
 * @param {number} year - full year
 * @param {number} month - zero-based month
 * @returns {Date} local midnight of the first day of the month
 */
function firstOfMonth(year, month) {
  return new Date(year, month, 1);
}

/**
 * Reports whether two dates are the same calendar day.
 *
 * @param {Date} left - first date; invalid dates never match
 * @param {Date} right - second date; invalid dates never match
 * @returns {boolean} true when both dates share year, month, and day
 */
function sameDay(left, right) {
  if (!(left instanceof Date) || !(right instanceof Date)) {
    return false;
  }
  if (isNaN(left.getTime()) || isNaN(right.getTime())) {
    return false;
  }
  return left.getFullYear() === right.getFullYear() && left.getMonth() === right.getMonth() && left.getDate() === right.getDate();
}
