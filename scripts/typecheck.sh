#!/usr/bin/env bash
# Typechecks production and test JavaScript with the TypeScript compiler.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

shopt -s globstar nullglob
files=(**/*.js **/*.mjs **/*.cjs)
if (( ${#files[@]} )); then
  tsc --project tsconfig.json
else
  printf "%s\n" "No JavaScript files to typecheck."
fi
