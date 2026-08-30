#!/usr/bin/env bash
# Generates the editor import configuration: builds the import tree, then
# writes a project-local .qmlls.ini pointing at the tree and the Nix QML
# module paths. Quickshell's managed .qmlls.ini does not resolve plain
# directory imports like `qs.Models`, and its managed importPaths shadow
# command line flags, so the editor needs this generated file instead.
# Rerun after a flake lock update or a module layout change.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [ -z "${QML_IMPORT_PATH:-}" ]; then
  echo "QML_IMPORT_PATH is not set. Run through 'just' so the Nix environment is active." >&2
  exit 1
fi

scripts/build-import-tree.sh results/vfs >/dev/null

printf '[General]\nno-cmake-calls=true\nimportPaths=%s/results/vfs:%s\n' "$PWD" "$QML_IMPORT_PATH" > .qmlls.ini

echo "Wrote .qmlls.ini (import tree + Nix QML modules)."
