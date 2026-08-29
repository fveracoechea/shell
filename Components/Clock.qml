import QtQuick

import qs.Models
import "../Models/Clock.js" as ClockFormat

Text {
  id: root

  /**
   * The raw date to display. Production composition binds this from the
   * Time platform adapter; tests inject fixed dates.
   */
  property date date: new Date()

  font.pixelSize: 18
  color: Theme.foreground
  text: ClockFormat.format(root.date)
}
