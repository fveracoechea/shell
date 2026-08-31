#!/usr/bin/env bash
# The verification command: runs the format gate, type check, lint, engine
# compile gate, deterministic test suite, and smoke check in cheapest-first
# order and fails fast. Composes the other scripts; it owns no harness logic
# itself.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

step() {
  printf '\n== %s ==\n' "$1"
  shift
  "$@"
  status=$?
  if [ "$status" -ne 0 ]; then
    printf '\n== check failed ==\n' >&2
    exit "$status"
  fi
}

step "Format gate" scripts/format-gate.sh
step "Type check" scripts/typecheck.sh
step "Lint" scripts/lint.sh
step "Compile" scripts/compile.sh
step "Test suite" scripts/test.sh
step "Smoke check" scripts/smoke.sh

printf '\n== check passed ==\n'
