#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
from datetime import datetime
import sys

from wiki_core import lint_wiki, resolve_root


def _print_section(title: str, items: list[str]) -> None:
    print(f"## {title}")
    if items:
        for item in items:
            print(f"- {item}")
    else:
        print("- None")
    print("")


def print_lint(root: str, report: dict) -> None:
    print("# Wiki Lint")
    print("")
    print(f"- Time: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print(f"- Root: {root}")
    print("")
    _print_section("Broken Links", report["broken_links"])
    _print_section("Ambiguous Links", report["ambiguous_links"])
    _print_section("Orphan Pages", report["orphan_pages"])
    _print_section("Missing From Index", report["missing_from_index"])
    _print_section("Missing Counterpoints Sections", report["missing_counterpoints"])
    _print_section("Missing Source Attribution", report["missing_attribution"])
    _print_section("Public / Private Boundary Leaks", report["private_leaks"])
    print("## Catalog Status")
    print(f"- {report['catalog_status']}")


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    root = resolve_root(args.root)
    report = lint_wiki(root)
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return
    print_lint(str(root), report)


if __name__ == "__main__":
    main()
