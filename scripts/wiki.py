#!/usr/bin/env python
"""Unified wiki CLI — single entry point for all wiki operations.

Usage:
    python scripts/wiki.py status [--json]
    python scripts/wiki.py catalog [--stdout]
    python scripts/wiki.py lint [--json]
    python scripts/wiki.py search <query> [--top N]
    python scripts/wiki.py context <level> [--query Q]
    python scripts/wiki.py maintain --scope whole-computer [--json]
    python scripts/wiki.py obsidian <report|export|search|quick|commands|backlinks|outgoing|outline|preview|tags|properties|tasks|daily|unique|random|word-count|footnotes|files|external-links|format-report|slides>
    python scripts/wiki.py health [--json] [--fix] [--dry-run]
    python scripts/wiki.py search <query> [--top N] [--graph] [--semantic]
    python scripts/wiki.py crystallize --title T [--type query|analysis|comparison|synthesis-session|synthesis|concept|topic|timeline] [--body .. | --from-file F] [--tags ..] [--source ..] [--dry-run]
    python scripts/wiki.py lifecycle [--json] [--stale-threshold F] [--apply]
    python scripts/wiki.py graph <stats|neighbors|path|export> [...]
    python scripts/wiki.py scrub <file> [--apply] [--out PATH]

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
    search_catalog_graph,
    graph_neighbors,
    graph_path,
    graph_stats,
    quality_score,
    lifecycle_audit,
    resolve_page,
    wiki_pages,
    parse_page,
    parse_frontmatter,
    body_without_frontmatter,
    infer_type_from_path,
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


def _load_fresh_catalog(root):
    """Load catalog.json, rebuilding it in-memory (no write) when stale/missing."""
    if catalog_freshness(root) == "fresh":
        try:
            return load_catalog(root)
        except SystemExit:
            pass
    return build_catalog(root)


def cmd_search(args):
    """Search wiki pages (BM25-lite; optional graph expansion and semantic fusion)."""
    root = resolve_root(args.root)
    catalog = _load_fresh_catalog(root)

    if getattr(args, "graph", False):
        results = search_catalog_graph(catalog, args.query, top=args.top)
        for i, r in enumerate(results, 1):
            print(f"{i}. [{r['score']:.4f}] ({r['via']}) {r['title']}")
            if r.get("path"):
                print(f"   {r['path']}")
    else:
        results = search_catalog(catalog, args.query, top=args.top)
        for i, r in enumerate(results, 1):
            score = r.get("score", 0)
            title = r.get("title", r.get("id", "?"))
            path = r.get("path", "")
            print(f"{i}. [{score:.2f}] {title}")
            if path:
                print(f"   {path}")

    if getattr(args, "semantic", False):
        sem = _agentmemory_search(args.query, top=args.top)
        print("\n## Semantic (agentmemory)")
        if not sem.get("available"):
            print(f"  unavailable: {sem.get('reason', 'agentmemory not reachable')} — BM25 results above.")
        elif sem.get("results") is None:
            print(f"  agentmemory reachable but {sem.get('reason', 'no semantic endpoint')}; BM25 results above.")
        else:
            print(f"  endpoint: {sem.get('endpoint')}")
            print(json.dumps(sem.get("results"), ensure_ascii=False, indent=2)[:2000])


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
    """Comprehensive health check — status, lint, metadata, quality, tiers; --fix self-heals."""
    root = resolve_root(args.root)

    if getattr(args, "fix", False):
        dry = getattr(args, "dry_run", False)
        actions = _apply_health_fixes(root, dry_run=dry)
        verb = "Would apply" if dry else "Applied"
        print(f"## Self-heal ({verb.lower()} {len(actions)} fix(es))")
        for action in actions[:50]:
            print(f"  - {action}")
        if len(actions) > 50:
            print(f"  ... and {len(actions) - 50} more")
        print()

    report = build_health_report(root)

    # Per-page content-quality distribution (read-only heuristic)
    catalog = _load_fresh_catalog(root)
    scores = [quality_score(p) for p in catalog.get("pages", [])]
    if scores:
        report["quality"] = {
            "avg": round(sum(scores) / len(scores), 3),
            "high_ge_0_8": sum(1 for s in scores if s >= 0.8),
            "medium_0_5_0_8": sum(1 for s in scores if 0.5 <= s < 0.8),
            "low_lt_0_5": sum(1 for s in scores if s < 0.5),
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

    if report.get("quality"):
        q = report["quality"]
        print(f"\n## Content Quality (heuristic 0-1)")
        print(f"- Average: {q['avg']}")
        print(f"- High (>=0.8): {q['high_ge_0_8']}")
        print(f"- Medium (0.5-0.8): {q['medium_0_5_0_8']}")
        print(f"- Low (<0.5): {q['low_lt_0_5']}")

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


def cmd_obsidian(args):
    """Obsidian-compatible vault reports and exports."""
    from wiki_obsidian import (
        backlinks_report,
        commands_report,
        create_daily_note,
        external_links_report,
        export_obsidian_artifacts,
        feature_report,
        files_report,
        footnotes_report,
        format_report,
        outline_report,
        outgoing_report,
        preview_report,
        properties_report,
        quick_switcher_report,
        random_note_report,
        search_report,
        slides_export,
        tags_report,
        tasks_report,
        unique_note,
        word_count_report,
    )

    root = resolve_root(args.root)
    if args.obsidian_command == "report":
        payload = feature_report(root)
    elif args.obsidian_command == "export":
        payload = export_obsidian_artifacts(root)
    elif args.obsidian_command == "search":
        payload = search_report(root, args.query, args.top)
    elif args.obsidian_command == "quick":
        payload = quick_switcher_report(root, args.query, args.top)
    elif args.obsidian_command == "commands":
        payload = commands_report(root)
    elif args.obsidian_command == "backlinks":
        payload = backlinks_report(root, args.page)
    elif args.obsidian_command == "outgoing":
        payload = outgoing_report(root, args.page)
    elif args.obsidian_command == "outline":
        payload = outline_report(root, args.page)
    elif args.obsidian_command == "preview":
        payload = preview_report(root, args.page, args.max_chars)
    elif args.obsidian_command == "tags":
        payload = tags_report(root)
    elif args.obsidian_command == "properties":
        payload = properties_report(root)
    elif args.obsidian_command == "tasks":
        payload = tasks_report(root, args.status)
    elif args.obsidian_command == "daily":
        payload = create_daily_note(root, args.date)
    elif args.obsidian_command == "unique":
        payload = unique_note(root, args.title)
    elif args.obsidian_command == "random":
        payload = random_note_report(root, args.seed)
    elif args.obsidian_command == "word-count":
        payload = word_count_report(root, args.page, args.top)
    elif args.obsidian_command == "footnotes":
        payload = footnotes_report(root, args.page)
    elif args.obsidian_command == "files":
        payload = files_report(root, args.max_items)
    elif args.obsidian_command == "external-links":
        payload = external_links_report(root, args.page, args.top)
    elif args.obsidian_command == "format-report":
        payload = format_report(root, args.page, args.top)
    elif args.obsidian_command == "slides":
        payload = slides_export(root, args.page)
    else:
        raise SystemExit("Unknown obsidian command")

    if getattr(args, "json", False):
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        print(json.dumps(payload, ensure_ascii=False, indent=2))


def cmd_hardness(args):
    """project-hardness: build/refresh a project's .agent/ causal layer."""
    # Import lazily so the rest of the CLI never depends on this package.
    from hardness import engine

    action = args.hardness_command
    if action == "scan":
        result = engine.scan(args.project, name=args.name, write=not args.no_write)
        if getattr(args, "json", False):
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            man = result.get("manifest", {})
            print(f"Hardened '{man.get('project', args.project)}' -> {result.get('agent_dir')}")
            print(f"  stats: {json.dumps(man.get('stats', {}))}")
            print(f"  artifacts: {len(man.get('artifacts', []))} files")
    elif action == "scan-all":
        from hardness import discover
        roots = args.root_dir or None
        result = discover.scan_all(roots=roots, dry_run=args.dry_run)
        if getattr(args, "json", False):
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            verb = "Discovered" if args.dry_run else "Hardened"
            print(f"{verb} {result['discovered']} project(s); "
                  f"hardened {result['hardened']}, errors {result['errors']}")
            for r in result["projects"]:
                stats = json.dumps(r.get("stats", {})) if r.get("stats") else ""
                print(f"  [{r['status']:>10}] {r['project']:<32} {stats} {r.get('error','')}")
    elif action == "harden":
        result = engine.harden(args.project, args.requirement, task_id=args.id)
        if getattr(args, "json", False):
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            print(f"Task hardened: {result['task_file']}")
            spec = result["spec"]
            print(f"  goal: {spec['clarified_goal']}")
            print(f"  modules: {', '.join(m['name'] for m in spec['involved_modules'])}")
            print(f"  risks: {len(spec['risk_points'])}; tests: {', '.join(spec['test_commands'])}")
    elif action == "auto":
        from hardness import auto
        roots = args.root_dir or None
        result = auto.auto_scan(roots=roots, threshold=args.threshold, dry_run=args.dry_run)
        if getattr(args, "json", False):
            print(json.dumps(result, ensure_ascii=False, indent=2))
        else:
            print(f"Checked {result['checked']}; hardened {result['hardened']}, "
                  f"baselined {result['baselined']}, skipped {result['skipped']}, "
                  f"errors {result['errors']}")
            for r in result["projects"]:
                if r.get("decision") not in ("skip", None) or r.get("status") == "error":
                    tag = r.get("decision") or r.get("status")
                    extra = " -> hardened" if r.get("hardened") else ""
                    print(f"  [{tag:>20}] {r['project']}{extra} {r.get('error','')}")
    elif action == "impact":
        result = engine.impact(args.project, args.module)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    elif action == "sync":
        lessons = args.lesson or []
        result = engine.sync(args.project, lessons, dry_run=not args.commit)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        raise SystemExit("Unknown hardness command")


