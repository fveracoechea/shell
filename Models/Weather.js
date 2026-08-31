/**
 * Open-Meteo payload normalization and WMO weather code description.
 *
 * `parse` is the seam between the raw HTTP response (see the Weather
 * Feature Service) and the views: it receives the raw body text and the
 * fetch timestamp and returns the single normalized shape used by the
 * dashboard, or null when the payload is missing or structurally invalid.
 */

/**
 * The refresh interval used by the Weather Feature Service, in
 * milliseconds. Staleness is measured against twice this interval.
 */
const refreshIntervalMs = 30 * 60 * 1000;

/**
 * Parses a raw Open-Meteo response body into the normalized shape.
 *
 * @param {string|null} body - raw HTTP response text
 * @param {number} fetchedAtMs - wall-clock time of the fetch
 * @returns {null | {current: {temperatureC: number, apparentC: number, humidity: number, code: number, isDay: boolean, windKph: number}, daily: Array<{date: string, code: number, maxC: number, minC: number, precipProbMax: number, sunrise: string, sunset: string}>, fetchedAtMs: number}}
 *   null when the body is missing, unparsable, or structurally invalid
 */
function parse(body, fetchedAtMs) {
  if (typeof body !== "string" || body.length === 0) {
    return null;
  }
  let payload;
  try {
    payload = JSON.parse(body);
  } catch (error) {
    return null;
  }
  if (payload === null || typeof payload !== "object") {
    return null;
  }
  const current = parseCurrent(payload.current);
  const daily = parseDaily(payload.daily);
  if (current === null || daily === null) {
    return null;
  }
  return {
    current: current,
    daily: daily,
    fetchedAtMs: fetchedAtMs
  };
}

/**
 * Validates the `current` object of an Open-Meteo payload.
 *
 * @param {object|null} raw - raw `current` object from the payload
 * @returns {null | {temperatureC: number, apparentC: number, humidity: number, code: number, isDay: boolean, windKph: number}}
 *   null when any current field is missing or not a finite number
 */
function parseCurrent(raw) {
  if (raw === undefined || raw === null || typeof raw !== "object") {
    return null;
  }
  const temperatureC = numberOf(raw.temperature_2m);
  const apparentC = numberOf(raw.apparent_temperature);
  const humidity = numberOf(raw.relative_humidity_2m);
  const code = numberOf(raw.weather_code);
  const windKph = numberOf(raw.wind_speed_10m);
  if (temperatureC === null || apparentC === null || humidity === null || code === null || windKph === null) {
    return null;
  }
  return {
    temperatureC: temperatureC,
    apparentC: apparentC,
    humidity: humidity,
    code: code,
    isDay: raw.is_day === 1,
    windKph: windKph
  };
}

/**
 * Validates the `daily` object of an Open-Meteo payload.
 *
 * @param {object|null} raw - raw `daily` object from the payload
 * @returns {null | Array<{date: string, code: number, maxC: number, minC: number, precipProbMax: number, sunrise: string, sunset: string}>}
 *   null when any daily column is missing, not an array, or carries an
 *   unusable entry
 */
function parseDaily(raw) {
  if (raw === undefined || raw === null || typeof raw !== "object") {
    return null;
  }
  const columns = [raw.time, raw.weather_code, raw.temperature_2m_max, raw.temperature_2m_min, raw.precipitation_probability_max, raw.sunrise, raw.sunset];
  for (let c = 0; c < columns.length; c++) {
    if (!Array.isArray(columns[c])) {
      return null;
    }
  }
  const days = [];
  for (let i = 0; i < columns[0].length; i++) {
    const date = typeof columns[0][i] === "string" ? columns[0][i] : null;
    const code = numberOf(columns[1][i]);
    const maxC = numberOf(columns[2][i]);
    const minC = numberOf(columns[3][i]);
    const precipProbMax = numberOf(columns[4][i]);
    const sunrise = typeof columns[5][i] === "string" ? columns[5][i] : null;
    const sunset = typeof columns[6][i] === "string" ? columns[6][i] : null;
    if (date === null || code === null || maxC === null || minC === null || precipProbMax === null || sunrise === null || sunset === null) {
      return null;
    }
    days.push({
      date: date,
      code: code,
      maxC: maxC,
      minC: minC,
      precipProbMax: precipProbMax,
      sunrise: sunrise,
      sunset: sunset
    });
  }
  return days;
}

/**
 * Narrows a payload value to a finite number.
 *
 * @param {unknown} value - raw payload value
 * @returns {number | null} the number, or null when not finite
 */
function numberOf(value) {
  return typeof value === "number" && isFinite(value) ? value : null;
}

