#!/usr/bin/env python
from __future__ import annotations

import datetime as dt
import hashlib
import json
import math
import os
import re
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass, field
from pathlib import Path, PurePosixPath
from typing import Iterable
from urllib.parse import urlsplit, urlunsplit


WIKI_EXCLUDE_DIRS = {"_templates"}
WIKI_EXCLUDE_STEMS = {"knowledge-graph"}
CATALOG_SCHEMA_VERSION = 2
LINK_RE = re.compile(r"\[\[([^\]]+)\]\]")
# Typed-relation vocabulary from .wiki-schema.md (plus supersession). Matches a
# relation word immediately preceding a wiki link, e.g. "supersedes [[old-page]]".
RELATION_WORDS = (
    "supersedes", "superseded-by", "supports", "contradicts",
    "compares", "extends", "depends-on", "derived-from",
)
RELATION_RE = re.compile(
    r"(?i)\b(" + "|".join(w.replace("-", "[ -]?") for w in RELATION_WORDS) + r")\b[\s:>\-]*\[\[([^\]]+)\]\]"
)
FRONTMATTER_RE = re.compile(r"^---\r?\n(.*?)\r?\n---\r?\n", re.DOTALL)
TOKEN_RE = re.compile(r"[\w+\-/]+", re.UNICODE)
CJK_RE = re.compile(r"[\u3400-\u9fff]")
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
    content_sha256: str
    body_preview: str
    body_text: str
    search_text: str
    typed_links: list = field(default_factory=list)


def resolve_root(root: str | Path = ".") -> Path:
    return Path(root).resolve()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore") if path.exists() else ""


def _read_text_with_digest(path: Path) -> tuple[str, str]:
    data = path.read_bytes()
    return data.decode("utf-8", errors="ignore"), hashlib.sha256(data).hexdigest()


def resolve_public_wiki_path(root: Path, relative_path: object) -> Path | None:
    """Resolve one catalog path without allowing reads outside public ``wiki/``."""
    if not isinstance(relative_path, str) or not relative_path.strip():
        return None
    try:
        wiki_root = (root / "wiki").resolve()
        candidate = (root / relative_path).resolve()
        candidate.relative_to(wiki_root)
    except (OSError, RuntimeError, ValueError):
        return None
    if candidate.suffix.casefold() != ".md" or not candidate.is_file():
        return None
    return candidate


def wiki_pages(root: Path) -> Iterable[Path]:
    """Yield canonical public pages without traversing symlinks or junctions.

    A catalog build reads full page bodies, so merely validating catalog paths at
    retrieval time is too late: a Markdown symlink could otherwise copy a file
    outside ``wiki/`` into the generated catalog.  A non-following ``scandir``
    walk prunes symlinks/junctions before recursion, and every file remains under
    the already-resolved physical wiki root before it can be read.
    """
    root = Path(root).resolve()
    wiki_dir = root / "wiki"
    try:
        wiki_root = wiki_dir.resolve(strict=True)
    except (OSError, RuntimeError):
        return

    is_junction = getattr(os.path, "isjunction", lambda _path: False)
    stack = [wiki_root]
    seen: set[Path] = set()
    while stack:
        current = stack.pop()
        try:
            entries = sorted(os.scandir(current), key=lambda entry: entry.name.casefold())
        except OSError:
            continue
        directories: list[Path] = []
        for entry in entries:
            physical = Path(entry.path)
            try:
                if entry.is_symlink() or is_junction(entry.path):
                    continue
                if entry.is_dir(follow_symlinks=False):
                    if entry.name not in WIKI_EXCLUDE_DIRS:
                        physical.relative_to(wiki_root)
                        directories.append(physical)
                    continue
                if not entry.is_file(follow_symlinks=False):
                    continue
                if physical.suffix.casefold() != ".md" or physical.stem in WIKI_EXCLUDE_STEMS:
                    continue
                relative = physical.relative_to(wiki_root)
            except (OSError, RuntimeError, ValueError):
                continue
            if physical in seen or any(part in WIKI_EXCLUDE_DIRS for part in relative.parts):
                continue
            seen.add(physical)
            # Preserve the repository-relative logical path even when the repo
            # itself is reached through a compatibility junction.
            yield wiki_dir / relative
        stack.extend(reversed(directories))


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


