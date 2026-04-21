#!/bin/bash

set -euo pipefail

WIKI_ROOT="${1:-$(pwd)}"
TOPIC="${2:-vipin wiki}"
LANGUAGE="${3:-English}"
DATE="$(date +%Y-%m-%d)"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/init-wiki.sh [wiki_root] [topic] [language]

This script creates or repairs a vipin-wiki style repository layout.
EOF
}

write_if_missing() {
  local path="$1"
  shift
  if [ ! -f "$path" ]; then
    mkdir -p "$(dirname "$path")"
    cat > "$path"
  fi
}

mkdir -p "$WIKI_ROOT"
mkdir -p \
  "$WIKI_ROOT/raw/articles" \
  "$WIKI_ROOT/raw/tweets" \
  "$WIKI_ROOT/raw/wechat" \
  "$WIKI_ROOT/raw/xiaohongshu" \
  "$WIKI_ROOT/raw/zhihu" \
  "$WIKI_ROOT/raw/pdfs" \
  "$WIKI_ROOT/raw/notes" \
  "$WIKI_ROOT/raw/assets" \
  "$WIKI_ROOT/raw/inbox" \
  "$WIKI_ROOT/wiki/entities" \
  "$WIKI_ROOT/wiki/concepts" \
  "$WIKI_ROOT/wiki/topics" \
  "$WIKI_ROOT/wiki/sources" \
  "$WIKI_ROOT/wiki/analyses" \
  "$WIKI_ROOT/wiki/comparisons" \
  "$WIKI_ROOT/wiki/queries" \
  "$WIKI_ROOT/wiki/synthesis/sessions" \
  "$WIKI_ROOT/wiki/timelines" \
  "$WIKI_ROOT/wiki/_templates" \
  "$WIKI_ROOT/wiki-private/sources" \
  "$WIKI_ROOT/scripts" \
  "$WIKI_ROOT/templates" \
  "$WIKI_ROOT/deps"

write_if_missing "$WIKI_ROOT/.gitignore" <<'EOF'
.wiki-cache.json
.llm-wiki-path
.wiki-tmp/
.obsidian/workspace*
.obsidian/cache
raw/private*/
wiki-private/
EOF

write_if_missing "$WIKI_ROOT/.wiki-schema.md" <<EOF
# .wiki-schema.md

This file defines the authoritative schema for \`$TOPIC\`.
EOF

write_if_missing "$WIKI_ROOT/WORKFLOWS.md" <<'EOF'
# Workflows

Run init, ingest, batch-ingest, query, digest, lint, status, graph, delete, and crystallize against the maintained wiki.
EOF

write_if_missing "$WIKI_ROOT/purpose.md" <<EOF
# $TOPIC

Language: $LANGUAGE
Created: $DATE
EOF

write_if_missing "$WIKI_ROOT/wiki/home.md" <<'EOF'
---
title: Home
type: overview
status: active
created: 2026-04-21
updated: 2026-04-21
---

# Home

- [[index]]
- [[overview]]
- [[log]]
EOF

write_if_missing "$WIKI_ROOT/wiki/overview.md" <<'EOF'
---
title: Overview
type: overview
status: active
created: 2026-04-21
updated: 2026-04-21
---

# Overview

Repository shape overview.
EOF

write_if_missing "$WIKI_ROOT/wiki/index.md" <<'EOF'
---
title: Index
type: index
status: active
created: 2026-04-21
updated: 2026-04-21
---

# Index
EOF

write_if_missing "$WIKI_ROOT/wiki/log.md" <<'EOF'
---
title: Log
type: log
status: active
created: 2026-04-21
updated: 2026-04-21
---

# Log
EOF

write_if_missing "$WIKI_ROOT/wiki-private/log.md" <<'EOF'
# Private Log
EOF

if [ ! -f "$WIKI_ROOT/.wiki-cache.json" ]; then
  cat > "$WIKI_ROOT/.wiki-cache.json" <<'EOF'
{
  "version": 1,
  "entries": {}
}
EOF
fi

echo "Initialized or repaired wiki at: $WIKI_ROOT"
