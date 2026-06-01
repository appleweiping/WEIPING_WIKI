#!/usr/bin/env python
"""Unified wiki CLI — single entry point for all wiki operations.

Usage:
    python scripts/wiki.py status [--json]
    python scripts/wiki.py catalog [--stdout]
    python scripts/wiki.py lint [--json]
    python scripts/wiki.py search <query> [--top N]
    python scripts/wiki.py context <level> [--query Q]
    python scripts/wiki.py maintain --scope whole-computer [--json]
    python scripts/wiki.py health [--json] [--fix]

All commands accept --root <path> (defaults to repo root).
"""
from __future__ import annotations

import argparse
import datetime as dt
import importlib.util
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
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
    status_module = Path(__file__).with_name("wiki-status.py")
    spec = importlib.util.spec_from_file_location("wiki_status", status_module)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {status_module}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    print_status = module.print_status
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


def cmd_context(args):
    """Build layered context packs through the shared context script."""
    root = resolve_root(args.root)
    context_module = Path(__file__).with_name("wiki-context.py")
    spec = importlib.util.spec_from_file_location("wiki_context", context_module)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {context_module}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    level = args.level.lower()
    if level == "l0":
        output = module.l0_pack(root)
    elif level == "l1":
        output = module.l1_pack(root)
        if args.query:
            output = output.rstrip() + "\n\n---\n\n" + module.query_pack(root, args.query, args.top)
    elif level in {"l2", "query"}:
        if not args.query:
            raise SystemExit("context L2/query requires --query")
        output = module.query_pack(root, args.query, args.top)
    elif level in {"l3", "page"}:
        page_id = args.page or args.query
        if not page_id:
            raise SystemExit("context L3/page requires --page or --query <page-id>")
        output = module.page_pack(root, page_id)
    else:
        raise SystemExit("level must be one of L0, L1, L2, L3, query, page")

    print(output, end="")


def build_health_report(root: Path) -> dict:
    """Build the health report used by `health` and `maintain`."""
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

    return report


def cmd_health(args):
    """Comprehensive health check — combines status, lint, metadata validation, and quality tiers."""
    root = resolve_root(args.root)
    report = build_health_report(root)

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


def _run_capture(command: list[str], root: Path, timeout: int = 60) -> dict:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            cwd=root,
            timeout=timeout,
            encoding="utf-8",
            errors="replace",
        )
        return {
            "command": command,
            "exit_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
        }
    except Exception as exc:
        return {
            "command": command,
            "exit_code": None,
            "stdout": "",
            "stderr": str(exc),
        }


def _agentmemory_health(timeout: int = 4) -> dict:
    url = "http://localhost:3111/agentmemory/health"
    try:
        with urllib.request.urlopen(url, timeout=timeout) as response:
            payload = json.loads(response.read().decode("utf-8", errors="replace"))
        health = payload.get("health", payload)
        return {
            "available": True,
            "status": payload.get("status") or health.get("status") or "unknown",
            "version": payload.get("version"),
            "connection_state": health.get("connectionState"),
            "alerts": health.get("alerts", []),
            "notes": health.get("notes", []),
        }
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
        return {
            "available": False,
            "status": "degraded",
            "error": str(exc),
        }


def _first_lines(text: str, limit: int = 80) -> list[str]:
    return text.splitlines()[:limit]


def _parse_audit_summary(text: str) -> dict:
    summary: dict[str, int] = {}
    for line in text.splitlines():
        match = re.match(r"^-\s+(.+?):\s+(\d+)\s*$", line.strip())
        if match:
            key = match.group(1).lower().replace(" ", "_").replace("`", "")
            summary[key] = int(match.group(2))
    return summary


def _parse_inventory_summary(text: str) -> dict:
    drives = []
    top_levels = []
    in_drives = False
    for line in text.splitlines():
        if line.startswith("## Drives"):
            in_drives = True
            continue
        if in_drives and line.startswith("## "):
            in_drives = False
        if in_drives and line.startswith("| ") and not line.startswith("| ---") and "Drive" not in line:
            drives.append(line)
        if line.startswith("## Top Level: "):
            top_levels.append(line.replace("## Top Level: ", ""))
    return {"drives": drives, "top_level_sections": top_levels}


def _maintenance_recommendations(report: dict) -> list[str]:
    recommendations = []
    if not report["agentmemory"].get("available"):
        recommendations.append("Agentmemory is unavailable; continue from wiki/git evidence and note degraded recall.")
    if report["wiki_health"].get("catalog_status") != "fresh":
        recommendations.append("Rebuild wiki/catalog.json before committing curated wiki changes.")
    if report["wiki_health"].get("lint_total", 0) > 0:
        recommendations.append("Fix lint issues before auto commit/push.")
    audit = report.get("wiki_maintenance_audit", {}).get("summary", {})
    if audit.get("pages_mentioning_agent_hub", 0) > 0:
        recommendations.append("Review Agent Hub mentions and keep only clearly historical references.")
    if audit.get("typed_pages_missing_counterpoints_section", 0) > 0:
        recommendations.append("Triage missing Counterpoints sections; update high-value current pages first.")
    dirty = report.get("git", {}).get("dirty_files", [])
    if dirty:
        recommendations.append("Preserve unrelated dirty work; stage only scoped maintenance files.")
    if not recommendations:
        recommendations.append("No immediate maintenance blockers detected; avoid noisy commits unless live evidence changed.")
    return recommendations