def parse_page(
    root: Path,
    path: Path,
    *,
    text: str | None = None,
    content_sha256: str | None = None,
) -> PageRecord:
    if text is None:
        text, content_sha256 = _read_text_with_digest(path)
    elif content_sha256 is None:
        content_sha256 = hashlib.sha256(text.encode("utf-8")).hexdigest()
    text = text.lstrip("\ufeff")
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
    typed_links = []
    for rel_match in RELATION_RE.finditer(body):
        relation = re.sub(r"[ ]+", "-", rel_match.group(1).lower())
        rel_target = rel_match.group(2).split("|", 1)[0].strip()
        if rel_target:
            typed_links.append({"relation": relation, "target": rel_target})

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
        content_sha256=content_sha256,
        body_preview=compact_body[:280],
        body_text=compact_body,
        search_text=_compact_body(" ".join(search_parts)),
        typed_links=typed_links,
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
    root = Path(root).resolve()
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

    pages_out = []
    for page in records:
        page_dict = asdict(page)
        # Keep the catalog lean: only emit typed_links for pages that use them.
        if not page_dict.get("typed_links"):
            page_dict.pop("typed_links", None)
        pages_out.append(page_dict)

    corpus_sha256 = _catalog_corpus_sha256(
        (page["path"], page["content_sha256"]) for page in pages_out
    )
    return {
        "meta": {
            "root": str(root),
            "page_count": len(records),
            "id_scheme": "wiki-relative-path-without-extension",
            "schema_version": CATALOG_SCHEMA_VERSION,
            "corpus_sha256": corpus_sha256,
            "catalog_sha256": _catalog_pages_sha256(pages_out),
        },
        "pages": pages_out,
    }


