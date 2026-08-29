# Shell Configuration

This context defines the language used to develop and verify the Quickshell configuration.

## Language

**Feedback contract**:
The command surface and guarantees that let a coding agent verify a change locally and in CI.

**Verification command**:
The single read-only command that checks formatting, types, lint, deterministic tests, and the smoke check.
_Avoid_: Verify, full test

**Format gate**:
The read-only check that files already have the required format. The separate format command is the fixer.
_Avoid_: Format check

**Test suite**:
The deterministic QtQuick Test suite that exercises code with no Quickshell runtime dependency.
_Avoid_: Unit runner

**Smoke check**:
An isolated Quickshell launch that checks whether the configuration loads and remains healthy.
_Avoid_: Smoke test

**Smoke signal**:
The combined process exit, health sentinel, and diagnostic log evidence produced by a smoke check.

**Runner boundary**:
The ownership split where QtQuick Test verifies deterministic seams and Quickshell supplies only the smoke signal.

**Pure module**:
A module whose complete import tree has no Quickshell dependency, so the test suite can load it.
_Avoid_: Testable module, headless module

**Platform adapter**:
A thin Quickshell-coupled module that supplies platform state to a pure module and is verified through the smoke check.
_Avoid_: Wrapper, shim, bridge

**Injected property**:
A QML property supplied by a production composition module or a test instead of being resolved from platform state.
_Avoid_: Prop
