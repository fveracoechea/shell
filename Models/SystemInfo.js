/**
 * Linux system identity and performance normalization.
 *
 * These functions are the seam between the System Feature Service (raw
 * `/proc`, `/sys`, `/etc`, and `df` inputs) and the dashboard views. All
 * functions are pure and return `null` or the documented sentinel when an
 * input is unusable, so views can show empty states instead of guessing.
 */

/**
 * Extracts PRETTY_NAME from `/etc/os-release` contents.
 *
 * @param {string|null} text - raw file contents
 * @returns {string} the pretty name without surrounding quotes, or ""
 *   when absent
 */
function parsePrettyName(text) {
  if (typeof text !== "string") {
    return "";
  }
  const match = text.match(/^PRETTY_NAME="?([^"\n]*)"?\s*$/m);
  return match === null ? "" : match[1];
}

/**
 * Extracts the kernel version from `/proc/version` contents.
 *
 * @param {string|null} text - raw file contents
 * @returns {string} version token such as "6.16.7", or "" when absent
 */
function parseKernelVersion(text) {
  if (typeof text !== "string") {
    return "";
  }
  const match = text.match(/^Linux version (\S+)/);
  return match === null ? "" : match[1];
}

/**
 * Extracts the version from `hyprctl version -j` output.
 *
 * @param {string|null} text - raw command output
 * @returns {string} version without a leading `v`, or "" when absent
 */
function parseHyprlandVersion(text) {
  if (typeof text !== "string") {
    return "";
  }
  try {
    const payload = JSON.parse(text);
    if (payload === null || typeof payload !== "object" || typeof payload.version !== "string") {
      return "";
    }
    return payload.version.trim().replace(/^v/, "");
  } catch (error) {
    return "";
  }
}

/**
 * Normalizes `/proc/meminfo` contents.
 *
 * @param {string|null} text - raw file contents
 * @returns {null | {totalKb: number, availableKb: number, usedFraction: number}}
 *   null when MemTotal or MemAvailable is missing
 */
function parseMeminfo(text) {
  const totalKb = meminfoField(text, "MemTotal");
  const availableKb = meminfoField(text, "MemAvailable");
  if (totalKb === null || availableKb === null || totalKb <= 0) {
    return null;
  }
  return {
    totalKb: totalKb,
    availableKb: availableKb,
    usedFraction: clamp((totalKb - availableKb) / totalKb),
  };
}

/**
 * Extracts one `field: N kB` entry from `/proc/meminfo` contents.
 *
 * @param {string|null} text - raw file contents
 * @param {string} field - entry name, for example "MemTotal"
 * @returns {number | null} the field value in kB, or null when absent
 */
function meminfoField(text, field) {
  if (typeof text !== "string") {
    return null;
  }
  const match = text.match(new RegExp(`^${field}:\\s+(\\d+) kB$`, "m"));
  return match === null ? null : Number(match[1]);
}

/**
 * Parses the aggregate `cpu` line of `/proc/stat` into tick counts.
 *
 * @param {string|null} text - raw file contents
 * @returns {number[] | null} [user, nice, system, idle, iowait, irq,
 *   softirq, steal], or null when the line is missing or malformed
 */
function parseCpuTicks(text) {
  if (typeof text !== "string") {
    return null;
  }
  const line = text.match(/^cpu\s+(.+)$/m);
  if (line === null) {
    return null;
  }
  const values = line[1].trim().split(/\s+/).map(Number);
  if (values.length < 8 || values.some((v) => !Number.isFinite(v) || v < 0)) {
    return null;
  }
  return values.slice(0, 8);
}

/**
 * Computes the busy CPU fraction between two `/proc/stat` samples.
 *
 * @param {number[] | null} prev - earlier tick counts
 * @param {number[] | null} next - later tick counts
 * @returns {number} busy fraction in [0, 1]; 0 when either sample is
 *   unusable or no time has passed
 */
function cpuFraction(prev, next) {
  if (!Array.isArray(prev) || !Array.isArray(next) || prev.length < 8 || next.length < 8) {
    return 0;
  }
  const totalPrev = sum(prev);
  const totalNext = sum(next);
  const idlePrev = prev[3] + prev[4];
  const idleNext = next[3] + next[4];
  const deltaTotal = totalNext - totalPrev;
  const deltaBusy = totalNext - idleNext - (totalPrev - idlePrev);
  if (deltaTotal <= 0 || deltaBusy <= 0) {
    return 0;
  }
  return clamp(deltaBusy / deltaTotal);
}

