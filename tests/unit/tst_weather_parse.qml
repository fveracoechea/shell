import QtQuick
import QtTest

import "../../Models/Weather.js" as Weather

TestCase {
  name: "WeatherParse"

  readonly property string validBody: JSON.stringify({
    "current": {
      "temperature_2m": 21.4,
      "relative_humidity_2m": 55,
      "apparent_temperature": 20.4,
      "is_day": 1,
      "weather_code": 2,
      "wind_speed_10m": 12.4
    },
    "daily": {
      "time": ["2026-08-30", "2026-08-31", "2026-09-01", "2026-09-02", "2026-09-03", "2026-09-04", "2026-09-05"],
      "weather_code": [1, 2, 3, 61, 80, 95, 0],
      "temperature_2m_max": [28.1, 27.4, 27.9, 26.0, 24.9, 23.2, 26.8],
      "temperature_2m_min": [15.2, 14.8, 15.0, 15.2, 15.1, 14.2, 15.0],
      "precipitation_probability_max": [5, 10, 12, 80, 60, 95, 0],
      "sunrise": ["2026-08-30T06:42", "2026-08-31T06:43", "2026-08-31T06:43", "2026-08-31T06:43", "2026-08-30T06:42", "2026-08-30T06:42", "2026-08-30T06:42"],
      "sunset": ["2026-08-30T19:47", "2026-08-31T19:45", "2026-08-31T19:45", "2026-08-31T19:45", "2026-08-31T19:45", "2026-08-31T19:45", "2026-08-31T19:45"]
    }
  })

  function test_parses_valid_payload() {
    const parsed = Weather.parse(validBody, 1000);
    verify(parsed !== null);
    compare(parsed.current.temperatureC, 21.4);
    compare(parsed.current.apparentC, 20.4);
    compare(parsed.current.humidity, 55);
    compare(parsed.current.code, 2);
    compare(parsed.current.isDay, true);
    compare(parsed.current.windKph, 12.4);
    compare(parsed.daily.length, 7);
    compare(parsed.daily[0].date, "2026-08-30");
    compare(parsed.daily[0].code, 1);
    compare(parsed.daily[0].maxC, 28.1);
    compare(parsed.daily[0].minC, 15.2);
    compare(parsed.daily[0].precipProbMax, 5);
    compare(parsed.daily[0].sunrise, "2026-08-30T06:42");
    compare(parsed.daily[0].sunset, "2026-08-30T19:47");
    compare(parsed.fetchedAtMs, 1000);
  }

  function test_parses_empty_body_to_null() {
    compare(Weather.parse(""), null);
    compare(Weather.parse(null), null);
  }

  function test_parses_invalid_json_to_null() {
    compare(Weather.parse("{not json"), null);
  }

  function test_parses_missing_current_to_null() {
    compare(Weather.parse(JSON.stringify({
      "daily": {
        "time": ["2026-08-30"],
        "weather_code": [1]
      }
    }), 1), null);
  }

  function test_parses_missing_daily_to_null() {
    compare(Weather.parse(JSON.stringify({
      "current": {
        "temperature_2m": 21.5,
        "relative_humidity_2m": 55,
        "apparent_temperature": 20.9,
        "is_day": 1,
        "weather_code": 1,
        "wind_speed_10m": 12.2
      }
    }), 1), null);
  }

  function test_describes_clear_code() {
    const described = Weather.describe(0);
    compare(described.label, "Clear");
    compare(described.iconKey, "clear_day");
  }

  function test_describes_rain_codes() {
    compare(Weather.describe(61).label, "Rain");
    compare(Weather.describe(65).label, "Heavy rain");
    compare(Weather.describe(65).iconKey, "rainy_heavy");
    compare(Weather.describe(80).label, "Rain showers");
  }

  function test_describes_snow_and_storm() {
    compare(Weather.describe(71).label, "Snow");
    compare(Weather.describe(75).iconKey, "snowing");
    compare(Weather.describe(95).label, "Thunderstorm");
    compare(Weather.describe(96).label, "Thunderstorm with hail");
  }

  function test_describes_unknown_code() {
    const described = Weather.describe(42);
    compare(described.label, "Unknown");
    compare(described.iconKey, "cloud");
  }

  function test_formats_temperature() {
    compare(Weather.formatTemp(21.4), "21°");
    compare(Weather.formatTemp(-3.6), "-4°");
    compare(Weather.formatTemp(Number.NaN), "--");
  }

  function test_day_name() {
    compare(Weather.dayName("2026-08-30"), "Sun");
    compare(Weather.dayName("2026-08-31"), "Mon");
  }

  function test_is_stale() {
    compare(Weather.isStale(0, 1000), false);
    compare(Weather.isStale(1000, 1000 + 59 * 60 * 1000), false);
    compare(Weather.isStale(1000, 1000 + 61 * 60 * 1000), true);
  }

  function test_service_status_is_loading_before_first_fetch() {
    compare(Weather.serviceStatus(false, false, 0, 0), "loading");
    compare(Weather.serviceStatus(false, true, 0, 0), "loading");
  }

  function test_service_status_unavailable_keeps_payload_signal() {
    // A failed fetch is unavailable even with a last good payload.
    compare(Weather.serviceStatus(true, true, 0, 1000), "unavailable");
    compare(Weather.serviceStatus(true, true, 1000, 1000 + 61 * 60 * 1000), "unavailable");
  }

  function test_service_status_ready_and_stale() {
    const fetchedAtMs = 1000;
    compare(Weather.serviceStatus(true, false, fetchedAtMs, fetchedAtMs), "ready");
    compare(Weather.serviceStatus(true, false, fetchedAtMs, fetchedAtMs + 59 * 60 * 1000), "ready");
    compare(Weather.serviceStatus(true, false, fetchedAtMs, fetchedAtMs + 61 * 60 * 1000), "stale");
  }
}
