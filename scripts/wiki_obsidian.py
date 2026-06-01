#!/usr/bin/env python
"""Obsidian-compatible vault helpers for vipin wiki.

This module does not depend on the proprietary Obsidian app. It exports local,
plain-text artifacts that Obsidian can open: .obsidian settings, .base views,
JSON Canvas files, templates, and generated Markdown dashboards.
"""
from __future__ import annotations

import datetime as dt
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

from wiki_core import build_catalog, load_catalog, parse_frontmatter, read_text, resolve_page, wiki_pages


TASK_RE = re.compile(r"^(?P<indent>\s*)[-*]\s+\[(?P<mark>[ xX-])\]\s+(?P<body>.+?)\s*$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
DATETIME_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}")


def _catalog(root: Path) -> dict:
    try:
        return load_catalog(root)
    except SystemExit:
        return build_catalog(root)


def _frontmatter_pages(root: Path) -> list[tuple[Path, dict]]:
    return [(path, parse_frontmatter(read_text(path))) for path in sorted(wiki_pages(root))]


def _infer_property_type(value: object) -> str:
    if isinstance(value, list):
        return "list"
    if isinstance(value, bool) or str(value).lower() in {"true", "false"}:
        return "checkbox"
    text = str(value).strip()
    if DATETIME_RE.match(text):
        return "date-time"
    if DATE_RE.match(text):
        return "date"
    try:
        float(text)
        return "number"
    except ValueError:
        return "text"


def _markdown_table(headers: list[str], rows: list[list[str]]) -> str:
    lines = ["| " + " | ".join(headers) + " |", "| " + " | ".join(["---"] * len(headers)) + " |"]
    for row in rows:
        safe = [str(cell).replace("\n", " ").replace("|", "\\|") for cell in row]
        lines.append("| " + " | ".join(safe) + " |")
    return "\n".join(lines)


def tags_report(root: Path) -> dict:
    catalog = _catalog(root)
    counts: Counter[str] = Counter()
    pages_by_tag: dict[str, list[str]] = defaultdict(list)
    for page in catalog.get("pages", []):
        for tag in page.get("tags", []):
            counts[tag] += 1
            pages_by_tag[tag].append(page["id"])
    return {
        "tags": [
            {"tag": tag, "count": count, "pages": sorted(pages_by_tag[tag])}
            for tag, count in sorted(counts.items(), key=lambda item: (-item[1], item[0]))
        ]
    }


def properties_report(root: Path) -> dict:
    prop_counts: Counter[str] = Counter()
    prop_types: dict[str, Counter[str]] = defaultdict(Counter)
    examples: dict[str, list[str]] = defaultdict(list)
    for path, fm in _frontmatter_pages(root):
        rel = path.relative_to(root).as_posix()
        for key, value in fm.items():
            prop_counts[key] += 1
            prop_types[key][_infer_property_type(value)] += 1
            if len(examples[key]) < 5:
                examples[key].append(rel)
    return {
        "properties": [
            {
                "property": key,
                "count": prop_counts[key],
                "types": dict(prop_types[key]),
                "examples": examples[key],
            }
            for key in sorted(prop_counts, key=lambda item: (-prop_counts[item], item))
        ]
    }


def tasks_report(root: Path, status: str = "all") -> dict:
    tasks = []
    for path in sorted(wiki_pages(root)):
        rel = path.relative_to(root).as_posix()
        for line_number, line in enumerate(read_text(path).splitlines(), 1):
            match = TASK_RE.match(line)
            if not match:
                continue
            mark = match.group("mark")
            done = mark.lower() == "x"
            task_status = "done" if done else "open"
            if status != "all" and task_status != status:
                continue
            tasks.append(
                {
                    "status": task_status,
                    "file": rel,
                    "line": line_number,
                    "text": match.group("body").strip(),
                }
            )
    return {"tasks": tasks}


def backlinks_report(root: Path, page_id: str) -> dict:
    catalog = _catalog(root)
    target = resolve_page(catalog, page_id)
    if not target:
        raise SystemExit(f"Page not found or ambiguous: {page_id}")
    linked = []
    unlinked = []
    needles = sorted(set([target["legacy_id"], target["title"], *target.get("aliases", [])]), key=len, reverse=True)
    for page in catalog.get("pages", []):
        if page["id"] == target["id"]:
            continue
        if target["id"] in page.get("resolved_links", []):
            linked.append({"id": page["id"], "title": page["title"], "path": page["path"]})
            continue
        body = page.get("body_text", "")
        if any(needle and needle in body for needle in needles):
            unlinked.append({"id": page["id"], "title": page["title"], "path": page["path"]})
    return {"target": target, "linked_backlinks": linked, "unlinked_mentions": unlinked}


def outgoing_report(root: Path, page_id: str) -> dict:
    catalog = _catalog(root)
    page = resolve_page(catalog, page_id)
    if not page:
        raise SystemExit(f"Page not found or ambiguous: {page_id}")
    resolved = set(page.get("resolved_links", []))
    unresolved = [link for link in page.get("links", []) if link not in resolved and link not in {p.split("/", 1)[-1] for p in resolved}]
    return {"page": page, "resolved_links": sorted(resolved), "raw_links": page.get("links", []), "unresolved_links": unresolved}


