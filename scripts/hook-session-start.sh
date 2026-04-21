#!/bin/bash

set -euo pipefail

WIKI_PATH=""

if [ -f "$HOME/.llm-wiki-path" ]; then
  WIKI_PATH="$(cat "$HOME/.llm-wiki-path")"
fi

if [ -z "$WIKI_PATH" ] && [ -f .wiki-schema.md ]; then
  WIKI_PATH="$(pwd)"
fi

if [ -z "$WIKI_PATH" ] || [ ! -f "$WIKI_PATH/.wiki-schema.md" ]; then
  printf '{}\n'
  exit 0
fi

python - "$WIKI_PATH" <<'PY'
import json
import os
import sys

wiki_path = os.path.realpath(sys.argv[1])
message = (
    f"[llm-wiki] Knowledge base detected at {wiki_path}. "
    f"Start from {os.path.join(wiki_path, 'wiki', 'index.md')} and "
    f"{os.path.join(wiki_path, 'wiki', 'overview.md')} before answering substantive questions."
)

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": message,
    }
}, ensure_ascii=False))
PY
