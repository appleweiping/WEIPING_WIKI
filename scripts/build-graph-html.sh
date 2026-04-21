#!/bin/bash

set -euo pipefail

WIKI_ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
DEPS_DIR="$SCRIPT_DIR/../deps"
DATA="$WIKI_ROOT/wiki/graph-data.json"
HEADER="$TEMPLATES_DIR/graph-styles/wash/header.html"
FOOTER="$TEMPLATES_DIR/graph-styles/wash/footer.html"
OUTPUT="$WIKI_ROOT/wiki/knowledge-graph.html"
GRAPH_JS="$TEMPLATES_DIR/graph-styles/wash/graph-wash.js"

to_native_path() {
  local path="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$path"
  else
    printf '%s\n' "$path"
  fi
}

[ -f "$DATA" ] || {
  echo "ERROR: graph data not found: $DATA" >&2
  echo "Run build-graph-data.sh first." >&2
  exit 1
}

[ -f "$HEADER" ] || { echo "ERROR: missing template $HEADER" >&2; exit 1; }
[ -f "$FOOTER" ] || { echo "ERROR: missing template $FOOTER" >&2; exit 1; }
[ -f "$GRAPH_JS" ] || { echo "ERROR: missing asset $GRAPH_JS" >&2; exit 1; }

DATA_NATIVE="$(to_native_path "$DATA")"
HEADER_NATIVE="$(to_native_path "$HEADER")"
FOOTER_NATIVE="$(to_native_path "$FOOTER")"
OUTPUT_NATIVE="$(to_native_path "$OUTPUT")"

python - "$DATA_NATIVE" "$HEADER_NATIVE" "$FOOTER_NATIVE" "$OUTPUT_NATIVE" <<'PY'
import json
import os
import sys

data_path, header_path, footer_path, output_path = sys.argv[1:5]

with open(data_path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

with open(header_path, "r", encoding="utf-8") as fh:
    header = fh.read()
with open(footer_path, "r", encoding="utf-8") as fh:
    footer = fh.read()

header = header.replace("__WIKI_TITLE__", data["meta"].get("wiki_title", "Knowledge Graph"))
header = header.replace("__NODE_COUNT__", str(data["meta"].get("total_nodes", 0)))
header = header.replace("__EDGE_COUNT__", str(data["meta"].get("total_edges", 0)))
header = header.replace("__BUILD_DATE__", str(data["meta"].get("build_date", ""))[:10] or "unknown")

graph_json = json.dumps(data, ensure_ascii=False, indent=2).replace("</script>", "<\\/script>")
os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "w", encoding="utf-8") as fh:
    fh.write(header)
    fh.write(graph_json)
    fh.write(footer)

print(output_path)
PY

OUTPUT_DIR="$(cd "$(dirname "$OUTPUT")" && pwd)"
CopyList=(
  "$DEPS_DIR/d3.min.js"
  "$DEPS_DIR/rough.min.js"
  "$DEPS_DIR/marked.min.js"
  "$DEPS_DIR/purify.min.js"
  "$DEPS_DIR/LICENSE-d3.txt"
  "$DEPS_DIR/LICENSE-roughjs.txt"
  "$DEPS_DIR/LICENSE-marked.txt"
  "$DEPS_DIR/LICENSE-purify.txt"
  "$GRAPH_JS"
)

for path in "${CopyList[@]}"; do
  [ -f "$path" ] || {
    echo "ERROR: missing asset $path" >&2
    exit 1
  }
  cp "$path" "$OUTPUT_DIR/$(basename "$path")"
done

echo "Interactive graph HTML written to $OUTPUT"
