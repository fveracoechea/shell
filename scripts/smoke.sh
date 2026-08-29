#!/usr/bin/env bash
# Runs every smoke fixture in tests/smoke/<case> as an isolated offscreen
# Quickshell launch and judges the smoke signal: the combined process exit,
# health sentinel, and @shell.qml diagnostic-log evidence.
#
# Each case directory declares its expectation in a one-word `contract`
# file: `healthy`, `load-failure`, or `post-load-error`. Unknown or missing
# contracts are harness failures, so new cases need no harness changes.
#
# Every case gets a fresh private HOME and XDG tree with the display and
# DBus session removed; runtime trees and processes are removed on every
# exit while the diagnostic log is retained at results/smoke/<case>.log.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

sentinel="SHELL_HEALTHY"
timeout_seconds=30
shutdown_grace_seconds=5
vfs=results/vfs
stage_root="results/smoke/.stage"
log_dir="results/smoke"

current_pid=""
current_stage=""
current_iso=""

# Removes the running case process and its private trees on any exit while
# keeping the retained log.
cleanup() {
  if [ -n "$current_pid" ]; then
    kill -KILL "$current_pid" 2>/dev/null || true
  fi
  [ -z "$current_stage" ] || rm -rf "$current_stage"
  [ -z "$current_iso" ] || rm -rf "$current_iso"
}
trap cleanup EXIT

scripts/build-import-tree.sh "$vfs" >/dev/null
mkdir -p "$log_dir" "$stage_root"

failures=0
cases=0

shopt -s nullglob
fixture_dirs=(tests/smoke/*/)
if [ "${#fixture_dirs[@]}" -eq 0 ]; then
  echo "Smoke harness failure: no smoke cases found under tests/smoke." >&2
  exit 1
fi

for fixture_dir in "${fixture_dirs[@]}"; do
  name="$(basename "$fixture_dir")"
  contract="$(cat "${fixture_dir}contract" 2>/dev/null || true)"

  case "$contract" in
    healthy | load-failure | post-load-error) ;;
    *)
      echo "FAIL smoke/$name: unknown or missing contract '${contract:-<none>}'." >&2
      failures=$((failures + 1))
      cases=$((cases + 1))
      continue
      ;;
  esac

  stage="$stage_root/$name"
  iso="$(mktemp -d "${TMPDIR:-/tmp}/qs-smoke-$name.XXXXXX")"
  mkdir -p "$iso/runtime" "$iso/config" "$iso/cache" "$iso/data" "$iso/state"

  rm -rf "$stage"
  mkdir -p "$stage"
  ln -s "$root/${fixture_dir}shell.qml" "$stage/shell.qml"
  for entry in "$vfs"/qs/*; do
    ln -s "$PWD/$entry" "$stage/$(basename "$entry")"
  done

  log="$log_dir/$name.log"
  : >"$log"
  current_stage="$stage"
  current_iso="$iso"

  env -u WAYLAND_DISPLAY -u DISPLAY -u DBUS_SESSION_BUS_ADDRESS \
    XDG_RUNTIME_DIR="$iso/runtime" \
    XDG_CONFIG_HOME="$iso/config" \
    XDG_CACHE_HOME="$iso/cache" \
    XDG_DATA_HOME="$iso/data" \
    XDG_STATE_HOME="$iso/state" \
    HOME="$iso" \
    QT_QPA_PLATFORM=offscreen \
    qs -p "$stage/shell.qml" --no-color --log-times >>"$log" 2>&1 &
  current_pid=$!
  qpid=$current_pid

  # Bounded wait: poll for the sentinel or process exit, with the hard
  # timeout as the deadline that triggers shutdown.
  sentinel_seen=0
  deadline=$((SECONDS + timeout_seconds))
  while :; do
    if grep -q "$sentinel" "$log" 2>/dev/null; then
      sentinel_seen=1
      break
    fi
    if ! kill -0 "$qpid" 2>/dev/null; then
      break
    fi
    if [ "$SECONDS" -ge "$deadline" ]; then
      break
    fi
    sleep 0.05
  done
  grep -q "$sentinel" "$log" 2>/dev/null && sentinel_seen=1

  # Shut down gracefully through Quickshell IPC before escalating.
  if kill -0 "$qpid" 2>/dev/null; then
    XDG_RUNTIME_DIR="$iso/runtime" qs kill --pid "$qpid" >/dev/null 2>&1 || true
    waited=0
    while kill -0 "$qpid" 2>/dev/null && [ "$waited" -lt $((shutdown_grace_seconds * 10)) ]; do
      sleep 0.1
      waited=$((waited + 1))
    done
    if kill -0 "$qpid" 2>/dev/null; then
      kill -TERM "$qpid" 2>/dev/null || true
      sleep 1
      kill -KILL "$qpid" 2>/dev/null || true
    fi
  fi
  wait "$qpid"
  exit_code=$?
  current_pid=""

  diagnostics="$(grep -E "(WARN|ERROR).*@shell\.qml" "$log" || true)"
  diagnostic_count="$(grep -cE "(WARN|ERROR).*@shell\.qml" "$log" || true)"

  verdict="pass"
  case "$contract" in
    healthy)
      [ "$exit_code" -eq 0 ] || verdict="fail"
      [ "$sentinel_seen" -eq 1 ] || verdict="fail"
      [ -z "$diagnostics" ] || verdict="fail"
      ;;
    load-failure)
      [ "$exit_code" -ne 0 ] || verdict="fail"
      [ "$sentinel_seen" -eq 0 ] || verdict="fail"
      ;;
    post-load-error)
      [ "$exit_code" -eq 0 ] || verdict="fail"
      [ "$sentinel_seen" -eq 1 ] || verdict="fail"
      [ -n "$diagnostics" ] || verdict="fail"
      ;;
  esac

  if [ "$verdict" = "pass" ]; then
    printf "pass smoke/%s: contract=%s exit=%s sentinel=%s diagnostics=%s log=%s\n" \
      "$name" "$contract" "$exit_code" "$sentinel_seen" "$diagnostic_count" "$log"
  else
    printf "FAIL smoke/%s: contract=%s\n" "$name" "$contract" >&2
    printf "  expected: %s\n" \
      "$(case "$contract" in
        healthy) echo "exit=0 sentinel=present no @shell.qml diagnostics" ;;
        load-failure) echo "exit!=0 sentinel=absent" ;;
        post-load-error) echo "exit=0 sentinel=present @shell.qml diagnostics" ;;
      esac)" >&2
    printf "  observed: exit=%s sentinel=%s diagnostics=%s\n" \
      "$exit_code" "$sentinel_seen" "$diagnostic_count" >&2
    if [ -n "$diagnostics" ]; then
      printf "%s\n" "$diagnostics" >&2
    fi
    printf "  log retained at %s\n" "$log" >&2
    failures=$((failures + 1))
  fi

  cases=$((cases + 1))
  rm -rf "$stage" "$iso"
  current_stage=""
  current_iso=""
done

if [ "$failures" -gt 0 ]; then
  echo "Smoke check failed ($failures of $cases case(s))." >&2
  exit 1
fi
echo "Smoke check passed ($cases case(s))."
