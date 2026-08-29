#!/usr/bin/env bash
# Builds the QML import tree that exposes tracked module directories under
# <output>/qs/<module-path> as symlinks, so a fresh clone can lint and test
# `qs.*` imports without a live Quickshell VFS.
#
# Usage: scripts/build-import-tree.sh [output]  (default: results/vfs)
#
# Module discovery is driven by tracked `qmldir` files; tracked `qmldir`
# content is never edited or synthesized. `.git`, `results`, and `tests`
# are excluded from the tree.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

output="${1:-results/vfs}"

rm -rf "$output"
mkdir -p "$output/qs"

modules=0
while IFS= read -r -d "" qmldir; do
  dir="${qmldir%/*}"
  case "$dir" in
    .git/* | results/* | tests/*) continue ;;
  esac
  mkdir -p "$output/qs/$(dirname "$dir")"
  ln -sfn "$root/$dir" "$output/qs/$dir"
  modules=$((modules + 1))
done < <(git ls-files -z "qmldir" "*/qmldir")

echo "Built import tree at $output ($modules modules)."
