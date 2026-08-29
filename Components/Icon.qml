import QtQuick

import qs.Models

Text {
  id: root

  enum Variant {
    Outlined = 0,
    Filled = 1
  }

  property string name: "indeterminate_question_box"
  property int variant: Qt.enumStringToValue(Icon.Variant, 'Outlined')

  font.pixelSize: 24
  font.family: "Material Symbols Rounded"
  font.variableAxes: ({
      FILL: root.variant,
      wght: 500,
      GRAD: 10,
      opsz: 50
    })

  color: Theme.accent
  text: root.name
}
