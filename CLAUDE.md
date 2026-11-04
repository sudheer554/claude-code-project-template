# Project: <name>

<One line: what this project does and for whom.>

## Stack and commands
@docs/stack.md

## Map
| Path | Holds |
|---|---|
| `src/` | Application code, one responsibility per module |
| `tests/` | Tests, mirroring the `src/` layout |
| `docs/` | `architecture.md` · `conventions.md` · `decisions.md` · `sources.md` |
| `.claude/` | `skills/` (procedures) · `agents/` · `commands/` · `hooks/` · `rules/` (per-file-type rules) |

## Rules
- Plan before any change touching 3+ files: list each file and why, then wait for approval.
- One task per session. Suggest a commit after each working change.
- One job per file; keep UI, logic, and data access in separate layers.
- Code files: aim under 300 lines; past 600, split before adding more (a hook enforces 600).
- Search for an existing helper before writing a new one.
- Settings come only from the config module. Every new setting gets a line in `.env.example`.
- Never hardcode, print, or log secrets. Never read `.env` files (only `.env.example`).
- Never run destructive operations (deletes, force-push, `reset --hard`, dropping data)
  without the user's explicit yes in this session.
- New dependency: say why, and why the standard library or an existing one is not enough.
- Never invent architecture that the requirements don't need yet.

## Done means
- Behaviour changes come with a test; the relevant tests ran; failures are reported as they are.
- `docs/decisions.md` has a line for any choice a future reader would question.

## Common AI mistakes in this repo
<!-- Add one line each time Claude gets something wrong twice. This list is the most valuable part. -->
- (none yet)

## Where deeper information lives
- Procedures (coding, testing, debugging, documenting): `.claude/skills/` (load on their own when needed)
- Language rules: `.claude/rules/` (load when matching files are touched)
- System design: `docs/architecture.md` · Naming and style: `docs/conventions.md`
