default:
  @just --list

# Run the shell configuration against a live Quickshell session
dev:
  nix develop --command qs -p ./shell.qml

# Rewrite QML files into the required format (mutating fixer)
format:
  nix develop --command bash -c 'git ls-files -z --cached --others --exclude-standard -- "*.qml" | xargs -0 qmlformat --inplace'

# Typecheck production and test JavaScript
typecheck:
  nix develop --command bash scripts/typecheck.sh

# Lint production and test QML against the generated import tree
lint:
  nix develop --command bash scripts/lint.sh

# Compile every production QML document through the engine compiler
compile:
  nix develop --command bash scripts/compile.sh

# Run the deterministic QtQuick Test suite
test:
  nix develop --command bash scripts/test.sh

# Run the isolated Quickshell smoke check
smoke:
  nix develop --command bash scripts/smoke.sh

# Regenerate the editor QML import configuration (.qmlls.ini)
lsp:
  nix develop --command bash scripts/lsp-setup.sh

# Run the full verification: format gate, type check, lint, compile, tests, smoke
check:
  nix develop --command bash scripts/check.sh
