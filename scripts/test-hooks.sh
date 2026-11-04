#!/usr/bin/env bash
# Feed sample tool calls to the safety hooks and check each is blocked (exit 2) or allowed (exit 0).
# Proves the hooks work instead of trusting that they do.
set -uo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
hooks=$root/.claude/hooks
export CLAUDE_PROJECT_DIR=$root
pass=0 fail=0

expect() { # expect <0|2> <hook> <json> <label>
  local want=$1 hook=$2 json=$3 label=$4 got
  printf '%s' "$json" | "$hooks/$hook" >/dev/null 2>&1
  got=$?
  if [[ $got == "$want" ]]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FAIL [$hook] $label: expected exit $want, got $got"
  fi
}
bash_call() { jq -cn --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}'; }
file_call() { jq -cn --arg t "$1" --arg p "$2" '{tool_name:$t,tool_input:{file_path:$p}}'; }

# guard-bash: blocked
for c in 'rm -rf build' 'rm -fr /' 'sudo rm -r -f /tmp/x' 'cd src && rm --recursive --force .' \
         'git push --force origin main' 'git push -f' 'git push origin +main' \
         'git reset --hard HEAD~1' 'git clean -fd' 'psql -c "DROP TABLE users"' \
         'cat .env' 'grep KEY .env.production' 'source .env' 'printenv' 'env | sort' \
         'echo $OPENAI_API_KEY' 'x=$(cat .env)' 'ls && sudo cat < .env.local'; do
  expect 2 guard-bash.sh "$(bash_call "$c")" "$c"
done
# guard-bash: allowed
for c in 'ls -la' 'rm build/old.log' 'rm -r build' 'git push origin main' \
         'git push --force-with-lease origin feat/x' 'cat .env.example' 'cp .env.example .env' \
         'git status' 'uv run pytest' 'echo hello' 'grep -rn TODO src' \
         'git check-ignore -v .env && scripts/check.sh | tail -3'; do
  expect 0 guard-bash.sh "$(bash_call "$c")" "$c"
done

# guard-files: blocked
for p in .env .env.local config/.env.production secrets/db.txt certs/server.pem id_rsa; do
  expect 2 guard-files.sh "$(file_call Read "$root/$p")" "Read $p"
done
expect 2 guard-files.sh "$(file_call Edit "$root/.git/config")" "Edit .git/config"
# guard-files: allowed
for p in .env.example src/app/main.py README.md docs/environment.md; do
  expect 0 guard-files.sh "$(file_call Edit "$root/$p")" "Edit $p"
done
expect 0 guard-files.sh "$(file_call Read "$root/.git/HEAD")" "Read .git/HEAD"

# guard-tests-only (test-writer agent)
expect 0 guard-tests-only.sh "$(file_call Write "$root/tests/test_x.py")" "Write tests/test_x.py"
expect 0 guard-tests-only.sh "$(file_call Write "$root/conftest.py")" "Write conftest.py"
expect 2 guard-tests-only.sh "$(file_call Edit "$root/src/app/main.py")" "Edit src/app/main.py"

# file-size: 601-line code file blocked, 600 allowed, long non-code file ignored
tmp=$(mktemp -d)
seq 601 | sed 's/^/x = /' >"$tmp/big.py"
seq 600 | sed 's/^/x = /' >"$tmp/ok.py"
seq 900 >"$tmp/notes.md"
expect 2 file-size.sh "$(file_call Write "$tmp/big.py")" "601-line .py"
expect 0 file-size.sh "$(file_call Write "$tmp/ok.py")" "600-line .py"
expect 0 file-size.sh "$(file_call Write "$tmp/notes.md")" "900-line .md"
mkdir "$tmp/migrations" && cp "$tmp/big.py" "$tmp/migrations/0001_init.py"
expect 0 file-size.sh "$(file_call Write "$tmp/migrations/0001_init.py")" "601-line generated migration"
rm -f "$tmp"/big.py "$tmp"/ok.py "$tmp"/notes.md "$tmp"/migrations/0001_init.py && rmdir "$tmp/migrations" "$tmp"

echo "hook tests: $pass passed, $fail failed"
[[ $fail == 0 ]]
