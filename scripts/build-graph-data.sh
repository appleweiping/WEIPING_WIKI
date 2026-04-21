#!/bin/bash

set -euo pipefail

WIKI_ROOT="${1:-.}"
OUTPUT="${2:-$WIKI_ROOT/wiki/graph-data.json}"

[ -d "$WIKI_ROOT/wiki" ] || {
  echo "ERROR: wiki directory not found: $WIKI_ROOT/wiki" >&2
  exit 1
}

python - "$WIKI_ROOT" "$OUTPUT" <<'PY'
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import UTC, datetime

wiki_root = os.path.realpath(sys.argv[1])
output_path = os.path.realpath(sys.argv[2])
wiki_dir = os.path.join(wiki_root, "wiki")

type_map = {
    "entities": "entity",
    "concepts": "concept",
    "topics": "topic",
    "sources": "source",
    "analyses": "analysis",
    "comparisons": "comparison",
    "queries": "query",
    "synthesis": "synthesis",
    "timelines": "timeline",
}

def page_type(path):
    rel = os.path.relpath(path, wiki_dir)
    first = rel.split(os.sep, 1)[0]
    return type_map.get(first, "overview")

def read_text(path):
    try:
        return open(path, "r", encoding="utf-8").read()
    except UnicodeDecodeError:
        return open(path, "r", encoding="utf-8", errors="ignore").read()

def first_heading(text, fallback):
    for line in text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return fallback

pages = []
name_to_node = {}
for root, _, files in os.walk(wiki_dir):
    if "_templates" in root.split(os.sep):
        continue
    for name in files:
        if not name.endswith(".md"):
            continue
        path = os.path.join(root, name)
        stem = os.path.splitext(name)[0]
        text = read_text(path)
        node = {
            "id": stem,
            "label": first_heading(text, stem),
            "type": page_type(path),
            "community": page_type(path),
            "source_path": os.path.relpath(path, wiki_root).replace("\\", "/"),
        }
        pages.append((node, text))
        name_to_node[stem] = node

edges = []
seen_edges = set()
degree = Counter()
for node, text in pages:
    current_conf = "EXTRACTED"
    for line in text.splitlines():
        conf_match = re.search(r"confidence:\s*(EXTRACTED|INFERRED|AMBIGUOUS|UNVERIFIED)", line)
        if conf_match:
            current_conf = conf_match.group(1)
        for target in re.findall(r"\[\[([^\]]+)\]\]", line):
            target = target.split("|", 1)[0].strip()
            if not target or target == node["id"] or target not in name_to_node:
                continue
            key = (node["id"], target)
            if key in seen_edges:
                continue
            seen_edges.add(key)
            edges.append({
                "id": f"e{len(edges)+1}",
                "from": node["id"],
                "to": target,
                "type": current_conf,
            })
            degree[node["id"]] += 1
            degree[target] += 1

nodes = sorted((node for node, _ in pages), key=lambda x: x["id"])
edges = sorted(edges, key=lambda x: (x["from"], x["to"], x["type"]))
for idx, edge in enumerate(edges, start=1):
    edge["id"] = f"e{idx}"

isolated_nodes = [
    {"id": node["id"], "label": node["label"], "type": node["type"]}
    for node in nodes if degree[node["id"]] == 0
]

bridge_nodes = [
    {"id": node["id"], "label": node["label"], "degree": degree[node["id"]]}
    for node in sorted(nodes, key=lambda n: (-degree[n["id"]], n["id"]))[:10]
    if degree[node["id"]] > 0
]

surprising_connections = []
for edge in edges:
    a = name_to_node[edge["from"]]
    b = name_to_node[edge["to"]]
    if a["community"] != b["community"]:
      surprising_connections.append({
          "from": a["id"],
          "to": b["id"],
          "from_type": a["community"],
          "to_type": b["community"],
          "edge_type": edge["type"],
      })

community_counts = Counter(node["community"] for node in nodes)
sparse_communities = [
    {"community": community, "count": count}
    for community, count in sorted(community_counts.items())
    if count <= 2
]

initial_view = [node["id"] for node in sorted(nodes, key=lambda n: (-degree[n["id"]], n["id"]))[:30]]
wiki_title = os.path.basename(wiki_root)
purpose_path = os.path.join(wiki_root, "purpose.md")
if os.path.isfile(purpose_path):
    purpose_text = read_text(purpose_path)
    for line in purpose_text.splitlines():
        if line.startswith("# "):
            wiki_title = line[2:].strip()
            break

payload = {
    "meta": {
        "build_date": datetime.now(UTC).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "wiki_title": wiki_title,
        "total_nodes": len(nodes),
        "total_edges": len(edges),
        "initial_view": initial_view,
        "degraded": False,
        "insights_degraded": False,
    },
    "nodes": nodes,
    "edges": edges,
    "insights": {
        "surprising_connections": surprising_connections[:25],
        "isolated_nodes": isolated_nodes[:25],
        "bridge_nodes": bridge_nodes,
        "sparse_communities": sparse_communities,
        "meta": {
            "degraded": False,
            "node_count": len(nodes),
            "edge_count": len(edges),
            "max_insight_nodes": 250,
            "max_insight_edges": 1000,
        }
    }
}

os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, ensure_ascii=False, indent=2)
    fh.write("\n")

print(f"Graph data written to {output_path}")
print(f"nodes={len(nodes)}")
print(f"edges={len(edges)}")
PY