def feature_report(root: Path) -> dict:
    return {
        "source_note": "Obsidian core app is proprietary; this report maps official Obsidian concepts to local plain-text equivalents.",
        "features": [
            {"obsidian": "Backlinks and outgoing links", "vipinknowledge": "catalog backlinks plus wiki.py obsidian backlinks/outgoing", "status": "implemented"},
            {"obsidian": "Graph view", "vipinknowledge": "existing knowledge graph plus JSON Canvas export", "status": "implemented"},
            {"obsidian": "Bases", "vipinknowledge": "generated .base files over Markdown properties", "status": "implemented"},
            {"obsidian": "Properties view", "vipinknowledge": "frontmatter property schema report", "status": "implemented"},
            {"obsidian": "Tags view", "vipinknowledge": "tag count and page index", "status": "implemented"},
            {"obsidian": "Tasks", "vipinknowledge": "checkbox task scan across wiki pages", "status": "implemented"},
            {"obsidian": "Daily notes and templates", "vipinknowledge": "daily template and daily note creator", "status": "implemented"},
            {"obsidian": "Bookmarks", "vipinknowledge": "generated bookmarks dashboard for high-value pages and searches", "status": "implemented"},
            {"obsidian": "Canvas", "vipinknowledge": "JSON Canvas map under wiki/canvases", "status": "implemented"},
            {"obsidian": "Web Clipper", "vipinknowledge": "web-clip template plus existing ingest/url-to-markdown skill route", "status": "adapted"},
            {"obsidian": "Sync/Publish", "vipinknowledge": "GitHub commit/push and Quartz site publish", "status": "already-covered"},
        ],
    }


