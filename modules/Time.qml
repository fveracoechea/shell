pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string time: {
    Qt.formatDateTime(clock.date, "h:mm AP - dddd, MMMM dd");
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