/**
 * Maps a WMO weather interpretation code to a display label and an icon
 * key usable with the Material Symbols Rounded icon component.
 *
 * @param {number} code - WMO weather interpretation code
 * @returns {{label: string, iconKey: string}} label for text, iconKey for
 *   the icon component
 */
function describe(code) {
  if (code === 0) {
    return {label: "Clear", iconKey: "clear_day"};
  }
  if (code === 1) {
    return {label: "Mainly clear", iconKey: "partly_cloudy_day"};
  }
  if (code === 2) {
    return {label: "Partly cloudy", iconKey: "partly_cloudy_day"};
  }
  if (code === 3) {
    return {label: "Overcast", iconKey: "cloud"};
  }
  if (code === 45 || code === 48) {
    return {label: "Fog", iconKey: "foggy"};
  }
  if ((code >= 51 && code <= 57) || (code >= 61 && code <= 67)) {
    if (code === 65) {
      return {label: "Heavy rain", iconKey: "rainy_heavy"};
    }
    if (code === 66 || code === 67) {
      return {label: "Freezing rain", iconKey: "rainy"};
    }
    return {label: "Rain", iconKey: "rainy"};
  }
  if (code >= 80 && code <= 82) {
    return {label: "Rain showers", iconKey: "rainy"};
  }
  if ((code >= 71 && code <= 77) || code === 85 || code === 86) {
    return {label: "Snow", iconKey: "snowing"};
  }
  if (code === 95) {
    return {label: "Thunderstorm", iconKey: "thunderstorm"};
  }
  if (code === 96 || code === 99) {
    return {label: "Thunderstorm with hail", iconKey: "thunderstorm"};
  }
  return {label: "Unknown", iconKey: "cloud"};
}

/**
 * Formats a temperature for display, for example "21°".
 *
 * @param {number} celsius - temperature in degrees Celsius
 * @returns {string} rounded display string, or "--" when not usable
 */
function formatTemp(celsius) {
  if (typeof celsius !== "number" || !isFinite(celsius)) {
    return "--";
  }
  return `${Math.round(celsius)}°`;
}

/**
 * Returns the weekday abbreviation for an ISO `yyyy-MM-dd` date string.
 *
 * @param {string} isoDate - date string in `yyyy-MM-dd` form
 * @returns {string} locale weekday abbreviation, or "" when unusable
 */
function dayName(isoDate) {
  const date = parseIsoDate(isoDate);
  if (date === null) {
    return "";
  }
  return Qt.formatDate(date, "ddd");
}

/**
 * Reports whether a payload is older than twice the refresh interval.
 *
 * @param {number} fetchedAtMs - timestamp of the last good fetch; 0 means
 *   never fetched
 * @param {number} nowMs - current time
 * @returns {boolean} true when the payload is present and stale
 */
function isStale(fetchedAtMs, nowMs) {
  if (!(fetchedAtMs > 0)) {
    return false;
  }
  return nowMs - fetchedAtMs > 2 * refreshIntervalMs;
}

/**
 * Resolves the Weather Feature Service status enum.
 *
 * Order of precedence: the service reports "loading" until its first fetch
 * settles, "unavailable" after any failed fetch (the last good payload is
 * retained), "stale" when the last good payload is older than twice the
 * refresh interval, and "ready" otherwise.
 *
 * @param {boolean} started - whether at least one fetch has settled
 * @param {boolean} failed - whether the most recent fetch failed
 * @param {number} fetchedAtMs - timestamp of the last good fetch; 0 means
 *   never fetched
 * @param {number} nowMs - current time
 * @returns {string} "loading", "ready", "unavailable", or "stale"
 */
function serviceStatus(started, failed, fetchedAtMs, nowMs) {
  if (!started) {
    return "loading";
  }
  if (failed) {
    return "unavailable";
  }
  return isStale(fetchedAtMs, nowMs) ? "stale" : "ready";
}

/**
 * Parses an ISO `yyyy-MM-dd` date string into a local Date.
 *
 * @param {unknown} isoDate - date string in `yyyy-MM-dd` form
 * @returns {Date | null} local midnight of the date, or null when the
 *   string is not three integer components joined by hyphens
 */
function parseIsoDate(isoDate) {
  if (typeof isoDate !== "string") {
    return null;
  }
  const parts = isoDate.split("-");
  if (parts.length !== 3) {
    return null;
  }
  const year = Number(parts[0]);
  const month = Number(parts[1]);
  const day = Number(parts[2]);
  if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day)) {
    return null;
  }
  return new Date(year, month - 1, day);
}
