#!/usr/bin/env python
from __future__ import annotations

import argparse
import sys

from wiki_core import load_catalog, read_text, recent_log_headings, resolve_page, resolve_root, search_catalog


def l0_pack(root) -> str:
    parts = [
        "# L0 Context Pack",
        "",
        "## Reader Context",
        read_text(root / "reader-context.md").strip(),
        "",
        "## Purpose",
        read_text(root / "purpose.md").strip(),
        "",
        "## Overview",
        read_text(root / "wiki" / "overview.md").strip(),
        "",
        "## Recent Log Headings",
    ]
    parts.extend(f"- {line}" for line in recent_log_headings(root / "wiki" / "log.md"))
    return "\n".join(parts).strip() + "\n"


def l1_pack(root) -> str:
    return read_text(root / "wiki" / "index.md")


def query_pack(root, query: str, top: int) -> str:
    catalog = load_catalog(root)
    results = search_catalog(catalog, query, top)
    lines = [f"# L2 Context Pack: {query}", ""]
    for item in results:
        lines.append(f"## {item['title']}")
        lines.append(f"- id: {item['id']}")
        lines.append(f"- legacy_id: {item['legacy_id']}")
        lines.append(f"- type: {item['type']}")
        lines.append(f"- path: {item['path']}")
        lines.append(f"- score: {item['score']}")
        lines.append(f"- preview: {item['preview']}")
        lines.append("")
    return "\n".join(lines).strip() + "\n"


def page_pack(root, page_id: str) -> str:
    catalog = load_catalog(root)
    page = resolve_page(catalog, page_id)
    if not page:
        raise SystemExit(f"Page not found or ambiguous in catalog: {page_id}")
    return read_text(root / page["path"])


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("mode", choices=["l0", "l1", "query", "page"])
    parser.add_argument("value", nargs="?")
    parser.add_argument("--root", default=".")
    parser.add_argument("--top", type=int, default=6)
    args = parser.parse_args()

    root = resolve_root(args.root)

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
