#!/usr/bin/env bash
# PreToolUse(Bash): block destructive commands and commands that would print secrets.
# Exit 2 blocks the call; stderr is shown to Claude. Second lock behind permissions.deny,
# which only matches command prefixes (this also catches `cd x && rm -rf y`, `sudo rm -fr`).
#
# The rm and git rules read the command the way bash does: split into simple commands at ; & | ( ) `
# and newlines outside quotes, with quote marks removed but words kept. So `git reset "--hard"` is caught,
# and a danger that is only mentioned (git commit -m "never run git reset --hard") is not. Commands inside
# $(...) and backticks are checked too, even inside double quotes; here-document bodies are skipped.
# When quoted text may run as code (bash -c, python3 -c, eval, ssh, ...), every git / rm / find word in
# the full text is checked as well (fail safe). Not a sandbox: a command built at run time (variables,
# base64) can get past it. Permissions, auto mode and backups are the other locks.
set -uo pipefail

command -v jq >/dev/null || { echo "Blocked: safety hooks need jq (brew install jq / apt install jq)." >&2; exit 2; }
cmd=$(jq -r '.tool_input.command // ""')
US=$'\037'

block() {
  echo "Blocked by .claude/hooks/guard-bash.sh: $1. If it is really needed, ask the user to run it themselves." >&2
  exit 2
}

# Print each simple command on its own line, its words separated by \037. POSIX awk, bash 3.2 safe.
# words <command> [keep] : with "keep", here-document bodies are read as commands too (bash <<EOF runs them).
words() {
  printf '%s' "$1" | awk -v RS='\001' -v keep="${2:-}" '
    function endtok() { if (have) { seg = (ntok ? seg US : "") tok; ntok++ } tok = ""; have = 0 }
    function endseg() { endtok(); if (ntok) print seg; seg = ""; ntok = 0 }
    function push(closer) { # $( or ` inside double quotes: its commands run, so read them as commands
      d++; sseg[d] = seg; sntok[d] = ntok; stok[d] = tok; cl[d] = closer; par[d] = 0
      seg = ""; ntok = 0; tok = ""; have = 0; q = ""
    }
    function pop() { endseg(); seg = sseg[d]; ntok = sntok[d]; tok = stok[d] SUBST; have = 1; q = "\""; d-- }
    function heredoc_op(   dash, dl, qq, c2) { # after <<: remember the delimiter word
      dash = 0; dl = ""; qq = ""
      if (substr(s, i + 1, 1) == "-") { dash = 1; i++ }
      while (i < n && substr(s, i + 1, 1) ~ /[ \t]/) i++
      while (i < n) {
        c2 = substr(s, i + 1, 1)
        if (qq != "") { i++; if (c2 == qq) qq = ""; else dl = dl c2; continue }
        if (c2 == "\047" || c2 == "\"") { qq = c2; i++; continue }
        if (c2 == "\\") { i++; continue }
        if (c2 ~ /[ \t\n;&|()<>]/) break
        dl = dl c2; i++
      }
      if (dl != "") { nhd++; hd[nhd] = dl; hdash[nhd] = dash }
    }
    function heredocs(   k, j, line) { # skip here-document bodies: they are data, not commands
      for (k = 1; k <= nhd; k++) {
        while (i < n) {
          j = index(substr(s, i + 1), "\n")
          if (j) { line = substr(s, i + 1, j - 1); i += j } else { line = substr(s, i + 1); i = n }
          if (hdash[k]) sub(/^\t+/, "", line)
          if (line == hd[k]) break
        }
      }
      nhd = 0
    }
    BEGIN { US = sprintf("%c", 31); SUBST = sprintf("%c", 30) }
    {
      s = $0; n = length(s); q = ""; tok = ""; have = 0; seg = ""; ntok = 0; d = 0; nhd = 0
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (q == "\047") { if (c == "\047") q = ""; else tok = tok (c == "\n" ? " " : c); continue }
        if (q == "\"") {
          if (c == "\"") { q = ""; continue }
          if (c == "$" && substr(s, i + 1, 1) == "(") { i++; push(")"); continue }
          if (c == "`") { push("`"); continue }
          if (c == "\\") { i++; c = substr(s, i, 1) }
          tok = tok (c == "\n" ? " " : c); continue
        }
        if (c == "\\") { i++; c = substr(s, i, 1); if (c != "\n") { tok = tok c; have = 1 } continue }
        if (c == "\047" || c == "\"") { q = c; have = 1; continue }
        if (c == "#" && !have) { while (i < n && substr(s, i + 1, 1) != "\n") i++; continue }
        if (c == "<" && substr(s, i + 1, 2) == "<<") { endtok(); i += 2; continue }
        if (c == "<" && substr(s, i + 1, 1) == "<") { endtok(); i++; if (keep == "") heredoc_op(); continue }
        if (c == " " || c == "\t" || c == "<" || c == ">") { endtok(); continue }
        if (c == "\n") { endseg(); if (nhd) heredocs(); continue }
        if (c == "(") { endseg(); if (d) par[d]++; continue }
        if (c == ")") { endseg(); if (d && par[d]) par[d]--; else if (d && cl[d] == ")") pop(); continue }
        if (c == "`") { endseg(); if (d && cl[d] == "`") pop(); continue }
        if (c == ";" || c == "&" || c == "|") { endseg(); continue }
        tok = tok c; have = 1
      }
      endseg()
    }'
}

