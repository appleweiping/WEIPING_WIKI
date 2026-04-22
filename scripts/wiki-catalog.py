#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


WIKI_EXCLUDE_DIRS = {"_templates"}
WIKI_EXCLUDE_STEMS = {"knowledge-graph"}
LINK_RE = re.compile(r"\[\[([^\]]+)\]\]")
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


@dataclass
class PageRecord:
    id: str
    title: str
    type: str
    path: str
    tags: list[str]
    headings: list[str]
    links: list[str]
    has_counterpoints: bool
    word_count: int
    source_pages: list[str]
    source_files: list[str]
    body_preview: str


def parse_simple_frontmatter(text: str) -> dict:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}
    raw = match.group(1)
    data: dict[str, object] = {}
    current_key: str | None = None
    for line in raw.splitlines():
        if not line.strip():
            continue
        if re.match(r"^[A-Za-z0-9_-]+:\s*$", line):
            current_key = line.split(":", 1)[0].strip()
            data[current_key] = []
            continue
        if line.lstrip().startswith("- ") and current_key and isinstance(data.get(current_key), list):
            data[current_key].append(line.lstrip()[2:].strip())
            continue
        if ":" in line:
            key, value = line.split(":", 1)
            current_key = key.strip()
            data[current_key] = value.strip()
    return data


def body_without_frontmatter(text: str) -> str:
    match = FRONTMATTER_RE.match(text)
    return text[match.end():] if match else text


def wiki_pages(wiki_root: Path) -> Iterable[Path]:
    wiki_dir = wiki_root / "wiki"
    for path in wiki_dir.rglob("*.md"):
        if any(part in WIKI_EXCLUDE_DIRS for part in path.parts):
            continue
        if path.stem in WIKI_EXCLUDE_STEMS:
            continue
        yield path


def parse_page(wiki_root: Path, path: Path) -> PageRecord:
    text = path.read_text(encoding="utf-8", errors="ignore").lstrip("\ufeff")
    frontmatter = parse_simple_frontmatter(text)
    body = body_without_frontmatter(text)
    rel_path = path.relative_to(wiki_root).as_posix()
    page_id = path.stem
    headings = [
        re.sub(r"^#+\s*", "", line).strip()
        for line in body.splitlines()
        if re.match(r"^#{1,6}\s+", line)
    ]
    links = []
    for match in LINK_RE.findall(body):
        target = match.split("|", 1)[0].strip()
        if target:
            links.append(target)
    preview = " ".join(line.strip() for line in body.splitlines() if line.strip())
    preview = preview[:280]
    source_pages = frontmatter.get("source_pages", [])
    source_files = frontmatter.get("source_files", [])
    if not isinstance(source_pages, list):
        source_pages = [str(source_pages)] if source_pages else []
    if not isinstance(source_files, list):
        source_files = [str(source_files)] if source_files else []
    tags = frontmatter.get("tags", [])
    if not isinstance(tags, list):
        tags = [str(tags)] if tags else []

    return PageRecord(
        id=page_id,
        title=str(frontmatter.get("title", headings[0] if headings else page_id)),
        type=str(frontmatter.get("type", infer_type_from_path(path))),
        path=rel_path,
        tags=[str(tag) for tag in tags],
        headings=headings,
        links=links,
        has_counterpoints=("## Counterpoints And Gaps" in body or "## Counterpoints and Gaps" in body),
        word_count=len(re.findall(r"\b\w+\b", body)),
        source_pages=[str(x) for x in source_pages],
        source_files=[str(x) for x in source_files],
        body_preview=preview,
    )


def infer_type_from_path(path: Path) -> str:
    parent = path.parent.name
    mapping = {
        "entities": "entity",
        "concepts": "concept",
        "topics": "topic",
        "sources": "source",
        "analyses": "analysis",
        "comparisons": "comparison",
        "queries": "query",
        "sessions": "synthesis",
        "synthesis": "synthesis",
        "timelines": "timeline",
    }
    return mapping.get(parent, "overview")


def build_catalog(root: Path) -> dict:
    pages = [parse_page(root, path) for path in sorted(wiki_pages(root))]
    backlinks: dict[str, list[str]] = {page.id: [] for page in pages}
    by_id = {page.id for page in pages}
    for page in pages:
        for link in page.links:
            if link in by_id:
                backlinks[link].append(page.id)

    records = []
    for page in pages:
        records.append(
            {
                "id": page.id,
                "title": page.title,
                "type": page.type,
                "path": page.path,
                "tags": page.tags,
                "headings": page.headings,
                "links": sorted(set(page.links)),
                "backlinks": sorted(set(backlinks.get(page.id, []))),
                "has_counterpoints": page.has_counterpoints,
                "word_count": page.word_count,
                "source_pages": page.source_pages,
                "source_files": page.source_files,
                "body_preview": page.body_preview,
            }
        )

    return {
        "meta": {
            "root": str(root),
            "page_count": len(records),
        },
        "pages": records,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    parser.add_argument("--output", default="wiki/catalog.json")
    parser.add_argument("--stdout", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
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
