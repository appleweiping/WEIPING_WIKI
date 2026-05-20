#!/usr/bin/env python3
"""Sync key wiki content to agentmemory for cross-agent access.

Usage:
    python scripts/wiki-agentmemory-sync.py [--full | --recent]

Requires agentmemory server running on localhost:3111.
"""

import json
import sys
import os
from pathlib import Path
from datetime import datetime

WIKI_ROOT = Path(__file__).parent.parent / "wiki"
AGENTMEMORY_URL = os.environ.get("AGENTMEMORY_URL", "http://localhost:3111")

try:
    import urllib.request
    import urllib.error
except ImportError:
    pass


def call_memory_save(content: str, concepts: list[str], mem_type: str = "fact") -> dict | None:
    """Save a memory via agentmemory REST API."""
    url = f"{AGENTMEMORY_URL}/api/memory"
    payload = json.dumps({
        "content": content,
        "concepts": concepts,
        "type": mem_type,
    }).encode("utf-8")

    req = urllib.request.Request(
        url, data=payload,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return json.loads(resp.read())
    except (urllib.error.URLError, OSError) as e:
        print(f"  [warn] agentmemory API call failed: {e}", file=sys.stderr)
        return None


def call_memory_save_mcp(content: str, concepts: list[str], mem_type: str = "fact") -> dict | None:
    """Save via MCP tool call (fallback if REST doesn't work)."""
    # Use the standalone MCP approach via subprocess
    import subprocess
    node = r"C:\Users\admin\AppData\Local\OpenAI\Codex\bin\node.exe"
    standalone = r"C:\Users\admin\AppData\Roaming\npm\node_modules\@agentmemory\agentmemory\dist\standalone.mjs"

    if not Path(node).exists() or not Path(standalone).exists():
        print("  [warn] node or standalone.mjs not found", file=sys.stderr)
        return None

    # Build MCP request sequence
    init_msg = json.dumps({
        "jsonrpc": "2.0", "id": 1, "method": "initialize",
        "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                   "clientInfo": {"name": "wiki-sync", "version": "1.0"}}
    })
    notify_msg = json.dumps({
        "jsonrpc": "2.0", "method": "notifications/initialized", "params": {}
    })
    save_msg = json.dumps({
        "jsonrpc": "2.0", "id": 2, "method": "tools/call",
        "params": {"name": "memory_save", "arguments": {
            "content": content,
            "concepts": ",".join(concepts),
            "type": mem_type,
        }}
    })

    input_data = f"{init_msg}\n{notify_msg}\n{save_msg}\n"

    try:
        result = subprocess.run(
            [node, standalone],
            input=input_data, capture_output=True, text=True, timeout=15,
            env={**os.environ, "AGENTMEMORY_URL": AGENTMEMORY_URL},
            encoding="utf-8", errors="replace"
        )
        lines = result.stdout.strip().split("\n")
        for line in lines:
            try:
                msg = json.loads(line)
                if msg.get("id") == 2 and "result" in msg:
                    return msg["result"]
            except json.JSONDecodeError:
                continue
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"  [warn] MCP subprocess failed: {e}", file=sys.stderr)
    return None


def save_memory(content: str, concepts: list[str], mem_type: str = "fact") -> bool:
    """Try REST first, fall back to MCP subprocess."""
    result = call_memory_save(content, concepts, mem_type)
    if result:
        return True
    result = call_memory_save_mcp(content, concepts, mem_type)
    return result is not None


def sync_wiki_summary():
    """Sync high-level wiki summary to agentmemory."""
    index_path = WIKI_ROOT / "index.md"
    if not index_path.exists():
        print("[error] wiki/index.md not found", file=sys.stderr)
        return False

    content = index_path.read_text(encoding="utf-8")
    lines = content.split("\n")

    # Extract section counts
    section_counts = {}
    current_section = None
    for line in lines[:500]:
        if line.startswith("## "):
            current_section = line[3:].strip()
            section_counts[current_section] = 0
        elif current_section and line.startswith("- ["):
            section_counts[current_section] = section_counts.get(current_section, 0) + 1

    total = sum(section_counts.values())
    summary = f"VIPIn's Knowledgebase wiki summary (synced {datetime.now().strftime('%Y-%m-%d %H:%M')}):\n\n"
    summary += f"Total pages: ~{total}\n"
    summary += "Sections:\n"
    for section, count in section_counts.items():
        if count > 0:
            summary += f"  - {section}: {count} pages\n"

    print(f"[sync] Wiki summary: {total} pages across {len(section_counts)} sections")
    return save_memory(summary, ["vipin-wiki", "summary", "wiki-structure"], "architecture")


def sync_recent_log(n: int = 20):
    """Sync recent log entries to agentmemory."""
    log_path = WIKI_ROOT / "log.md"
    if not log_path.exists():
        print("[skip] wiki/log.md not found")
        return False

    content = log_path.read_text(encoding="utf-8")
    lines = content.split("\n")

    # Get last N non-empty lines
    entries = [l for l in lines if l.strip() and not l.startswith("#")][-n:]
    if not entries:
        print("[skip] No log entries found")
        return False

    log_content = f"VIPIn wiki recent activity (last {len(entries)} entries, synced {datetime.now().strftime('%Y-%m-%d %H:%M')}):\n\n"
    log_content += "\n".join(entries)

    print(f"[sync] Recent log: {len(entries)} entries")
    return save_memory(log_content, ["vipin-wiki", "log", "recent-activity"], "fact")


def sync_catalog_stats():
    """Sync catalog statistics to agentmemory."""
    catalog_path = WIKI_ROOT / "catalog.json"
    if not catalog_path.exists():
        print("[skip] wiki/catalog.json not found")
        return False

    data = json.loads(catalog_path.read_text(encoding="utf-8"))
    pages = data if isinstance(data, list) else data.get("pages", [])

    type_counts = {}
    for page in pages:
        ptype = page.get("type", "unknown")
        type_counts[ptype] = type_counts.get(ptype, 0) + 1

    stats = f"VIPIn wiki catalog stats (synced {datetime.now().strftime('%Y-%m-%d %H:%M')}):\n\n"
    stats += f"Total pages in catalog: {len(pages)}\n"
    stats += "By type:\n"
    for t, c in sorted(type_counts.items(), key=lambda x: -x[1]):
        stats += f"  - {t}: {c}\n"

    # Top 10 most-linked pages
    pages_with_backlinks = [(p.get("title", "?"), len(p.get("backlinks", []))) for p in pages]
    pages_with_backlinks.sort(key=lambda x: -x[1])
    if pages_with_backlinks[:10]:
        stats += "\nMost-linked pages:\n"
        for title, count in pages_with_backlinks[:10]:
            stats += f"  - {title} ({count} backlinks)\n"

    print(f"[sync] Catalog: {len(pages)} pages, {len(type_counts)} types")
    return save_memory(stats, ["vipin-wiki", "catalog", "statistics"], "architecture")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--recent"

    print(f"=== VIPIn Wiki → agentmemory sync ({mode}) ===")
    print(f"    agentmemory: {AGENTMEMORY_URL}")
    print()

    results = []

    if mode in ("--full", "--all"):
        results.append(("wiki summary", sync_wiki_summary()))
        results.append(("catalog stats", sync_catalog_stats()))
        results.append(("recent log", sync_recent_log(30)))
    else:
        results.append(("recent log", sync_recent_log(20)))

    print()
    print("=== Results ===")
    for name, ok in results:
        status = "OK" if ok else "FAILED"
        print(f"  {name}: {status}")


if __name__ == "__main__":
    main()
