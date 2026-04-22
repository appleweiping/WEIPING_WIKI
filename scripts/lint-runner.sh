#!/bin/bash

set -euo pipefail

WIKI_ROOT="${1:-.}"

[ -d "$WIKI_ROOT/wiki" ] || {
  echo "ERROR: wiki directory not found: $WIKI_ROOT/wiki" >&2
  exit 1
}

[ -f "$WIKI_ROOT/wiki/index.md" ] || {
  echo "ERROR: index file not found: $WIKI_ROOT/wiki/index.md" >&2
  exit 1
}

python - "$WIKI_ROOT" <<'PY'
import os
import re
import sys
from collections import Counter, defaultdict

wiki_root = os.path.realpath(sys.argv[1])
wiki_dir = os.path.join(wiki_root, "wiki")
index_path = os.path.join(wiki_dir, "index.md")

exclude_names = {
    "home", "overview", "index", "log", "queries-home",
    "synthesis-home", "timelines-home", "topics-home",
    "comparisons-home", "knowledge-graph", "README",
}

pages = []
name_to_paths = defaultdict(list)
page_types = {}
for root, _, files in os.walk(wiki_dir):
    if "_templates" in root.split(os.sep):
        continue
    for name in files:
        if not name.endswith(".md"):
            continue
        path = os.path.join(root, name)
        stem = os.path.splitext(name)[0]
        pages.append((stem, path))
        name_to_paths[stem].append(path)

type_map = {
    "entities": "entity",
    "concepts": "concept",
    "topics": "topic",
    "sources": "source",
    "analyses": "analysis",
    "comparisons": "comparison",
    "queries": "query",
    "synthesis": "synthesis",
    "sessions": "synthesis",
    "timelines": "timeline",
}

def read_text(path):
    try:
        return open(path, "r", encoding="utf-8").read()
    except UnicodeDecodeError:
        return open(path, "r", encoding="utf-8", errors="ignore").read()

inbound = Counter()
broken = set()
private_leaks = set()
missing_counterpoints = set()
missing_attribution = set()

for stem, path in pages:
    text = read_text(path)
    page_type = None
    match = re.search(r"(?ms)^---\n.*?^type:\s*([A-Za-z0-9_-]+)\s*$.*?^---\n", text)
    if match:
        page_type = match.group(1).strip().lower()
    else:
        page_type = type_map.get(os.path.basename(os.path.dirname(path)), "overview")
    page_types[stem] = page_type

    if "raw/private-" in text or "wiki-private/" in text:
        private_leaks.add(os.path.relpath(path, wiki_root))

    if page_type in {"concept", "topic", "comparison", "analysis", "synthesis"}:
        if stem not in exclude_names and not re.search(r"(?im)^##\s+Counterpoints and Gaps\s*$", text):
            missing_counterpoints.add(os.path.relpath(path, wiki_root))

    if page_type in {"concept", "topic", "comparison", "analysis", "query", "synthesis"}:
        has_sources = (
            re.search(r"(?im)^source_pages:\s*$", text)
            or re.search(r"(?im)^source_files:\s*$", text)
            or re.search(r"(?im)^source_pages:\s+\S", text)
            or re.search(r"(?im)^source_files:\s+\S", text)
            or re.search(r"(?im)^##\s+Sources\s*$", text)
            or re.search(r"\[\[20\d{2}-\d{2}-\d{2}-", text)
        )
        if stem not in exclude_names and not has_sources:
            missing_attribution.add(os.path.relpath(path, wiki_root))

    for target in re.findall(r"\[\[([^\]]+)\]\]", text):
        target = target.split("|", 1)[0].strip()
        if not target:
            continue
        if target in name_to_paths:
            inbound[target] += 1
        else:
            broken.add(f"{os.path.relpath(path, wiki_root)} -> [[{target}]]")
orphan_pages = sorted(
    os.path.relpath(path, wiki_root)
    for stem, path in pages
    if stem not in exclude_names and inbound[stem] == 0
)

index_text = read_text(index_path)
index_targets = {
    match.split("|", 1)[0].strip()
    for match in re.findall(r"\[\[([^\]]+)\]\]", index_text)
    if match.strip()
}
missing_from_index = sorted(
    os.path.relpath(path, wiki_root)
    for stem, path in pages
    if stem not in {"index", "knowledge-graph"} and stem not in index_targets
)

catalog_path = os.path.join(wiki_dir, "catalog.json")
if not os.path.exists(catalog_path):
    catalog_status = "missing"
else:
    latest_page = max(os.path.getmtime(path) for _, path in pages) if pages else 0
    catalog_status = "stale" if latest_page > os.path.getmtime(catalog_path) else "fresh"

topic_dir = os.path.join(wiki_dir, "topics")
comparison_dir = os.path.join(wiki_dir, "comparisons")
synthesis_sessions_dir = os.path.join(wiki_dir, "synthesis", "sessions")
section_gaps = []
if not any(name.endswith(".md") and name != "topics-home.md" for name in os.listdir(topic_dir)):
    section_gaps.append("topics: no durable topic pages yet")
if not any(name.endswith(".md") and name != "comparisons-home.md" for name in os.listdir(comparison_dir)):
    section_gaps.append("comparisons: no durable comparison pages yet")
if not any(name.endswith(".md") and name != "README.md" for name in os.listdir(synthesis_sessions_dir)):
    section_gaps.append("synthesis/sessions: no crystallized session notes yet")

print("=== llm-wiki lint report ===")
print(f"time: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M')}")
print(f"wiki_root: {wiki_root}")
print("")

print("--- broken links ---")
if broken:
    for item in sorted(broken):
        print(f"- {item}")
else:
    print("- none")
print("")

print("--- orphan pages ---")
if orphan_pages:
    for item in orphan_pages:
        print(f"- {item}")
else:
    print("- none")
print("")

print("--- missing from index ---")
if missing_from_index:
    for item in missing_from_index:
        print(f"- {item}")
else:
    print("- none")
print("")

print("--- missing counterpoints sections ---")
if missing_counterpoints:
    for item in sorted(missing_counterpoints):
        print(f"- {item}")
else:
    print("- none")
print("")

print("--- missing source attribution ---")
if missing_attribution:
    for item in sorted(missing_attribution):
        print(f"- {item}")
else:
    print("- none")
print("")

print("--- public/private boundary leaks ---")
if private_leaks:
    for item in sorted(private_leaks):
        print(f"- {item}")
else:
    print("- none")
print("")

print("--- catalog status ---")
print(f"- {catalog_status}")
print("")

print("--- section gaps ---")
if section_gaps:
    for item in section_gaps:
        print(f"- {item}")
else:
    print("- none")
PY
