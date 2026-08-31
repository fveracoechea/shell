# Testing

This document records the feedback contract that coding agents use to verify
changes. The vocabulary here (verification command, compile gate, test suite,
smoke check, pure module, platform adapter, injected property, runner
boundary) is defined in [CONTEXT.md](../CONTEXT.md). This document describes
the commands as they exist in the scripts; it never describes aspiration.

## Command guarantees

Every command runs through `nix develop`, so tool versions are pinned by
`flake.nix`. All recipes are defined in the `justfile`.

- `just check` runs the format gate, type check, lint, compile gate, test
  suite, and smoke check in cheapest-first order. It fails fast: it stops at
  the first gate that fails and exits with that gate's status. It prints
  `== check failed ==` with the failed gate name, or `== check passed ==` on
  success.
- The format gate (inside `just check`) fails when a tracked or untracked QML
  file differs from its `qmlformat` output. It never modifies files; it
  prints a per-file diff. `just format` is the mutating fixer.
- `just typecheck` runs `tsc` over project `.js`, `.mjs`, and `.cjs` files
  through `tsconfig.json`.
- `just lint` runs `qmllint` over tracked and untracked QML using the
  generated import tree plus the Quickshell and Qt QML import paths from
  `QML_IMPORT_PATH`, then `shellcheck` over `scripts/*.sh`, then `actionlint`
  over GitHub workflows.
- `just compile` runs the engine compile gate: every production QML document
  (tracked and untracked, excluding `tests/`) is compiled through
  `qmlcachegen`. This catches engine compile-stage load failures that
  `qmllint` does not report, such as duplicate signal handlers. It is the
  load-failure signal for window surfaces, because the offscreen smoke
  harness has no window backend and cannot instantiate them.
- `just test` runs `qmltestrunner` over `tests/unit` with no Quickshell,
  display, DBus, GPU, or home dependency. It uses the offscreen platform and
  software rendering, so it is deterministic. It preserves the QtTest exit
  status, including the budget timeout status.
- `just smoke` runs every fixture in `tests/smoke/<case>` as an isolated
  Quickshell launch and judges the smoke signal: process exit, the
  `SHELL_HEALTHY` health sentinel in the log, and `@shell.qml` diagnostic
  lines (WARN or ERROR). Each case gets a fresh private HOME and XDG tree;
  the display and DBus session are removed.
- CI runs `just check` on every push and pull request (`.github/workflows/`
  `check`, 10-minute job timeout) and uploads `results/` as artifacts on
  failure.

## Narrow runs

To run a single unit test file (after the import tree exists; `just test` or
`just lint` builds it first):

```sh
nix develop --command bash scripts/build-import-tree.sh
nix develop --command bash -c 'LC_ALL=C.UTF-8 QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software qmltestrunner -import "$PWD/results/vfs" -input tests/unit/tst_clock_format.qml'
```

The smoke harness always runs all declared cases. Run `just smoke`, then read
the retained `results/smoke/<case>.log` for a specific case.

## Timeouts

- Test suite: hard budget of 10 seconds for the whole `qmltestrunner` run.
  Exceeding it exits with status 124 and a clear message.
- Smoke check: hard deadline of 30 seconds per case, including graceful IPC
  shutdown. At the deadline, the harness escalates to TERM and KILL.
- Full local verification: advisory budget of 2 minutes. Exceeding it triggers
  a review of suite scope and runner cost; it is not a hard timeout.

## Artifacts

- `results/junit.xml`: JUnit XML from the test suite.
- `results/smoke/<case>.log`: full diagnostic log of each smoke case,
  retained on every exit.
- `results/vfs/`: generated QML import tree exposing `qs.*` module paths as
  symlinks. Generated on every run; never edit it.
- `results/compile/`: generated ahead-of-time compilation outputs from the
  compile gate; the compile verdict is the gate's exit status.
- `results/` is not tracked. CI uploads it only on failure.

## Directory and extension rules

- Production QML lives in `Components/`, `Modules/`, and `Models/`; module
  identity comes from tracked `qmldir` files, which are never synthesized.
- A unit test is any `tests/unit/*.qml` file importing `QtTest`. The runner
  picks up every file; no harness change is needed to add one.
- A smoke case is a directory `tests/smoke/<case>/` with `shell.qml` and a
  one-word `contract` file (`healthy`, `load-failure`, or `post-load-error`).
  The harness discovers every case directory; unknown or missing contracts
  are harness failures, so no harness change is needed to add a case.
