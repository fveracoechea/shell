#!/usr/bin/env bash
# Typechecks production and test JavaScript with the TypeScript compiler.
# Documentation assets are browser-side teaching material, not production or
# test JavaScript, so they are excluded.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

shopt -s globstar nullglob
skipped=()
files=()
for file in **/*.js **/*.mjs **/*.cjs; do
  if [[ "$file" == docs/* ]]; then
    skipped+=("$file")
    continue
  fi
  files+=("$file")
done

if [ "${#skipped[@]}" -gt 0 ]; then
  printf "Skipping documentation assets: %s\n" "${skipped[*]}" >&2
fi

if (( ${#files[@]} )); then
  tsc --project tsconfig.json
else
  printf "%s\n" "No JavaScript files to typecheck."
fi
