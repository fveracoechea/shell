# shell

A Quickshell desktop configuration with a verified coding-agent feedback loop.

The configuration is QML. Every change is verified by one command, `just check`,
which runs the format gate, type check, lint, the deterministic test suite, and
the smoke check. All tools run through the Nix development shell, so a fresh
clone needs only Nix.

## Setup

Enter the development shell before running any command by hand:

```sh
nix develop
```

The `just` recipes enter the shell for you, so you normally do not need this
step.

## Commands

| Command          | Effect                                                              |
| ---------------- | ------------------------------------------------------------------- |
| `just dev`       | Run the configuration against a live Quickshell session             |
| `just format`    | Rewrite QML files into the required format (mutating fixer)         |
| `just typecheck` | Typecheck production and test JavaScript                            |
| `just lint`      | Lint production and test QML, shell scripts, and GitHub workflows   |
| `just test`      | Run the deterministic QtQuick Test suite (no Quickshell runtime)    |
| `just smoke`     | Run the isolated Quickshell smoke check                             |
| `just check`     | Run the full verification: format gate, type check, lint, test, smoke |
| `just`           | List all recipes                                                    |

`just check` is the single verification command. It is cheapest-first and
fails fast, so it names the first broken gate and stops. CI runs the same
command on every push and pull request.

## Layout

- `Components/`, `Modules/`, `Models/`: production QML and JavaScript
- `tests/unit/`: deterministic QtQuick Test files
- `tests/smoke/<case>/`: isolated smoke fixtures, each with a `contract` file
- `scripts/`: verification harness, composed by `scripts/check.sh`
- `docs/testing.md`: testing rules, guarantees, and failure diagnosis
- `CONTEXT.md`: the domain vocabulary used across code, tests, and docs
