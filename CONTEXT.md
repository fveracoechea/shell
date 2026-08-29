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
