# Sources: why each rule is here

Every rule in this template traces to a source. Re-check monthly; update the date or the rule.
Last full check: **2026-11-04**.

| Rule in this template | Where | Source |
|---|---|---|
| CLAUDE.md small (official target under 200 lines; we use 100) | `CLAUDE.md`, `scripts/check.sh` | [Claude Code docs: memory](https://code.claude.com/docs/en/memory) |
| `@imports` organise but do not save tokens | `CLAUDE.md` → `docs/stack.md` | [Claude Code docs: memory](https://code.claude.com/docs/en/memory) |
| Per-file-type rules in `.claude/rules/` with `paths:` load only when needed | `packs/*/.claude/rules/` | [Claude Code docs: memory](https://code.claude.com/docs/en/memory) |
| SKILL.md under 500 lines; references one level deep; table of contents on files over 100 lines | `.claude/skills/`, `scripts/check.sh` | [Anthropic: skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) |
| Skill name: lowercase, hyphens, max 64, no "claude"/"anthropic"; description third person, max 1024 | `scripts/check.sh` | same |
| Checklists + feedback loops (check → fix → repeat) inside skills | all skills | same |
| "Only add context Claude doesn't already have" | all skills, `docs/conventions.md` | same |
| Commands and skills are merged; `disable-model-invocation: true` keeps a command manual and out of context | `.claude/commands/` | [Claude Code docs: skills](https://code.claude.com/docs/en/skills) |
| Agents preload skills (`skills:`) instead of copying them; per-agent `hooks:` | `.claude/agents/` | [Claude Code docs: sub-agents](https://code.claude.com/docs/en/sub-agents) |
| Read-only reviewer: `permissionMode: plan`, limited `tools` | `code-reviewer.md` | same |
| Permission order deny → ask → allow; `Read(**/.env)` deny | `.claude/settings.json` | [Claude Code docs: settings](https://code.claude.com/docs/en/settings), [permissions](https://code.claude.com/docs/en/permissions) |
| Read-deny does not cover every command (e.g. `grep -r`), so a hook is the second lock | `guard-bash.sh` | same |
| Hooks: exit 2 blocks and shows stderr to Claude; `$CLAUDE_PROJECT_DIR` | `.claude/hooks/` | [Claude Code docs: hooks](https://code.claude.com/docs/en/hooks) |
| Must-never-break rules belong in hooks, not prompts | `settings.json` hooks | Claude Code docs: hooks · Hasan Aboul Hasan, *Claude Code Guide* (hooks section) |
| Block dangerous commands, protect secret files, desktop notification | `.claude/hooks/` | Hasan Aboul Hasan, [Claude Code Guide](https://learnwithhasan.com/claude-code-guide/) |
| Aim under 300 lines; one task per session; plan before big changes | `CLAUDE.md` | same (Workflows: Three Pillars, Power Prompts) |
| Past ~600 lines, split by job (hook-enforced); keep UI, logic, data separate | `CLAUDE.md`, `file-size.sh`, `check.sh` | Hasan Aboul Hasan, *Vibe Engineering Blocks*, Part 4 (Modularity, Separation) |
| Plan a "fully modular structure" before building a new feature | coding skill | Hasan Aboul Hasan, *Build With AI 1.0*, S3 L1 "The Secret to Scalable AI Coding" |
| Function size limits (complexity 10, 50 statements), not just file size | `packs/python-fastapi/pyproject.toml` | [Google C++ style guide](https://google.github.io/styleguide/cppguide.html) ("about 40 lines… think about whether it can be broken up") · Ruff C901 / PLR0915 |
| Code-file size: Claude docs set **no** limit; they limit only CLAUDE.md (200) and SKILL.md (500). Our 300/600 is Hasan's rule; ESLint `max-lines` default is 300, Pylint's is 1000 | `file-size.sh` | [Claude Code best practices](https://code.claude.com/docs/en/best-practices) · [ESLint max-lines](https://eslint.org/docs/rules/max-lines) |
| Files over 100 lines start with a contents list (Claude may preview only the first 100 lines) | `check.sh`, documenting skill | Anthropic skill authoring best practices · RoboNuggets, "10 NEW Rules for Claude Skills" (rule 2) |
| Keep only the skills the project needs ("dead skills eat context") | 4 skills only | Hasan Aboul Hasan, YouTube short, 2026-07-15 |
| One validated config + `.env.example`; secrets masked in logs | `packs/python-fastapi/src/app/config.py` | Hasan Aboul Hasan, *Vibe Engineering Blocks*, Part 2 (Env vars, Secrets) |
| Secret scan on every commit and in CI | `.pre-commit-config.yaml`, CI | [gitleaks](https://github.com/gitleaks/gitleaks) |
| Base structure: CLAUDE.md + 4 skills + 3 agents + 3 commands + hooks + docs | whole repo | Euron, Super30 *Claude Code Masterclass for Developers* (Sudhanshu Kumar) |
