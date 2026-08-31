import QtQuick
import QtTest

import "../../Models/Calendar.js" as Calendar

TestCase {
  name: "CalendarGrid"

  function countToday(grid: var): int {
    let markers = 0;
    for (let w = 0; w < grid.length; w++) {
      for (let d = 0; d < 7; d++) {
        if (grid[w][d].isToday) {
          markers++;
        }
      }
    }
    return markers;
  }

  function test_grid_is_six_weeks_of_seven() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(2026, 7, 30));
    compare(grid.length, 6);
    for (let w = 0; w < grid.length; w++) {
      compare(grid[w].length, 7);
    }
  }

  function test_first_week_pads_with_july_days_monday_start() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(2026, 7, 30));
    compare(grid[0][0].isoDate, "2026-07-27");
    compare(grid[0][0].dayOfMonth, 27);
    compare(grid[0][0].inMonth, false);
    compare(grid[0][6].dayOfMonth, 2);
    compare(grid[0][6].inMonth, true);
  }

  function test_sixth_week_pads_with_september() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(2026, 7, 30));
    compare(grid[5][0].isoDate, "2026-08-31");
    compare(grid[5][1].isoDate, "2026-09-01");
    compare(grid[5][1].inMonth, false);
  }

  function test_today_marker() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(2026, 7, 30));
    compare(grid[4][6].isoDate, "2026-08-30");
    compare(grid[4][6].isToday, true);
    compare(countToday(grid), 1);
  }

  function test_other_month_reference_never_marks_today() {
    const grid = Calendar.buildMonthGrid(2026, 8, new Date(2026, 7, 30));
    compare(countToday(grid), 0);
  }

  function test_invalid_today_never_marks() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(NaN));
    compare(countToday(grid), 0);
  }

  function test_sunday_first_day() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(2026, 7, 30), 0);
    compare(grid[0][0].isoDate, "2026-07-26");
    compare(grid[0][0].dayOfMonth, 26);
    compare(grid[0][6].isoDate, "2026-08-01");
  }

  function test_month_title() {
    compare(Calendar.monthTitle(2026, 7), "August 2026");
    compare(Calendar.monthTitle(2027, 0), "January 2027");
  }

  function test_weekday_names_monday_start() {
    const names = Calendar.weekdayNames(1);
    compare(names.length, 7);
    compare(names[0], "Mon");
    compare(names[6], "Sun");
  }

  function test_weekday_names_sunday_start() {
    const names = Calendar.weekdayNames(0);
    compare(names[0], "Sun");
    compare(names[6], "Sat");
  }

  function test_cells_carry_weekend_flag() {
    const grid = Calendar.buildMonthGrid(2026, 7, new Date(2026, 7, 30));
    compare(grid[4][6].isoDate, "2026-08-30");
    compare(grid[4][6].isWeekend, true);
    compare(grid[4][5].isoDate, "2026-08-29");
    compare(grid[4][5].isWeekend, true);
    compare(grid[4][4].isoDate, "2026-08-28");
    compare(grid[4][4].isWeekend, false);
    compare(grid[0][5].isoDate, "2026-08-01");
    compare(grid[0][5].isWeekend, true);
    compare(grid[0][4].isoDate, "2026-07-31");
    compare(grid[0][4].isWeekend, false);
  }

  function test_month_cells_flatten_the_grid() {
    const cells = Calendar.buildMonthCells(2026, 7, new Date(2026, 7, 30));
    compare(cells.length, 42);
    compare(cells[0].isoDate, "2026-07-27");
    compare(cells[41].isoDate, "2026-09-06");
    let markers = 0;
    for (let i = 0; i < cells.length; i++) {
      if (cells[i].isToday) {
        markers++;
      }
    }
    compare(markers, 1);
    compare(cells[34].isoDate, "2026-08-30");
    compare(cells[34].isToday, true);
  }
}
