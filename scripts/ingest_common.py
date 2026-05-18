"""Shared ingest utilities for vipin wiki corpus automation.

This module provides the common pipeline stages that all ingest scripts should use.
New ingest scripts should import from here instead of reimplementing these patterns.

Existing large .ps1 ingest scripts (frontend-frameworks, shunyu-yao, etc.) will be
migrated incrementally to use this library.

Pipeline stages:
    fetch → normalize → generate → validate → catalog update
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

# Ensure wiki_core is importable
sys.path.insert(0, str(Path(__file__).parent))
from wiki_core import resolve_root, build_catalog, lint_wiki


# --- Data models ---

@dataclass
class ManifestEntry:
    """One item in a corpus manifest."""
    slug: str
    title: str
    url: str = ""
    dedupe_key: str = ""
    semantic_hash: str = ""
    first_seen: str = ""
    last_changed: str = ""
    status: str = "active"  # active | removed | error
    error: str = ""
    metadata: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {k: v for k, v in asdict(self).items() if v}


@dataclass
class PageSpec:
    """Specification for a wiki page to be generated."""
    path: str  # relative to repo root, e.g. "wiki/entities/foo.md"
    title: str
    type: str  # entity, source, concept, topic, analysis
    status: str = "active"
    tags: list = field(default_factory=list)
    frontmatter: dict = field(default_factory=dict)
    body: str = ""
    source_files: list = field(default_factory=list)


# --- Utility functions ---

def sha256_text(text: str) -> str:
    """Compute SHA-256 hash of text content."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]


def slugify(text: str) -> str:
    """Convert text to kebab-case slug."""
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-+", "-", text)
    return text.strip("-")


def now_iso() -> str:
    """Current UTC timestamp in ISO format."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def today_iso() -> str:
    """Current date in ISO format."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%d")


# --- Manifest operations ---

def load_manifest(path: str) -> list[dict]:
    """Load a manifest JSON file, return list of entries."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, list):
            return data
        return data.get("entries", data.get("items", []))
    except (FileNotFoundError, json.JSONDecodeError):
        return []


def save_manifest(path: str, entries: list[dict], metadata: dict = None) -> None:
    """Save manifest with optional metadata header."""
    os.makedirs(os.path.dirname(path), exist_ok=True)
    output = {
        "generated": now_iso(),
        "count": len(entries),
    }
    if metadata:
        output.update(metadata)
    output["entries"] = entries
    with open(path, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
        f.write("\n")


def diff_manifests(old: list[dict], new: list[dict], key_field: str = "dedupe_key") -> dict:
    """Compare two manifest entry lists, return added/updated/removed."""
    old_map = {e.get(key_field, e.get("slug", "")): e for e in old}
    new_map = {e.get(key_field, e.get("slug", "")): e for e in new}

    added = [new_map[k] for k in new_map if k not in old_map]
    removed = [old_map[k] for k in old_map if k not in new_map]
    updated = []
    for k in new_map:
        if k in old_map:
            old_hash = old_map[k].get("semantic_hash", "")
            new_hash = new_map[k].get("semantic_hash", "")
            if old_hash and new_hash and old_hash != new_hash:
                updated.append(new_map[k])

    return {"added": added, "updated": updated, "removed": removed}


# --- Page generation ---

def render_frontmatter(spec: PageSpec) -> str:
    """Render YAML frontmatter from a PageSpec."""
    fm = {
        "title": spec.title,
        "type": spec.type,
        "status": spec.status,
        "created": spec.frontmatter.get("created", today_iso()),
        "updated": today_iso(),
    }
    if spec.tags:
        fm["tags"] = spec.tags
    if spec.source_files:
        fm["source_files"] = spec.source_files
    # Merge any extra frontmatter
    for k, v in spec.frontmatter.items():
        if k not in fm:
            fm[k] = v

    lines = ["---"]
    for k, v in fm.items():
        if isinstance(v, list):
            lines.append(f"{k}:")
            for item in v:
                lines.append(f"  - {item}")
        else:
            # Escape values that need quoting
            sv = str(v)
            if ":" in sv or sv.startswith("[") or sv.startswith("{"):
                lines.append(f'{k}: "{sv}"')
            else:
                lines.append(f"{k}: {sv}")
    lines.append("---")
    return "\n".join(lines)


def render_page(spec: PageSpec) -> str:
    """Render a complete wiki page from a PageSpec."""
    parts = [render_frontmatter(spec), "", f"# {spec.title}", ""]
    if spec.body:
        parts.append(spec.body)
    return "\n".join(parts) + "\n"


def write_page_if_changed(root: str, spec: PageSpec) -> bool:
    """Write a page only if content actually changed. Returns True if written."""
    full_path = os.path.join(root, spec.path)
    new_content = render_page(spec)
    new_hash = sha256_text(new_content)

    if os.path.exists(full_path):
        old_content = ""
        try:
            with open(full_path, "r", encoding="utf-8") as f:
                old_content = f.read()
        except Exception:
            pass
        if sha256_text(old_content) == new_hash:
            return False  # No change

    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    return True


# --- Validation gate ---

def validate_wiki(root: str, skip: bool = False) -> dict:
    """Run catalog rebuild and lint as validation gate.

    Returns dict with 'catalog_pages', 'lint_issues', 'passed'.
    """
    if skip:
        return {"skipped": True, "passed": True}

    root = resolve_root(root)
    catalog = build_catalog(root)
    catalog_path = os.path.join(root, "wiki", "catalog.json")
    with open(catalog_path, "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)
        f.write("\n")

    issues = lint_wiki(root)
    total_issues = sum(len(v) if isinstance(v, list) else 0 for v in issues.items())

    return {
        "catalog_pages": len(catalog.get("pages", [])),
        "lint_issues": total_issues,
        "passed": total_issues == 0,
        "details": {k: len(v) for k, v in issues.items() if isinstance(v, list) and v},
    }


# --- Ingest summary ---

@dataclass
class IngestResult:
    """Summary of an ingest run."""
    corpus: str
    started: str = ""
    completed: str = ""
    entries_total: int = 0
    entries_new: int = 0
    entries_updated: int = 0
    entries_removed: int = 0
    pages_written: int = 0
    errors: list = field(default_factory=list)
    validation: dict = field(default_factory=dict)

    def summary_line(self) -> str:
        return (
            f"{self.corpus}: {self.entries_total} entries "
            f"(+{self.entries_new} new, ~{self.entries_updated} updated, "
            f"-{self.entries_removed} removed), "
            f"{self.pages_written} pages written, "
            f"{len(self.errors)} errors"
        )