def cmd_distill(args):
    """Feature A: distill the owner's recurring prompt patterns (advisory, human-gated).

    Default = dry-run (writes only .wiki-tmp/distill-candidates.json). --apply is the
    only mode that writes the curated, human-editable pattern table; it merges and never
    clobbers pinned/edited rows.
    """
    import distill as _distill

    result = _distill.distill(min_count=args.min_count, since_days=args.since_days)
    root = Path(args.root).resolve()
    cand_path = root / ".wiki-tmp" / "distill-candidates.json"
    cand_path.parent.mkdir(parents=True, exist_ok=True)
    cand_path.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")

    if args.apply:
        md_path = root / "memory" / "preferences" / "distilled-task-patterns.md"
        md_path.parent.mkdir(parents=True, exist_ok=True)
        prior = md_path.read_text(encoding="utf-8") if md_path.exists() else ""
        md_path.write_text(_distill.render_apply(result, prior), encoding="utf-8")

    if getattr(args, "json", False):
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"distill: {result['turns_extracted']} owner turns "
              f"({result['turns_dropped_redacted']} redaction-dropped); "
              f"sources={result['sources_read']}")
        print(f"  clusters (>= {result['min_count']}):")
        for c in result["clusters"]:
            print(f"    {c['count']:>4}  {c['pattern_key']:<20} "
                  f"skill={c['suggested_skill'] or '-'}  projects={','.join(c['top_projects'])}")
        print(f"  candidates -> {cand_path}")
        print(f"  APPLIED -> memory/preferences/distilled-task-patterns.md" if args.apply
              else "  (dry-run; re-run with --apply to write the curated pattern table)")


