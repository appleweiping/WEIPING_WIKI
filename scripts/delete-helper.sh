#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bash scripts/delete-helper.sh scan-refs <wiki_root> <needle>
EOF
}

scan_refs() {
  local wiki_root="$1"
  local needle="$2"
  local wiki_dir="$wiki_root/wiki"
  [ -n "$needle" ] || {
    echo "Needle must not be empty" >&2
    exit 1
  }
  [ -d "$wiki_dir" ] || {
    echo "Wiki directory not found: $wiki_dir" >&2
    exit 1
  }
  python - "$wiki_root" "$needle" <<'PY'
import os
import sys

wiki_root = os.path.realpath(sys.argv[1])
needle = sys.argv[2]
hits = []

for root, _, files in os.walk(os.path.join(wiki_root, "wiki")):
    for name in files:
        if not name.endswith(".md"):
            continue
        path = os.path.join(root, name)
        try:
            text = open(path, "r", encoding="utf-8").read()
        except UnicodeDecodeError:
            text = open(path, "r", encoding="utf-8", errors="ignore").read()
        if needle in text:
            hits.append(os.path.relpath(path, wiki_root))

for path in sorted(dict.fromkeys(hits)):
    print(path)
PY
}

command_name="${1:-}"

case "$command_name" in
  scan-refs)
    [ "$#" -eq 3 ] || { usage; exit 1; }
    scan_refs "$2" "$3"
    ;;
  *)
    usage
    exit 1
    ;;
esac
