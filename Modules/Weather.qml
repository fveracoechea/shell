pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../Models/Weather.js" as Weather

// Weather Feature Service. Fetches the Open-Meteo forecast through curl
// with a direct argv command, normalizes the body through
// Models/Weather.js, and degrades silently: a failing fetch keeps the last
// good payload, marks the status "unavailable", and retries on the next
// interval. No display strings are produced here.
Singleton {
  id: root

  // Pinned configuration constants. Geocoding and location search are out
  // of scope for the dashboard.
  readonly property real latitude: 40.4168
  readonly property real longitude: -3.7038

  // Fixed refresh cadence in milliseconds; staleness is twice this.
  readonly property int refreshIntervalMs: 30 * 60 * 1000

  // One of "loading", "ready", "unavailable", or "stale" (see
  // Models/Weather.js serviceStatus). A failing fetch keeps the last good
  // payload and still reports "unavailable".
  readonly property string status: Weather.serviceStatus(_started, _failed, fetchedAtMs, nowMs)

  // True when the last good payload is older than twice the interval.
  readonly property bool stale: status === "stale"

  // Normalized current conditions, or null before the first good fetch.
  property var current: null

  // Normalized daily forecast entries, today first.
  property var daily: []

  // Wall-clock time of the last good fetch; 0 before the first one.
  property double fetchedAtMs: 0

  property bool _started: false
  property bool _failed: false

  // Reactive wall clock. Date.now() is not reactive, so staleness is
  // driven by this property and refreshed by a timer.
  property double nowMs: new Date().getTime()

  readonly property string url: "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset&forecast_days=7&timezone=auto"

  function fetch() {
    fetcher.running = true;
  }

  // Settles one fetch: a nonzero curl exit (HTTP failure, connection
  // failure, or timeout through -fsS and --max-time) marks the fetch as
  // failed while keeping the last good payload; a zero exit normalizes the
  // collected body.
  function finishFetch(exitCode: int): void {
    _started = true;
    if (exitCode !== 0) {
      _failed = true;
      return;
    }
    const parsed = Weather.parse(collector.text, new Date().getTime());
    if (parsed === null) {
      _failed = true;
      return;
    }
    _failed = false;
    current = parsed.current;
    daily = parsed.daily;
    fetchedAtMs = parsed.fetchedAtMs;
    nowMs = parsed.fetchedAtMs;
  }

  Process {
    id: fetcher

    command: ["curl", "-fsS", "--max-time", "15", root.url]

    stdout: StdioCollector {
      id: collector
    }

    // QProcess::ExitStatus is not resolvable by qmllint through the
    // Quickshell qmltypes; silence the parameter type warning.
    // qmllint disable signal-handler-parameters
    onExited: (exitCode, exitStatus) => root.finishFetch(exitCode)
  }

  Timer {
    interval: root.refreshIntervalMs
    running: true
    repeat: true
    triggeredOnStart: false
    onTriggered: root.fetch()
  }

  // Keeps the staleness binding reactive between fetches.
  Timer {
    interval: 60 * 1000
    running: true
    repeat: true

    onTriggered: root.nowMs = new Date().getTime()
  }

  Component.onCompleted: root.fetch()
}