# ──────────────────────────────────────────────────────────────────────────────
# LLM Wiki v2 upgrade commands: crystallize, lifecycle, graph, scrub + self-heal.
# All additive. Writes only under wiki/ (public-safe); never touches raw/ or
# wiki-private/. agentmemory calls are best-effort and non-fatal.
# ──────────────────────────────────────────────────────────────────────────────

# crystallize type -> (relative dir, frontmatter type, dated-filename?, needs-counterpoints?)
_CRYSTALLIZE_ROUTES = {
    "query": ("wiki/queries", "query", True, False),
    "analysis": ("wiki/analyses", "analysis", True, True),
    "comparison": ("wiki/comparisons", "comparison", True, True),
    "synthesis-session": ("wiki/synthesis/sessions", "synthesis", True, True),
    "synthesis": ("wiki/synthesis", "synthesis", False, True),
    "concept": ("wiki/concepts", "concept", False, True),
    "topic": ("wiki/topics", "topic", False, True),
    "timeline": ("wiki/timelines", "timeline", True, False),
}

_INDEX_MARK_START = "<!-- crystallize:auto:start -->"
_INDEX_MARK_END = "<!-- crystallize:auto:end -->"


def _slugify(text: str) -> str:
    text = (text or "").strip().lower()
    text = re.sub(r"[^\w\s-]", "", text, flags=re.UNICODE)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-+", "-", text).strip("-")
    return text or "untitled"


def _read_body_arg(args) -> str:
    if getattr(args, "body", None):
        return args.body
    if getattr(args, "from_file", None):
        return Path(args.from_file).read_text(encoding="utf-8", errors="ignore")
    try:
        if not sys.stdin.isatty():
            data = sys.stdin.read()
            if data.strip():
                return data
    except Exception:
        pass
    return ""


def _fmt_list_block(key: str, values: list) -> str:
    if not values:
        return f"{key}:"
    return f"{key}:\n" + "\n".join(f"  - {v}" for v in values)


def build_catalog_and_write(root: Path) -> dict:
    catalog = build_catalog(root)
    (root / "wiki" / "catalog.json").write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return catalog


