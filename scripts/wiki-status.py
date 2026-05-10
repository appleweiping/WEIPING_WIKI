#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import sys

from wiki_core import build_status, resolve_root


def print_status(status: dict) -> None:
    print("# Wiki Status")
    print("")
    print(f"- Root: {status['root']}")
    print(f"- Public markdown pages: {status['public_markdown']}")
    print(f"- Private markdown pages: {status['private_markdown']}")
    section_labels = {
        "source": "Public source pages",
        "concept": "Public concept pages",
        "entity": "Public entity pages",
        "analysis": "Public analysis pages",
        "topic": "Public topic pages",
        "comparison": "Public comparison pages",
        "query": "Public query pages",
        "synthesis": "Public synthesis pages",
    }
    for key, label in section_labels.items():
        print(f"- {label}: {status['section_counts'].get(key, 0)}")
    print(f"- Private images: {status['private_images']}")
    print(f"- Private videos: {status['private_videos']}")
    print(f"- Reader context present: {status['reader_context_present']}")
    print(f"- Contributions ledger present: {status['contributions_present']}")
    print(f"- Catalog status: {status['catalog_status']}")
    print("")
    print("## Recent Public Log Entries")
    recent_public = status.get("recent_public_log") or []
    if recent_public:
        for line in recent_public:
            print(f"- {line}")
    else:
        print("- No public log entries found.")
    print("")
    print("## Recent Private Log Entries")
    recent_private = status.get("recent_private_log") or []
    if recent_private:
        for line in recent_private:
            print(f"- {line}")
    else:
        print("- No private log entries found.")


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    status = build_status(resolve_root(args.root))
    if args.json:
        print(json.dumps(status, ensure_ascii=False, indent=2))
        return
    print_status(status)


if __name__ == "__main__":
    main()