def _maintenance_markdown(report: dict) -> str:
    lines = [
        "# VipinKnowledge Maintenance Report",
        "",
        f"- Generated: {report['generated_at']}",
        f"- Scope: {report['scope']}",
        f"- Root: {report['root']}",
        f"- Agentmemory: {report['agentmemory'].get('status')} (available={report['agentmemory'].get('available')})",
        f"- Catalog: {report['wiki_health'].get('catalog_status')}",
        f"- Lint total: {report['wiki_health'].get('lint_total')}",
        f"- Git dirty files: {len(report['git'].get('dirty_files', []))}",
        "",
        "## Recommendations",
        "",
    ]
    lines.extend(f"- {item}" for item in report["recommendations"])
    lines.extend(["", "## Inventory Preview", ""])
    lines.extend(report["computer_inventory"]["preview"])
    lines.extend(["", "## Wiki Maintenance Audit Preview", ""])
    lines.extend(report["wiki_maintenance_audit"]["preview"])
    return "\n".join(lines).rstrip() + "\n"


def cmd_maintain(args):
    """Dry-run maintenance report for vipinknowledge whole-computer upkeep."""
    root = resolve_root(args.root)
    if args.scope != "whole-computer":
        raise SystemExit("Only --scope whole-computer is supported.")

    timestamp = dt.datetime.now().astimezone().isoformat(timespec="seconds")
    safe_stamp = re.sub(r"[^0-9A-Za-z]+", "-", timestamp).strip("-")
    artifact_dir = root / ".wiki-tmp" / "vipinknowledge-maintenance"
    artifact_dir.mkdir(parents=True, exist_ok=True)

    git_status = _run_capture(["git", "status", "--short", "--branch"], root, timeout=10)
    git_diff_names = _run_capture(["git", "diff", "--name-only"], root, timeout=10)
    inventory = _run_capture(
        [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(root / "scripts" / "computer-inventory.ps1"),
            "-MaxTopLevelItems",
            str(args.max_top_level_items),
        ],
        root,
        timeout=120,
    )
    audit = _run_capture(
        [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(root / "scripts" / "wiki-maintenance-audit.ps1"),
            "-MaxItems",
            str(args.max_audit_items),
        ],
        root,
        timeout=120,
    )

    report = {
        "generated_at": timestamp,
        "scope": args.scope,
        "root": str(root),
        "artifact_dir": str(artifact_dir),
        "git": {
            "status_output": git_status["stdout"].splitlines(),
            "dirty_files": [line for line in git_status["stdout"].splitlines() if line and not line.startswith("##")],
            "diff_name_only": [line for line in git_diff_names["stdout"].splitlines() if line.strip()],
            "status_error": git_status["stderr"],
        },
        "agentmemory": _agentmemory_health(),
        "wiki_health": build_health_report(root),
        "computer_inventory": {
            "exit_code": inventory["exit_code"],
            "summary": _parse_inventory_summary(inventory["stdout"]),
            "preview": _first_lines(inventory["stdout"], 80),
            "stderr": inventory["stderr"],
        },
        "wiki_maintenance_audit": {
            "exit_code": audit["exit_code"],
            "summary": _parse_audit_summary(audit["stdout"]),
            "preview": _first_lines(audit["stdout"], 80),
            "stderr": audit["stderr"],
        },
    }
    report["recommendations"] = _maintenance_recommendations(report)

    json_path = artifact_dir / f"{safe_stamp}.json"
    md_path = artifact_dir / f"{safe_stamp}.md"
    json_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    md_path.write_text(_maintenance_markdown(report), encoding="utf-8")
    report["artifacts"] = {"json": str(json_path), "markdown": str(md_path)}

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(_maintenance_markdown(report), end="")
        print(f"\nArtifacts:\n- {json_path}\n- {md_path}")


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

    # context
    p = sub.add_parser("context", help="Build layered context packs")
    p.add_argument("level", help="L0, L1, L2, L3, query, or page")
    p.add_argument("--query", help="Search query or page id, depending on level")
    p.add_argument("--page", help="Page id for L3/page context")
    p.add_argument("--top", type=int, default=6)

    # maintain
    p = sub.add_parser("maintain", help="Build a VipinKnowledge maintenance report")
    p.add_argument("--scope", choices=["whole-computer"], default="whole-computer")
    p.add_argument("--json", action="store_true")
    p.add_argument("--max-top-level-items", type=int, default=40)
    p.add_argument("--max-audit-items", type=int, default=25)

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
        "context": cmd_context,
        "maintain": cmd_maintain,
        "health": cmd_health,
    }

    if args.command in commands:
        commands[args.command](args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