def _append_index_entry(root: Path, legacy_id: str, title: str, date: str) -> bool:
    index_path = root / "wiki" / "index.md"
    text = read_text(index_path)
    if f"[[{legacy_id}" in text:
        return False  # already referenced
    entry = f"- [[{legacy_id}]] — {title} ({date})"
    if _INDEX_MARK_START in text and _INDEX_MARK_END in text:
        text = text.replace(_INDEX_MARK_END, entry + "\n" + _INDEX_MARK_END, 1)
    else:
        block = f"\n{_INDEX_MARK_START}\n## Recently Crystallized\n\n{entry}\n{_INDEX_MARK_END}\n"
        text = text.rstrip() + "\n" + block
    index_path.write_text(text, encoding="utf-8")
    return True


def _append_log_entry(root: Path, fm_type: str, title: str, page_path: str, sources: list) -> None:
    log_path = root / "wiki" / "log.md"
    op = "query" if fm_type == "query" else "analysis"  # AGENTS.md log operations
    stamp = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    lines = [
        "",
        f"## [{stamp}] {op} | crystallize: {title}",
        "",
        f"- page: {page_path}",
        f"- sources: {', '.join(sources) if sources else 'crystallized outcome'}",
        "- note: crystallized via `wiki.py crystallize`",
        "",
    ]
    with open(log_path, "a", encoding="utf-8") as handle:
        handle.write("\n".join(lines))


def cmd_crystallize(args):
    """Turn a high-value outcome into a durable, routed wiki page (LLM Wiki v2 'crystallization')."""
    root = resolve_root(args.root)
    route = _CRYSTALLIZE_ROUTES.get(args.type)
    if not route:
        raise SystemExit(f"Unknown --type {args.type!r}; choose from {', '.join(_CRYSTALLIZE_ROUTES)}")
    rel_dir, fm_type, dated, needs_cp = route

    body = _read_body_arg(args).strip()
    if not body:
        raise SystemExit("No body provided. Use --body, --from-file, or pipe content via stdin.")

    today = args.date or dt.date.today().isoformat()
    slug = _slugify(args.title)
    filename = f"{today}-{slug}.md" if dated else f"{slug}.md"
    target = root / rel_dir / filename
    legacy_id = Path(filename).stem

    if target.exists() and not args.force:
        rel = target.relative_to(root).as_posix()
        raise SystemExit(f"{rel} already exists. Use --force to overwrite, or update it directly.")

    tags = [t.strip() for t in (args.tags or "").split(",") if t.strip()] or [fm_type]
    source_pages = [s.strip() for s in (args.source or "").split(",") if s.strip()]
    source_files = [s.strip() for s in (args.source_file or "").split(",") if s.strip()]

    fm_lines = [
        "---",
        f"title: {args.title}",
        f"type: {fm_type}",
        f"status: {args.status}",
        f"created: {today}",
        f"updated: {today}",
        f"confidence: {args.confidence}",
        _fmt_list_block("tags", tags),
        _fmt_list_block("source_pages", source_pages),
        _fmt_list_block("source_files", source_files),
        "---",
    ]
    parts = ["\n".join(fm_lines), "", f"# {args.title}", "", body, ""]

    src_section = ["## Sources", ""]
    src_section += [f"- [[{s}]]" for s in source_pages]
    src_section += [f"- `{s}`" for s in source_files]
    if not source_pages and not source_files:
        src_section += [f"- origin: crystallized via `wiki.py crystallize` on {today}"]
    parts += ["\n".join(src_section), ""]

    if needs_cp and "## Counterpoints" not in body:
        parts += ["## Counterpoints and Gaps", "", "- (none recorded yet — review and fill in)", ""]

    content = "\n".join(parts).rstrip() + "\n"

    if args.dry_run:
        print(f"# DRY RUN — would write {target.relative_to(root).as_posix()}\n")
        print(content)
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")

    index_added = _append_index_entry(root, legacy_id, args.title, today)
    _append_log_entry(root, fm_type, args.title, target.relative_to(root).as_posix(), source_pages + source_files)

    build_catalog_and_write(root)
    issues = lint_wiki(root)
    rel_path = target.relative_to(root).as_posix()
    new_issues = {
        k: [x for x in v if rel_path in str(x) or f"[[{legacy_id}]]" in str(x)]
        for k, v in issues.items()
        if isinstance(v, list)
    }
    new_issues = {k: v for k, v in new_issues.items() if v}
    lint_total = sum(len(v) for v in issues.values() if isinstance(v, list))

    print(f"Crystallized -> {rel_path}")
    print(f"  index updated: {index_added}; catalog rebuilt; lint total: {lint_total}")
    if new_issues:
        print("  WARNING — lint issues attributable to the new page:")
        for k, v in new_issues.items():
            print(f"    {k}: {v}")


