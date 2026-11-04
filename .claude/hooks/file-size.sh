#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): a code file past 600 lines goes back to Claude to split.
# Hasan Aboul Hasan's rule (Vibe Engineering Blocks, Modularity): past ~600 lines, split by job.
set -uo pipefail

limit=600
command -v jq >/dev/null || exit 0
file=$(jq -r '.tool_input.file_path // ""')
[[ -f $file ]] || exit 0

# Generated code is long by nature and never hand-edited: skip it.
case "$file" in
  */migrations/* | */generated/* | */__generated__/* | *_pb2.py | *_pb2_grpc.py | *.generated.* | *.gen.* | *.min.js) exit 0 ;;
esac

case "$file" in
  *.py | *.js | *.jsx | *.ts | *.tsx | *.mjs | *.cjs | *.go | *.rs | *.java | *.kt | *.rb | *.php | *.cs | *.swift | *.vue | *.svelte) ;;
  *) exit 0 ;;
esac

lines=$(wc -l <"$file" | tr -d ' ')
if ((lines > limit)); then
  echo "$file is $lines lines (limit $limit). Split it by responsibility before adding more; propose the split first." >&2
  exit 2
fi
exit 0
