pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../Models/SystemInfo.js" as SystemInfo

// System identity and performance Feature Service. Static identity files
// load once; procfs and df poll on fixed intervals because procfs never
// fires filesystem watchers. Values are policy-free numbers and -1 means
// "no sample yet"; display strings come from the pure models, never from
// here. Failures leave the affected value unset and the shell healthy.
Singleton {
  id: root

  // Identity strings, "" when unknown.
  readonly property string distro: _distro
  readonly property string hostname: _hostname
  readonly property string kernel: _kernel

  // Desktop environment from the session environment; "" when absent.
  readonly property string desktop: _currentDesktop !== "" ? _currentDesktop : _hyprlandSignature !== "" ? "Hyprland" : ""

  // Performance values; -1 means "no sample yet". Fractions are in [0, 1].
  readonly property real cpuUsage: _cpuUsage
  readonly property real cpuTempC: _cpuTempC
  readonly property real memoryUsed: _memory === null ? -1 : _memory.usedFraction
  readonly property real diskUsed: _disk === null ? -1 : _disk.usedFraction
  readonly property int uptimeSeconds: _uptimeSeconds

  property string _distro: ""
  property string _hostname: ""
  property string _kernel: ""
  property real _cpuUsage: -1
  property real _cpuTempC: -1
  property var _memory: null
  property var _disk: null
  property int _uptimeSeconds: -1
  property var _prevCpuTicks: null

  readonly property string _currentDesktop: {
    const value = Quickshell.env("XDG_CURRENT_DESKTOP");
    return typeof value === "string" ? value : "";
  }

  readonly property string _hyprlandSignature: {
    const value = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
    return typeof value === "string" ? value : "";
  }

  // The CPU sensor probe matches the common x86 and ARM package sensors
  // and prints the first available millidegree reading.
  readonly property string _cpuSensorScript: "for d in /sys/class/hwmon/hwmon*; do [ -r \"$d/name\" ] || continue; n=$(cat \"$d/name\" 2>/dev/null); case \"$n\" in coretemp|k10temp|zenpower|cpu_thermal) for f in \"$d\"/temp1_input \"$d\"/temp2_input; do if [ -r \"$f\" ]; then cat \"$f\"; exit 0; fi; done ;; esac; done"

  function sampleCpuTemp(): void {
    tempProbe.running = true;
  }

  function sampleDisk(): void {
    diskProbe.running = true;
  }

  FileView {
    id: osRelease

    path: "/etc/os-release"
    watchChanges: false

    onTextChanged: root._distro = SystemInfo.parsePrettyName(text)
  }

  FileView {
    id: hostnameFile

    path: "/etc/hostname"
    watchChanges: false

    onTextChanged: root._hostname = typeof text === "string" ? text.trim() : ""
  }

  FileView {
    id: procVersion

    path: "/proc/version"
    watchChanges: false

    onTextChanged: root._kernel = SystemInfo.parseKernelVersion(text)
  }

  FileView {
    id: procStat

    path: "/proc/stat"

    onTextChanged: {
      const ticks = SystemInfo.parseCpuTicks(text);
      if (ticks !== null) {
        root._cpuUsage = SystemInfo.cpuFraction(root._prevCpuTicks, ticks);
        root._prevCpuTicks = ticks;
      }
    }
  }

  FileView {
    id: meminfo

    path: "/proc/meminfo"

    onTextChanged: root._memory = SystemInfo.parseMeminfo(text)
  }

  FileView {
    id: uptimeFile

    path: "/proc/uptime"

    onTextChanged: root._uptimeSeconds = SystemInfo.parseUptime(text)
  }

  Process {
    id: tempProbe

    command: ["sh", "-c", root._cpuSensorScript]

    stdout: StdioCollector {
      id: tempCollector

      onStreamFinished: root._cpuTempC = SystemInfo.parseCpuTemp(tempCollector.text)
    }
  }

  Process {
    id: diskProbe

    command: ["df", "-kP", "/"]

    stdout: StdioCollector {
      id: diskCollector

      onStreamFinished: root._disk = SystemInfo.parseDf(diskCollector.text)
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true

    onTriggered: {
      procStat.reload();
      meminfo.reload();
      uptimeFile.reload();
      tempProbe.running = true;
    }
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.sampleDisk()
  }

  Component.onCompleted: {
    osRelease.reload();
    hostnameFile.reload();
    procVersion.reload();
    procStat.reload();
    meminfo.reload();
    uptimeFile.reload();
    root.sampleCpuTemp();
    root.sampleDisk();
  }
}
