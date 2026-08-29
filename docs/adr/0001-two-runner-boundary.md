# Two-runner boundary: qmltestrunner for seams, Quickshell only for smoke

Testing this configuration requires a runner split, and each half owns a
different job. The runner boundary is: QtQuick Test (`qmltestrunner`) verifies
deterministic seams in pure modules through injected properties, and Quickshell
supplies only the smoke signal from isolated launches of the composed
configuration. This is the accepted architecture, so neither runner may absorb
the other's job: do not add Quickshell imports to unit tests, and do not add
assertion logic to smoke fixtures.

## Considered Options

- Run assertions inside Quickshell. Rejected: `TestCase` bodies execute, but
  assertion failures produce no QtTest failure output or nonzero exit.
- Load the complete configuration in `qmltestrunner`. Rejected: the Quickshell
  plugin cannot load in its foreign QML engine, so platform types are
  unavailable.
- Drop the smoke check and rely on manual `just dev`. Rejected: the
  configuration would break without any local signal.

## Consequences

- Lint and unit-test `qs.*` imports resolve through `results/vfs`, built fresh
  on each run by `scripts/build-import-tree.sh`. Live Quickshell owns its
  runtime import tree.
- Unit tests depend only on pure modules; platform state reaches them through
  injected properties supplied by adapters in production and by tests.
- Smoke fixtures that deliberately fail declare a `contract` file and are
  excluded from lint; see `docs/testing.md`.