def _write_json(path: Path, payload: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n", encoding="utf-8")


def _base_files(root: Path) -> dict[str, str]:
    return {
        "all-pages.base": """filters:
  and:
    - file.inFolder("wiki")
views:
  - type: table
    name: All pages
    order:
      - file.name
      - title
      - type
      - status
      - updated
      - tags
""",
        "active-projects.base": """filters:
  and:
    - or:
      - file.hasTag("project")
      - file.hasTag("research")
      - file.hasTag("infrastructure")
views:
  - type: table
    name: Active roots
    order:
      - file.name
      - title
      - type
      - status
      - updated
      - tags
""",
        "sources.base": """filters:
  and:
    - file.inFolder("wiki/sources")
views:
  - type: table
    name: Source notes
    order:
      - file.name
      - title
      - status
      - updated
      - source_files
      - tags
""",
        "maintenance.base": """filters:
  and:
    - or:
      - file.hasTag("maintenance")
      - file.hasTag("workflow")
      - file.hasTag("agentmemory")
      - file.hasTag("skills")
views:
  - type: table
    name: Maintenance
    order:
      - file.name
      - title
      - status
      - updated
      - tags
""",
    }


def _canvas(root: Path, catalog: dict) -> dict:
    wanted = [
        "home",
        "index",
        "log",
        "concepts/vipinknowledge-maintenance-system",
        "concepts/whole-computer-project-map",
        "concepts/d-drive-project-map",
        "topics/local-active-project-roots",
        "topics/local-project-roots",
        "concepts/research-project-workbench",
        "concepts/agentmemory-first-agent-collaboration",
        "concepts/implicit-skill-routing",
        "concepts/agent-skill-installation-workflow",
    ]
    pages = {page["id"]: page for page in catalog.get("pages", [])}
    selected = [pages[item] for item in wanted if item in pages]
    nodes = []
    for index, page in enumerate(selected):
        col = index % 4
        row = index // 4
        nodes.append(
            {
                "id": f"n{index}",
                "type": "file",
                "file": page["path"].removeprefix("wiki/"),
                "x": col * 520,
                "y": row * 260,
                "width": 420,
                "height": 180,
                "color": str((index % 6) + 1),
            }
        )
    id_to_node = {page["id"]: f"n{index}" for index, page in enumerate(selected)}
    edges = []
    for page in selected:
        from_node = id_to_node[page["id"]]
        for target in page.get("resolved_links", []):
            if target in id_to_node:
                edges.append(
                    {
                        "id": f"e{len(edges)}",
                        "fromNode": from_node,
                        "toNode": id_to_node[target],
                        "toEnd": "arrow",
                    }
                )
    return {"nodes": nodes, "edges": edges}


def export_obsidian_artifacts(root: Path) -> dict:
    catalog = build_catalog(root)
    artifacts: list[str] = []

    obsidian_dir = root / ".obsidian"
    _write_json(
        obsidian_dir / "app.json",
        {
            "alwaysUpdateLinks": True,
            "attachmentFolderPath": "raw/attachments",
            "newFileLocation": "folder",
            "newFileFolderPath": "wiki/inbox",
            "promptDelete": False,
            "showInlineTitle": True,
        },
    )
    _write_json(
        obsidian_dir / "core-plugins.json",
        [
            "backlink",
            "bookmarks",
            "canvas",
            "daily-notes",
            "file-explorer",
            "global-search",
            "graph",
            "outgoing-link",
            "outline",
            "page-preview",
            "properties",
            "slash-command",
            "switcher",
            "tag-pane",
            "templates",
            "word-count",
            "workspaces",
        ],
    )
    _write_json(obsidian_dir / "daily-notes.json", {"folder": "wiki/daily", "format": "YYYY-MM-DD", "template": "wiki/_templates/daily.md"})
    _write_json(obsidian_dir / "templates.json", {"folder": "wiki/_templates"})
    _write_json(obsidian_dir / "graph.json", {"collapse-filter": False, "search": "", "showTags": True, "showAttachments": False})
    artifacts.extend(str(path.relative_to(root)) for path in obsidian_dir.glob("*.json"))

    for name, content in _base_files(root).items():
        path = root / "wiki" / "bases" / name
        _write_text(path, content)
        artifacts.append(str(path.relative_to(root)))
    bases_readme = """---
title: Obsidian Bases
type: overview
status: generated
created: 2026-06-01
updated: 2026-06-01
tags:
  - obsidian
  - bases
---

# Obsidian Bases

Generated `.base` views for opening this repository as an Obsidian vault.

- ![[bases/all-pages.base]]
- ![[bases/active-projects.base]]
- ![[bases/sources.base]]
- ![[bases/maintenance.base]]

These files are generated by `python scripts/wiki.py obsidian export`.
"""
    _write_text(root / "wiki" / "bases" / "README.md", bases_readme)
    artifacts.append("wiki/bases/README.md")

    canvas_path = root / "wiki" / "canvases" / "vipinknowledge-map.canvas"
    _write_json(canvas_path, _canvas(root, catalog))
    artifacts.append(str(canvas_path.relative_to(root)))

    _write_text(
        root / "wiki" / "_templates" / "daily.md",
        """---
title: "{{date}}"
type: daily
status: draft
created: "{{date}}"
updated: "{{date}}"
tags:
  - daily
---

# {{date}}

## Focus

-

## Notes

-

## Links

- [[index]]
""",
    )
    _write_text(
        root / "wiki" / "_templates" / "web-clip.md",
        """---
title: "{{title}}"
type: source
status: captured
created: "{{date}}"
updated: "{{date}}"
tags:
  - source
  - web-clip
source_url: "{{url}}"
---

# {{title}}

## Source

- URL: {{url}}
- Captured: {{date}}

## Notes

{{content}}
""",
    )
    artifacts.extend(["wiki/_templates/daily.md", "wiki/_templates/web-clip.md"])

    tags = tags_report(root)["tags"]
    properties = properties_report(root)["properties"]
    tasks = tasks_report(root, "all")["tasks"]
    dashboard = [
        "---",
        "title: Obsidian Dashboard",
        "type: overview",
        "status: generated",
        "created: 2026-06-01",
        "updated: 2026-06-01",
        "tags:",
        "  - obsidian",
        "  - dashboard",
        "---",
        "",
        "# Obsidian Dashboard",
        "",
        "Generated by `python scripts/wiki.py obsidian export`.",
        "",
        "## Bookmarks",
        "",
        "- [[home]]",
        "- [[index]]",
        "- [[log]]",
        "- [[vipinknowledge-maintenance-system]]",
        "- [[whole-computer-project-map]]",
        "- [[d-drive-project-map]]",
        "- [[local-active-project-roots]]",
        "- [[research-project-workbench]]",
        "- [[canvases/vipinknowledge-map.canvas]]",
        "- [[bases/README]]",
        "",
        "## Top Tags",
        "",
        _markdown_table(["Tag", "Count"], [[item["tag"], str(item["count"])] for item in tags[:30]]),
        "",
        "## Properties",
        "",
        _markdown_table(["Property", "Count", "Types"], [[item["property"], str(item["count"]), ", ".join(f"{k}:{v}" for k, v in item["types"].items())] for item in properties[:40]]),
        "",
        "## Open Tasks",
        "",
        _markdown_table(["File", "Line", "Task"], [[task["file"], str(task["line"]), task["text"]] for task in tasks if task["status"] == "open"][:50]) if tasks else "No Markdown checkbox tasks found.",
    ]
    _write_text(root / "wiki" / "obsidian-dashboard.md", "\n".join(dashboard))
    artifacts.append("wiki/obsidian-dashboard.md")

    return {"artifact_count": len(artifacts), "artifacts": sorted(artifacts)}


def create_daily_note(root: Path, date: str | None = None) -> dict:
    day = date or dt.date.today().isoformat()
    if not DATE_RE.match(day):
        raise SystemExit("--date must use YYYY-MM-DD")
    path = root / "wiki" / "daily" / f"{day}.md"
    if path.exists():
        return {"created": False, "path": str(path.relative_to(root))}
    template = read_text(root / "wiki" / "_templates" / "daily.md")
    if not template:
        template = "# {{date}}\n\n## Focus\n\n- \n"
    text = template.replace("{{date}}", day)
    _write_text(path, text)
    return {"created": True, "path": str(path.relative_to(root))}
