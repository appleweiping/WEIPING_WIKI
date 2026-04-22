#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def recent_log_headings(path: Path, limit: int = 5) -> list[str]:
    lines = [line.strip() for line in read(path).splitlines() if line.startswith("## ")]
    return lines[-limit:]


def l0_pack(root: Path) -> str:
    parts = [
        "# L0 Context Pack",
        "",
        "## Reader Context",
        read(root / "reader-context.md").strip(),
        "",
        "## Purpose",
        read(root / "purpose.md").strip(),
        "",
        "## Overview",
        read(root / "wiki" / "overview.md").strip(),
        "",
        "## Recent Log Headings",
    ]
    parts.extend(f"- {line}" for line in recent_log_headings(root / "wiki" / "log.md"))
    return "\n".join(parts).strip() + "\n"


def l1_pack(root: Path) -> str:
    return read(root / "wiki" / "index.md")


def load_catalog(root: Path) -> dict:
    path = root / "wiki" / "catalog.json"
    if not path.exists():
        raise SystemExit("wiki/catalog.json not found. Run scripts/wiki-catalog.py first.")
    return json.loads(path.read_text(encoding="utf-8"))


def query_pack(root: Path, query: str, top: int) -> str:
    import subprocess
    proc = subprocess.run(
        [sys.executable, str(root / "scripts" / "wiki-search.py"), query, "--root", str(root), "--top", str(top), "--json"],
        capture_output=True,
        text=True,
        encoding="utf-8",
        cwd=root,
        check=True,
    )
    payload = json.loads(proc.stdout)
    lines = [f"# L2 Context Pack: {query}", ""]
    for item in payload.get("results", []):
        lines.append(f"## {item['title']}")
        lines.append(f"- type: {item['type']}")
        lines.append(f"- path: {item['path']}")
        lines.append(f"- score: {item['score']}")
        lines.append(f"- preview: {item['preview']}")
        lines.append("")
    return "\n".join(lines).strip() + "\n"


def page_pack(root: Path, page_id: str) -> str:
    catalog = load_catalog(root)
    by_id = {page["id"]: page for page in catalog.get("pages", [])}
    page = by_id.get(page_id)
    if not page:
        raise SystemExit(f"Page not found in catalog: {page_id}")
    return read(root / page["path"])


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["l0", "l1", "query", "page"])
    parser.add_argument("value", nargs="?")
    parser.add_argument("--root", default=".")
    parser.add_argument("--top", type=int, default=6)
    args = parser.parse_args()

    root = Path(args.root).resolve()

    if args.mode == "l0":
        print(l0_pack(root), end="")
    elif args.mode == "l1":
        print(l1_pack(root), end="")
    elif args.mode == "query":
        if not args.value:
            raise SystemExit("query mode requires a search string")
        print(query_pack(root, args.value, args.top), end="")
    elif args.mode == "page":
        if not args.value:
            raise SystemExit("page mode requires a page id")
        print(page_pack(root, args.value), end="")


if __name__ == "__main__":
    main()
