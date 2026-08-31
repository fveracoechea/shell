#!/usr/bin/env bash
# Format gate: fails when a production QML file differs from its
# `qmlformat` output. Prints the file name and diff for every offender.
# The mutating fixer is `just format`. Untracked files are checked too, so
# the gate verifies the whole working tree, not only committed files.
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

failures=0
while IFS= read -r -d "" file; do
  formatted="$work/$(echo "$file" | tr / _)"
  if ! qmlformat "$file" >"$formatted" 2>"$work/error"; then
    echo "qmlformat failed on $file:" >&2
    cat "$work/error" >&2
    failures=$((failures + 1))
    continue
  fi
  if ! diff -u --label "a/$file" --label "b/$file" "$file" "$formatted" >"$work/diff"; then
    echo "Not formatted: $file"
    cat "$work/diff"
    failures=$((failures + 1))
  fi
done < <(git ls-files -z --cached --others --exclude-standard -- "*.qml")

if [ "$failures" -gt 0 ]; then
  echo "Format gate failed ($failures file(s)). Run 'just format' to fix." >&2
  exit 1
fi
