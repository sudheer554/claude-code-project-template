# Conventions

> Project-specific choices only. Do not restate general good practice; Claude already knows it.
> Language rules that apply automatically live in `.claude/rules/`.

## Naming
| Thing | Pattern | Example |
|---|---|---|
| Files / modules | | |
| Functions | | |
| Classes / types | | |
| Tests | `test_<behaviour>` | `test_rejects_expired_token` |

## Structure
- Where a new feature goes:
- Where shared helpers go:

## Errors and logging
- How errors are returned to callers:
- What is logged (never secrets or personal data):

## Git
- Branch names: `feat/<topic>`, `fix/<topic>`
- Commit messages: imperative, why over what.
