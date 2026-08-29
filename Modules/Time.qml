pragma Singleton

import Quickshell

Singleton {
  id: root

  // The raw platform date. Policy-free: consumers own normalization.
  readonly property date now: clock.date

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
