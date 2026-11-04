#!/usr/bin/env bash
# PreToolUse for the test-writer agent only (wired in its frontmatter): it may write tests, nothing else.
set -uo pipefail

command -v jq >/dev/null || { echo "Blocked: safety hooks need jq." >&2; exit 2; }
path=$(jq -r '.tool_input.file_path // ""')
[[ -z $path ]] && exit 0
rel=${path#"${CLAUDE_PROJECT_DIR:-$PWD}"/}

case "$rel" in
  tests/* | */tests/* | conftest.py | */conftest.py) exit 0 ;;
esac
echo "Blocked: test-writer may only change files under tests/. Report the needed change to $rel instead." >&2
exit 2