def _catalog_corpus_sha256(items: Iterable[tuple[str, str]]) -> str:
    digest = hashlib.sha256()
    for path, content_sha256 in sorted(items):
        digest.update(path.encode("utf-8"))
        digest.update(b"\0")
        digest.update(content_sha256.encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def _catalog_pages_sha256(pages: list[dict]) -> str:
    payload = json.dumps(
        pages,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def load_catalog(root: Path) -> dict:
    path = root / "wiki" / "catalog.json"
    if not path.exists():
        raise SystemExit("wiki/catalog.json not found. Run scripts/wiki-catalog.py first.")
    return json.loads(path.read_text(encoding="utf-8"))


def validate_catalog(root: Path, catalog: object) -> tuple[bool, str]:
    """Validate a generated catalog against the live public corpus.

    The catalog is a cache, not an authority.  Structural validation blocks
    path/id collisions and malformed records; per-page digests catch content
    changes even when mtimes are forged; the catalog digest catches accidental
    or hostile metadata edits (including spoofed provenance).
    """
    root = Path(root).resolve()
    if not isinstance(catalog, dict):
        return False, "invalid"
    meta = catalog.get("meta")
    pages = catalog.get("pages")
    if not isinstance(meta, dict) or not isinstance(pages, list):
        return False, "invalid"
    if meta.get("schema_version") != CATALOG_SCHEMA_VERSION:
        return False, "stale"
    if meta.get("page_count") != len(pages):
        return False, "invalid"

    try:
        expected_paths = {
            path.relative_to(root).as_posix(): path for path in wiki_pages(root)
        }
    except (OSError, RuntimeError, ValueError):
        return False, "invalid"

    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    corpus_items: list[tuple[str, str]] = []
    list_fields = {
        "tags",
        "headings",
        "links",
        "resolved_links",
        "backlinks",
        "aliases",
        "source_pages",
        "source_files",
    }
    string_fields = {
        "id",
        "legacy_id",
        "title",
        "type",
        "path",
        "body_preview",
        "body_text",
        "search_text",
        "content_sha256",
    }
    for page in pages:
        if not isinstance(page, dict):
            return False, "invalid"
        if any(not isinstance(page.get(field), str) for field in string_fields):
            return False, "invalid"
        if any(
            not isinstance(page.get(field), list)
            or any(not isinstance(item, str) for item in page[field])
            for field in list_fields
        ):
            return False, "invalid"
        typed_links = page.get("typed_links", [])
        if not isinstance(typed_links, list) or any(
            not isinstance(item, dict)
            or not isinstance(item.get("relation"), str)
            or not isinstance(item.get("target"), str)
            for item in typed_links
        ):
            return False, "invalid"

        relative = page["path"]
        if relative in seen_paths or page["id"] in seen_ids:
            return False, "invalid"
        seen_paths.add(relative)
        seen_ids.add(page["id"])
        live_path = expected_paths.get(relative)
        if live_path is None or resolve_public_wiki_path(root, relative) is None:
            return False, "invalid" if relative not in expected_paths else "stale"

        posix_path = PurePosixPath(relative)
        try:
            wiki_relative = posix_path.relative_to("wiki")
        except ValueError:
            return False, "invalid"
        if (
            posix_path.as_posix() != relative
            or ".." in posix_path.parts
            or page["id"] != wiki_relative.with_suffix("").as_posix()
            or page["legacy_id"] != wiki_relative.stem
        ):
            return False, "invalid"

        try:
            actual_digest = hashlib.sha256(live_path.read_bytes()).hexdigest()
        except OSError:
            return False, "stale"
        if page["content_sha256"] != actual_digest:
            return False, "stale"
        corpus_items.append((relative, actual_digest))

    if seen_paths != set(expected_paths):
        return False, "stale"
    if meta.get("corpus_sha256") != _catalog_corpus_sha256(corpus_items):
        return False, "stale"
    if meta.get("catalog_sha256") != _catalog_pages_sha256(pages):
        return False, "invalid"
    return True, "fresh"


def load_catalog_if_fresh(root: Path) -> tuple[dict | None, str]:
    """Return ``(catalog, state)`` while degrading all bad caches read-only."""
    root = Path(root).resolve()
    catalog_path = root / "wiki" / "catalog.json"
    if not catalog_path.exists():
        return None, "missing"
    pages = list(wiki_pages(root))
    try:
        if pages:
            latest_page_time = max(path.stat().st_mtime_ns for path in pages)
            if latest_page_time > catalog_path.stat().st_mtime_ns:
                return None, "stale"
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, ValueError, json.JSONDecodeError):
        return None, "invalid"
    valid, state = validate_catalog(root, catalog)
    return (catalog, "fresh") if valid else (None, state)


def catalog_freshness(root: Path) -> str:
    _catalog, state = load_catalog_if_fresh(root)
    return state


def tokenize(text: str) -> list[str]:
    tokens: list[str] = []
    for raw_token in TOKEN_RE.findall(text):
        token = raw_token.lower()
        tokens.append(token)
        if CJK_RE.search(token):
            cjk_chars = [char for char in token if CJK_RE.match(char)]
            tokens.extend(cjk_chars)
            tokens.extend("".join(cjk_chars[index : index + 2]) for index in range(len(cjk_chars) - 1))
    return tokens


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
            linked_file = link.split("#", 1)[0].split("|", 1)[0].strip()
            if Path(linked_file).suffix and (
                (root / "wiki" / linked_file).exists() or (root / linked_file).exists()
            ):
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


# ──────────────────────────────────────────────────────────────────────────────
# LLM Wiki v2 upgrade helpers (additive): link-graph, hybrid search, quality,
# and memory-lifecycle (confidence / retention-decay / supersession).
# All functions below are read-only and never mutate pages.
# ──────────────────────────────────────────────────────────────────────────────

# Ebbinghaus-style retention half-life per page type, in days. Durable subject
# pages decay slowly; dated/transient notes decay fast. Reinforcement (a newer
# `updated`/`last_confirmed`) resets the clock.
TYPE_HALFLIFE_DAYS = {
    "concept": 720,
    "topic": 720,
    "entity": 720,
    "timeline": 540,
    "analysis": 365,
    "comparison": 365,
    "synthesis": 365,
    "overview": 540,
    "query": 180,
    "source": 150,
}


def build_link_graph(catalog: dict) -> dict:
    """Build an undirected adjacency map from the catalog's resolved wiki links.

    Uses the already-computed `resolved_links` (and their mirror `backlinks`) so
    no page re-parsing is needed. Typed relations, when present, are exposed in a
    parallel labelled-edge map for relation-filtered traversal.
    """
    pages = catalog.get("pages", [])
    by_id = {p["id"]: p for p in pages}
    adj: dict[str, set] = {p["id"]: set() for p in pages}
    typed_edges: dict[str, list] = {p["id"]: [] for p in pages}

    resolver, _ambiguous = None, None
    for page in pages:
        pid = page["id"]
        for target in page.get("resolved_links", []):
            if target in adj:
                adj[pid].add(target)
                adj[target].add(pid)
        for rel in page.get("typed_links", []) or []:
            target = rel.get("target", "")
            # typed_links store the raw link text; map it onto a resolved id when possible
            resolved = target if target in by_id else None
            if resolved is None:
                for cand in page.get("resolved_links", []):
                    if cand.endswith("/" + target) or cand == target:
                        resolved = cand
                        break
            if resolved and resolved in adj:
                typed_edges[pid].append({"relation": rel.get("relation", ""), "target": resolved})

    return {
        "by_id": by_id,
        "adj": {k: sorted(v) for k, v in adj.items()},
        "typed_edges": typed_edges,
    }


def graph_neighbors(catalog: dict, page_id: str, depth: int = 1, relation: str | None = None) -> dict:
    """BFS neighborhood of a page up to `depth` hops. Returns {id: hop_distance}."""
    graph = build_link_graph(catalog)
    adj = graph["adj"]
    if relation:
        # Restrict first-hop expansion to a specific typed relation.
        adj = {k: [] for k in adj}
        for src, edges in graph["typed_edges"].items():
            adj[src] = [e["target"] for e in edges if e["relation"] == relation]
    if page_id not in adj:
        return {}
    from collections import deque

    visited = {page_id: 0}
    queue = deque([(page_id, 0)])
    while queue:
        current, d = queue.popleft()
        if d >= depth:
            continue
        for neighbor in adj.get(current, []):
            if neighbor not in visited:
                visited[neighbor] = d + 1
                queue.append((neighbor, d + 1))
    visited.pop(page_id, None)
    return visited


def graph_path(catalog: dict, src_id: str, dst_id: str, max_depth: int = 8) -> list | None:
    """Shortest wiki-link path between two pages (BFS), or None."""
    graph = build_link_graph(catalog)
    adj = graph["adj"]
    if src_id not in adj or dst_id not in adj:
        return None
    if src_id == dst_id:
        return [src_id]
    from collections import deque

    prev = {src_id: None}
    queue = deque([(src_id, 0)])
    while queue:
        current, d = queue.popleft()
        if d >= max_depth:
            continue
        for neighbor in adj.get(current, []):
            if neighbor not in prev:
                prev[neighbor] = current
                if neighbor == dst_id:
                    path = [dst_id]
                    node = current
                    while node is not None:
                        path.append(node)
                        node = prev[node]
                    return list(reversed(path))
                queue.append((neighbor, d + 1))
    return None


def graph_stats(catalog: dict, top: int = 15) -> dict:
    """Summary statistics for the wiki-link graph."""
    graph = build_link_graph(catalog)
    adj = graph["adj"]
    by_id = graph["by_id"]
    degrees = {pid: len(neigh) for pid, neigh in adj.items()}
    edge_count = sum(degrees.values()) // 2
    orphans = sorted(pid for pid, deg in degrees.items() if deg == 0)
    hubs = sorted(degrees.items(), key=lambda kv: (-kv[1], kv[0]))[:top]
    relation_counts: Counter = Counter()
    for edges in graph["typed_edges"].values():
        for edge in edges:
            relation_counts[edge["relation"]] += 1
    return {
        "nodes": len(adj),
        "edges": edge_count,
        "avg_degree": round(sum(degrees.values()) / max(len(adj), 1), 2),
        "orphan_count": len(orphans),
        "orphans_sample": orphans[:top],
        "top_hubs": [
            {"id": pid, "degree": deg, "title": by_id.get(pid, {}).get("title", pid)}
            for pid, deg in hubs
        ],
        "typed_relation_counts": dict(relation_counts),
    }


def search_catalog_graph(catalog: dict, query: str, top: int = 8, expand_weight: float = 0.5, k: int = 60) -> list[dict]:
    """Hybrid search: BM25-lite ranking fused with 1-hop graph expansion via RRF.

    Direct keyword hits are ranked by `search_catalog`; each hit then contributes
    a discounted reciprocal-rank score to its wiki-link neighbors, so structurally
    connected pages surface even when they don't match the query terms directly.
    """
    base = search_catalog(catalog, query, top=max(top * 3, 15))
    if not base:
        return []
    graph = build_link_graph(catalog)
    adj = graph["adj"]
    by_id = graph["by_id"]
    # Structural hub pages (index/home/log/section-homes) link to everything, so
    # they would dominate neighbor expansion. Keep them only as direct BM25 hits.
    structural = {
        p["id"] for p in catalog.get("pages", [])
        if p.get("legacy_id") in LINT_EXCLUDE_NAMES
    }

    rrf: dict[str, float] = defaultdict(float)
    via: dict[str, str] = {}
    base_scores = {r["id"]: r.get("score", 0.0) for r in base}
    for rank, result in enumerate(base):
        rid = result["id"]
        rrf[rid] += 1.0 / (k + rank + 1)
        # A direct lexical hit must remain explainable as such even if an
        # earlier seed already reached it through the graph.
        via[rid] = "bm25"
        for neighbor in adj.get(rid, []):
            if neighbor in structural:
                continue
            rrf[neighbor] += expand_weight * (1.0 / (k + rank + 1))
            via.setdefault(neighbor, "graph")

    results = []
    for pid, score in rrf.items():
        page = by_id.get(pid)
        if not page:
            continue
        results.append(
            {
                "score": round(score, 6),
                "bm25": base_scores.get(pid, 0.0),
                "id": pid,
                "title": page.get("title", pid),
                "type": page.get("type", ""),
                "path": page.get("path", ""),
                "via": via.get(pid, "graph"),
                "preview": page.get("body_preview", ""),
            }
        )
    results.sort(key=lambda item: (-item["score"], -item["bm25"], item["title"].lower()))
    return results[:top]


def _markdown_sections(text: str) -> list[tuple[str, str]]:
    """Split a page into heading-scoped blocks for evidence extraction."""
    body = body_without_frontmatter(text).strip()
    if not body:
        return []

    sections: list[tuple[str, str]] = []
    heading = "Introduction"
    lines: list[str] = []
    for line in body.splitlines():
        match = re.match(r"^#{1,6}\s+(.+?)\s*$", line)
        if match:
            content = "\n".join(lines).strip()
            if content:
                sections.append((heading, content))
            heading = match.group(1).strip()
            lines = []
        else:
            lines.append(line)
    content = "\n".join(lines).strip()
    if content:
        sections.append((heading, content))
    return sections


def _section_relevance(heading: str, content: str, query: str, query_tokens: list[str]) -> float:
    """Return a deterministic lexical relevance score for one Markdown section."""
    heading_tokens = Counter(tokenize(heading))
    content_tokens = Counter(tokenize(content))
    score = 0.0
    for token in set(query_tokens):
        # Page ranking has already rewarded title/heading matches. At excerpt
        # time, prefer a section whose body actually carries the evidence.
        score += min(heading_tokens[token], 2) * 1.5
        score += min(content_tokens[token], 4) * 2.0
    phrase = re.sub(r"\s+", " ", query).strip().casefold()
    if phrase:
        if phrase in heading.casefold():
            score += 3.0
        if phrase in re.sub(r"\s+", " ", content).casefold():
            score += 8.0
    return score


def _trim_evidence(text: str, query: str, query_tokens: list[str], max_chars: int) -> tuple[str, bool]:
    """Trim around the first useful query match instead of always taking the prefix."""
    compact = text.strip()
    if len(compact) <= max_chars:
        return compact, False

    folded = compact.casefold()
    phrase = query.strip().casefold()
    anchor = folded.find(phrase) if phrase else -1
    needles = [
        token.casefold()
        for token in sorted(set(query_tokens), key=lambda item: (-len(item), item))
        if len(token) > 1
    ]
    if anchor < 0:
        anchor = next(
            (position for needle in needles if (position := folded.find(needle)) >= 0),
            0,
        )
    start = max(0, anchor - max_chars // 3)
    end = min(len(compact), start + max_chars)
    if end - start < max_chars:
        start = max(0, end - max_chars)

    # Prefer paragraph/line boundaries without sacrificing too much context.
    if start > 0:
        boundary = compact.find("\n", start, min(anchor + 1, start + 240))
        if boundary >= 0:
            start = boundary + 1
    if end < len(compact):
        boundary = compact.rfind("\n", max(start, end - 240), end)
        if boundary > start:
            end = boundary

    excerpt = compact[start:end].strip()
    if start > 0:
        excerpt = "… " + excerpt
    if end < len(compact):
        excerpt += " …"
    if len(excerpt) > max_chars:
        excerpt = excerpt[: max_chars - 1].rstrip() + "…"
    return excerpt, True


def relevant_excerpt(text: str, query: str, max_chars: int = 2400) -> dict:
    """Select a heading-aware, bounded excerpt suitable for an auditable citation."""
    if max_chars < 80:
        raise ValueError("max_chars must be at least 80")
    sections = _markdown_sections(text)
    if not sections:
        return {"heading": "", "text": "", "truncated": False}

    query_tokens = tokenize(query)
    ranked = sorted(
        enumerate(sections),
        key=lambda item: (
            -_section_relevance(item[1][0], item[1][1], query, query_tokens),
            item[0],
        ),
    )
    _index, (heading, content) = ranked[0]
    excerpt, truncated = _trim_evidence(content, query, query_tokens, max_chars)
    return {"heading": heading, "text": excerpt, "truncated": truncated}


def _public_provenance(values: object) -> tuple[list[str], int]:
    """Return public-safe provenance and the number of suppressed entries.

    Wiki frontmatter often records local workstation paths for maintainer use.
    Those paths are useful inside the page but must not be copied automatically
    into a default agent context pack.  Preserve safe repository-relative paths
    and public HTTP(S) locators; suppress absolute, traversing, private-layer,
    credential-bearing, and drive-relative values.
    """
    safe: list[str] = []
    redacted = 0
    for raw in values if isinstance(values, list) else []:
        if not isinstance(raw, str) or not raw.strip():
            redacted += 1
            continue
        value = raw.strip()
        parsed = urlsplit(value)
        if parsed.scheme.casefold() in {"http", "https"}:
            if parsed.hostname and parsed.username is None and parsed.password is None:
                # Query strings and fragments can carry access tokens.  The
                # origin/path is sufficient provenance for a default pack.
                clean_url = urlunsplit(
                    (parsed.scheme.casefold(), parsed.netloc, parsed.path, "", "")
                )
                if clean_url not in safe:
                    safe.append(clean_url)
                continue
            redacted += 1
            continue

        normalized = value.replace("\\", "/")
        folded = normalized.casefold()
        path = PurePosixPath(normalized)
        unsafe = (
            normalized.startswith(("/", "//", "~"))
            or bool(re.match(r"(?i)^[a-z]:", normalized))
            or ":" in path.parts[0]
            or ".." in path.parts
            or any(part in {"wiki-private"} for part in (p.casefold() for p in path.parts))
            or any(part.startswith("private-") for part in (p.casefold() for p in path.parts))
            or "raw/private-" in folded
        )
        if unsafe:
            redacted += 1
            continue
        clean = path.as_posix()
        if clean not in safe:
            safe.append(clean)
    return safe, redacted


def _balanced_graph_lane(
    candidates: list[dict],
    seed_results: list[dict],
    seed_for_page: dict[str, str],
    slots: int,
) -> list[dict]:
    """Choose a deterministic graph minority without letting seed 1 monopolize it."""
    if slots <= 0:
        return []
    queues: dict[str, list[dict]] = {
        seed["id"]: [] for seed in seed_results if isinstance(seed.get("id"), str)
    }
    unassigned: list[dict] = []
    for candidate in candidates:
        seed_id = seed_for_page.get(candidate.get("id", ""))
        if seed_id in queues:
            queues[seed_id].append(candidate)
        else:
            unassigned.append(candidate)

    selected: list[dict] = []
    chosen: set[str] = set()
    while len(selected) < slots:
        progressed = False
        for seed in seed_results:
            queue = queues.get(seed.get("id", ""), [])
            while queue and queue[0].get("id") in chosen:
                queue.pop(0)
            if queue and len(selected) < slots:
                item = queue.pop(0)
                selected.append(item)
                chosen.add(item["id"])
                progressed = True
        if not progressed:
            break
    for item in candidates + unassigned:
        if len(selected) >= slots:
            break
        if item.get("id") not in chosen:
            selected.append(item)
            chosen.add(item["id"])
    return selected


def build_evidence_pack(
    root: Path,
    catalog: dict,
    query: str,
    top: int = 6,
    max_chars: int = 12000,
    max_source_chars: int = 2400,
    use_graph: bool = False,
) -> dict:
    """Build a source-attributed, context-budgeted retrieval pack.

    The pack stays entirely inside the public ``wiki/`` layer. Keyword results
    can optionally be expanded through one-hop wiki links, then each selected
    page is reduced to its most relevant heading-scoped excerpt. Stable ``W<n>``
    identifiers let downstream agents cite the exact local page they used.
    """
    if not query.strip():
        raise ValueError("query must not be empty")
    if top < 1:
        raise ValueError("top must be at least 1")
    if max_chars < 200:
        raise ValueError("max_chars must be at least 200")
    if max_source_chars < 80:
        raise ValueError("max_source_chars must be at least 80")

    candidate_limit = max(top * 4, 20)
    base_candidates = search_catalog(catalog, query, top=candidate_limit)
    by_id = {page["id"]: page for page in catalog.get("pages", [])}

    graph = build_link_graph(catalog) if use_graph else None
    seed_results = base_candidates[: min(3, len(base_candidates))]
    graph_candidates: list[dict] = []
    graph_seed: dict[str, str] = {}
    if graph and top >= 3:
        structural = {
            page["id"]
            for page in catalog.get("pages", [])
            if page.get("legacy_id") in LINT_EXCLUDE_NAMES
        }
        base_ids = {result["id"] for result in base_candidates}
        graph_scores: dict[str, float] = defaultdict(float)
        best_contribution: dict[str, float] = defaultdict(float)
        for rank, seed in enumerate(seed_results):
            seed_id = seed["id"]
            for neighbor in graph["adj"].get(seed_id, []):
                if neighbor in structural or neighbor in base_ids:
                    continue
                # Discount broad hubs: a focused backlink is better evidence
                # than a generic page connected to hundreds of notes.
                degree = len(graph["adj"].get(neighbor, []))
                contribution = (1.0 / (rank + 1)) / max(1.0, math.log2(degree + 2))
                graph_scores[neighbor] += contribution
                if contribution > best_contribution[neighbor]:
                    best_contribution[neighbor] = contribution
                    graph_seed[neighbor] = seed_id
        for page_id, score in sorted(graph_scores.items(), key=lambda item: (-item[1], item[0])):
            page = by_id.get(page_id)
            if not page:
                continue
            graph_candidates.append(
                {
                    "score": round(score, 6),
                    "bm25": 0.0,
                    "id": page_id,
                    "title": page.get("title", page_id),
                    "type": page.get("type", ""),
                    "path": page.get("path", ""),
                    "via": "graph",
                }
            )

    if use_graph and graph_candidates and top >= 3:
        # Reserve a bounded minority of the pack for graph discoveries. This
        # prevents high-degree neighbors from crowding out direct evidence while
        # still making the graph mode observably different from lexical search.
        graph_slots = min(max(1, top // 3), top - 1)
        direct_slots = top - graph_slots
        graph_lane = _balanced_graph_lane(
            graph_candidates, seed_results, graph_seed, graph_slots
        )
        candidates = base_candidates[:direct_slots] + graph_lane
        # Keep direct fallbacks after the reserved graph lane so an empty or
        # unreadable linked page cannot reduce the requested citation count.
        chosen = {result["id"] for result in candidates}
        candidates.extend(
            result for result in base_candidates if result["id"] not in chosen
        )
    else:
        candidates = base_candidates
    remaining = max_chars
    citations = []
    for result in candidates:
        if len(citations) >= top or remaining < 80:
            break
        page = by_id.get(result.get("id", ""))
        if not page:
            continue
        # Reserve the minimum valid excerpt budget for later citations.  This
        # prevents long direct hits from consuming the entire pack before the
        # intentionally reserved graph lane is reached.
        remaining_slots = min(top - len(citations), max(1, remaining // 80))
        allowance = min(
            max_source_chars,
            remaining - 80 * max(0, remaining_slots - 1),
        )
        page_path = resolve_public_wiki_path(root, page.get("path"))
        if page_path is None:
            continue
        try:
            page_text, page_sha256 = _read_text_with_digest(page_path)
            live_page = parse_page(
                Path(root).resolve(),
                page_path,
                text=page_text,
                content_sha256=page_sha256,
            )
        except (OSError, RuntimeError, ValueError):
            continue
        # Catalog records rank candidates but never define citation identity or
        # provenance.  A stale/malicious id-path binding is skipped fail-closed.
        if live_page.id != page.get("id"):
            continue
        excerpt = relevant_excerpt(page_text, query, allowance)
        if not excerpt["text"]:
            continue

        connected_to = None
        if graph and result.get("via") == "graph":
            seed_id = graph_seed.get(live_page.id)
            seed_page = by_id.get(seed_id or "")
            if seed_page and resolve_public_wiki_path(root, seed_page.get("path")) is not None:
                connected_to = seed_id

        source_pages, redacted_source_pages = _public_provenance(live_page.source_pages)
        source_files, redacted_source_files = _public_provenance(live_page.source_files)

        citation_id = f"W{len(citations) + 1}"
        citations.append(
            {
                "citation_id": citation_id,
                "id": live_page.id,
                "legacy_id": live_page.legacy_id,
                "title": live_page.title,
                "type": live_page.type,
                "path": live_page.path,
                "page_sha256": page_sha256,
                "score": result.get("score", 0.0),
                "via": result.get("via", "bm25"),
                "connected_to": connected_to,
                "section": excerpt["heading"],
                "excerpt": excerpt["text"],
                "truncated": excerpt["truncated"],
                "source_pages": source_pages,
                "source_files": source_files,
                "redacted_source_pages": redacted_source_pages,
                "redacted_source_files": redacted_source_files,
            }
        )
        remaining -= len(excerpt["text"])

    return {
        "query": query,
        "retrieval": "lexical+bounded-wiki-graph" if use_graph else "lexical",
        "requested_top": top,
        "returned": len(citations),
        "candidate_count": len(base_candidates) + len(graph_candidates),
        "omitted_candidates": max(0, len(base_candidates) + len(graph_candidates) - len(citations)),
        "excerpt_char_budget": max_chars,
        "excerpt_chars_used": max_chars - remaining,
        "max_source_chars": max_source_chars,
        "citations": citations,
    }


def quality_score(page: dict) -> float:
    """Heuristic 0..1 content-quality score for a catalog page record."""
    score = 0.0
    if page.get("title"):
        score += 0.12
    if page.get("type"):
        score += 0.08
    word_count = page.get("word_count", 0)
    if word_count >= 50:
        score += 0.15
    elif word_count >= 10:
        score += 0.07
    if page.get("source_pages") or page.get("source_files"):
        score += 0.20
    if page.get("resolved_links"):
        score += 0.10
    if page.get("backlinks"):
        score += 0.15
    debatable = page.get("type") in {"concept", "topic", "comparison", "analysis", "synthesis"}
    if not debatable or page.get("has_counterpoints"):
        score += 0.20
    return round(min(score, 1.0), 3)


def _parse_date(value: object) -> dt.date | None:
    if not value:
        return None
    text = str(value).strip()[:10]
    try:
        return dt.date.fromisoformat(text)
    except ValueError:
        return None


def retention_score(page_type: str, last_reinforced: dt.date | None, today: dt.date | None = None,
                    confidence: float | None = None) -> float | None:
    """Ebbinghaus retention R = exp(-ln2 * age / halflife), optionally scaled by confidence."""
    if last_reinforced is None:
        return None
    today = today or dt.date.today()
    halflife = TYPE_HALFLIFE_DAYS.get(page_type, 365)
    age = max((today - last_reinforced).days, 0)
    base = math.exp(-math.log(2) * age / halflife)
    if confidence is not None:
        base *= max(0.2, min(1.0, confidence))
    return round(base, 4)


def lifecycle_audit(root: Path, today: dt.date | None = None, stale_threshold: float = 0.35,
                    top: int = 25) -> dict:
    """Advisory memory-lifecycle audit: retention decay, confidence, supersession.

    Read-only. Reads optional frontmatter fields (`confidence`, `last_confirmed`,
    `superseded_by`) that pages may omit; absence is handled gracefully.
    """
    today = today or dt.date.today()
    records = []
    for path in sorted(wiki_pages(root)):
        text = read_text(path)
        fm = parse_frontmatter(text)
        rel = path.relative_to(root).as_posix()
        page_type = str(fm.get("type", infer_type_from_path(path)))
        created = _parse_date(fm.get("created"))
        updated = _parse_date(fm.get("updated"))
        confirmed = _parse_date(fm.get("last_confirmed"))
        reinforced = max([d for d in (created, updated, confirmed) if d], default=None)
        confidence = None
        conf_raw = fm.get("confidence")
        if conf_raw is not None:
            try:
                confidence = float(conf_raw)
            except (TypeError, ValueError):
                confidence = None
        retention = retention_score(page_type, reinforced, today, confidence)
        superseded_by = fm.get("superseded_by") or None
        records.append(
            {
                "path": rel,
                "type": page_type,
                "last_reinforced": reinforced.isoformat() if reinforced else None,
                "age_days": (today - reinforced).days if reinforced else None,
                "retention": retention,
                "confidence": confidence,
                "superseded_by": superseded_by,
                "stale": retention is not None and retention < stale_threshold,
            }
        )

    stale = sorted(
        (r for r in records if r["stale"]),
        key=lambda r: (r["retention"] if r["retention"] is not None else 1.0),
    )
    low_conf = sorted(
        (r for r in records if r["confidence"] is not None and r["confidence"] < 0.5),
        key=lambda r: r["confidence"],
    )
    superseded = [r for r in records if r["superseded_by"]]
    no_date = [r for r in records if r["last_reinforced"] is None]

    return {
        "generated_for": today.isoformat(),
        "stale_threshold": stale_threshold,
        "total_pages": len(records),
        "counts": {
            "stale": len(stale),
            "low_confidence": len(low_conf),
            "superseded": len(superseded),
            "no_date": len(no_date),
        },
        "stale_candidates": stale[:top],
        "low_confidence": low_conf[:top],
        "superseded": superseded[:top],
        "no_date_sample": no_date[:top],
    }
