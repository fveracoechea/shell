import QtQuick
import QtTest

import "../../Models/SystemInfo.js" as SystemInfo

TestCase {
  name: "SystemInfo"

  function test_parses_pretty_name() {
    const text = 'NAME="NixOS"\nPRETTY_NAME="NixOS 25.05 (Warbler)"\nID=nixos\n';
    compare(SystemInfo.parsePrettyName(text), "NixOS 25.05 (Warbler)");
  }

  function test_parses_pretty_name_without_quotes() {
    compare(SystemInfo.parsePrettyName("PRETTY_NAME=Fedora Linux\n"), "Fedora Linux");
  }

  function test_parses_missing_pretty_name_to_empty() {
    compare(SystemInfo.parsePrettyName("NAME=\"NixOS\"\n"), "");
    compare(SystemInfo.parsePrettyName(""), "");
    compare(SystemInfo.parsePrettyName(null), "");
  }

  function test_parses_meminfo() {
    const memory = SystemInfo.parseMeminfo("MemTotal:       16384000 kB\nMemFree:     1000000 kB\nMemAvailable:  8192000 kB\n");
    verify(memory !== null);
    compare(memory.totalKb, 16384000);
    compare(memory.availableKb, 8192000);
    compare(memory.usedFraction, 0.5);
  }

  function test_parses_meminfo_without_available() {
    const memory = SystemInfo.parseMeminfo("MemTotal:  16384000 kB\n");
    compare(memory, null);
  }

  function test_parses_meminfo_null_on_garbage() {
    compare(SystemInfo.parseMeminfo(""), null);
    compare(SystemInfo.parseMeminfo(null), null);
  }

  function test_parses_cpu_ticks() {
    const ticks = SystemInfo.parseCpuTicks("cpu  100 10 50 800 20 0 10 5 0 0\ncpu0 1 2 3 4\n");
    compare(ticks.length, 8);
    compare(ticks[0], 100);
    compare(ticks[7], 5);
  }

  function test_parses_cpu_ticks_null_on_garbage() {
    compare(SystemInfo.parseCpuTicks("garbage"), null);
    compare(SystemInfo.parseCpuTicks(""), null);
    compare(SystemInfo.parseCpuTicks(null), null);
  }

  function test_cpu_fraction() {
    // 400 ticks elapsed, 100 of them busy (800 -> 1200 idle).
    const prev = [100, 0, 100, 800, 0, 0, 0, 0];
    const next = [200, 0, 200, 1200, 0, 0, 0, 0];
    const fraction = SystemInfo.cpuFraction(prev, next);
    verify(fraction > 0.0 && fraction <= 1.0);
    fuzzyCompare(fraction, 1 / 3, 0.0001);
  }

  function test_cpu_fraction_zero_when_unusable() {
    compare(SystemInfo.cpuFraction(null, [1, 2, 3, 4, 5, 6, 7, 8]), 0);
    compare(SystemInfo.cpuFraction([1, 2], [1, 2, 3, 4]), 0);
    compare(SystemInfo.cpuFraction([0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0]), 0);
    const frozen = [1, 1, 1, 1, 1, 1, 1, 1];
    compare(SystemInfo.cpuFraction(frozen, frozen), 0);
  }

  function test_parses_cpu_temp() {
    compare(SystemInfo.parseCpuTemp("45500\n"), 45.5);
    compare(SystemInfo.parseCpuTemp("71250"), 71.25);
    compare(SystemInfo.parseCpuTemp(""), null);
    compare(SystemInfo.parseCpuTemp("nope"), null);
  }

  function test_parses_df() {
    const disk = SystemInfo.parseDf("Filesystem 1024-blocks  Used Available Capacity Mounted on\n/dev/root        1000   440       560      44% /\n");
    verify(disk !== null);
    compare(disk.totalKb, 1000);
    compare(disk.usedKb, 440);
    compare(disk.usedFraction, 0.44);
  }

  function test_parses_df_null_on_garbage() {
    compare(SystemInfo.parseDf(""), null);
    compare(SystemInfo.parseDf("nonsense only"), null);
    compare(SystemInfo.parseDf(null), null);
  }

  function test_parses_uptime() {
    compare(SystemInfo.parseUptime("123456.78 234567.89\n"), 123456);
    compare(SystemInfo.parseUptime("garbage"), -1);
    compare(SystemInfo.parseUptime(null), -1);
  }

  function test_parses_kernel_version() {
    compare(SystemInfo.parseKernelVersion("Linux version 6.16.7 (gcc 14.3.0) #1 SMP"), "6.16.7");
    compare(SystemInfo.parseKernelVersion(""), "");
  }

  function test_parses_hyprland_version() {
    compare(SystemInfo.parseHyprlandVersion('{"branch":"main","version":"v0.56.2"}'), "0.56.2");
    compare(SystemInfo.parseHyprlandVersion("not json"), "");
    compare(SystemInfo.parseHyprlandVersion('{"branch":"main"}'), "");
  }

  function test_formats_percent() {
    compare(SystemInfo.formatPercent(0.425), "43%");
    compare(SystemInfo.formatPercent(0), "0%");
    compare(SystemInfo.formatPercent(1), "100%");
    compare(SystemInfo.formatPercent(-1), "--");
  }

  function test_formats_temp() {
    compare(SystemInfo.formatTempC(45.6), "46°");
    compare(SystemInfo.formatTempC(-1), "--");
  }

  function test_describes_uptime() {
    compare(SystemInfo.describeUptime(9), "less than a minute");
    compare(SystemInfo.describeUptime(600), "10m");
    compare(SystemInfo.describeUptime(2 * 3600 + 14 * 60), "2h 14m");
    compare(SystemInfo.describeUptime(5 * 86400 + 3 * 3600 + 42 * 60), "5d 3h");
    compare(SystemInfo.describeUptime(-1), "--");
  }

  function test_formats_kibibyte_pair() {
    compare(SystemInfo.formatKibPair(4404019, 16384000), "4.2 / 15.6 GiB");
    compare(SystemInfo.formatKibPair(512000, 1024000), "500 / 1000 MiB");
    compare(SystemInfo.formatKibPair(-1, -1), "--");
  }
}
