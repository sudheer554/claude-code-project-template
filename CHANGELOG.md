# Changelog

Each entry says what changed in Claude Code (or in our understanding), what we changed, and why.

## 0.1.0 · 2026-11-04
First version.
- Structure from the Euron Super30 masterclass: CLAUDE.md, 4 skills, 3 agents, 3 commands, hooks, docs.
- Upgraded against the official docs (checked 2026-11-04):
  - Commands are merged into skills, so ours use `disable-model-invocation: true`: manual only, and out of context until typed.
  - Agents preload their skill (`skills:`) instead of repeating it: one instruction, one place.
  - Path-scoped `.claude/rules/` for language rules, so Python rules load only for `.py` files.
  - Skills follow Anthropic's authoring guide: checklists, feedback loops, third-person descriptions.
- Modularity (Hasan's book, Part 4): aim under 300 lines, hard limit 600 via a hook; UI, logic, and data kept separate.
- Generated code (migrations, protobuf, minified) is skipped by the size rule. The Python pack also limits function complexity and length (Ruff C901, PLR0915).
- Long docs need a contents list (Anthropic's skill guide): Claude may preview only the first 100 lines.
- Safety: permissions plus hooks as a second lock, a hook self-test, gitleaks pre-commit, and CI.
- Optional pack: `python-fastapi` (uv, FastAPI, Pydantic Settings, pytest, Ruff).
