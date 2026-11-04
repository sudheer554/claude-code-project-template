#!/usr/bin/env bash
# PreToolUse(Read|Edit|Write|MultiEdit|NotebookEdit): keep Claude out of secret files and git internals.
# permissions.deny cannot say "all .env.* except .env.example", so that rule lives here.
set -uo pipefail

command -v jq >/dev/null || { echo "Blocked: safety hooks need jq (brew install jq / apt install jq)." >&2; exit 2; }
input=$(cat)
tool=$(jq -r '.tool_name // ""' <<<"$input")
path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' <<<"$input")
[[ -z $path ]] && exit 0
name=$(basename "$path")

block() {
  echo "Blocked by .claude/hooks/guard-files.sh: $path is $1. Ask the user to handle it." >&2
  exit 2
}

case "$name" in
  .env.example | .env.sample | .env.template) ;;
  .env | .env.*) block "an environment file that may hold secrets" ;;
  *.pem | *.key | *.p12 | *.pfx | *.keystore | *.jks | id_rsa* | id_ed25519* | id_ecdsa*) block "a private key or certificate store" ;;
esac

[[ $path == */secrets/* || $path == secrets/* ]] && block "inside a secrets folder"

if [[ $tool != Read && ( $path == */.git/* || $path == .git/* ) ]]; then
  block "inside .git (use git commands instead)"
fi

exit 0
