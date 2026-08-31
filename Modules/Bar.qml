import Quickshell
import qs.Modules as Modules

Scope {
  Variants {
    model: Quickshell.screens

    Modules.SurfaceManager {
      required property ShellScreen modelData

      screen: modelData
    }
  }
}