/**
 * Parses a hwmon temperature reading in millidegrees Celsius.
 *
 * @param {string|null} text - raw first-line sensor output
 * @returns {number | null} degrees Celsius, or null when unusable
 */
function parseCpuTemp(text) {
  if (typeof text !== "string") {
    return null;
  }
  const token = text.trim().split(/\s+/)[0];
  if (token === undefined || token === "") {
    return null;
  }
  const value = Number(token);
  return Number.isFinite(value) ? value / 1000 : null;
}

/**
 * Parses `df -kP` output for the last filesystem line.
 *
 * @param {string|null} text - raw command output
 * @returns {null | {totalKb: number, usedKb: number, usedFraction: number}}
 *   null when no usable data line exists
 */
function parseDf(text) {
  if (typeof text !== "string") {
    return null;
  }
  const lines = text.trim().split("\n");
  if (lines.length < 2) {
    return null;
  }
  const fields = lines[lines.length - 1].trim().split(/\s+/);
  if (fields.length < 6) {
    return null;
  }
  const totalKb = Number(fields[1]);
  const usedKb = Number(fields[2]);
  if (!Number.isFinite(totalKb) || !Number.isFinite(usedKb) || totalKb <= 0) {
    return null;
  }
  return {
    totalKb: totalKb,
    usedKb: usedKb,
    usedFraction: clamp(usedKb / totalKb),
  };
}

/**
 * Parses the uptime seconds from `/proc/uptime`.
 *
 * @param {string|null} text - raw file contents
 * @returns {number} whole seconds, or -1 when unusable
 */
function parseUptime(text) {
  if (typeof text !== "string") {
    return -1;
  }
  const value = Number(text.trim().split(/\s+/)[0]);
  return Number.isFinite(value) && value >= 0 ? Math.floor(value) : -1;
}

/**
 * Formats a busy fraction for display, for example "43%".
 *
 * @param {number} fraction - usage fraction in [0, 1]; negative means
 *   "no sample yet"
 * @returns {string} display string
 */
function formatPercent(fraction) {
  if (typeof fraction !== "number" || !isFinite(fraction) || fraction < 0) {
    return "--";
  }
  return `${Math.round(fraction * 100)}%`;
}

/**
 * Formats a Celsius temperature for display, for example "46°".
 *
 * @param {number} celsius - temperature; the -1 sentinel means "no sample"
 * @returns {string} display string
 */
function formatTempC(celsius) {
  if (typeof celsius !== "number" || !isFinite(celsius) || celsius < 0) {
    return "--";
  }
  return `${Math.round(celsius)}°`;
}

/**
 * Describes an uptime in whole seconds, for example "5d 3h".
 *
 * @param {number} seconds - uptime; negative means "no sample yet"
 * @returns {string} display string
 */
function describeUptime(seconds) {
  if (typeof seconds !== "number" || !isFinite(seconds) || seconds < 0) {
    return "--";
  }
  if (seconds < 60) {
    return "less than a minute";
  }
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  if (days > 0) {
    return `${days}d ${hours}h`;
  }
  if (hours > 0) {
    return `${hours}h ${minutes}m`;
  }
  return `${minutes}m`;
}

/**
 * Formats used and total kibibytes as a compact pair.
 *
 * @param {number} usedKb - used capacity in KiB
 * @param {number} totalKb - total capacity in KiB
 * @returns {string} display string such as "4.2 / 15.6 GiB", or "--"
 */
function formatKibPair(usedKb, totalKb) {
  if (!Number.isFinite(usedKb) || !Number.isFinite(totalKb) || usedKb < 0 || totalKb <= 0) {
    return "--";
  }
  const divisor = totalKb >= 1024 * 1024 ? 1024 * 1024 : 1024;
  const unit = divisor === 1024 * 1024 ? "GiB" : "MiB";
  return `${formatDecimal(usedKb / divisor)} / ${formatDecimal(totalKb / divisor)} ${unit}`;
}

/**
 * Formats a capacity value with at most one decimal place.
 *
 * @param {number} value - capacity in the selected unit
 * @returns {string} compact decimal value
 */
function formatDecimal(value) {
  return value >= 100 ? String(Math.round(value)) : value.toFixed(1);
}

/**
 * Sums a list of tick counts.
 *
 * @param {number[]} values - tick counts
 * @returns {number} the sum of all entries
 */
function sum(values) {
  let total = 0;
  for (let i = 0; i < values.length; i++) {
    total += values[i];
  }
  return total;
}

/**
 * Clamps a value into the unit interval.
 *
 * @param {number} value - unbounded value
 * @returns {number} the value limited to [0, 1]
 */
function clamp(value) {
  return Math.min(1, Math.max(0, value));
}
