"""Discovery + batch hardening across many projects.

Finds project roots under a set of search roots, de-duplicates by realpath
(junctions/aliases collapse to one), applies safety excludes, and hardens each.

Research isolation: this only ever READS and writes the target's own .agent/.
It never moves, stages, or mutates experiment code/data.
"""
from __future__ import annotations

import os
from pathlib import Path

from . import engine

# Manifest/marker files that signal "this dir is a project".
PROJECT_MARKERS = {
    "package.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt",
    "Cargo.toml", "go.mod", "pom.xml", "build.gradle", "Gemfile", "composer.json",
    "CLAUDE.md", "AGENTS.md",
}
SRC_DIRS = {"src", "backend", "lib", "app", "pkg", "scripts", "engine", "core"}

# Substrings that disqualify a directory (archives, backups, third-party, junk).
EXCLUDE_SUBSTR = (
    "archive", "backup", "__split", "offline_pkgs", "external_repos",
    "node_modules", ".egg-info", "__pycache__", ".work", "_archive",
    "新建文件夹", "文件管理", "project chat", "demo toy",
)
# Names we never harden (third-party upstreams we don't own).
EXCLUDE_NAMES = {"agentmemory", "openhands", "llm-wiki-skill-ref"}

DEFAULT_ROOTS = [
    r"D:/research", r"D:/Research", r"D:/Company",
    r"D:/Terraria_doc", r"D:/agent-resources",
]


def is_project(p: Path) -> bool:
    if not p.is_dir():
        return False
    if (p / ".git").exists():
        return True
    try:
        names = {c.name for c in p.iterdir()}
    except OSError:
        return False
    if names & PROJECT_MARKERS:
        return True
    return bool(names & SRC_DIRS)


def discover(roots: list[str] | None = None) -> list[Path]:
    """Return de-duplicated project roots (realpath-unique, excludes applied)."""
    roots = roots or DEFAULT_ROOTS
    seen: set[str] = set()
    out: list[Path] = []
    for root in roots:
        rp = Path(root)
        if not rp.exists():
            continue
        candidates = [rp]
        try:
            candidates += [c for c in rp.iterdir() if c.is_dir()]
        except OSError:
            pass
        for cand in candidates:
            low = str(cand).lower()
            if any(s in low for s in EXCLUDE_SUBSTR):
                continue
            if cand.name.lower() in EXCLUDE_NAMES:
                continue
            real = os.path.realpath(cand)
            if real in seen:
                continue
            if is_project(cand):
                seen.add(real)
                out.append(cand)
    return sorted(out, key=lambda x: str(x).lower())


def scan_all(roots: list[str] | None = None, dry_run: bool = False) -> dict:
    """Discover and harden every project. Returns a per-project report."""
    projects = discover(roots)
    results = []
    for p in projects:
        if dry_run:
            results.append({"project": p.name, "path": str(p), "status": "discovered"})
            continue
        try:
            res = engine.scan(str(p))
            man = res.get("manifest", {})
            results.append({
                "project": man.get("project", p.name),
                "path": str(p),
                "status": "hardened",
                "stats": man.get("stats", {}),
                "agent_dir": res.get("agent_dir"),
            })
        except Exception as e:  # never let one bad project stop the batch
            results.append({"project": p.name, "path": str(p),
                            "status": "error", "error": f"{type(e).__name__}: {e}"})
    return {
        "discovered": len(projects),
        "hardened": sum(1 for r in results if r["status"] == "hardened"),
        "errors": sum(1 for r in results if r["status"] == "error"),
        "projects": results,
    }
