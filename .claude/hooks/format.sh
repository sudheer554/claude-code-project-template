#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): format and lint only the file just changed.
# Uses project-local tools when present and is a no-op otherwise, so it is safe on any stack.
# Lint errors that cannot be auto-fixed exit 2, which feeds them back to Claude to fix.
set -uo pipefail

command -v jq >/dev/null || exit 0
file=$(jq -r '.tool_input.file_path // ""')
[[ -f $file ]] || exit 0
root=${CLAUDE_PROJECT_DIR:-.}

case "$file" in
  *.py)
    ruff=""
    if [[ -x $root/.venv/bin/ruff ]]; then ruff=$root/.venv/bin/ruff
    elif command -v ruff >/dev/null; then ruff=ruff
    fi
    [[ -z $ruff ]] && exit 0
    # Fix first, then format, so removed lines leave no gaps behind.
    out=$("$ruff" check --quiet --fix "$file" 2>&1)
    status=$?
    "$ruff" format --quiet "$file" >/dev/null 2>&1
    if ((status != 0)); then
      echo "ruff found issues it could not fix in $file:" >&2
      echo "$out" >&2
      exit 2
    fi
    ;;
  *.js | *.jsx | *.ts | *.tsx | *.mjs | *.cjs | *.css | *.scss | *.html | *.vue | *.svelte)
    prettier=$root/node_modules/.bin/prettier
    [[ -x $prettier ]] && "$prettier" --write --log-level warn "$file" >/dev/null 2>&1
    ;;
esac

exit 0
