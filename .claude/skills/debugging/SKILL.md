---
name: debugging
description: Finds the root cause of an error, failing test, or wrong behaviour, then fixes it with proof. Use when something is broken, a test fails, or output is unexpected.
---

# Debugging

Fix the cause, not the symptom. Copy this checklist into your reply:

```
- [ ] 1. Reproduce: the exact command or input that shows the bug
- [ ] 2. Read the full error and stack trace; note the first frame in our code
- [ ] 3. List 2–3 hypotheses, cheapest to check first
- [ ] 4. Test one hypothesis at a time (read code, add a log line, run a small script)
- [ ] 5. State the root cause in one sentence, with the evidence
- [ ] 6. Write a test that fails because of the bug
- [ ] 7. Fix, then confirm the new test and the nearby tests pass
- [ ] 8. Remove temporary logging
```

If a hypothesis is wrong, cross it out and go back to step 3. Do not change code
"to see if it helps" before step 5.

## Report format
- **Symptom:** what the user saw
- **Root cause:** one sentence, with file:line
- **Fix:** what changed and why it addresses the cause
- **Proof:** the test that now passes
- **Related risk:** other places with the same pattern, if any
