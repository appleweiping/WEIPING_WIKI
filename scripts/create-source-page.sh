#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/create-source-page.sh <raw_file> <output_path> <content_file>

Arguments:
  raw_file     Source file path used for cache provenance
  output_path  Relative path inside the wiki repo, for example wiki/sources/2026-04-21-example.md
  content_file Temporary file containing the markdown content to write
EOF
}

find_wiki_root() {
  local path="$1"
  local dir parent
  dir="$(cd "$(dirname "$path")" && pwd)"
  while true; do
    if [ -f "$dir/.wiki-schema.md" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
    parent="$(dirname "$dir")"
    [ "$parent" = "$dir" ] && return 1
    dir="$parent"
  done
}

[ "$#" -eq 3 ] || { usage; exit 1; }

raw_file="$1"
output_path="$2"
content_file="$3"

[ -f "$raw_file" ] || { echo "Raw source file not found: $raw_file" >&2; exit 1; }
[ -f "$content_file" ] || { echo "Content file not found: $content_file" >&2; exit 1; }

wiki_root="$(find_wiki_root "$raw_file")" || {
  echo "Could not find wiki root from: $raw_file" >&2
  exit 1
}

case "$output_path" in
  wiki/*|wiki-private/*) ;;
  *)
    echo "output_path must be inside wiki/ or wiki-private/: $output_path" >&2
    exit 1
    ;;
esac

full_output="$wiki_root/$output_path"
mkdir -p "$(dirname "$full_output")"
tmp_output="${full_output}.tmp.$$"
cp "$content_file" "$tmp_output"
mv "$tmp_output" "$full_output"

bash "$SCRIPT_DIR/cache.sh" update "$raw_file" "$output_path" >/dev/null
printf 'SUCCESS\n'
