---
name: coding
description: Implements or changes application code in this repo, step by step with a self-check. Use when adding a feature, changing behaviour, or refactoring code under src/.
---

# Coding

Copy this checklist into your reply and tick it off:

```
- [ ] 1. Read the target file, its callers, and its existing tests
- [ ] 2. Check docs/conventions.md and docs/decisions.md for anything that applies
- [ ] 3. Search for an existing helper before writing a new one
- [ ] 4. Make the smallest change that does the job
- [ ] 5. Self-check (below)
- [ ] 6. Run the tests for the touched area (testing skill)
- [ ] 7. Summarise: files changed, why, anything left undone
```

## Design defaults
- New feature or project: plan a fully modular structure first (folders and one-job files),
  so code is split before it grows, not after.
- Inputs and outputs explicit; prefer pure functions for logic.
- Keep I/O (network, disk, database, clock) at the edges so core logic stays testable.
- Validate external input at the boundary; trust it inside.
- Fail loudly with a clear message; never swallow an exception silently.
- Calls to outside services (AI providers, payment, email) get a timeout, and a fallback
  if `docs/architecture.md` lists one.

## Self-check (step 5)
1. Does the diff contain only what the task needs? Remove drive-by edits.
2. Does it break any rule in `CLAUDE.md`? Go through them one by one.
3. Did the format hook report lint errors? Fix them.

If any answer fails, fix it and run the self-check again. Go to step 6 only when all three pass.
