#!/bin/bash

set -euo pipefail

WIKI_ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

python "$SCRIPT_DIR/wiki-status.py" --root "$WIKI_ROOT"
