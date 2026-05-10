#!/usr/bin/env python
from __future__ import annotations

import json
import math
import re
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


WIKI_EXCLUDE_DIRS = {"_templates"}
WIKI_EXCLUDE_STEMS = {"knowledge-graph"}
LINK_RE = re.compile(r"\[\[([^\]]+)\]\]")
FRONTMATTER_RE = re.compile(r"^---\r?\n(.*?)\r?\n---\r?\n", re.DOTALL)
TOKEN_RE = re.compile(r"[A-Za-z0-9_+\-/]+")
LINT_EXCLUDE_NAMES = {
    "home",
    "overview",
    "index",
    "log",
    "queries-home",
    "synthesis-home",
    "timelines-home",
    "topics-home",
    "comparisons-home",
    "knowledge-graph",
    "README",
}


@dataclass
class PageRecord:
    id: str
    legacy_id: str
    title: str
    type: str
    path: str
    tags: list[str]
    headings: list[str]
    links: list[str]
    resolved_links: list[str]
    backlinks: list[str]
    aliases: list[str]
    has_counterpoints: bool
    word_count: int
    source_pages: list[str]
    source_files: list[str]
    body_preview: str
    body_text: str
    search_text: str


def resolve_root(root: str | Path = ".") -> Path:
    return Path(root).resolve()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def wiki_pages(root: Path) -> Iterable[Path]:
    wiki_dir = root / "wiki"
    for path in wiki_dir.rglob("*.md"):
        rel_parts = path.relative_to(wiki_dir).parts
        if any(part in WIKI_EXCLUDE_DIRS for part in rel_parts):
            continue
        if path.stem in WIKI_EXCLUDE_STEMS:
            continue
        yield path


def parse_frontmatter(text: str) -> dict:
    match = FRONTMATTER_RE.match(text.lstrip("\ufeff"))
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
            data[current_key].append(line.lstrip()[2:].strip().strip('"').strip("'"))
            continue
        if ":" in line:
            key, value = line.split(":", 1)
            current_key = key.strip()
            data[current_key] = value.strip().strip('"').strip("'")
    return data


def body_without_frontmatter(text: str) -> str:
    clean = text.lstrip("\ufeff")
    match = FRONTMATTER_RE.match(clean)
    return clean[match.end() :] if match else clean


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


def canonical_page_id(root: Path, path: Path) -> str:
    rel = path.relative_to(root / "wiki").with_suffix("")
    return rel.as_posix()


def legacy_page_id(path: Path) -> str:
    return path.stem


def _as_list(value: object) -> list[str]:
    if isinstance(value, list):
        return [str(item) for item in value if str(item).strip()]
    if value:
        return [str(value)]
    return []


def _compact_body(body: str) -> str:
    return re.sub(r"\s+", " ", body).strip()


def parse_page(root: Path, path: Path) -> PageRecord:
    text = read_text(path).lstrip("\ufeff")
    frontmatter = parse_frontmatter(text)
    body = body_without_frontmatter(text)
    compact_body = _compact_body(body)
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

    tags = _as_list(frontmatter.get("tags", []))
    aliases = sorted(set(_as_list(frontmatter.get("aliases", [])) + [legacy_page_id(path)]))
    title = str(frontmatter.get("title", headings[0] if headings else legacy_page_id(path)))
    page_type = str(frontmatter.get("type", infer_type_from_path(path)))
    source_pages = _as_list(frontmatter.get("source_pages", []))
    source_files = _as_list(frontmatter.get("source_files", []))
    page_id = canonical_page_id(root, path)
    legacy_id = legacy_page_id(path)
    search_parts = [
        page_id,
        legacy_id,
        title,
        page_type,
        " ".join(tags),
        " ".join(aliases),
        " ".join(headings),
        " ".join(links),
        compact_body,
    ]

    return PageRecord(
        id=page_id,
        legacy_id=legacy_id,
        title=title,
        type=page_type,
        path=path.relative_to(root).as_posix(),
        tags=tags,
        headings=headings,
        links=sorted(set(links)),
        resolved_links=[],
        backlinks=[],
        aliases=aliases,
        has_counterpoints=("## Counterpoints And Gaps" in body or "## Counterpoints and Gaps" in body),
        word_count=len(re.findall(r"\b\w+\b", body)),
        source_pages=source_pages,
        source_files=source_files,
        body_preview=compact_body[:280],
        body_text=compact_body,
        search_text=_compact_body(" ".join(search_parts)),
    )


