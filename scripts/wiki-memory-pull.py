#!/usr/bin/env python3
"""Pull agentmemory content into VIPIn wiki pages.

Reads memories from agentmemory and creates/updates wiki pages under
wiki/synthesis/agent-memory-*.md for cross-agent knowledge persistence.

Usage:
    python scripts/wiki-memory-pull.py [--dry-run]
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

WIKI_ROOT = Path(__file__).parent.parent / "wiki"
SYNTHESIS_DIR = WIKI_ROOT / "synthesis"
AGENTMEMORY_URL = os.environ.get("AGENTMEMORY_URL", "http://localhost:3111")


def fetch_memories_via_mcp() -> list[dict]:
    """Fetch all memories via MCP subprocess."""
    node = r"C:\Users\admin\AppData\Local\OpenAI\Codex\bin\node.exe"
    standalone = r"C:\Users\admin\AppData\Roaming\npm\node_modules\@agentmemory\agentmemory\dist\standalone.mjs"

    if not Path(node).exists() or not Path(standalone).exists():
        print("[error] node or standalone.mjs not found", file=sys.stderr)
        return []

    init_msg = json.dumps({
        "jsonrpc": "2.0", "id": 1, "method": "initialize",
        "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                   "clientInfo": {"name": "wiki-pull", "version": "1.0"}}
    })
    notify_msg = json.dumps({
        "jsonrpc": "2.0", "method": "notifications/initialized", "params": {}
    })
    export_msg = json.dumps({
        "jsonrpc": "2.0", "id": 2, "method": "tools/call",
        "params": {"name": "memory_export", "arguments": {}}
    })

    input_data = f"{init_msg}\n{notify_msg}\n{export_msg}\n"

    try:
        result = subprocess.run(
            [node, standalone],
            input=input_data, capture_output=True, text=True, timeout=20,
            env={**os.environ, "AGENTMEMORY_URL": AGENTMEMORY_URL},
            encoding="utf-8", errors="replace"
        )
        for line in result.stdout.strip().split("\n"):
            try:
                msg = json.loads(line)
                if msg.get("id") == 2 and "result" in msg:
                    content = msg["result"].get("content", [])
                    for c in content:
                        if c.get("type") == "text":
                            data = json.loads(c["text"])
                            return data.get("memories", [])
                    return []
            except (json.JSONDecodeError, KeyError):
                continue
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"[error] MCP subprocess failed: {e}", file=sys.stderr)
    return []


def memory_to_markdown(mem: dict) -> str:
    """Convert a memory record to a wiki-compatible markdown page."""
    title = mem.get("title", "Untitled")[:80].replace("\n", " ")
    mem_type = mem.get("type", "unknown")
    concepts = mem.get("concepts", [])
    content = mem.get("content", "")
    created = mem.get("createdAt", "")[:10]
    updated = mem.get("updatedAt", "")[:10]
    mem_id = mem.get("id", "unknown")

    frontmatter = f"""---
title: "{title}"
type: synthesis
status: active
created: {created}
updated: {updated}
tags: [agent-memory, {mem_type}, {', '.join(concepts[:5])}]
source_pages: []
memory_id: {mem_id}
---"""

    body = f"""{frontmatter}

# {title}

**Memory type:** {mem_type}
**Concepts:** {', '.join(concepts)}
**Created:** {created} | **Updated:** {updated}

---

{content}
"""
    return body


def slugify(text: str) -> str:
    """Create a filename-safe slug from text."""
    import re
    slug = text.lower().strip()
    slug = re.sub(r'[^\w\s-]', '', slug)
    slug = re.sub(r'[\s_]+', '-', slug)
    slug = re.sub(r'-+', '-', slug)
    return slug[:60].strip("-") or "untitled"


def main():
    dry_run = "--dry-run" in sys.argv

    print("=== agentmemory → VIPIn wiki pull ===")
    print(f"    target: {SYNTHESIS_DIR}")
    print(f"    dry_run: {dry_run}")
    print()

    memories = fetch_memories_via_mcp()
    if not memories:
        print("[warn] No memories fetched. Is agentmemory running?")
        return

    print(f"[info] Fetched {len(memories)} memories")

    SYNTHESIS_DIR.mkdir(parents=True, exist_ok=True)
    written = 0
    skipped = 0

    for mem in memories:
        mem_id = mem.get("id", "")
        mem_type = mem.get("type", "unknown")
        title = mem.get("title", "")[:60].replace("\n", " ")

        slug = slugify(f"agent-memory-{mem_type}-{title[:30]}")
        filename = f"{slug}.md"
        filepath = SYNTHESIS_DIR / filename

        # Skip if file exists and memory hasn't been updated
        if filepath.exists():
            existing = filepath.read_text(encoding="utf-8")
            if mem_id in existing:
                skipped += 1
                continue

        md = memory_to_markdown(mem)

        if dry_run:
            print(f"  [dry-run] Would write: {filename}")
        else:
            filepath.write_text(md, encoding="utf-8")
            print(f"  [written] {filename}")
        written += 1

    print()
    print(f"=== Done: {written} written, {skipped} skipped (unchanged) ===")


if __name__ == "__main__":
    main()