def _lifecycle_apply(root: Path) -> int:
    """Stamp last_confirmed (file mtime) onto pages missing all date fields. Additive only."""
    count = 0
    for path in wiki_pages(root):
        text = read_text(path)
        fm = parse_frontmatter(text)
        if fm.get("created") or fm.get("updated") or fm.get("last_confirmed"):
            continue
        stamp = dt.date.fromtimestamp(path.stat().st_mtime).isoformat()
        path.write_text(_apply_frontmatter(text, {"last_confirmed": stamp}), encoding="utf-8")
        count += 1
    return count


def cmd_lifecycle(args):
    """Advisory memory-lifecycle audit: confidence, Ebbinghaus retention decay, supersession."""
    root = resolve_root(args.root)
    audit = lifecycle_audit(root, stale_threshold=args.stale_threshold, top=args.top)
    if args.apply:
        audit["applied"] = _lifecycle_apply(root)

    if args.json:
        print(json.dumps(audit, ensure_ascii=False, indent=2))
        return

    print("# Memory Lifecycle Audit")
    print(f"- generated for: {audit['generated_for']}  (stale = retention < {audit['stale_threshold']})")
    print(f"- total pages: {audit['total_pages']}")
    counts = audit["counts"]
    print(f"- stale: {counts['stale']}  low-confidence: {counts['low_confidence']}  "
          f"superseded: {counts['superseded']}  no-date: {counts['no_date']}")

    def _show(title, rows, fields):
        print(f"\n## {title} ({len(rows)} shown)")
        for row in rows:
            print("  - " + "  ".join(f"{f}={row.get(f)}" for f in fields))

    if audit["stale_candidates"]:
        _show("Stale candidates (lowest retention)", audit["stale_candidates"],
              ["path", "type", "age_days", "retention"])
    if audit["low_confidence"]:
        _show("Low confidence", audit["low_confidence"], ["path", "confidence", "retention"])
    if audit["superseded"]:
        _show("Marked superseded", audit["superseded"], ["path", "superseded_by"])
    if audit["no_date_sample"]:
        _show("No date fields (sample)", audit["no_date_sample"], ["path", "type"])
    if args.apply:
        print(f"\n## Applied\n- stamped last_confirmed on {audit['applied']} page(s) missing all date fields")


def cmd_graph(args):
    """Query the wiki-link knowledge graph (built from catalog resolved links)."""
    root = resolve_root(args.root)
    catalog = _load_fresh_catalog(root)
    by_id = {p["id"]: p for p in catalog.get("pages", [])}
    sub = args.graph_command

    if sub == "stats":
        payload = graph_stats(catalog, top=args.top)
    elif sub == "neighbors":
        page = resolve_page(catalog, args.page)
        if not page:
            raise SystemExit(f"page not found: {args.page}")
        neigh = graph_neighbors(catalog, page["id"], depth=args.depth, relation=args.relation)
        payload = {
            "center": page["id"], "depth": args.depth, "relation": args.relation,
            "neighbors": [
                {"id": nid, "hops": hops, "title": by_id.get(nid, {}).get("title", nid),
                 "path": by_id.get(nid, {}).get("path", "")}
                for nid, hops in sorted(neigh.items(), key=lambda kv: (kv[1], kv[0]))
            ],
        }
    elif sub == "path":
        a = resolve_page(catalog, args.source)
        b = resolve_page(catalog, args.target)
        if not a or not b:
            raise SystemExit("source or target page not found")
        link_path = graph_path(catalog, a["id"], b["id"], max_depth=args.max_depth)
        payload = {"source": a["id"], "target": b["id"],
                   "hops": (len(link_path) - 1 if link_path else None), "path": link_path}
    elif sub == "export":
        page = resolve_page(catalog, args.page)
        if not page:
            raise SystemExit(f"page not found: {args.page}")
        neigh = graph_neighbors(catalog, page["id"], depth=args.depth)
        payload = {
            "center": {"id": page["id"], "title": page.get("title")},
            "neighbors": [
                {"id": nid, "hops": hops, "title": by_id.get(nid, {}).get("title", nid)}
                for nid, hops in sorted(neigh.items(), key=lambda kv: (kv[1], kv[0]))
            ],
        }
    else:
        raise SystemExit("Unknown graph command")
    print(json.dumps(payload, ensure_ascii=False, indent=2))


