#!/usr/bin/env bash
# Validate the Claude Code setup: JSON, sizes, frontmatter, hooks, and leaks. Run before every commit.
set -uo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
errors=0
ok() { echo "✅ $1"; }
bad() { echo "🔴 $1"; errors=$((errors + 1)); }

# 1. JSON files parse
for f in $(find . -name '*.json' -not -path './node_modules/*' -not -path './.venv/*'); do
  jq empty "$f" 2>/dev/null || bad "invalid JSON: $f"
done
ok "JSON files checked"

# 2. CLAUDE.md stays small (it is paid for on every message)
lines=$(wc -l <CLAUDE.md | tr -d ' ')
((lines <= 100)) && ok "CLAUDE.md: $lines lines (limit 100)" || bad "CLAUDE.md: $lines lines (limit 100)"

# 3. Skills: frontmatter rules from Anthropic's skill authoring guide
for f in .claude/skills/*/SKILL.md; do
  dir=$(basename "$(dirname "$f")")
  name=$(sed -n 's/^name: *//p' "$f" | head -1)
  desc=$(sed -n 's/^description: *//p' "$f" | head -1)
  n=$(wc -l <"$f" | tr -d ' ')
  [[ $name == "$dir" ]] || bad "$f: name '$name' must match folder '$dir'"
  [[ $name =~ ^[a-z0-9-]{1,64}$ ]] || bad "$f: name must be lowercase letters, digits, hyphens, max 64"
  [[ $name == *claude* || $name == *anthropic* ]] && bad "$f: name may not contain 'claude' or 'anthropic'"
  [[ -n $desc && ${#desc} -le 1024 ]] || bad "$f: description missing or over 1024 chars"
  [[ $desc =~ ^(I |You ) ]] && bad "$f: description must be third person"
  ((n <= 500)) || bad "$f: $n lines (limit 500, split into reference files)"
done
ok "skills checked"

# 3b. Long instruction files start with a contents list: Claude may preview only the first 100 lines
for f in $(find .claude docs packs -name '*.md' 2>/dev/null); do
  n=$(wc -l <"$f" | tr -d ' ')
  ((n > 100)) && ! head -30 "$f" | grep -qiE '^#+ *(contents|table of contents)' \
    && bad "$f: $n lines, needs a '## Contents' list near the top"
done
ok "long docs have a contents list"

# 3c. Code files: warn past 300 lines, fail past 600 (modularity rule)
for f in $(find src tests -type f \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' -o -name '*.go' -o -name '*.rs' -o -name '*.java' \) \
    -not -path '*/migrations/*' -not -path '*/generated/*' -not -name '*_pb2*.py' 2>/dev/null); do
  n=$(wc -l <"$f" | tr -d ' ')
  if ((n > 600)); then bad "$f: $n lines (limit 600), split it"
  elif ((n > 300)); then echo "⚠️  $f: $n lines (aim under 300)"
  fi
done
ok "code file sizes checked"

# 4. Agents and commands have the fields Claude Code needs
for f in .claude/agents/*.md; do
  grep -q '^name: ' "$f" && grep -q '^description: ' "$f" || bad "$f: needs name and description"
done
for f in .claude/commands/*.md; do
  grep -q '^description: ' "$f" || bad "$f: needs a description"
done
ok "agents and commands checked"

# 5. Hooks are executable and actually block what they should
for f in .claude/hooks/*.sh scripts/*.sh; do
  [[ -x $f ]] || bad "not executable: $f"
done
scripts/test-hooks.sh || bad "hook tests failed"

# 6. Nothing private or secret is committed
if grep -rnE '(/Users/|/home/)[A-Za-z0-9_-]+/' --exclude-dir={.git,.venv,node_modules} \
     --exclude=check.sh . >/dev/null; then
  bad "local machine paths found: grep -rnE '(/Users/|/home/)' ."
fi
if [[ -e .env ]] && ! git check-ignore -q .env 2>/dev/null; then
  bad ".env exists and is not git-ignored"
fi
if command -v gitleaks >/dev/null; then
  gitleaks dir . --no-banner --redact >/dev/null 2>&1 && ok "gitleaks: no secrets" || bad "gitleaks found possible secrets: gitleaks dir . --redact"
else
  echo "⚠️  gitleaks not installed: secret scan skipped (brew install gitleaks)"
fi

echo
((errors == 0)) && echo "All checks passed." || echo "$errors check(s) failed."
exit $((errors > 0))
