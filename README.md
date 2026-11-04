# Claude Code Project Template

A starting point for any project built with [Claude Code](https://code.claude.com/docs).
It is set up to spend as few tokens as possible, to be safe by default, and to test its own setup.
**No application code**, just the setup, plus an optional Python/FastAPI starter pack.

- **Small always-on context.** `CLAUDE.md` stays under 100 lines. Everything else loads only when a task needs it.
- **Rules that must hold are code, not prompts.** Hooks and permissions block secret reads, `rm -rf`,
  force-pushes, and data drops, and `scripts/test-hooks.sh` proves they do.
- **Every rule has a source.** [`docs/sources.md`](docs/sources.md) links each one to the official docs
  or the course it came from, with the date it was checked.

## Quick start

1. Click **Use this template** on GitHub (or clone it), then open the folder.
2. Optional, pick a stack: `scripts/apply-pack.sh python-fastapi`
3. Fill in the top of `CLAUDE.md` (project name and one-line purpose).
4. `cp .env.example .env` and fill in real values.
5. `uvx pre-commit install` (secret scan on every commit).
6. Run `scripts/check.sh`. Every line should be ✅.
7. Start `claude` and ask: *"What are this project's rules, and where do skills live?"*
   A correct answer means Claude read `CLAUDE.md`.

Needs: `git`, `jq` (the hooks parse JSON with it), and for the Python pack, [uv](https://docs.astral.sh/uv/).

## What Claude loads, and when

| Loaded | Files | Token cost |
|---|---|---|
| **Every session** | `CLAUDE.md` + `docs/stack.md` | Paid on every message, so kept small |
| **When a matching file is touched** | `.claude/rules/*.md` (e.g. Python rules for `*.py`) | Only while relevant |
| **When the task matches** | `.claude/skills/*/SKILL.md` (only the one-line descriptions are always visible) | Only when used |
| **When you type it** | `.claude/commands/` → `/review`, `/test`, `/explain` | Only when typed |
| **In a separate context** | `.claude/agents/` → code-reviewer, debugger, test-writer | Kept out of your main chat |
| **Never (runs as code)** | `.claude/hooks/` | Zero tokens |
| **When asked** | `docs/architecture.md`, `conventions.md`, `decisions.md` | Only when read |

## Layout

```text
CLAUDE.md                 always-on rules and a map (under 100 lines)
.claude/
  settings.json           permissions (deny → ask → allow) + hook wiring
  hooks/                  guard-bash · guard-files · format · file-size · notify · guard-tests-only
  skills/                 coding · testing · debugging · documenting (procedures with checklists)
  agents/                 code-reviewer (read-only) · debugger · test-writer (tests/ only)
  commands/               /review · /test · /explain
docs/                     stack · architecture · conventions · decisions · sources
packs/python-fastapi/     optional stack pack (uv, FastAPI, pytest, Ruff, Python rules)
scripts/                  check.sh · test-hooks.sh · apply-pack.sh
src/  tests/              your code
```

## Safety layers

| Layer | Stops | Where |
|---|---|---|
| Permissions | Reading/editing `.env`, `rm -rf`, force-push, `reset --hard`; asks before `git push` or edits to hooks/settings | `.claude/settings.json` |
| Hooks | The same, written any other way (`cd x && rm -fr y`, `cat .env.local`, `printenv`, `DROP TABLE`); test-writer editing app code | `.claude/hooks/` |
| Git | Secrets in any commit, yours or Claude's | `.pre-commit-config.yaml` (gitleaks) |
| CI | Broken setup, invalid settings, leaked secrets, broken pack | `.github/workflows/check.yml` |

Don't start Claude with `--dangerously-skip-permissions` here. To get fewer prompts, use auto mode (Shift+Tab).

## Keeping it current

Claude Code changes often. Once a month: re-read the sources in `docs/sources.md`, update rules
that changed, bump the date, add a line to [`CHANGELOG.md`](CHANGELOG.md) saying what changed and why,
and run `scripts/check.sh`.

Grow it from real use: when Claude repeats a mistake, add one line under "Common AI mistakes" in
`CLAUDE.md`. When you repeat a multi-step task, make it a skill. When a rule must never break, make it a hook.

## Credits

Base structure from Euron's Super30 *Claude Code Masterclass for Developers* (Sudhanshu Kumar).
Hook and workflow patterns from Hasan Aboul Hasan's [Claude Code Guide](https://learnwithhasan.com/claude-code-guide/)
and *Vibe Engineering Blocks*. Rules checked against Anthropic's official documentation.

MIT licensed.