def _agentmemory_search(query: str, top: int = 6, timeout: int = 5) -> dict:
    """Best-effort semantic search via the local agentmemory service. Never raises."""
    health = _agentmemory_health()
    if not health.get("available"):
        return {"available": False, "reason": "service not reachable on localhost:3111"}
    base = "http://localhost:3111"
    candidates = [
        "/agentmemory/search",
        "/agentmemory/memory/search",
        "/agentmemory/smart-search",
    ]
    payload = json.dumps({"query": query, "limit": top}).encode("utf-8")
    for path in candidates:
        try:
            req = urllib.request.Request(
                base + path, data=payload,
                headers={"Content-Type": "application/json"}, method="POST",
            )
            with urllib.request.urlopen(req, timeout=timeout) as response:
                body = json.loads(response.read().decode("utf-8", errors="replace"))
            return {"available": True, "endpoint": path, "results": body}
        except Exception:
            continue
    return {"available": True, "reason": "no known semantic endpoint responded", "results": None}


# Secret / private-path patterns for the ingest privacy-scrub.
_SECRET_PATTERNS = [
    ("private-path", re.compile(r"raw/private-[\w./\-]*|wiki-private/[\w./\-]*")),
    ("api-key", re.compile(r"(?i)\b(sk-[A-Za-z0-9]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})\b")),
    ("bearer", re.compile(r"(?i)\bBearer\s+[A-Za-z0-9._\-]{16,}")),
    ("assignment", re.compile(r"(?i)\b(api[_-]?key|secret|token|password|passwd|access[_-]?key)\b\s*[:=]\s*\S+")),
    ("email", re.compile(r"\b[\w.+\-]+@[\w\-]+\.[\w.\-]+\b")),
    ("private-ip", re.compile(r"\b(?:10\.\d{1,3}|192\.168|172\.(?:1[6-9]|2\d|3[01]))\.\d{1,3}\.\d{1,3}\b")),
]


def cmd_scrub(args):
    """Scan a file for secrets/private paths before ingest. Report-first; --apply writes a redacted copy."""
    path = Path(args.file)
    if not path.exists():
        raise SystemExit(f"file not found: {path}")
    text = path.read_text(encoding="utf-8", errors="ignore")
    findings = []
    redacted = text
    for name, pattern in _SECRET_PATTERNS:
        for match in pattern.finditer(text):
            findings.append({
                "type": name,
                "match": match.group(0)[:80],
                "line": text[: match.start()].count("\n") + 1,
            })
        if args.apply:
            redacted = pattern.sub(f"[REDACTED:{name}]", redacted)
    report = {"file": str(path), "count": len(findings), "findings": findings}
    if args.apply:
        out = Path(args.out) if args.out else path.with_suffix(path.suffix + ".scrubbed")
        out.write_text(redacted, encoding="utf-8")
        report["redacted_written"] = str(out)
    print(json.dumps(report, ensure_ascii=False, indent=2))


def _apply_frontmatter(text: str, additions: dict) -> str:
    """Insert `key: value` lines into a page's YAML frontmatter (or create one). Non-destructive."""
    bom = "﻿" if text.startswith("﻿") else ""
    body = text[len(bom):]
    add_lines = "\n".join(f"{k}: {v}" for k, v in additions.items())
    if body.startswith("---"):
        sections = re.split(r"(?m)^---[ \t]*$", body, maxsplit=2)
        if len(sections) >= 3:
            frontmatter = sections[1].strip("\n")
            rest = sections[2]
            return f"{bom}---\n{frontmatter}\n{add_lines}\n---{rest}"
    return f"{bom}---\n{add_lines}\n---\n\n{body}"


