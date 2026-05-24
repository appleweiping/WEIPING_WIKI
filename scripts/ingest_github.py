"""
ingest_github.py — Python replacement for PowerShell GitHub ingest scripts.

Provides a reusable GitHubIngestor class that handles:
  - GitHub API queries (repos, gists, user info)
  - Shallow git clone/fetch of repos
  - README/LICENSE extraction
  - File tree analysis
  - Content hashing for dedup
  - Wiki page generation via ingest_common.PageSpec
  - Manifest tracking

Used by corpus-specific ingest scripts (ingest_karpathy.py, etc.)
which only need to define their sources and category logic.

Usage (from corpus scripts):
    from ingest_github import GitHubIngestor
    ingestor = GitHubIngestor(root=REPO_ROOT, corpus="karpathy")
    ingestor.run(sources=[...])
"""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
import sys
import textwrap
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

# Import shared ingest library
sys.path.insert(0, str(Path(__file__).parent))
from ingest_common import (
    ManifestEntry, PageSpec,
    load_manifest, diff_manifests,
    render_page, write_page_if_changed,
    validate_wiki, sha256_text, slugify, now_iso, today_iso,
)

REPO_ROOT = Path(__file__).resolve().parent.parent


# ── HTTP helpers ───────────────────────────────────────────────────────────────

def http_get(url: str, headers: dict | None = None, timeout: int = 30) -> bytes:
    """Simple HTTP GET with retry."""
    req = Request(url, headers=headers or {})
    req.add_header("User-Agent", "vipin-wiki-ingest/1.0")
    for attempt in range(3):
        try:
            with urlopen(req, timeout=timeout) as resp:
                return resp.read()
        except HTTPError as e:
            if e.code == 403 and "rate limit" in str(e).lower():
                wait = 60 * (attempt + 1)
                print(f"  Rate limited. Waiting {wait}s…")
                time.sleep(wait)
            elif e.code == 404:
                return b""
            else:
                raise
        except URLError:
            if attempt == 2:
                raise
            time.sleep(5)
    return b""


def github_api(path: str, token: str = "") -> dict | list:
    """Call GitHub API. Returns parsed JSON."""
    url = f"https://api.github.com{path}"
    headers = {"Accept": "application/vnd.github.v3+json"}
    if token:
        headers["Authorization"] = f"token {token}"
    data = http_get(url, headers=headers)
    if not data:
        return {}
    return json.loads(data)


def fetch_rss(url: str) -> list[dict]:
    """Fetch and parse RSS/Atom feed. Returns list of items."""
    data = http_get(url)
    if not data:
        return []
    text = data.decode("utf-8", errors="replace")
    items = []
    # Simple regex-based RSS parser (no external deps)
    for item_match in re.finditer(r"<item>(.*?)</item>", text, re.DOTALL):
        item_text = item_match.group(1)
        def extract(tag: str) -> str:
            m = re.search(rf"<{tag}[^>]*>(?:<!\[CDATA\[)?(.*?)(?:\]\]>)?</{tag}>",
                          item_text, re.DOTALL)
            return m.group(1).strip() if m else ""
        items.append({
            "title": extract("title"),
            "link": extract("link"),
            "description": extract("description"),
            "pubDate": extract("pubDate"),
            "guid": extract("guid"),
        })
    # Also handle Atom <entry> elements
    for entry_match in re.finditer(r"<entry>(.*?)</entry>", text, re.DOTALL):
        entry_text = entry_match.group(1)
        def extract_atom(tag: str, attr: str = "") -> str:
            if attr:
                m = re.search(rf'<{tag}[^>]*{attr}="([^"]*)"', entry_text)
                return m.group(1).strip() if m else ""
            m = re.search(rf"<{tag}[^>]*>(.*?)</{tag}>", entry_text, re.DOTALL)
            return m.group(1).strip() if m else ""
        items.append({
            "title": extract_atom("title"),
            "link": extract_atom("link", "href"),
            "description": extract_atom("summary") or extract_atom("content"),
            "pubDate": extract_atom("published") or extract_atom("updated"),
            "guid": extract_atom("id"),
        })
    return items


# ── Git helpers ────────────────────────────────────────────────────────────────

