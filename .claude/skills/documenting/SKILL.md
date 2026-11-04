---
name: documenting
description: Writes or updates project documentation (README, docs/, docstrings, decision log). Use when behaviour, setup, or architecture changes, or when asked to document something.
---

# Documenting

## Which file
| Change | Update |
|---|---|
| Setup, commands, or how to run | `README.md` and `docs/stack.md` |
| Components or data flow | `docs/architecture.md` |
| Naming or style rule | `docs/conventions.md` |
| A choice someone would question | `docs/decisions.md` (date · decision · why · what we gave up) |
| A Claude mistake seen twice | the "Common AI mistakes" list in `CLAUDE.md` (one line) |

## Style
- Plain words, short sentences. Explain a term in one line where it first appears.
- Show, don't describe: a command, a table, or a short example beats a paragraph.
- Write the why; the code already shows the what.
- Docstrings: public functions only. One line for purpose; add args, returns, and raises only when not obvious.
- Never paste secrets, real customer data, or local machine paths.
- One fact lives in one place. Link to it instead of copying it.
- Any doc or skill file over 100 lines starts with a `## Contents` list; Claude may preview only the top.
- New skill files: link reference files directly from SKILL.md (one level deep), never file → file → file.

## Check before finishing
Every command in the changed docs runs as written, every linked path exists,
and nothing contradicts `CLAUDE.md`. Fix anything that fails, then check again.
