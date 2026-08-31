pragma Singleton

import QtQuick

QtObject {
  id: root

  readonly property var curves: ({
      emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1],
      emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1],
      expressiveSpatial: [0.38, 1.21, 0.22, 1, 1, 1],
      effects: [0.34, 0.8, 0.34, 1, 1, 1]
    })

  readonly property var duration: ({
      effects: 200,
      spatialOpen: 400,
      spatialClose: 200,
      spatial: 500
    })

  // When true, every animation collapses to zero duration. The Surface
  // Manager wires this from the SHELL_REDUCED_MOTION environment flag; the
  // singleton itself stays Quickshell free so tests can load it.
  property bool reduce: false
}
