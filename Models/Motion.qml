pragma Singleton

import QtQuick

QtObject {
  id: root

  readonly property QtObject curves: QtObject {
    readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property list<real> expressiveSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property list<real> effects: [0.34, 0.8, 0.34, 1, 1, 1]
  }

  readonly property QtObject duration: QtObject {
    readonly property int effects: 200
    readonly property int spatialOpen: 400
    readonly property int spatialClose: 200
    readonly property int spatial: 500
  }
}
