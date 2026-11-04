---
name: testing
description: Writes and runs tests for this repo and reports results honestly. Use when adding or fixing tests, checking a change, or when asked whether something works.
---

# Testing

## What to test
- One test per behaviour, named for the behaviour: `test_<what happens>_when_<condition>`.
- Cover: the normal case, one edge case (empty, zero, maximum), and one failure case.
- Test through the public interface, not private helpers.
- Fake only what is slow or outside the process (network, paid APIs, clock). Prefer real objects otherwise.
- A bug fix starts with a test that fails for the bug.

## Workflow
```
- [ ] 1. Find existing tests for the area; follow their style and fixtures
- [ ] 2. Write or update the tests
- [ ] 3. Run only the affected tests first (fast feedback)
- [ ] 4. If red: decide whether the test or the code is wrong, fix that one, rerun
- [ ] 5. Run the wider suite once before saying "done"
- [ ] 6. Report: command run, passed/failed counts, any test skipped and why
```
Repeat steps 3–4 until green. Never weaken or delete an assertion to make a test pass;
if a test looks wrong, say so and ask.

Test commands are in `docs/stack.md`.
