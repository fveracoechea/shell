import QtQuick
import Quickshell

import qs.Modules as Modules
import qs.Modules.Dash as Dash

// Composed healthy fixture: instantiates the real dashboard composition
// against deterministic weather data and local Feature Services. The offscreen harness
// has no window backend, so the window surfaces are verified by the
// compile gate instead; this fixture catches composition and binding load
// failures that the minimal fixture cannot see.
Scope {
  Dash.Dashboard {
    now: Modules.Time.now
    preciseNow: Modules.Time.preciseNow
    weatherStatus: "unavailable"
    weatherCurrent: null
    weatherDaily: []
    distro: Modules.System.distro
    hostname: Modules.System.hostname
    kernel: Modules.System.kernel
    desktop: Modules.System.desktop
    compositorVersion: Modules.System.compositorVersion
    cpuUsage: Modules.System.cpuUsage
    cpuTempC: Modules.System.cpuTempC
    memoryUsed: Modules.System.memoryUsed
    memoryUsedKb: Modules.System.memoryUsedKb
    memoryTotalKb: Modules.System.memoryTotalKb
    diskUsed: Modules.System.diskUsed
    diskUsedKb: Modules.System.diskUsedKb
    diskTotalKb: Modules.System.diskTotalKb
    uptimeSeconds: Modules.System.uptimeSeconds
    userName: Modules.Identity.name
    userFacePath: Modules.Identity.facePath
  }

  Component.onCompleted: {
    console.log("SHELL_HEALTHY");
  }
}
