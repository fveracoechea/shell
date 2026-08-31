#!/usr/bin/env bash
# Runs qmllint over production QML and unit tests using the generated import
# tree, including untracked files so the whole working tree is verified.
# Smoke fixtures are verified by the smoke check at runtime; deliberate
# negative fixtures are excluded, and only fixtures whose contract is
# `healthy` are linted.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [ -z "${QML_IMPORT_PATH:-}" ]; then
  echo "QML_IMPORT_PATH is not set. Run through 'just' so the Nix environment is active." >&2
  exit 1
fi

vfs=results/vfs
scripts/build-import-tree.sh "$vfs" >/dev/null

flags=()
IFS=: read -ra import_paths <<< "$QML_IMPORT_PATH"
for path in "${import_paths[@]}"; do
  flags+=(-I "$path")
done
flags+=(-I "$PWD/$vfs")

files=()
skipped=()
while IFS= read -r -d "" file; do
  if [[ "$file" == tests/smoke/* ]]; then
    case_dir="${file#tests/smoke/}"
    case_dir="${case_dir%%/*}"
    contract="$(cat "tests/smoke/$case_dir/contract" 2>/dev/null || true)"
    if [ "$contract" != "healthy" ]; then
      skipped+=("$file")
      continue
    fi
  fi
  files+=("$file")
done < <(git ls-files -z --cached --others --exclude-standard -- "*.qml")

if [ "${#skipped[@]}" -gt 0 ]; then
  printf "Skipping deliberate smoke fixtures: %s\n" "${skipped[*]}" >&2
fi

qmllint "${flags[@]}" "${files[@]}"
shellcheck scripts/*.sh
actionlint
echo "Lint passed."
