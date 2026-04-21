#!/bin/bash

set -euo pipefail

WIKI_ROOT="${1:-.}"

python - "$WIKI_ROOT" <<'PY'
import os
import sys

root = os.path.realpath(sys.argv[1])
wiki = os.path.join(root, "wiki")
wiki_private = os.path.join(root, "wiki-private")
raw = os.path.join(root, "raw")

def md_count(path):
    total = 0
    for base, _, files in os.walk(path):
        for name in files:
            if name.endswith(".md"):
                total += 1
    return total

def recent_headings(path, limit=3):
    if not os.path.isfile(path):
        return []
    headings = []
    with open(path, "r", encoding="utf-8", errors="ignore") as fh:
        for line in fh:
            if line.startswith("## "):
                headings.append(line.strip())
    return headings[-limit:]

private_images = 0
private_videos = 0
if os.path.isdir(os.path.join(raw, "private-images")):
    private_images = len([n for n in os.listdir(os.path.join(raw, "private-images")) if n.lower() != "readme.md"])
if os.path.isdir(os.path.join(raw, "private-videos")):
    private_videos = len([n for n in os.listdir(os.path.join(raw, "private-videos")) if n.lower() != "readme.md"])

print("# Wiki Status")
print("")
print(f"- Root: {root}")
print(f"- Public markdown pages: {md_count(wiki) if os.path.isdir(wiki) else 0}")
print(f"- Private markdown pages: {md_count(wiki_private) if os.path.isdir(wiki_private) else 0}")
print(f"- Private images: {private_images}")
print(f"- Private videos: {private_videos}")
print("")
print("## Recent Public Log Entries")
for line in recent_headings(os.path.join(wiki, "log.md")) or ["No public log entries found."]:
    print(f"- {line}")
print("")
print("## Recent Private Log Entries")
for line in recent_headings(os.path.join(wiki_private, "log.md")) or ["No private log entries found."]:
    print(f"- {line}")
PY
