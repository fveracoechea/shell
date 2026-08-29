# Two-runner boundary: qmltestrunner for seams, Quickshell only for smoke

Testing this configuration requires a runner split, and each half owns a
different job. The runner boundary is: QtQuick Test (`qmltestrunner`) verifies
deterministic seams in pure modules through injected properties, and Quickshell
supplies only the smoke signal from isolated launches of the composed
configuration. This is the accepted architecture, so neither runner may absorb
the other's job: do not add Quickshell imports to unit tests, and do not add
assertion logic to smoke fixtures.

## Considered Options

- Run everything in Quickshell. Rejected: a live Quickshell runtime gives no
  deterministic assertions, and its types cannot load in the `qmltestrunner`
  engine, so pure logic would be untestable headlessly.
- Run everything in `qmltestrunner`. Rejected: platform coupling (the adapter
  layer and the composed configuration) would go unverified.
- Drop the smoke check and rely on manual `just dev`. Rejected: the
  configuration would break without any local signal.

## Consequences

- `qs.*` imports only resolve through the generated import tree
  (`results/vfs`), built fresh on each run by `scripts/build-import-tree.sh`.
- Unit tests depend only on pure modules; platform state reaches them through
  injected properties supplied by adapters in production and by tests.
- Smoke fixtures that deliberately fail declare a `contract` file and are
  excluded from lint; see `docs/testing.md`.
