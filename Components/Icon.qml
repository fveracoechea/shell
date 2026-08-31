import QtQuick

import qs.Models as Models

Text {
  id: root

  enum Variant {
    Outlined = 0,
    Filled = 1
  }

  property string name: "indeterminate_question_box"
  property int variant: Qt.enumStringToValue(Icon.Variant, 'Outlined')
  property int size: 24

  font.pixelSize: root.size
  font.family: "Material Symbols Rounded"
  font.variableAxes: ({
      FILL: root.variant,
      wght: 500,
      GRAD: 10,
      opsz: 50
    })

  color: Models.Theme.accent
  text: root.name
}