def sync_repo(repo_url: str, local_path: Path, branch: str = "main") -> bool:
    """Shallow clone or fetch a repo. Returns True on success."""
    local_path.parent.mkdir(parents=True, exist_ok=True)
    git_dir = local_path / ".git"
    try:
        if git_dir.exists():
            result = subprocess.run(
                ["git", "-C", str(local_path), "fetch", "--depth", "1",
                 "--no-tags", "origin", branch],
                capture_output=True, timeout=120,
            )
            if result.returncode != 0:
                # Try main/master fallback
                for fb in ("main", "master"):
                    if fb != branch:
                        r2 = subprocess.run(
                            ["git", "-C", str(local_path), "fetch", "--depth", "1",
                             "--no-tags", "origin", fb],
                            capture_output=True, timeout=120,
                        )
                        if r2.returncode == 0:
                            break
            subprocess.run(
                ["git", "-C", str(local_path), "checkout", "-f", "FETCH_HEAD"],
                capture_output=True, timeout=60,
            )
        else:
            for br in [branch, "main", "master"]:
                result = subprocess.run(
                    ["git", "clone", "--depth", "1", "--no-tags",
                     "--branch", br, repo_url, str(local_path)],
                    capture_output=True, timeout=300,
                )
                if result.returncode == 0:
                    break
        return local_path.exists()
    except subprocess.TimeoutExpired:
        print(f"  Timeout cloning {repo_url}")
        return False
    except Exception as e:
        print(f"  Error syncing {repo_url}: {e}")
        return False


def git_head(repo_path: Path) -> str:
    try:
        r = subprocess.run(["git", "-C", str(repo_path), "rev-parse", "HEAD"],
                           capture_output=True, text=True, timeout=10)
        return r.stdout.strip()
    except Exception:
        return ""


def git_ls_files(repo_path: Path) -> list[str]:
    try:
        r = subprocess.run(["git", "-C", str(repo_path), "ls-files"],
                           capture_output=True, text=True, timeout=30)
        return [f for f in r.stdout.splitlines() if f.strip()]
    except Exception:
        return []


def find_file(repo_path: Path, names: list[str]) -> Optional[Path]:
    """Find first matching file (case-insensitive) in repo root."""
    try:
        for f in repo_path.iterdir():
            if f.is_file() and f.stem.lower() in [n.lower() for n in names]:
                return f
    except Exception:
        pass
    return None


def read_text_file(path: Optional[Path], max_bytes: int = 65536) -> str:
    if not path or not path.exists():
        return ""
    try:
        return path.read_bytes()[:max_bytes].decode("utf-8", errors="replace")
    except Exception:
        return ""


# ── Content helpers ────────────────────────────────────────────────────────────

def plain_summary(text: str, max_chars: int = 620) -> str:
    """Extract plain text summary from markdown/HTML."""
    # Strip HTML tags
    text = re.sub(r"<[^>]+>", " ", text)
    # Strip markdown headers, links, code blocks
    text = re.sub(r"```.*?```", " ", text, flags=re.DOTALL)
    text = re.sub(r"`[^`]+`", " ", text)
    text = re.sub(r"!\[.*?\]\(.*?\)", " ", text)
    text = re.sub(r"\[([^\]]+)\]\([^\)]+\)", r"\1", text)
    text = re.sub(r"^#{1,6}\s+", "", text, flags=re.MULTILINE)
    text = re.sub(r"\*{1,2}([^*]+)\*{1,2}", r"\1", text)
    text = re.sub(r"\s+", " ", text).strip()
    if len(text) <= max_chars:
        return text
    # Truncate at sentence boundary
    truncated = text[:max_chars]
    last_period = max(truncated.rfind(". "), truncated.rfind(".\n"))
    if last_period > max_chars * 0.6:
        return truncated[:last_period + 1]
    return truncated + "…"


def extension_stats(files: list[str], top: int = 12) -> list[dict]:
    from collections import Counter
    exts = Counter(Path(f).suffix.lower() or "[none]" for f in files)
    return [{"extension": ext, "count": cnt}
            for ext, cnt in exts.most_common(top)]