def _build_resolver(records: list[PageRecord]) -> tuple[dict[str, str], set[str]]:
    candidates: dict[str, set[str]] = defaultdict(set)
    for page in records:
        candidates[page.id].add(page.id)
        candidates[page.legacy_id].add(page.id)
        for alias in page.aliases:
            candidates[alias].add(page.id)
    resolver = {key: next(iter(values)) for key, values in candidates.items() if len(values) == 1}
    ambiguous = {key for key, values in candidates.items() if len(values) > 1}
    return resolver, ambiguous


def build_catalog(root: Path) -> dict:
    records = [parse_page(root, path) for path in sorted(wiki_pages(root))]
    resolver, _ambiguous = _build_resolver(records)
    backlinks: dict[str, list[str]] = {page.id: [] for page in records}

    for page in records:
        resolved = []
        for link in page.links:
            target = resolver.get(link)
            if target:
                resolved.append(target)
                backlinks[target].append(page.id)
        page.resolved_links = sorted(set(resolved))

    for page in records:
        page.backlinks = sorted(set(backlinks.get(page.id, [])))

    return {
        "meta": {
            "root": str(root),
            "page_count": len(records),
            "id_scheme": "wiki-relative-path-without-extension",
        },
        "pages": [asdict(page) for page in records],
    }


def load_catalog(root: Path) -> dict:
    path = root / "wiki" / "catalog.json"
    if not path.exists():
        raise SystemExit("wiki/catalog.json not found. Run scripts/wiki-catalog.py first.")
    return json.loads(path.read_text(encoding="utf-8"))


def catalog_freshness(root: Path) -> str:
    catalog_path = root / "wiki" / "catalog.json"
    if not catalog_path.exists():
        return "missing"
    pages = list(wiki_pages(root))
    if not pages:
        return "fresh"
    latest_page_time = max(path.stat().st_mtime for path in pages)
    return "stale" if latest_page_time > catalog_path.stat().st_mtime else "fresh"


def tokenize(text: str) -> list[str]:
    return [token.lower() for token in TOKEN_RE.findall(text)]


def _score_page(page: dict, query_tokens: list[str], doc_freq: Counter, total_docs: int) -> float:
    fields = {
        "title": tokenize(page.get("title", "")),
        "headings": tokenize(" ".join(page.get("headings", []))),
        "tags": tokenize(" ".join(page.get("tags", []))),
        "type": tokenize(page.get("type", "")),
        "ids": tokenize(" ".join([page.get("id", ""), page.get("legacy_id", ""), " ".join(page.get("aliases", []))])),
        "links": tokenize(" ".join(page.get("links", []) + page.get("resolved_links", []))),
        "body": tokenize(page.get("body_text", page.get("body_preview", ""))),
    }
    combined = []
    for values in fields.values():
        combined.extend(values)
    freqs = Counter(combined)

    score = 0.0
    for token in query_tokens:
        tf = freqs[token]
        if tf == 0:
            continue
        idf = math.log((1 + total_docs) / (1 + doc_freq[token])) + 1
        boost = 1.0
        if token in fields["title"]:
            boost += 4.0
        if token in fields["ids"]:
            boost += 3.0
        if token in fields["headings"]:
            boost += 1.8
        if token in fields["tags"]:
            boost += 1.4
        if token in fields["type"]:
            boost += 0.8
        if token in fields["links"]:
            boost += 0.6
        score += tf * idf * boost

    joined_query = " ".join(query_tokens)
    if joined_query and joined_query in page.get("search_text", "").lower():
        score += 5.0
    return score


def search_catalog(catalog: dict, query: str, top: int = 8) -> list[dict]:
    pages = catalog.get("pages", [])
    query_tokens = tokenize(query)
    if not query_tokens:
        return []

    doc_freq: Counter[str] = Counter()
    for page in pages:
        tokens = set(tokenize(page.get("search_text", page.get("body_preview", ""))))
        for token in tokens:
            doc_freq[token] += 1

    results = []
    for page in pages:
        score = _score_page(page, query_tokens, doc_freq, len(pages))
        if score <= 0:
            continue
        results.append(
            {
                "score": round(score, 4),
                "id": page["id"],
                "legacy_id": page.get("legacy_id", ""),
                "title": page["title"],
                "type": page["type"],
                "path": page["path"],
                "preview": page["body_preview"],
            }
        )

    results.sort(key=lambda item: (-item["score"], item["title"].lower(), item["id"]))
    return results[:top]


def resolve_page(catalog: dict, page_id: str) -> dict | None:
    pages = catalog.get("pages", [])
    by_id = {page["id"]: page for page in pages}
    if page_id in by_id:
        return by_id[page_id]
    matches = [
        page
        for page in pages
        if page.get("legacy_id") == page_id or page_id in page.get("aliases", [])
    ]
    return matches[0] if len(matches) == 1 else None


