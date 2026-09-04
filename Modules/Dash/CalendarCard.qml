pragma ComponentBehavior: Bound

import QtQuick

import qs.Components as Components
import qs.Models as Models
import "../../Models/Calendar.js" as Calendar

// Calendar section card with month and year navigation. The grid always
// shows six week rows so the card height never changes between months.
// The viewed month is local view state seeded from the injected today
// date; clicking the title returns to today.
Rectangle {
  id: root

  // The today reference date for the marker; tests inject fixed dates.
  property date now: new Date(NaN)

  // First day of the currently viewed month; navigation mutates it.
  property date viewDate: validNow ? new Date(now.getFullYear(), now.getMonth(), 1) : new Date(1970, 0, 1)

  readonly property bool validNow: !isNaN(now.getTime())
  readonly property int viewYear: viewDate.getFullYear()
  readonly property int viewMonth: viewDate.getMonth()
  readonly property int cellSize: 44
  readonly property int cellSpacing: 4
  readonly property int todayDiameter: 30
  readonly property int gridWidth: 7 * cellSize + 6 * cellSpacing
  readonly property var monthCells: Calendar.buildMonthCells(root.viewYear, root.viewMonth, root.now)

  implicitWidth: gridWidth + 2 * 16
  implicitHeight: content.implicitHeight + 32

  function navigate(delta: int): void {
    if (monthSlide.running) {
      monthSlide.complete();
    }
    monthSlide.nextViewYear = viewDate.getFullYear();
    monthSlide.nextViewMonth = viewDate.getMonth() + delta;
    monthSlide.dir = delta > 0 ? 1 : -1;
    monthSlide.restart();
  }

  function navigateYear(delta: int): void {
    navigate(delta * 12);
  }

  function returnToToday(): void {
    if (validNow) {
      viewDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }
  }

  color: Models.Theme.surface
  radius: Models.Theme.radius

  Column {
    id: content

    anchors.fill: parent
    anchors.margins: 16
    spacing: 8

    Components.SectionLabel {
      label: "Calendar"
    }

    Item {
      id: navRow

      width: parent.width
      height: 28

      Text {
        id: monthLabel

        anchors.centerIn: parent
        text: Calendar.monthTitle(root.viewDate.getFullYear(), root.viewDate.getMonth())
        font.pixelSize: 14
        font.weight: Font.Medium
        color: Models.Theme.foreground

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.viewDate = root.validNow ? new Date(root.now.getFullYear(), root.now.getMonth(), 1) : root.viewDate
        }
      }

      Item {
        id: previousYear

        anchors.left: parent.left
        width: 28
        height: 28

        Components.Icon {
          anchors.centerIn: parent
          name: "keyboard_double_arrow_left"
          size: 20
          color: previousYearArea.containsMouse ? Models.Theme.foreground : Models.Theme.muted
        }

        MouseArea {
          id: previousYearArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.navigateYear(-1)
        }
      }

      Item {
        id: previousMonth

        anchors.left: previousYear.right
        anchors.leftMargin: 4
        width: 28
        height: 28

        Components.Icon {
          anchors.centerIn: parent
          name: "chevron_left"
          size: 20
          color: previousArea.containsMouse ? Models.Theme.foreground : Models.Theme.muted
        }

        MouseArea {
          id: previousArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.navigate(-1)
        }
      }

      Item {
        id: nextMonth

        anchors.right: nextYear.left
        anchors.rightMargin: 4
        width: 28
        height: 28

        Components.Icon {
          anchors.centerIn: parent
          name: "chevron_right"
          size: 20
          color: nextArea.containsMouse ? Models.Theme.foreground : Models.Theme.muted
        }

        MouseArea {
          id: nextArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.navigate(1)
        }
      }

      Item {
        id: nextYear

        anchors.right: parent.right
        width: 28
        height: 28

        Components.Icon {
          anchors.centerIn: parent
          name: "keyboard_double_arrow_right"
          size: 20
          color: nextYearArea.containsMouse ? Models.Theme.foreground : Models.Theme.muted
        }

        MouseArea {
          id: nextYearArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.navigateYear(1)
        }
      }
    }

    Row {
      id: weekdayRow

      spacing: root.cellSpacing

      Repeater {
        model: Calendar.weekdayNames(1)

        delegate: Text {
          id: weekdayLabel

          required property string modelData

          width: root.cellSize
          horizontalAlignment: Text.AlignHCenter
          text: weekdayLabel.modelData
          font.pixelSize: 10
          font.letterSpacing: 1
          color: Models.Theme.muted
        }
      }
    }

    Item {
      id: monthGrid

      width: root.gridWidth
      height: 6 * root.cellSize + 5 * root.cellSpacing

      Repeater {
        model: root.monthCells

        delegate: Item {
          id: cell

          required property var modelData
          required property int index

          x: (cell.index % 7) * (root.cellSize + root.cellSpacing)
          y: Math.floor(cell.index / 7) * (root.cellSize + root.cellSpacing)
          width: root.cellSize
          height: root.cellSize

          Rectangle {
            anchors.centerIn: parent
            width: root.todayDiameter
            height: root.todayDiameter
            radius: root.todayDiameter / 2
            visible: cell.modelData.isToday
            color: Models.Theme.accent
          }

          Text {
            anchors.centerIn: parent
            text: cell.modelData.dayOfMonth
            font.pixelSize: 12
            font.family: "JetBrains Mono"
            color: cell.modelData.isToday ? Models.Theme.background : cell.modelData.isWeekend ? Models.Theme.muted : Models.Theme.foreground
            opacity: cell.modelData.inMonth ? 1 : 0.4
          }
        }
      }
    }
  }

  SequentialAnimation {
    id: monthSlide

    property int nextViewYear: 1970
    property int nextViewMonth: 0
    property int dir: 1

    ParallelAnimation {
      NumberAnimation {
        target: monthGrid
        property: "opacity"
        to: 0
        duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
      }

      NumberAnimation {
        target: monthGrid
        property: "x"
        to: -24 * monthSlide.dir
        duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
      }
    }

    ScriptAction {
      script: {
        root.viewDate = new Date(monthSlide.nextViewYear, monthSlide.nextViewMonth, 1);
      }
    }

    ParallelAnimation {
      NumberAnimation {
        target: monthGrid
        property: "x"
        from: 24 * monthSlide.dir
        to: 0
        duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
      }

      NumberAnimation {
        target: monthGrid
        property: "opacity"
        from: 0
        to: 1
        duration: Models.Motion.reduce ? 0 : Models.Motion.duration.effects
      }
    }
  }
}
