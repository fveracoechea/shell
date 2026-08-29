#!/usr/bin/env bash
# Runs the deterministic QtQuick Test suite over tests/unit with no
# Quickshell, display, DBus, GPU, or home dependency. Writes plain text
# results to stdout and JUnit XML to results/junit.xml, and preserves the
# QtTest exit status.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

budget_seconds=10
vfs=results/vfs
junit=results/junit.xml

if ! scripts/build-import-tree.sh "$vfs" >/dev/null; then
  echo "Failed to build the QML import tree." >&2
  exit 1
fi
mkdir -p results
rm -f "$junit"

LC_ALL=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  timeout "$budget_seconds" qmltestrunner \
  -import "$PWD/$vfs" -input tests/unit \
  -o -,txt -o "$junit,junitxml"
status=$?

if [ "$status" -eq 124 ]; then
  echo "Test suite exceeded the ${budget_seconds}s budget." >&2
elif [ "$status" -eq 0 ]; then
  echo "JUnit XML written to $junit."
else
  echo "JUnit XML written to $junit." >&2
fi
exit "$status"