def recent_log_headings(path: Path, limit: int = 5) -> list[str]:
    lines = [line.strip() for line in read_text(path).splitlines() if line.startswith("## ")]
    return lines[-limit:]


def _markdown_count(path: Path) -> int:
    if not path.exists():
        return 0
    return sum(1 for _ in path.rglob("*.md"))


def build_status(root: Path) -> dict:
    wiki = root / "wiki"
    raw = root / "raw"
    private = root / "wiki-private"
    sections = {
        "source": wiki / "sources",
        "concept": wiki / "concepts",
        "entity": wiki / "entities",
        "analysis": wiki / "analyses",
        "topic": wiki / "topics",
        "comparison": wiki / "comparisons",
        "query": wiki / "queries",
        "synthesis": wiki / "synthesis",
    }
    private_images = raw / "private-images"
    private_videos = raw / "private-videos"
    return {
        "root": str(root),
        "public_markdown": _markdown_count(wiki),
        "private_markdown": _markdown_count(private),
        "section_counts": {key: _markdown_count(path) for key, path in sections.items()},
        "private_images": len([p for p in private_images.glob("*") if p.is_file() and p.name.lower() != "readme.md"])
        if private_images.exists()
        else 0,
        "private_videos": len([p for p in private_videos.glob("*") if p.is_file() and p.name.lower() != "readme.md"])
        if private_videos.exists()
        else 0,
        "reader_context_present": (root / "reader-context.md").exists(),
        "contributions_present": (root / "CONTRIBUTIONS.md").exists(),
        "catalog_status": catalog_freshness(root),
        "recent_public_log": recent_log_headings(wiki / "log.md", 3),
        "recent_private_log": recent_log_headings(private / "log.md", 3),
    }


def lint_wiki(root: Path) -> dict:
    pages = [parse_page(root, path) for path in sorted(wiki_pages(root))]
    resolver, ambiguous = _build_resolver(pages)
    inbound: Counter[str] = Counter()
    broken_links: set[str] = set()
    ambiguous_links: set[str] = set()
    private_leaks: set[str] = set()
    missing_counterpoints: set[str] = set()
    missing_attribution: set[str] = set()

    for page in pages:
        text = read_text(root / page.path)
        if "raw/private-" in text or "wiki-private/" in text:
            private_leaks.add(page.path)
        if page.type in {"concept", "topic", "comparison", "analysis", "synthesis"}:
            if page.legacy_id not in LINT_EXCLUDE_NAMES and not page.has_counterpoints:
                missing_counterpoints.add(page.path)
        if page.type in {"concept", "topic", "comparison", "analysis", "query", "synthesis"}:
            has_sources = (
                re.search(r"(?im)^source_pages:\s*$", text)
                or re.search(r"(?im)^source_files:\s*$", text)
                or re.search(r"(?im)^source_pages:\s+\S", text)
                or re.search(r"(?im)^source_files:\s+\S", text)
                or re.search(r"(?im)^##\s+Sources\s*$", text)
                or re.search(r"\[\[20\d{2}-\d{2}-\d{2}-", text)
            )
            if page.legacy_id not in LINT_EXCLUDE_NAMES and not has_sources:
                missing_attribution.add(page.path)

        for link in page.links:
            if link in WIKI_EXCLUDE_STEMS:
                continue
            if link in ambiguous:
                ambiguous_links.add(f"{page.path} -> [[{link}]]")
                continue
            target = resolver.get(link)
            if target:
                inbound[target] += 1
            else:
                broken_links.add(f"{page.path} -> [[{link}]]")

    index_text = read_text(root / "wiki" / "index.md")
    index_targets = {
        match.split("|", 1)[0].strip()
        for match in LINK_RE.findall(index_text)
        if match.strip()
    }
    indexed_ids = {resolver.get(target, target) for target in index_targets if target not in ambiguous}

    orphan_pages = sorted(
        page.path
        for page in pages
        if page.legacy_id not in LINT_EXCLUDE_NAMES and inbound[page.id] == 0
    )
    missing_from_index = sorted(
        page.path
        for page in pages
        if page.legacy_id not in {"index", "knowledge-graph", "README"} and page.id not in indexed_ids
    )

    return {
        "broken_links": sorted(broken_links),
        "ambiguous_links": sorted(ambiguous_links),
        "orphan_pages": orphan_pages,
        "missing_from_index": missing_from_index,
        "missing_counterpoints": sorted(missing_counterpoints),
        "missing_attribution": sorted(missing_attribution),
        "private_leaks": sorted(private_leaks),
        "catalog_status": catalog_freshness(root),
    }
