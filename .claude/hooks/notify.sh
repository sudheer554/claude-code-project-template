#!/usr/bin/env bash
# Notification: desktop alert when Claude is waiting for you. Never blocks; silent if unsupported.
msg=$( (command -v jq >/dev/null && jq -r '.message // "Claude Code needs your input"') 2>/dev/null )
msg=${msg:-Claude Code needs your input}

if [[ $(uname) == Darwin ]]; then
  # Message passed as an argument, never spliced into the script, so quotes in it are harmless.
  osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "Claude Code"' -e 'end run' "$msg" >/dev/null 2>&1
elif command -v notify-send >/dev/null; then
  notify-send "Claude Code" "$msg" >/dev/null 2>&1
fi
exit 0
