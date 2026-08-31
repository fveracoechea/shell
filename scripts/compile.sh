#!/usr/bin/env bash
# Compile gate: compiles every production QML document through the engine's
# ahead-of-time compiler (qmlcachegen). This catches engine compile-stage
# load failures that qmllint does not report, such as duplicate signal
# handlers, which would otherwise only surface at runtime on a live shell.
#
# Window surfaces cannot be instantiated by the smoke check because the
# offscreen harness has no window backend, so this gate is their
# load-failure signal. Output goes to results/compile/ and is not tracked.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

if [ -z "${QML_IMPORT_PATH:-}" ]; then
  echo "QML_IMPORT_PATH is not set. Run through 'just' so the Nix environment is active." >&2
  exit 1
fi

compiler="$(dirname "$(command -v qmllint)")/../libexec/qmlcachegen"
if [ ! -x "$compiler" ]; then
  echo "qmlcachegen not found next to qmllint; check the Nix environment." >&2
  exit 1
fi

vfs=results/vfs
scripts/build-import-tree.sh "$vfs" >/dev/null
out="results/compile"
rm -rf "$out"
mkdir -p "$out"

failures=0
while IFS= read -r -d "" file; do
  case "$file" in
    tests/* | results/*) continue ;;
  esac
  if ! "$compiler" --resource-path "$file" -I "$PWD/$vfs" "$file" -o "$out/$(basename "$file").cpp" >/dev/null; then
    echo "Failed to compile: $file" >&2
    failures=$((failures + 1))
  fi
done < <(git ls-files -z --cached --others --exclude-standard -- "*.qml")

if [ "$failures" -gt 0 ]; then
  echo "Compile gate failed ($failures file(s) failed to compile)." >&2
  exit 1
fi
echo "Compile gate passed."
