pragma Singleton

import Quickshell

Singleton {
  id: root

  // The bar clock date at Minutes precision. Policy-free: consumers own
  // normalization; tests inject fixed dates.
  readonly property date now: clock.date

  // The dashboard date at Seconds precision, feeding the hero clock and
  // its seconds line.
  readonly property date preciseNow: secondsClock.date

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  SystemClock {
    id: secondsClock
    precision: SystemClock.Seconds
  }
}
