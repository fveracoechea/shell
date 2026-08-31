import QtQuick

import qs.Models as Models

// The dashboard panel content: one grid with a single gap token and
// non-uniform, content-driven card sizes and spans per the composition
// amendment. Row 1 is weather (compact) plus system (wide); row 2 is the
// calendar (fixed cell geometry) plus the large clock absorbing remaining
// space. Below the two-column threshold the same gap and order fall back
// to a single column with a horizontal hero clock. All data properties
// are injected; the Surface Manager binds Feature Services, tests bind
// fixed values.
Rectangle {
  id: root

  // Time. Minutes drives the hero text, Seconds the seconds line.
  property date now: new Date(NaN)
  property date preciseNow: new Date(NaN)

  // Weather section state (Models/Weather.js shapes and service status).
  property string weatherStatus: "loading"
  property var weatherCurrent: null
  property var weatherDaily: []

  // System identity and performance; -1 means "no sample yet".
  property string distro: ""
  property string hostname: ""
  property string kernel: ""
  property string desktop: ""
  property real cpuUsage: -1
  property real cpuTempC: -1
  property real memoryUsed: -1
  property real diskUsed: -1
  property int uptimeSeconds: -1

  // User identity; empty strings hide the greeting.
  property string userName: ""
  property string userFacePath: ""

  readonly property int padding: 16
  readonly property int gap: 12
  readonly property int weatherWidth: 296
  readonly property int systemMin: 352
  readonly property int clockMin: 240
  readonly property int contentWidth: width - 2 * padding
  readonly property bool narrow: width < 672
  readonly property int calendarWidth: calendarCard.implicitWidth
  readonly property bool clockVisible: narrow || contentWidth - calendarWidth - gap >= clockMin
  readonly property int row1Height: Math.max(weatherCard.implicitHeight, systemCard.implicitHeight)
  readonly property int row2Height: Math.max(calendarCard.implicitHeight, clockVisible ? clockCard.implicitHeight : 0)

  // The panel surface: background fill with the 1 px surface1 border and
  // the 16 panel radius from the composition decision. Cards sit on it
  // with tonal surface0 separation.
  color: Models.Theme.background
  border.color: Models.Theme.surface1
  border.width: 1
  radius: 16

  implicitWidth: 2 * padding + Math.max(weatherWidth + gap + systemMin, calendarCard.implicitWidth + gap + clockMin)
  implicitHeight: narrow ? systemCard.y + systemCard.implicitHeight + padding : padding + row1Height + gap + row2Height + padding

  // Cards stagger in after the height morph starts; reduced motion shows
  // everything immediately.
  function revealCards() {
    if (Models.Motion.reduce) {
      weatherCard.opacity = 1;
      systemCard.opacity = 1;
      calendarCard.opacity = 1;
      clockCard.opacity = 1;
      weatherShift.y = 0;
      systemShift.y = 0;
      calendarShift.y = 0;
      clockShift.y = 0;
      return;
    }
    stagger.restart();
  }

  WeatherCard {
    id: weatherCard

    current: root.weatherCurrent
    daily: root.weatherDaily
    status: root.weatherStatus
    x: root.padding
    y: root.narrow ? root.padding + calendarCard.implicitHeight + root.gap : root.padding
    width: root.narrow ? root.contentWidth : root.weatherWidth
    height: root.row1Height
    opacity: Models.Motion.reduce ? 1 : 0

    transform: Translate {
      id: weatherShift

      y: Models.Motion.reduce ? 0 : 12
    }
  }

  SystemCard {
    id: systemCard

    distro: root.distro
    hostname: root.hostname
    kernel: root.kernel
    desktop: root.desktop
    cpuUsage: root.cpuUsage
    cpuTempC: root.cpuTempC
    memoryUsed: root.memoryUsed
    diskUsed: root.diskUsed
    uptimeSeconds: root.uptimeSeconds
    userName: root.userName
    userFacePath: root.userFacePath
    x: root.narrow ? root.padding : root.padding + root.weatherWidth + root.gap
    y: root.narrow ? clockCard.y + clockCard.implicitHeight + root.gap : root.padding
    width: root.narrow ? root.contentWidth : root.contentWidth - root.weatherWidth - root.gap
    height: root.narrow ? implicitHeight : root.row1Height
    opacity: Models.Motion.reduce ? 1 : 0

    transform: Translate {
      id: systemShift

      y: Models.Motion.reduce ? 0 : 12
    }
  }

  CalendarCard {
    id: calendarCard

    now: root.now
    x: root.padding
    y: root.narrow ? root.padding : root.padding + root.row1Height + root.gap
    width: root.narrow ? root.contentWidth : root.calendarWidth
    height: root.narrow ? implicitHeight : root.row2Height
    opacity: Models.Motion.reduce ? 1 : 0

    transform: Translate {
      id: calendarShift

      y: Models.Motion.reduce ? 0 : 12
    }
  }

  ClockCard {
    id: clockCard

    now: root.now
    preciseNow: root.preciseNow
    stacked: !root.narrow
    x: root.narrow ? root.padding : root.padding + root.calendarWidth + root.gap
    y: root.narrow ? weatherCard.y + weatherCard.height + root.gap : root.padding + root.row1Height + root.gap
    width: root.narrow ? root.contentWidth : root.contentWidth - root.calendarWidth - root.gap
    height: root.narrow ? implicitHeight : root.row2Height
    visible: root.clockVisible
    opacity: Models.Motion.reduce ? 1 : 0

    transform: Translate {
      id: clockShift

      y: Models.Motion.reduce ? 0 : 12
    }
  }

  SequentialAnimation {
    id: stagger

    PauseAnimation {
      duration: 80
    }

    ParallelAnimation {
      NumberAnimation {
        target: weatherCard
        property: "opacity"
        from: 0
        to: 1
        duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }

      NumberAnimation {
        target: weatherShift
        property: "y"
        from: 12
        to: 0
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }
    }

    PauseAnimation {
      duration: 40
    }

    ParallelAnimation {
      NumberAnimation {
        target: systemCard
        property: "opacity"
        from: 0
        to: 1
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }

      NumberAnimation {
        target: systemShift
        property: "y"
        from: 12
        to: 0
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }
    }

    PauseAnimation {
      duration: 40
    }

    ParallelAnimation {
      NumberAnimation {
        target: calendarCard
        property: "opacity"
        from: 0
        to: 1
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }

      NumberAnimation {
        target: calendarShift
        property: "y"
        from: 12
        to: 0
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }
    }

    PauseAnimation {
      duration: 40
    }

    ParallelAnimation {
      NumberAnimation {
        target: clockCard
        property: "opacity"
        from: 0
        to: 1
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }

      NumberAnimation {
        target: clockShift
        property: "y"
        from: 12
        to: 0
        duration: Models.Motion.duration.effects
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Models.Motion.curves.effects
      }
    }
  }
}