def _apply_health_fixes(root: Path, dry_run: bool = False) -> list:
    """Non-destructive self-healing: rebuild stale catalog + inject missing frontmatter."""
    actions = []
    if catalog_freshness(root) != "fresh":
        actions.append("rebuild stale wiki/catalog.json")
        if not dry_run:
            build_catalog_and_write(root)
    for path in wiki_pages(root):
        text = read_text(path)
        if not text.strip():
            continue
        fm = parse_frontmatter(text)
        additions = {}
        if not fm.get("title"):
            heading = re.search(r"(?m)^#\s+(.+)$", body_without_frontmatter(text))
            additions["title"] = heading.group(1).strip() if heading else path.stem
        if not fm.get("type"):
            additions["type"] = infer_type_from_path(path)
        if not fm.get("created"):
            additions["created"] = dt.date.fromtimestamp(path.stat().st_mtime).isoformat()
        if additions:
            actions.append(f"add {list(additions)} to {path.relative_to(root).as_posix()}")
            if not dry_run:
                path.write_text(_apply_frontmatter(text, additions), encoding="utf-8")
    return actions


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
    p.add_argument("--graph", action="store_true", help="Fuse BM25 with 1-hop wiki-link graph expansion (RRF)")
    p.add_argument("--semantic", action="store_true", help="Also query agentmemory semantic search (best-effort)")

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

    # obsidian
    p = sub.add_parser("obsidian", help="Obsidian-compatible vault helpers")
    obsidian_sub = p.add_subparsers(dest="obsidian_command", required=True)
    q = obsidian_sub.add_parser("report", help="Show Obsidian feature parity report")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("export", help="Write Obsidian vault config, bases, canvas, templates, and dashboard")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("search", help="Search wiki pages with structured JSON")
    q.add_argument("query")
    q.add_argument("--top", type=int, default=10)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("quick", help="Quick-switch by title, id, alias, or search")
    q.add_argument("query")
    q.add_argument("--top", type=int, default=10)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("commands", help="Show Obsidian-style command palette")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("backlinks", help="Show backlinks and unlinked mentions for a page")
    q.add_argument("page")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("outgoing", help="Show outgoing links for a page")
    q.add_argument("page")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("outline", help="Show heading outline for a page")
    q.add_argument("page")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("preview", help="Show a short page preview")
    q.add_argument("page")
    q.add_argument("--max-chars", type=int, default=900)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("tags", help="Show tag counts and tagged pages")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("properties", help="Show frontmatter property schema")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("tasks", help="Show Markdown checkbox tasks")
    q.add_argument("--status", choices=["all", "open", "done"], default="all")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("daily", help="Create a daily note from the daily template")
    q.add_argument("--date", help="YYYY-MM-DD; defaults to today")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("unique", help="Create a timestamped inbox note")
    q.add_argument("--title", help="Optional note title")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("random", help="Open a random note candidate")
    q.add_argument("--seed", help="Optional deterministic seed")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("word-count", help="Show word and character counts")
    q.add_argument("--page", help="Optional page id")
    q.add_argument("--top", type=int, default=20)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("footnotes", help="Audit footnote references and definitions")
    q.add_argument("--page", help="Optional page id")
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("files", help="Show vault folder/recent-file report")
    q.add_argument("--max-items", type=int, default=100)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("external-links", help="Show external links for a page or vault slice")
    q.add_argument("--page", help="Optional page id")
    q.add_argument("--top", type=int, default=100)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("format-report", help="Report Markdown conversion issues")
    q.add_argument("--page", help="Optional page id")
    q.add_argument("--top", type=int, default=100)
    q.add_argument("--json", action="store_true")
    q = obsidian_sub.add_parser("slides", help="Export a wiki page as a Markdown slide deck")
    q.add_argument("page")
    q.add_argument("--json", action="store_true")

    # health
    p = sub.add_parser("health", help="Comprehensive health check")
    p.add_argument("--json", action="store_true")
    p.add_argument("--fix", action="store_true", help="Auto-fix safe, non-destructive issues")
    p.add_argument("--dry-run", action="store_true", help="With --fix, preview fixes without writing")

    # hardness — project causal-layer engine
    p = sub.add_parser("hardness", help="project-hardness: AI-readable causal layer for a project")
    hsub = p.add_subparsers(dest="hardness_command", required=True)
    hs = hsub.add_parser("scan", help="Scan a project and write its .agent/ tree")
    hs.add_argument("project", help="Path to the target project root")
    hs.add_argument("--name", help="Override project name")
    hs.add_argument("--no-write", action="store_true", help="Analyze only, do not write .agent/")
    hs.add_argument("--json", action="store_true")
    hsa = hsub.add_parser("scan-all", help="Discover and harden every important project under D:")
    hsa.add_argument("--root-dir", action="append", help="Override search root (repeatable)")
    hsa.add_argument("--dry-run", action="store_true", help="List discovered projects, do not write")
    hsa.add_argument("--json", action="store_true")
    hau = hsub.add_parser("auto", help="Auto-incremental: harden only NEW or significantly-changed projects")
    hau.add_argument("--root-dir", action="append", help="Override search root (repeatable)")
    hau.add_argument("--threshold", type=int, default=15,
                     help="Code-file count delta that counts as 'significant change' (default 15)")
    hau.add_argument("--dry-run", action="store_true", help="Show decisions, do not write")
    hau.add_argument("--json", action="store_true")
    hh = hsub.add_parser("harden", help="Harden a vague requirement into a task spec")
    hh.add_argument("project", help="Path to the target project root")
    hh.add_argument("requirement", help="The free-text requirement to harden")
    hh.add_argument("--id", help="Optional task id (default: timestamp)")
    hh.add_argument("--json", action="store_true")
    hi = hsub.add_parser("impact", help="Show blast radius of a module")
    hi.add_argument("project", help="Path to the target project root")
    hi.add_argument("module", help="Module name (as in architecture.md)")
    hsy = hsub.add_parser("sync", help="Sync cross-project lessons to agentmemory (facts rejected)")
    hsy.add_argument("project", help="Path to the target project root")
    hsy.add_argument("--lesson", action="append", help="A cross-project lesson (repeatable)")
    hsy.add_argument("--commit", action="store_true", help="Actually send (default: dry-run)")

    # distill (Feature A: owner prompt-pattern distiller — advisory, human-gated)
    pd = sub.add_parser("distill", help="Distill the owner's recurring prompt patterns (advisory)")
    pd.add_argument("--apply", action="store_true",
                    help="Write the curated pattern table (default: dry-run, .wiki-tmp only)")
    pd.add_argument("--dry-run", action="store_true", help="Explicit dry-run (the default)")
    pd.add_argument("--min-count", type=int, default=4, help="Min cluster size to emit (default 4)")
    pd.add_argument("--since-days", type=int, default=180, help="Ignore turns older than N days (default 180)")
    pd.add_argument("--json", action="store_true")

    # crystallize (LLM Wiki v2: turn a high-value outcome into a durable page)
    pc = sub.add_parser("crystallize", help="Crystallize a high-value outcome into a durable wiki page")
    pc.add_argument("--title", required=True)
    pc.add_argument("--type", default="query", choices=list(_CRYSTALLIZE_ROUTES))
    pc.add_argument("--body", help="Page body text")
    pc.add_argument("--from-file", dest="from_file", help="Read body from a file")
    pc.add_argument("--tags", help="Comma-separated tags")
    pc.add_argument("--source", help="Comma-separated source page ids")
    pc.add_argument("--source-file", dest="source_file", help="Comma-separated source file paths")
    pc.add_argument("--status", default="active")
    pc.add_argument("--confidence", default="INFERRED", help="Confidence label or numeric (frontmatter)")
    pc.add_argument("--date", help="Override created/updated date (YYYY-MM-DD)")
    pc.add_argument("--force", action="store_true", help="Overwrite if the page already exists")
    pc.add_argument("--dry-run", action="store_true", help="Print the page instead of writing")

    # lifecycle (LLM Wiki v2: confidence / retention-decay / supersession audit)
    pl = sub.add_parser("lifecycle", help="Advisory memory-lifecycle audit")
    pl.add_argument("--json", action="store_true")
    pl.add_argument("--stale-threshold", dest="stale_threshold", type=float, default=0.35)
    pl.add_argument("--top", type=int, default=25)
    pl.add_argument("--apply", action="store_true",
                    help="Stamp last_confirmed on pages missing all date fields (additive)")

    # graph (LLM Wiki v2: typed knowledge-graph traversal over wiki links)
    pg = sub.add_parser("graph", help="Query the wiki-link knowledge graph")
    gsub = pg.add_subparsers(dest="graph_command", required=True)
    gs = gsub.add_parser("stats", help="Graph statistics")
    gs.add_argument("--top", type=int, default=15)
    gn = gsub.add_parser("neighbors", help="Neighborhood of a page")
    gn.add_argument("page")
    gn.add_argument("--depth", type=int, default=1)
    gn.add_argument("--relation", help="Restrict expansion to a typed relation")
    gp = gsub.add_parser("path", help="Shortest link path between two pages")
    gp.add_argument("source")
    gp.add_argument("target")
    gp.add_argument("--max-depth", dest="max_depth", type=int, default=8)
    ge = gsub.add_parser("export", help="Export a page neighborhood as JSON")
    ge.add_argument("page")
    ge.add_argument("--depth", type=int, default=2)

    # scrub (LLM Wiki v2: privacy filter-on-ingest)
    psc = sub.add_parser("scrub", help="Scan a file for secrets/private paths before ingest")
    psc.add_argument("file")
    psc.add_argument("--apply", action="store_true", help="Write a redacted copy (never overwrites the original)")
    psc.add_argument("--out", help="Output path for the redacted copy")

    args = parser.parse_args()

    commands = {
        "status": cmd_status,
        "catalog": cmd_catalog,
        "lint": cmd_lint,
        "search": cmd_search,
        "context": cmd_context,
        "maintain": cmd_maintain,
        "obsidian": cmd_obsidian,
        "health": cmd_health,
        "hardness": cmd_hardness,
        "distill": cmd_distill,
        "crystallize": cmd_crystallize,
        "lifecycle": cmd_lifecycle,
        "graph": cmd_graph,
        "scrub": cmd_scrub,
    }

    if args.command in commands:
        commands[args.command](args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