def top_level_stats(files: list[str], top: int = 12) -> list[dict]:
    from collections import Counter
    dirs = Counter(f.split("/")[0] if "/" in f else "[root]" for f in files)
    return [{"path": d, "count": cnt} for d, cnt in dirs.most_common(top)]


# ── Core ingestor ──────────────────────────────────────────────────────────────

@dataclass
class CorpusSource:
    """Defines a single source to ingest (GitHub user, RSS feed, etc.)"""
    kind: str                          # github_user | rss | youtube | webpage
    url: str
    corpus_id: str                     # e.g. "karpathy"
    wiki_section: str                  # e.g. "wiki/sources/karpathy-public"
    category_fn: callable = None       # (name, desc, files) → {Category, Tags}
    teaching_fn: callable = None       # (category, name) → [str, str]
    why_matters_fn: callable = None    # (category) → str
    extra: dict = field(default_factory=dict)


class GitHubIngestor:
    """
    Reusable GitHub corpus ingestor.
    Replaces the PowerShell ingest-*.ps1 scripts with a clean Python API.
    """

    def __init__(self, root: Path, corpus: str, dry_run: bool = False,
                 skip_validation: bool = False, token: str = ""):
        self.root = root
        self.corpus = corpus
        self.dry_run = dry_run
        self.skip_validation = skip_validation
        self.token = token
        self.today = today_iso()
        self.now = now_iso()
        self.errors: list[str] = []
        self.stats = {"added": 0, "updated": 0, "removed": 0, "unchanged": 0}

    def ingest_github_user(self, username: str, source: CorpusSource,
                           manifest_path: Path) -> list[ManifestEntry]:
        """Ingest all public repos for a GitHub user."""
        print(f"  Fetching repos for {username}…")
        repos = github_api(f"/users/{username}/repos?per_page=100&sort=updated",
                           token=self.token)
        if not isinstance(repos, list):
            self.errors.append(f"Failed to fetch repos for {username}")
            return []

        old_manifest = load_manifest(manifest_path)
        old_by_id = {e["slug"]: e for e in old_manifest.get("entries", [])}
        new_entries: list[ManifestEntry] = []

        for repo in repos:
            if repo.get("fork") or repo.get("archived"):
                continue
            entry = self._process_repo(repo, source, old_by_id)
            if entry:
                new_entries.append(entry)

        return new_entries

    def ingest_rss(self, feed_url: str, source: CorpusSource,
                   manifest_path: Path, item_kind: str = "blog") -> list[ManifestEntry]:
        """Ingest RSS/Atom feed items."""
        print(f"  Fetching RSS: {feed_url}…")
        items = fetch_rss(feed_url)
        if not items:
            print(f"  No items found in feed: {feed_url}")
            return []

        old_manifest = load_manifest(manifest_path)
        old_by_id = {e["slug"]: e for e in old_manifest.get("entries", [])}
        new_entries: list[ManifestEntry] = []

        for item in items:
            entry = self._process_rss_item(item, source, old_by_id, item_kind)
            if entry:
                new_entries.append(entry)

        return new_entries

    def _process_repo(self, repo: dict, source: CorpusSource,
                      old_by_id: dict) -> Optional[ManifestEntry]:
        name = repo.get("name", "")
        desc = repo.get("description", "") or ""
        html_url = repo.get("html_url", "")
        clone_url = repo.get("clone_url", "")
        default_branch = repo.get("default_branch", "main")

        # Sync repo locally
        tmp_dir = self.root / ".wiki-tmp" / f"{source.corpus_id}-repos" / slugify(name)
        if not self.dry_run:
            sync_repo(clone_url, tmp_dir, default_branch)

        files = git_ls_files(tmp_dir) if tmp_dir.exists() else []
        head = git_head(tmp_dir) if tmp_dir.exists() else ""
        readme_path = find_file(tmp_dir, ["README", "Readme", "readme"]) if tmp_dir.exists() else None
        license_path = find_file(tmp_dir, ["LICENSE", "LICENCE", "COPYING"]) if tmp_dir.exists() else None
        readme = read_text_file(readme_path)
        license_text = read_text_file(license_path)

        # Category + tags
        cat_info = {"Category": "General", "Tags": [source.corpus_id]}
        if source.category_fn:
            cat_info = source.category_fn(name, desc, files)

        # Content hash
        hash_input = "\n".join([
            repo.get("full_name", ""), desc, html_url, default_branch, head,
            sha256_text(readme), sha256_text(license_text),
            "\n".join(sorted(files)),
        ])
        content_hash = sha256_text(hash_input)

        entry_id = f"github:{name}"
        slug = f"github-{slugify(name)}"
        old = old_by_id.get(slug, {})
        first_seen = old.get("first_seen", self.today)
        last_changed = old.get("last_changed", self.today) if old.get("semantic_hash") == content_hash else self.today

        license_name = (repo.get("license") or {}).get("spdx_id", "NOASSERTION") or "NOASSERTION"
        dist_policy = ("public-summary-plus-license-aware-excerpts"
                       if license_name != "NOASSERTION"
                       else "public-summary-local-archive-only")

        summary = plain_summary(readme, 620)
        teaching = source.teaching_fn(cat_info["Category"], name) if source.teaching_fn else []
        why = source.why_matters_fn(cat_info["Category"]) if source.why_matters_fn else ""

        # Build wiki page
        page_path = f"{source.wiki_section}/{slug}.md"
        body_lines = [
            f"## Source",
            "",
            f"- Source kind: `github-repository`",
            f"- URL: {html_url}",
            f"- Discovery source: {html_url}",
            f"- License: `{license_name}`",
            f"- Distribution policy: `{dist_policy}`",
            f"- Public mirror status: `{'partial excerpt' if license_name != 'NOASSERTION' else 'summary-only'}`",
            f"- Content hash: `{content_hash}`",
            f"- First seen: {first_seen}",
            f"- Last changed: {last_changed}",
            "",
            f"## Classification",
            "",
            f"- Primary category: {cat_info['Category']}",
            f"- Corpus source note: [[{self.today[:7]}-{source.corpus_id}-public-corpus]]",
            "",
            f"## Summary",
            "",
            summary,
            "",
        ]
        if teaching:
            body_lines += ["## What This Teaches", ""]
            for t in teaching:
                body_lines.append(f"- {t}")
            body_lines.append("")
        if why:
            body_lines += ["## Why It Matters", "", why, ""]

        body_lines += [
            "## Repository Snapshot",
            "",
            f"- Full name: `{repo.get('full_name', '')}`",
            f"- Default branch: `{default_branch}`",
            f"- HEAD: `{head}`",
            f"- Stars at crawl: {repo.get('stargazers_count', 0)}",
            f"- Forks at crawl: {repo.get('forks_count', 0)}",
            f"- File count: {len(files)}",
            f"- README path: `{readme_path.name if readme_path else ''}`",
            f"- License path: `{license_path.name if license_path else ''}`",
            f"- Created: {repo.get('created_at', '')}",
            f"- Updated: {repo.get('updated_at', '')}",
            f"- Pushed: {repo.get('pushed_at', '')}",
            "",
        ]
        if files:
            top_level = top_level_stats(files)
            body_lines += ["### Top-Level Structure", ""]
            for item in top_level:
                body_lines.append(f"- `{item['path']}`: {item['count']}")
            body_lines.append("")
            ext_stats = extension_stats(files)
            body_lines += ["### File Extension Profile", ""]
            for item in ext_stats:
                body_lines.append(f"- `{item['extension']}`: {item['count']}")
            body_lines.append("")
            sample = sorted(files)[:120]
            body_lines += ["### Sample File Tree", ""]
            for f in sample:
                body_lines.append(f"- `{f}`")
            body_lines.append("")

        body_lines += [
            "## Public Handling Notes",
            "",
            "- EXTRACTED: This page records public metadata and a source-grounded summary.",
            "- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.",
            "- Do not treat this page as permission to republish unlicensed source text or code wholesale.",
        ]

        spec = PageSpec(
            path=page_path,
            title=name,
            type="source",
            status="active",
            tags=cat_info["Tags"],
            frontmatter={
                "created": first_seen,
                "updated": last_changed,
                "source_pages": [],
                "source_files": [f"raw/{source.corpus_id}-public/manifest.json"],
            },
            body="\n".join(body_lines),
        )

        if not self.dry_run:
            written = write_page_if_changed(self.root, spec)
            if written:
                self.stats["updated" if old else "added"] += 1
            else:
                self.stats["unchanged"] += 1

        return ManifestEntry(
            slug=slug,
            title=name,
            url=html_url,
            dedupe_key=entry_id,
            semantic_hash=content_hash,
            first_seen=first_seen,
            last_changed=last_changed,
            status="active",
            metadata={
                "stars": repo.get("stargazers_count", 0),
                "license": license_name,
                "category": cat_info["Category"],
            },
        )

    def _process_rss_item(self, item: dict, source: CorpusSource,
                          old_by_id: dict, item_kind: str) -> Optional[ManifestEntry]:
        title = item.get("title", "").strip()
        link = item.get("link", "").strip()
        description = item.get("description", "").strip()
        if not title or not link:
            return None

        slug_base = re.sub(r"^https?://", "", link).replace("/", "-").strip("-")
        slug = f"{item_kind}-{slugify(slug_base[:60])}"
        content_hash = sha256_text(f"{title}\n{link}\n{description}")
        old = old_by_id.get(slug, {})
        first_seen = old.get("first_seen", self.today)
        last_changed = old.get("last_changed", self.today) if old.get("semantic_hash") == content_hash else self.today

        summary = plain_summary(description, 720)
        teaching = source.teaching_fn("blog", title) if source.teaching_fn else []
        why = source.why_matters_fn("blog") if source.why_matters_fn else ""

        page_path = f"{source.wiki_section}/{slug}.md"
        body_lines = [
            "## Source",
            "",
            f"- Source kind: `{item_kind}-rss-item`",
            f"- URL: {link}",
            f"- Source feed: {source.url}",
            f"- Published: {item.get('pubDate', '')}",
            f"- Content hash: `{content_hash}`",
            f"- First seen: {first_seen}",
            f"- Last changed: {last_changed}",
            "",
            "## Summary",
            "",
            summary,
            "",
        ]
        if teaching:
            body_lines += ["## What This Teaches", ""]
            for t in teaching:
                body_lines.append(f"- {t}")
            body_lines.append("")
        if why:
            body_lines += ["## Why It Matters", "", why, ""]

        spec = PageSpec(
            path=page_path,
            title=title,
            type="source",
            status="active",
            tags=[source.corpus_id, item_kind],
            frontmatter={"created": first_seen, "updated": last_changed},
            body="\n".join(body_lines),
        )

        if not self.dry_run:
            written = write_page_if_changed(self.root, spec)
            if written:
                self.stats["updated" if old else "added"] += 1
            else:
                self.stats["unchanged"] += 1

        return ManifestEntry(
            slug=slug,
            title=title,
            url=link,
            dedupe_key=f"{item_kind}:{link}",
            semantic_hash=content_hash,
            first_seen=first_seen,
            last_changed=last_changed,
            status="active",
        )

    def save_manifest(self, entries: list[ManifestEntry], manifest_path: Path):
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        data = {
            "generated": self.now,
            "count": len(entries),
            "entries": [
                {
                    "slug": e.slug,
                    "title": e.title,
                    "url": e.url,
                    "dedupe_key": e.dedupe_key,
                    "semantic_hash": e.semantic_hash,
                    "first_seen": e.first_seen,
                    "last_changed": e.last_changed,
                    "status": e.status,
                    "metadata": e.metadata,
                }
                for e in entries
            ],
        }
        manifest_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

    def validate(self) -> bool:
        if self.skip_validation or self.dry_run:
            return True
        print("  Validating wiki…")
        result = validate_wiki(self.root)
        if not result["passed"]:
            print(f"  ✗ Validation failed: {result['lint_issues']} lint issues")
            return False
        print(f"  ✓ Validation passed ({result['catalog_pages']} pages)")
        return True

    def print_summary(self):
        print(f"\n  Results: +{self.stats['added']} added  "
              f"~{self.stats['updated']} updated  "
              f"={self.stats['unchanged']} unchanged")
        if self.errors:
            print(f"  Errors ({len(self.errors)}):")
            for e in self.errors[:5]:
                print(f"    - {e}")
