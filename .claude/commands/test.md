---
description: Run the tests (all, or for the given path) and report the results honestly
argument-hint: "[path or test name]"
disable-model-invocation: true
---

Run the tests for: $ARGUMENTS (if empty, the whole suite), using the test command in `docs/stack.md`.

Report: the command, pass/fail counts, and for each failure the test name with a one-line reason.
Then stop. Offer, without starting: the debugger agent for failures, or the test-writer agent
if changed code has no tests.
