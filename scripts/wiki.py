#!/usr/bin/env python
"""Unified wiki CLI — single entry point for all wiki operations.

Usage:
    python scripts/wiki.py status [--json]
    python scripts/wiki.py catalog [--stdout]
    python scripts/wiki.py lint [--json]
    python scripts/wiki.py search <query> [--top N]
    python scripts/wiki.py context <level> [--query Q]
    python scripts/wiki.py health [--json] [--fix]

All commands accept --root <path> (defaults to repo root).
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# Ensure scripts/ is on path for wiki_core import
sys.path.insert(0, str(Path(__file__).parent))

from wiki_core import (
    build_catalog,
    build_status,
    catalog_freshness,
    lint_wiki,
    load_catalog,
    resolve_root,
    search_catalog,
    wiki_pages,
    parse_page,
    parse_frontmatter,
    read_text,
)


def cmd_status(args):
    """Show wiki status summary."""
    from wiki_status import print_status
    status = build_status(resolve_root(args.root))
    if args.json:
        print(json.dumps(status, ensure_ascii=False, indent=2))
    else:
        print_status(status)


def cmd_catalog(args):
    """Rebuild wiki/catalog.json."""
    root = resolve_root(args.root)
    catalog = build_catalog(root)
    output = json.dumps(catalog, ensure_ascii=False, indent=2)
    if args.stdout:
        print(output)
    else:
        catalog_path = os.path.join(root, "wiki", "catalog.json")
        with open(catalog_path, "w", encoding="utf-8") as f:
            f.write(output + "\n")
        print(f"Wrote {catalog_path} ({len(catalog.get('pages', []))} pages)")


def cmd_lint(args):
    """Run wiki lint checks."""
    root = resolve_root(args.root)
    issues = lint_wiki(root)
    if args.json:
        print(json.dumps(issues, ensure_ascii=False, indent=2))
    else:
        total = sum(len(v) if isinstance(v, list) else 0 for v in issues.values())
        if total == 0:
            print("No issues found.")
            return
        for category, items in issues.items():
            if items:
                print(f"\n## {category} ({len(items)})")
                for item in items[:20]:
                    print(f"  - {item}")
                if len(items) > 20:
                    print(f"  ... and {len(items) - 20} more")
        print(f"\nTotal issues: {total}")


def cmd_search(args):
    """Search wiki pages."""
    root = resolve_root(args.root)
    catalog = load_catalog(root)
    if not catalog:
        catalog = build_catalog(root)
    results = search_catalog(catalog, args.query, top=args.top)
    for i, r in enumerate(results, 1):
        score = r.get("score", 0)
        title = r.get("title", r.get("id", "?"))
        path = r.get("path", "")
        print(f"{i}. [{score:.2f}] {title}")
        if path:
            print(f"   {path}")


def cmd_health(args):
    """Comprehensive health check — combines status, lint, metadata validation, and quality tiers."""
    root = resolve_root(args.root)
    report = {}

    # 1. Basic status
    status = build_status(root)
    report["total_pages"] = status.get("public_markdown", 0)
    report["private_pages"] = status.get("private_markdown", 0)
    report["catalog_status"] = status.get("catalog_status", "unknown")
    report["section_counts"] = status.get("section_counts", {})

    # 2. Lint issues
    issues = lint_wiki(root)
    report["lint_issues"] = {k: len(v) if isinstance(v, list) else 0 for k, v in issues.items()}
    report["lint_total"] = sum(report["lint_issues"].values())

    # 3. Metadata quality audit
    missing_title = []
    missing_type = []
    missing_status = []
    missing_created = []
    tier_counts = {"tier1_canonical": 0, "tier2_useful": 0, "tier3_imported": 0, "tier4_stale": 0, "unclassified": 0}
    large_pages = []
    empty_pages = []

    for page_path in wiki_pages(root):
        text = read_text(page_path)
        if not text:
            empty_pages.append(str(page_path))
            continue
        fm = parse_frontmatter(text)
        rel = os.path.relpath(page_path, root).replace("\\", "/")

        if not fm.get("title"):
            missing_title.append(rel)
        if not fm.get("type"):
            missing_type.append(rel)
        if not fm.get("created"):
            missing_created.append(rel)

        # Classify tier by status field
        page_status = fm.get("status", "").lower()
        if page_status in ("canonical", "active", "maintained"):
            tier_counts["tier1_canonical"] += 1
        elif page_status in ("useful", "draft", "partial"):
            tier_counts["tier2_useful"] += 1
        elif page_status in ("imported", "generated", "crawled"):
            tier_counts["tier3_imported"] += 1
        elif page_status in ("stale", "archived", "deprecated"):
            tier_counts["tier4_stale"] += 1
        else:
            tier_counts["unclassified"] += 1

        # Large page detection
        word_count = len(text.split())
        if word_count > 3000:
            large_pages.append({"path": rel, "words": word_count})

    report["metadata_quality"] = {
        "missing_title": len(missing_title),
        "missing_type": len(missing_type),
        "missing_created": len(missing_created),
        "empty_pages": len(empty_pages),
    }
    report["content_tiers"] = tier_counts
    report["large_pages"] = sorted(large_pages, key=lambda x: -x["words"])[:10]

    # 4. Git state
    try:
        git_status = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True, text=True, cwd=root, timeout=10
        )
        dirty_count = len([l for l in git_status.stdout.strip().split("\n") if l.strip()])
        report["git_dirty_files"] = dirty_count
    except Exception:
        report["git_dirty_files"] = "unknown"

    # 5. Script health
    scripts_dir = os.path.join(root, "scripts")
    if os.path.isdir(scripts_dir):
        sh_count = len([f for f in os.listdir(scripts_dir) if f.endswith(".sh")])
        ps1_count = len([f for f in os.listdir(scripts_dir) if f.endswith(".ps1")])
        py_count = len([f for f in os.listdir(scripts_dir) if f.endswith(".py")])
        large_scripts = []
        for f in os.listdir(scripts_dir):
            fp = os.path.join(scripts_dir, f)
            if os.path.isfile(fp):
                size = os.path.getsize(fp)
                if size > 20000:
                    large_scripts.append({"file": f, "size_kb": round(size / 1024, 1)})
        report["scripts"] = {
            "sh_count": sh_count,
            "ps1_count": ps1_count,
            "py_count": py_count,
            "large_scripts": sorted(large_scripts, key=lambda x: -x["size_kb"]),
        }

    # Output
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return

    # Human-readable output
    print("# Wiki Health Report")
    print(f"\n## Scale")
    print(f"- Public pages: {report['total_pages']}")
    print(f"- Private pages: {report['private_pages']}")
    print(f"- Catalog: {report['catalog_status']}")
    print(f"- Git dirty files: {report['git_dirty_files']}")

    print(f"\n## Content Tiers")
    for tier, count in report["content_tiers"].items():
        print(f"- {tier}: {count}")

    print(f"\n## Metadata Quality")
    mq = report["metadata_quality"]
    print(f"- Missing title: {mq['missing_title']}")
    print(f"- Missing type: {mq['missing_type']}")
    print(f"- Missing created date: {mq['missing_created']}")
    print(f"- Empty pages: {mq['empty_pages']}")

    print(f"\n## Lint Issues (total: {report['lint_total']})")
    for cat, count in report["lint_issues"].items():
        if count > 0:
            print(f"- {cat}: {count}")

    if report.get("large_pages"):
        print(f"\n## Large Pages (top 10)")
        for p in report["large_pages"]:
            print(f"- {p['path']} ({p['words']} words)")

    if report.get("scripts", {}).get("large_scripts"):
        print(f"\n## Large Scripts")
        for s in report["scripts"]["large_scripts"]:
            print(f"- {s['file']} ({s['size_kb']} KB)")


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser(
        prog="wiki.py",
        description="Unified wiki CLI for vipin wiki",
    )
    parser.add_argument("--root", default=".", help="Repository root path")
    sub = parser.add_subparsers(dest="command")

    # status
    p = sub.add_parser("status", help="Show wiki status")
    p.add_argument("--json", action="store_true")

    # catalog
    p = sub.add_parser("catalog", help="Rebuild wiki/catalog.json")
    p.add_argument("--stdout", action="store_true")

    # lint
    p = sub.add_parser("lint", help="Run lint checks")
    p.add_argument("--json", action="store_true")

    # search
    p = sub.add_parser("search", help="Search wiki pages")
    p.add_argument("query", help="Search query")
    p.add_argument("--top", type=int, default=10)

    # health
    p = sub.add_parser("health", help="Comprehensive health check")
    p.add_argument("--json", action="store_true")
    p.add_argument("--fix", action="store_true", help="Auto-fix safe issues")

    args = parser.parse_args()

    commands = {
        "status": cmd_status,
        "catalog": cmd_catalog,
        "lint": cmd_lint,
        "search": cmd_search,
        "health": cmd_health,
    }

    if args.command in commands:
        commands[args.command](args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
