---
description: Review uncommitted changes (or the given files) with the code-reviewer agent
argument-hint: "[files or git range]"
disable-model-invocation: true
---

Use the code-reviewer agent on: $ARGUMENTS (if empty, the uncommitted changes from `git diff HEAD`).
Show its findings table as it is. Do not fix anything until I choose which findings to fix.
