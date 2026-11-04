#!/usr/bin/env bash
# Copy a stack pack into the project. Never overwrites existing files, except docs/stack.md,
# which every pack is meant to replace. Usage: scripts/apply-pack.sh <pack-name>
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
pack=${1:-}
src=$root/packs/$pack

if [[ -z $pack || ! -d $src ]]; then
  echo "Usage: scripts/apply-pack.sh <pack>   Available: $(ls "$root/packs" | tr '\n' ' ')" >&2
  exit 1
fi

copied=0 skipped=0
while IFS= read -r -d '' file; do
  rel=${file#"$src"/}
  [[ $rel == README.md ]] && continue
  dest=$root/$rel
  if [[ -e $dest && $rel != docs/stack.md ]]; then
    echo "skip (exists): $rel"
    skipped=$((skipped + 1))
    continue
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$file" "$dest"
  echo "added: $rel"
  copied=$((copied + 1))
done < <(find "$src" -type f -print0)

rm -f "$root/src/.gitkeep" "$root/tests/.gitkeep"
echo "Pack '$pack': $copied added, $skipped skipped. Next: see docs/stack.md for install and test commands."
