#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import sys

from wiki_core import load_catalog, resolve_root, search_catalog, tokenize


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("query")
    parser.add_argument("--root", default=".")
    parser.add_argument("--top", type=int, default=8)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    query_tokens = tokenize(args.query)
    if not query_tokens:
        raise SystemExit("Query produced no usable tokens.")

    root = resolve_root(args.root)
    results = search_catalog(load_catalog(root), args.query, args.top)

    if args.json:
        print(json.dumps({"query": args.query, "results": results}, ensure_ascii=False, indent=2))
        return

    print(f"# Search Results: {args.query}")
    print("")
    if not results:
        print("- No matches")
        return

    for item in results:
        print(f"- {item['title']} ({item['type']}, score={item['score']})")
        print(f"  id: {item['id']}")
        print(f"  path: {item['path']}")
        print(f"  preview: {item['preview']}")


if __name__ == "__main__":
    main()
