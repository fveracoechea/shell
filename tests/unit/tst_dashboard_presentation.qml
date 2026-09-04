import QtQuick
import QtTest

import qs.Models as Models
import qs.Modules.Dash as Dash

TestCase {
  id: testCase

  name: "DashboardPresentation"

  function cleanup() {
    Models.Motion.reduce = false;
  }

  Component {
    id: dashboardComponent

    Dash.Dashboard {
      width: 752
      now: new Date(2026, 7, 30, 15, 5)
      preciseNow: new Date(2026, 7, 30, 15, 5, 30)
    }
  }

  function test_sections_do_not_animate_when_dashboard_appears() {
    Models.Motion.reduce = false;
    const dashboard = createTemporaryObject(dashboardComponent, testCase);
    verify(dashboard !== null);

    const names = ["weatherCard", "systemCard", "calendarCard", "clockCard"];
    for (let i = 0; i < names.length; i++) {
      const card = findChild(dashboard, names[i]);
      verify(card !== null, `Missing ${names[i]}`);
      compare(card.opacity, 1, `${names[i]} must be fully visible immediately`);
    }
  }

  function test_profile_picture_is_prominent() {
    const dashboard = createTemporaryObject(dashboardComponent, testCase);
    verify(dashboard !== null);
    const profilePicture = findChild(dashboard, "profilePicture");
    verify(profilePicture !== null);
    verify(profilePicture.width >= 64);
    compare(profilePicture.width, profilePicture.height);
  }

  function test_cards_fit_wide_and_narrow_dashboard_bounds() {
    const dashboard = createTemporaryObject(dashboardComponent, testCase);
    verify(dashboard !== null);
    const names = ["weatherCard", "systemCard", "calendarCard", "clockCard"];

    for (let widthIndex = 0; widthIndex < 2; widthIndex++) {
      dashboard.width = widthIndex === 0 ? 752 : 600;
      wait(0);
      for (let i = 0; i < names.length; i++) {
        const card = findChild(dashboard, names[i]);
        verify(card.x >= 0, `${names[i]} starts outside the dashboard`);
        verify(card.y >= 0, `${names[i]} starts above the dashboard`);
        verify(card.x + card.width <= dashboard.width, `${names[i]} exceeds dashboard width`);
        verify(card.y + card.height <= dashboard.implicitHeight, `${names[i]} exceeds dashboard height`);
      }
    }
  }

  function test_calendar_cycles_years() {
    Models.Motion.reduce = true;
    const dashboard = createTemporaryObject(dashboardComponent, testCase);
    verify(dashboard !== null);
    const calendar = findChild(dashboard, "calendarCard");
    verify(calendar !== null);
    verify(calendar.todayDiameter < calendar.cellSize);
    compare(calendar.viewYear, 2026);
    calendar.navigateYear(1);
    tryCompare(calendar, "viewYear", 2027);
    calendar.navigateYear(-1);
    tryCompare(calendar, "viewYear", 2026);
  }
}
