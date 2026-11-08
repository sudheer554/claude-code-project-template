# Changelog

Each entry says what changed in Claude Code (or in our understanding), what we changed, and why.

## 0.1.2 · 2026-11-08
`guard-bash.sh`: the fail-safe check now reads only the text a shell or interpreter will run.
- **Why:** in 0.1.1, one `bash` word anywhere made the guard scan the whole command, so
  `printf x | bash -c "$1"; echo 'rm -fr backend'` was blocked although `rm` was only data. Found the
  same day, when the global copy blocked a real check.
- **How:** for `bash -c "…"`, `ssh host …`, `python3 -c "…"`, `eval …`, only the words after the shell or
  interpreter are re-read as commands. A here-document body is now one word of the command that reads
  it, so `bash <<EOF` / `python3 <<EOF` bodies are checked and `cat <<EOF` bodies stay data.
- **New blocks:** `ssh vps git reset --hard` (no quotes), `python3 <<EOF … os.system("git reset --hard")`,
  `find . -exec sh -c 'rm -rf "$1"' _ {} \;`.
- Tests: 91 → 96.

## 0.1.1 · 2026-11-08
`guard-bash.sh`: the rm and git rules now read a command the way bash does, not as one long string.
- **Why:** an audit found 7 dangerous commands that slipped past this guard or a project's copy of it.
  Quotes do not make an argument harmless: `git reset "--hard"`, `git clean "-fd"`, `git checkout "."`
  still run. A project copy that ignored quoted text, to stop false alarms, also missed
  `echo "$(git reset --hard)"` and `python3 -c "…os.system('git reset --hard')"`.
- **How:** split the command at ``; & | ( ) ` `` and newlines outside quotes, then remove the quote marks but keep the
  words. Commands inside `$(…)` and backticks are checked even inside double quotes. Here-document
  bodies are skipped, except when a shell reads them (`bash <<EOF`). When quoted text may run as code
  (`bash -c`, `python3 -c`, `eval`, `ssh`, …), every git / rm / find word in the full text is checked too.
- **New blocks:** `git checkout .`, `git restore .` (but not `git restore --staged .`), `find -exec rm -rf`,
  `xargs rm -rf`, `sudo -u x rm -rf`, `git -C dir reset --hard`, combined flags like `git push -fu`.
- **No more false alarms** when a danger is only mentioned: commit messages, grep patterns, `echo`,
  here-documents (`git commit -m "$(cat <<'EOF' … EOF)"`).
- Still not a sandbox: a command built at run time (variables, base64) can get past it.
- Tests: 49 → 91 in `scripts/test-hooks.sh`, passing on macOS bash 3.2.

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