check_rm() { # <arg>... : recursive + force, in any flag order or spelling
  local x r=0 f=0
  for x in "$@"; do
    case $x in
      --) break ;;
      --recursive) r=1 ;;
      --force) f=1 ;;
      --*) ;;
      -*) [[ $x == *[rR]* ]] && r=1; [[ $x == *f* ]] && f=1 ;;
    esac
  done
  if ((r && f)); then block "recursive force delete (rm -rf)"; fi
  return 0
}

check_git() { # <args after git>... : history and working-tree destroyers
  while (($#)) && [[ $1 == -* ]]; do # global options: -C dir, -c key=value, --no-pager, ...
    case $1 in -C | -c | --git-dir | --work-tree | --namespace | --config-env) (($# > 1)) && shift ;; esac
    shift
  done
  (($#)) || return 0
  local sub=$1 x dot=0 staged=0 worktree=0
  shift
  for x in "$@"; do
    case $sub:$x in
      push:--force | push:+?*) block "force push (use --force-with-lease after asking the user)" ;;
      push:--*) ;;
      push:-*f*) block "force push (use --force-with-lease after asking the user)" ;;
      reset:--hard) block "git reset --hard" ;;
      clean:--force) block "git clean -f" ;;
      clean:--*) ;;
      clean:-*f*) block "git clean -f" ;;
      checkout:. | checkout:./ | checkout::/ | restore:. | restore:./ | restore::/) dot=1 ;;
      restore:--staged) staged=1 ;;
      restore:--worktree) worktree=1 ;;
      restore:--*) ;;
      restore:-*) [[ $x == *S* ]] && staged=1; [[ $x == *W* ]] && worktree=1 ;;
    esac
  done
  [[ $sub == checkout ]] && ((dot)) && block "git checkout . (throws away all uncommitted changes)"
  [[ $sub == restore ]] && ((dot && (worktree || !staged))) && block "git restore . (throws away all uncommitted changes)"
  return 0
}

check_cmd() { # <word>... : one simple command; skip what runs in front of it (VAR=1, sudo, env, if, ...)
  local -a w=("$@")
  local n=${#w[@]} i=0 j name
  while ((i < n)); do
    case ${w[i]} in
      [A-Za-z_]*=*) ;;
      sudo | doas | env | command | exec | nohup | time | nice | xargs | stdbuf | '!' | '{' | if | then | else | elif | do | while | until)
        name=${w[i]}
        while ((i + 1 < n)) && [[ ${w[i + 1]} == -* ]]; do
          i=$((i + 1))
          case $name:${w[i]} in sudo:-[ugCDhpRrtU] | env:-u | nice:-n | xargs:-[IdELnPsa]) i=$((i + 1)) ;; esac
        done ;;
      timeout)
        while ((i + 1 < n)) && [[ ${w[i + 1]} == -* ]]; do
          i=$((i + 1))
          [[ ${w[i]} == -[sk] ]] && i=$((i + 1))
        done
        i=$((i + 1)) ;; # the duration
      *) break ;;
    esac
    i=$((i + 1))
  done
  ((i < n)) || return 0
  name=${w[i]##*/}
  ((i + 1 < n)) || return 0
  case $name in
    rm) check_rm "${w[@]:i+1}" ;;
    git) check_git "${w[@]:i+1}" ;;
    find)
      for ((j = i + 1; j < n; j++)); do
        case ${w[j]} in -exec | -execdir | -ok | -okdir) ((j + 1 < n)) && check_cmd "${w[@]:j+1}" ;; esac
      done ;;
  esac
  return 0
}

runs_code=0
while IFS= read -r line; do
  IFS=$US read -ra w <<<"$line"
  ((${#w[@]})) || continue
  for x in "${w[@]}"; do
    case ${x##*/} in
      bash | sh | zsh | dash | ksh | fish | eval | ssh | su | watch | osascript | node | deno | bun | perl | ruby | php | python | python[0-9]*) runs_code=1 ;;
    esac
  done
  check_cmd "${w[@]}"
done < <(words "$cmd")

# Quoted text may run as code: check every git / rm / find word in the full text, quotes and brackets removed.
if ((runs_code)); then
  while IFS= read -r line; do
    IFS=$US read -ra w <<<"$line"
    for ((j = 0; j < ${#w[@]}; j++)); do
      case ${w[j]##*/} in git | rm | find) check_cmd "${w[@]:j}" ;; esac
    done
  done < <(words "$(tr -d '\042\047\134\133\135\054' <<<"$cmd")" keep) # removes " ' \ [ ] ,
fi

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
