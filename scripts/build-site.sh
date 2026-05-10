#!/bin/bash

set -euo pipefail

ROOT="${1:-.}"
QUARTZ_REF="${QUARTZ_REF:-v4}"
ROOT="$(cd "$ROOT" && pwd)"
QUARTZ_DIR="$ROOT/.wiki-tmp/quartz"
CONTENT_DIR="$QUARTZ_DIR/content"
PUBLIC_DIR="$ROOT/public"

command -v git >/dev/null 2>&1 || { echo "git is required to clone Quartz." >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "node is required to sync the public wiki content." >&2; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "npm is required to install Quartz dependencies." >&2; exit 1; }

if [ ! -d "$QUARTZ_DIR" ]; then
  git clone --depth 1 --branch "$QUARTZ_REF" https://github.com/jackyzha0/quartz.git "$QUARTZ_DIR"
fi

node "$ROOT/site/sync-content.mjs" "$CONTENT_DIR"
cp "$ROOT/site/quartz.config.ts" "$QUARTZ_DIR/quartz.config.ts"
cp "$ROOT/site/quartz.layout.ts" "$QUARTZ_DIR/quartz.layout.ts"

(
  cd "$QUARTZ_DIR"
  npm ci
  npx quartz build -d content -o public
)

rm -rf "$PUBLIC_DIR"
cp -R "$QUARTZ_DIR/public" "$PUBLIC_DIR"

if grep -R -n -E "wiki-private|raw/private" "$PUBLIC_DIR" >/tmp/vipin-wiki-site-leaks.txt 2>/dev/null; then
  cat /tmp/vipin-wiki-site-leaks.txt >&2
  echo "Public site build contains private/raw path references." >&2
  exit 1
fi

echo "Built public Quartz site at $PUBLIC_DIR"
