#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import sys

from wiki_core import build_catalog, resolve_root


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--output", default="wiki/catalog.json")
    parser.add_argument("--stdout", action="store_true")
    args = parser.parse_args()

    root = resolve_root(args.root)
    catalog = build_catalog(root)

    if args.stdout:
        print(json.dumps(catalog, ensure_ascii=False, indent=2))
        return

    output = (root / args.output).resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
