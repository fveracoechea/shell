import QtQuick

// The dashboard panel content: one grid with a single gap token and
// non-uniform, content-driven card sizes and spans per the composition
// amendment. Row 1 is weather (compact) plus system (wide); row 2 is the
// calendar (fixed cell geometry) plus the large clock absorbing remaining
// space. Below the two-column threshold the same gap and order fall back
// to a single column with a horizontal hero clock. All data properties
// are injected; the Surface Manager binds Feature Services, tests bind
// fixed values.
Item {
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
  property string compositorVersion: ""
  property real cpuUsage: -1
  property real cpuTempC: -1
  property real memoryUsed: -1
  property real memoryUsedKb: -1
  property real memoryTotalKb: -1
  property real diskUsed: -1
  property real diskUsedKb: -1
  property real diskTotalKb: -1
  property int uptimeSeconds: -1

  // User identity; empty strings hide the greeting.
  property string userName: ""
  property string userFacePath: ""
  property bool showClock: true

  readonly property int padding: 16
  readonly property int gap: 12
  readonly property int weatherWidth: 296
  readonly property int systemMin: 352
  readonly property int clockMin: 240
  readonly property int contentWidth: width - 2 * padding
  readonly property bool narrow: width < 672
  readonly property int calendarWidth: calendarCard.implicitWidth
  readonly property bool clockVisible: showClock && (narrow || contentWidth - calendarWidth - gap >= clockMin)
  readonly property int row1Height: Math.max(weatherCard.implicitHeight, systemCard.implicitHeight)
  readonly property int row2Height: Math.max(calendarCard.implicitHeight, clockVisible ? clockCard.implicitHeight : 0)

  implicitWidth: 2 * padding + Math.max(weatherWidth + gap + systemMin, calendarCard.implicitWidth + gap + clockMin)
  implicitHeight: narrow ? (clockVisible ? clockCard.y + clockCard.implicitHeight : systemCard.y + systemCard.implicitHeight) + padding : padding + row1Height + gap + row2Height + padding

  WeatherCard {
    id: weatherCard

    objectName: "weatherCard"

    current: root.weatherCurrent
    daily: root.weatherDaily
    status: root.weatherStatus
    x: root.padding
    y: root.narrow ? root.padding + calendarCard.implicitHeight + root.gap : root.padding
    width: root.narrow ? root.contentWidth : root.weatherWidth
    height: root.narrow ? implicitHeight : root.row1Height
  }

  SystemCard {
    id: systemCard

    objectName: "systemCard"

    distro: root.distro
    hostname: root.hostname
    kernel: root.kernel
    desktop: root.desktop
    compositorVersion: root.compositorVersion
    cpuUsage: root.cpuUsage
    cpuTempC: root.cpuTempC
    memoryUsed: root.memoryUsed
    memoryUsedKb: root.memoryUsedKb
    memoryTotalKb: root.memoryTotalKb
    diskUsed: root.diskUsed
    diskUsedKb: root.diskUsedKb
    diskTotalKb: root.diskTotalKb
    uptimeSeconds: root.uptimeSeconds
    userName: root.userName
    userFacePath: root.userFacePath
    x: root.narrow ? root.padding : root.padding + root.weatherWidth + root.gap
    y: root.narrow ? weatherCard.y + weatherCard.height + root.gap : root.padding
    width: root.narrow ? root.contentWidth : root.contentWidth - root.weatherWidth - root.gap
    height: root.narrow ? implicitHeight : root.row1Height
  }

  CalendarCard {
    id: calendarCard

    objectName: "calendarCard"

    now: root.now
    x: root.padding
    y: root.narrow ? root.padding : root.padding + root.row1Height + root.gap
    width: root.narrow ? root.contentWidth : root.calendarWidth
    height: root.narrow ? implicitHeight : root.row2Height
  }

  ClockCard {
    id: clockCard

    objectName: "clockCard"

    now: root.now
    preciseNow: root.preciseNow
    stacked: !root.narrow
    x: root.narrow ? root.padding : root.padding + root.calendarWidth + root.gap
    y: root.narrow ? systemCard.y + systemCard.height + root.gap : root.padding + root.row1Height + root.gap
    width: root.narrow ? root.contentWidth : root.contentWidth - root.calendarWidth - root.gap
    height: root.narrow ? implicitHeight : root.row2Height
    visible: root.clockVisible
  }
}
