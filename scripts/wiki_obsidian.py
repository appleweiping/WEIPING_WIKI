#!/usr/bin/env python
"""Obsidian-compatible vault helpers for vipin wiki.

This module does not depend on the proprietary Obsidian app. It exports local,
plain-text artifacts that Obsidian can open: .obsidian settings, .base views,
JSON Canvas files, templates, and generated Markdown dashboards.
"""
from __future__ import annotations

import datetime as dt
import json
import random
import re
from collections import Counter, defaultdict
from pathlib import Path

from wiki_core import build_catalog, load_catalog, parse_frontmatter, read_text, resolve_page, search_catalog, wiki_pages


TASK_RE = re.compile(r"^(?P<indent>\s*)[-*]\s+\[(?P<mark>[ xX-])\]\s+(?P<body>.+?)\s*$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
DATETIME_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$", re.MULTILINE)
FOOTNOTE_DEF_RE = re.compile(r"^\[\^([^\]]+)\]:\s*(.*)$", re.MULTILINE)
FOOTNOTE_REF_RE = re.compile(r"\[\^([^\]]+)\]")
URL_RE = re.compile(r"https?://[^\s)\]>\"']+")


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


def _slug(value: str) -> str:
    slug = re.sub(r"[^A-Za-z0-9\u4e00-\u9fff]+", "-", value.strip()).strip("-").lower()
    return slug or "note"


def _page_text(root: Path, page: dict) -> str:
    return read_text(root / page["path"])


def _resolve_required(catalog: dict, page_id: str) -> dict:
    page = resolve_page(catalog, page_id)
    if not page:
        raise SystemExit(f"Page not found or ambiguous: {page_id}")
    return page


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
    page = _resolve_required(catalog, page_id)
    resolved = set(page.get("resolved_links", []))
    unresolved = [link for link in page.get("links", []) if link not in resolved and link not in {p.split("/", 1)[-1] for p in resolved}]
    return {"page": page, "resolved_links": sorted(resolved), "raw_links": page.get("links", []), "unresolved_links": unresolved}


def search_report(root: Path, query: str, top: int = 10) -> dict:
    catalog = _catalog(root)
    return {"query": query, "results": search_catalog(catalog, query, top=top)}


def quick_switcher_report(root: Path, query: str, top: int = 10) -> dict:
    catalog = _catalog(root)
    query_lower = query.lower()
    exactish = []
    for page in catalog.get("pages", []):
        haystacks = [page.get("title", ""), page.get("legacy_id", ""), page.get("id", ""), *page.get("aliases", [])]
        if any(query_lower in str(item).lower() for item in haystacks):
            exactish.append(page)
    ranked = exactish[:top] or search_catalog(catalog, query, top=top)
    return {"query": query, "results": ranked[:top]}


def outline_report(root: Path, page_id: str) -> dict:
    catalog = _catalog(root)
    page = _resolve_required(catalog, page_id)
    headings = [
        {"level": len(match.group(1)), "text": match.group(2).strip()}
        for match in HEADING_RE.finditer(_page_text(root, page))
    ]
    return {"page": page, "headings": headings}


def preview_report(root: Path, page_id: str, max_chars: int = 900) -> dict:
    catalog = _catalog(root)
    page = _resolve_required(catalog, page_id)
    text = _page_text(root, page)
    body = re.sub(r"^---\n.*?\n---\n", "", text, flags=re.DOTALL).strip()
    body = re.sub(r"\s+", " ", body)
    return {"page": page, "preview": body[:max_chars].rstrip()}


def footnotes_report(root: Path, page_id: str | None = None) -> dict:
    catalog = _catalog(root)
    pages = [_resolve_required(catalog, page_id)] if page_id else catalog.get("pages", [])
    results = []
    for page in pages:
        text = _page_text(root, page)
        definitions = [{"id": item.group(1), "text": item.group(2).strip()} for item in FOOTNOTE_DEF_RE.finditer(text)]
        refs = Counter(FOOTNOTE_REF_RE.findall(text))
        if definitions or refs:
            results.append(
                {
                    "page": page,
                    "definitions": definitions,
                    "references": dict(sorted(refs.items())),
                    "missing_definitions": sorted(set(refs) - {item["id"] for item in definitions}),
                    "unused_definitions": sorted({item["id"] for item in definitions} - set(refs)),
                }
            )
    return {"pages": results}


def word_count_report(root: Path, page_id: str | None = None, top: int = 20) -> dict:
    catalog = _catalog(root)
    pages = [_resolve_required(catalog, page_id)] if page_id else catalog.get("pages", [])
    counts = []
    for page in pages:
        text = _page_text(root, page)
        words = len(re.findall(r"\b\w+\b", text))
        chars = len(text)
        counts.append({"id": page["id"], "title": page["title"], "path": page["path"], "words": words, "characters": chars})
    return {"pages": sorted(counts, key=lambda item: -item["words"])[:top if not page_id else 1]}


def random_note_report(root: Path, seed: str | None = None) -> dict:
    catalog = _catalog(root)
    pages = catalog.get("pages", [])
    if not pages:
        return {"page": None}
    rng = random.Random(seed)
    page = rng.choice(pages)
    return {"seed": seed, "page": page}


def files_report(root: Path, max_items: int = 100) -> dict:
    catalog = _catalog(root)
    folders: Counter[str] = Counter()
    recent = []
    for page in catalog.get("pages", []):
        rel = page.get("path", "")
        folders[str(Path(rel).parent).replace("\\", "/")] += 1
        recent.append({"path": rel, "title": page.get("title", ""), "updated": page.get("updated", "")})
    return {
        "folders": [{"folder": folder, "count": count} for folder, count in folders.most_common(max_items)],
        "recent": sorted(recent, key=lambda item: item.get("updated") or "", reverse=True)[:max_items],
    }


def external_links_report(root: Path, page_id: str | None = None, top: int = 100) -> dict:
    catalog = _catalog(root)
    pages = [_resolve_required(catalog, page_id)] if page_id else catalog.get("pages", [])
    rows = []
    for page in pages:
        urls = sorted(set(URL_RE.findall(_page_text(root, page))))
        if urls:
            rows.append({"page": page, "urls": urls[:top]})
    return {"pages": rows[:top if not page_id else 1]}


def commands_report(root: Path) -> dict:
    return {
        "commands": [
            {"command": "python scripts/wiki.py search <query>", "obsidian": "Search", "purpose": "Find files in the vault."},
            {"command": "python scripts/wiki.py context L1 --query <query>", "obsidian": "Quick switcher / context", "purpose": "Open a compact context pack around a topic."},
            {"command": "python scripts/wiki.py obsidian quick <query>", "obsidian": "Quick switcher", "purpose": "Find likely pages by title, id, alias, or body."},
            {"command": "python scripts/wiki.py obsidian backlinks <page>", "obsidian": "Backlinks", "purpose": "Show linked backlinks and unlinked mentions."},
            {"command": "python scripts/wiki.py obsidian outgoing <page>", "obsidian": "Outgoing links", "purpose": "Show resolved and unresolved outgoing links."},
            {"command": "python scripts/wiki.py obsidian outline <page>", "obsidian": "Outline", "purpose": "Show heading tree for a page."},
            {"command": "python scripts/wiki.py obsidian preview <page>", "obsidian": "Page preview", "purpose": "Show a short hover-style preview."},
            {"command": "python scripts/wiki.py obsidian tags", "obsidian": "Tags view", "purpose": "List tags and tagged pages."},
            {"command": "python scripts/wiki.py obsidian properties", "obsidian": "Properties view", "purpose": "Summarize frontmatter properties and inferred types."},
            {"command": "python scripts/wiki.py obsidian tasks", "obsidian": "Tasks", "purpose": "Scan Markdown checkbox tasks."},
            {"command": "python scripts/wiki.py obsidian daily", "obsidian": "Daily notes", "purpose": "Create a dated daily note from the template."},
            {"command": "python scripts/wiki.py obsidian unique --title <title>", "obsidian": "Unique note creator", "purpose": "Create a timestamped inbox note."},
            {"command": "python scripts/wiki.py obsidian random", "obsidian": "Random note", "purpose": "Pick a random wiki page."},
            {"command": "python scripts/wiki.py obsidian word-count", "obsidian": "Word count", "purpose": "Show word and character counts."},
            {"command": "python scripts/wiki.py obsidian footnotes", "obsidian": "Footnotes view", "purpose": "Audit footnote definitions and references."},
            {"command": "python scripts/wiki.py obsidian slides <page>", "obsidian": "Slides", "purpose": "Export a note-derived Markdown slide deck."},
            {"command": "python scripts/wiki.py obsidian export", "obsidian": "Bases / Canvas / Bookmarks / Workspaces", "purpose": "Regenerate Obsidian vault artifacts."},
        ]
    }


def format_report(root: Path, page_id: str | None = None, top: int = 100) -> dict:
    catalog = _catalog(root)
    pages = [_resolve_required(catalog, page_id)] if page_id else catalog.get("pages", [])
    rows = []
    for page in pages:
        text = _page_text(root, page)
        findings = []
        if "<br" in text.lower():
            findings.append("HTML line breaks; convert to Markdown hard breaks only if needed.")
        if re.search(r"\[[^\]]+\]\([A-Za-z]:\\", text):
            findings.append("Absolute Windows file link; prefer repo-relative Markdown or wiki link when public-safe.")
        if re.search(r"\[\[[^\]]*#[^\]|]+\|?[^\]]*\]\]", text):
            findings.append("Heading wikilink present; verify target heading survives future renames.")
        if findings:
            rows.append({"page": page, "findings": findings})
    return {"pages": rows[:top if not page_id else 1]}


def unique_note(root: Path, title: str | None = None) -> dict:
    now = dt.datetime.now().strftime("%Y%m%d%H%M%S")
    note_title = title or f"Unique note {now}"
    path = root / "wiki" / "inbox" / f"{now}-{_slug(note_title)}.md"
    content = f"""---
title: {note_title}
type: note
status: draft
created: {dt.date.today().isoformat()}
updated: {dt.date.today().isoformat()}
tags:
  - inbox
---

# {note_title}

"""
    _write_text(path, content)
    return {"created": True, "path": str(path.relative_to(root))}


def slides_export(root: Path, page_id: str) -> dict:
    catalog = _catalog(root)
    page = _resolve_required(catalog, page_id)
    text = _page_text(root, page)
    title = page.get("title") or page.get("legacy_id")
    body = re.sub(r"^---\n.*?\n---\n", "", text, flags=re.DOTALL).strip()
    sections = []
    current = [f"# {title}"]
    for line in body.splitlines():
        if line.startswith("## "):
            if current:
                sections.append("\n".join(current).strip())
            current = [line.replace("## ", "# ", 1)]
        elif not line.startswith("# "):
            current.append(line)
    if current:
        sections.append("\n".join(current).strip())
    deck = f"""---
title: {title} slides
type: presentation
status: generated
created: {dt.date.today().isoformat()}
updated: {dt.date.today().isoformat()}
tags:
  - slides
source_pages:
  - [[{page.get("legacy_id")}]]
---

""" + "\n\n---\n\n".join(section for section in sections if section)
    out = root / "wiki" / "slides" / f"{_slug(page.get('legacy_id') or title)}.slides.md"
    _write_text(out, deck)
    return {"created": True, "path": str(out.relative_to(root))}


def feature_report(root: Path) -> dict:
    return {
        "source_note": "Obsidian core app is proprietary; this report maps official Obsidian concepts to local plain-text equivalents.",
        "features": [
            {"obsidian": "Audio recorder", "vipinknowledge": "raw/attachments accepts media evidence; recording UI is hardware/app-specific", "status": "not-applicable"},
            {"obsidian": "Backlinks", "vipinknowledge": "catalog backlinks plus wiki.py obsidian backlinks", "status": "implemented"},
            {"obsidian": "Bases", "vipinknowledge": "generated .base files over Markdown properties", "status": "implemented"},
            {"obsidian": "Bookmarks", "vipinknowledge": "generated bookmarks dashboard for high-value pages and searches", "status": "implemented"},
            {"obsidian": "Canvas", "vipinknowledge": "JSON Canvas map under wiki/canvases", "status": "implemented"},
            {"obsidian": "Command palette", "vipinknowledge": "python scripts/wiki.py obsidian commands", "status": "implemented"},
            {"obsidian": "Daily notes", "vipinknowledge": "daily template and daily note creator", "status": "implemented"},
            {"obsidian": "File explorer", "vipinknowledge": "python scripts/wiki.py obsidian files", "status": "implemented"},
            {"obsidian": "File recovery", "vipinknowledge": "Git history plus pre-push safety; snapshots are intentionally commit-backed", "status": "already-covered"},
            {"obsidian": "Footnotes view", "vipinknowledge": "python scripts/wiki.py obsidian footnotes", "status": "implemented"},
            {"obsidian": "Format converter", "vipinknowledge": "python scripts/wiki.py obsidian format-report", "status": "adapted"},
            {"obsidian": "Graph view", "vipinknowledge": "existing knowledge graph plus JSON Canvas export", "status": "implemented"},
            {"obsidian": "Note composer", "vipinknowledge": "merge/split remains safety-gated; agents edit with validation instead of blind note surgery", "status": "safety-gated"},
            {"obsidian": "Outgoing links", "vipinknowledge": "python scripts/wiki.py obsidian outgoing", "status": "implemented"},
            {"obsidian": "Outline", "vipinknowledge": "python scripts/wiki.py obsidian outline", "status": "implemented"},
            {"obsidian": "Page preview", "vipinknowledge": "python scripts/wiki.py obsidian preview", "status": "implemented"},
            {"obsidian": "Properties view", "vipinknowledge": "frontmatter property schema report", "status": "implemented"},
            {"obsidian": "Publish", "vipinknowledge": "Quartz site publishing layer", "status": "already-covered"},
            {"obsidian": "Quick switcher", "vipinknowledge": "python scripts/wiki.py obsidian quick", "status": "implemented"},
            {"obsidian": "Random note", "vipinknowledge": "python scripts/wiki.py obsidian random", "status": "implemented"},
            {"obsidian": "Search", "vipinknowledge": "python scripts/wiki.py search and obsidian search", "status": "implemented"},
            {"obsidian": "Slash commands", "vipinknowledge": "same command palette surfaced through obsidian commands", "status": "implemented"},
            {"obsidian": "Slides", "vipinknowledge": "python scripts/wiki.py obsidian slides", "status": "implemented"},
            {"obsidian": "Sync", "vipinknowledge": "Git commit/push policy and GitHub remote", "status": "already-covered"},
            {"obsidian": "Tags view", "vipinknowledge": "tag count and page index", "status": "implemented"},
            {"obsidian": "Templates", "vipinknowledge": "wiki/_templates plus creation commands", "status": "implemented"},
            {"obsidian": "Unique note creator", "vipinknowledge": "python scripts/wiki.py obsidian unique", "status": "implemented"},
            {"obsidian": "Web viewer", "vipinknowledge": "external-link report; browsing remains browser/app-level", "status": "adapted"},
            {"obsidian": "Word count", "vipinknowledge": "python scripts/wiki.py obsidian word-count", "status": "implemented"},
            {"obsidian": "Workspaces", "vipinknowledge": "generated workspace config plus dashboard/canvas/bases", "status": "implemented"},
            {"obsidian": "Web Clipper", "vipinknowledge": "web-clip template plus existing ingest/url-to-markdown skill route", "status": "adapted"},
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
    _write_json(
        obsidian_dir / "bookmarks.json",
        {
            "items": [
                {"type": "file", "path": "wiki/home.md", "title": "Home"},
                {"type": "file", "path": "wiki/index.md", "title": "Index"},
                {"type": "file", "path": "wiki/obsidian-dashboard.md", "title": "Obsidian Dashboard"},
                {"type": "file", "path": "wiki/canvases/vipinknowledge-map.canvas", "title": "VipinKnowledge Map"},
                {"type": "search", "query": "tag:#maintenance", "title": "Maintenance"},
            ]
        },
    )
    _write_json(
        obsidian_dir / "workspaces.json",
        {
            "workspaces": {
                "VipinKnowledge Maintenance": {
                    "main": {"type": "split", "children": []},
                    "left": {"type": "split", "children": []},
                    "right": {"type": "split", "children": []},
                    "active": "wiki/obsidian-dashboard.md",
                }
            },
            "active": "VipinKnowledge Maintenance",
        },
    )
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

    commands = commands_report(root)["commands"]
    commands_page = [
        "---",
        "title: Obsidian-Compatible Commands",
        "type: overview",
        "status: generated",
        "created: 2026-06-01",
        "updated: 2026-06-01",
        "tags:",
        "  - obsidian",
        "  - commands",
        "---",
        "",
        "# Obsidian-Compatible Commands",
        "",
        "Generated by `python scripts/wiki.py obsidian export`.",
        "",
        _markdown_table(["Obsidian feature", "Command", "Purpose"], [[item["obsidian"], f"`{item['command']}`", item["purpose"]] for item in commands]),
    ]
    _write_text(root / "wiki" / "commands" / "obsidian-compatible-commands.md", "\n".join(commands_page))
    artifacts.append("wiki/commands/obsidian-compatible-commands.md")

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

    slides_readme = """---
title: Slides
type: overview
status: generated
created: 2026-06-01
updated: 2026-06-01
tags:
  - obsidian
  - slides
---

# Slides

Generated slide decks from wiki pages live here. Create one with:

```powershell
python scripts/wiki.py obsidian slides <page>
```
"""
    _write_text(root / "wiki" / "slides" / "README.md", slides_readme)
    artifacts.append("wiki/slides/README.md")

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
        "- [[commands/obsidian-compatible-commands]]",
        "- [[slides/README]]",
        "",
        "## Core Plugin Coverage",
        "",
        _markdown_table(["Obsidian", "Local equivalent", "Status"], [[item["obsidian"], item["vipinknowledge"], item["status"]] for item in feature_report(root)["features"]]),
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