- A `healthy` smoke fixture should instantiate as much real composed QML as
  the offscreen harness allows. The composed fixture instantiates the full
  dashboard composition against local Feature Services and deterministic
  weather inputs, so the smoke check stays network-free; window surfaces
  cannot be instantiated offscreen and are instead covered by the compile
  gate. A minimal fixture that only touches components is allowed but
  should not be the only `healthy` fixture for a new surface area.
- A pure module has no Quickshell import in its complete import tree, so the
  test suite can load it. Policy goes in pure JavaScript (`Models/*.js`)
  with JSDoc `@param`/`@returns` on every function. QML functions never
  carry JSDoc; they declare input types with QML parameter annotations.
- A platform adapter is a thin Quickshell-coupled module that supplies
  platform state to a pure module. Keep platform state here, not in views.
- An injected property is a QML property supplied by a production
  composition module or a test. Tests inject fixed values through injected
  properties instead of reaching into platform state.

## Negative fixture rules

- A deliberate failure lives only in `tests/smoke/<case>/` and declares its
  contract in the `contract` file. Never leave a deliberate failure in
  production code or in `tests/unit`.
- `just lint` skips smoke fixtures whose contract is not `healthy`, because
  those files are deliberately broken. `healthy` fixtures are linted like
  production code.
- A smoke case with an unknown or missing contract fails the harness itself.

## Failure diagnosis

- The format gate names each offender and prints its diff; run `just format`.
- The test suite reports failures with the test name, actual and expected
  values, and the source file and line, for example
  `Loc: [...tests/unit/tst_clock_format.qml(48)]`. The retained
  `results/junit.xml` carries the same evidence.
- The smoke check prints, per failed case: the contract, the expected
  signal, the observed exit, sentinel, and diagnostic counts, the diagnostic
  lines themselves, and the retained log path. Compare observed against the
  contract meanings: `healthy` wants exit 0, sentinel present, no
  diagnostics; `load-failure` wants a nonzero exit, no sentinel, and
  diagnostics; `post-load-error` wants exit 0, sentinel present, and
  diagnostics.
- If `qmllint` reports `QML_IMPORT_PATH is not set`, you ran the script
  without the Nix environment; use the `just` recipes.

## Verified red-green proof

The fail-fast diagnosis was proven end to end on this repository. Steps and
evidence:

1. Baseline: `just check` passed (18 test assertions, 3 smoke cases).
2. Mutation: one expected string in `tests/unit/tst_clock_format.qml` was
   changed from `...August 29` to `...August 30`.
3. Narrow run:
   `nix develop --command qmltestrunner -import "$PWD/results/vfs" -input tests/unit/tst_clock_format.qml`
   reported `FAIL! ... Compared values are not the same`, actual
   `3:05 PM - Saturday, August 29`, expected `3:05 PM - Saturday, August 30`,
   at `tests/unit/tst_clock_format.qml(48)`, and exited 1.
4. `just check` failed fast at the Test suite stage
   (`17 passed, 1 failed`, then `== check failed ==`, exit 1). The smoke
   check never ran.
5. Restoration: the file was restored and its checksum matched the
   pre-mutation checksum (`197717b95d690db39777afeb255267a7`), and
   `git diff` was clean.
6. Recovery: `just format`, `just lint`, `just typecheck`, `just test`,
   `just smoke`, and `just check` all passed again.

No deliberate failure is committed.

## Compile gate and composed fixture red-green proof

The compile gate and the composed smoke fixture were proven against the
failure class that motivated them (duplicate signal handlers make a QML
document fail to compile, and the offscreen harness cannot instantiate
window surfaces):

1. Baseline: `just compile` and `just smoke` passed with the composed
   fixture present.
2. Mutation: a second identical `onOpenChanged` handler was added to
   `Modules/DropdownSurface.qml`. `just compile` failed with
   `Property value set multiple times`, and `just smoke` still passed,
   which is exactly the gap the compile gate closes.
3. Restoration: the file was restored and `just compile` passed again.
4. Composition mutation: two duplicate signal handlers were added to
   `Modules/Dash/Dashboard.qml`. `just smoke` failed the `composed` case
   (healthy contract, no sentinel, retained log at
   `results/smoke/composed.log`).
5. Restoration: `just smoke` passed again (4 case(s)).

No deliberate failure is committed.
