import QtQuick

import qs.Models as Models
import "../Models/Clock.js" as ClockFormat

Text {
  id: root

  /**
   * The raw date to display. Production composition binds this from the
   * Time platform adapter; tests inject fixed dates.
   */
  property date date: new Date(NaN)

  font.pixelSize: 18
  color: Models.Theme.foreground
  text: ClockFormat.format(root.date)
}
