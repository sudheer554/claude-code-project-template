#!/usr/bin/env bash
# PreToolUse(Bash): block destructive commands and commands that would print secrets.
# Exit 2 blocks the call; stderr is shown to Claude. Second lock behind permissions.deny,
# which only matches command prefixes (this also catches `cd x && rm -rf y`, `sudo rm -fr`).
set -uo pipefail

command -v jq >/dev/null || { echo "Blocked: safety hooks need jq (brew install jq / apt install jq)." >&2; exit 2; }
cmd=$(jq -r '.tool_input.command // ""')

block() {
  echo "Blocked by .claude/hooks/guard-bash.sh: $1. If it is really needed, ask the user to run it themselves." >&2
  exit 2
}

# rm with recursive + force, in any flag order or spelling (-rf, -fr, -r -f, --recursive --force)
while IFS= read -r flags; do
  flags=$(sed -E 's/--recursive/-r/g; s/--force/-f/g; s/--[a-z-]+//g' <<<"$flags")
  [[ $flags == *[rR]* && $flags == *f* ]] && block "recursive force delete (rm -rf)"
done < <(grep -oE '(^|[^[:alnum:]_.-])rm([[:space:]]+-[[:alnum:]-]+)+' <<<"$cmd" | sed -E 's/^.?rm//')

# git history and working-tree destroyers
grep -qE 'git[[:space:]]+push[^;&|]*([[:space:]](--force|-f)([[:space:]]|$)|[[:space:]]\+[^[:space:]])' <<<"$cmd" \
  && block "force push (use --force-with-lease after asking the user)"
grep -qE 'git[[:space:]]+reset[^;&|]*--hard' <<<"$cmd" && block "git reset --hard"
grep -qE 'git[[:space:]]+clean[[:space:]]+-[[:alnum:]]*f' <<<"$cmd" && block "git clean -f"

# dropping data
grep -qiE '(drop[[:space:]]+(table|database|schema)|truncate[[:space:]]+table)' <<<"$cmd" && block "dropping database objects"

# printing secrets: whole environment, secret-looking variables, or .env files
grep -qE '(^|[;&|[:space:]])(printenv|env)[[:space:]]*($|[;&|])' <<<"$cmd" && block "printing the whole environment"
grep -qE '\$\{?[A-Za-z_]*(KEY|TOKEN|SECRET|PASSWORD|PASSWD)' <<<"$cmd" && grep -qE '(^|[;&|[:space:]])(echo|printf|print)[[:space:]]' <<<"$cmd" \
  && block "printing a secret variable"
# Per command segment (split on ; & | $( and backticks): block when a reader command is given a real .env file.
while IFS= read -r seg; do
  seg=$(sed -E 's/^[[:space:]]*(sudo[[:space:]]+)?//' <<<"$seg")
  case "${seg%%[[:space:]]*}" in
    cat | less | more | head | tail | bat | nl | strings | xxd | od | base64 | grep | egrep | rg | awk | sed | cut | sort | diff | curl | scp | source | .) ;;
    *) continue ;;
  esac
  grep -oE '(^|[[:space:]/="'"'"'<])\.env(\.[[:alnum:]_.-]+)?' <<<"$seg" | grep -qvE '\.env\.(example|sample|template)$' \
    && block "reading a .env file (use .env.example to see which settings exist)"
done < <(tr ';&|(`' '\n' <<<"$cmd")

exit 0
