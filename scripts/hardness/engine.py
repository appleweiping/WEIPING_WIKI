"""High-level orchestration entry points for the hardness engine.

Thin layer used by both the wiki.py subcommand and any direct callers.
"""
from __future__ import annotations

import json
from pathlib import Path

from . import __version__
from .analyzer import analyze, blast_radius
from .harden import harden_task, write_task
from .memory_sync import sync_lessons
from .model import ProjectModel
from .scanner import scan_project
from .writer import write_agent_dir

AGENT_DIRNAME = ".agent"


def scan(project_path: str, name: str | None = None, write: bool = True) -> dict:
    """Scan + analyze a project and (optionally) write its .agent/ tree."""
    model = scan_project(project_path, name=name)
    model.engine_version = __version__
    analyze(model)
    if not write:
        return {"model": model.to_json()}
    agent_dir = Path(model.root) / AGENT_DIRNAME
    manifest = write_agent_dir(model, agent_dir)
    _ensure_gitignore(Path(model.root))
    return {"manifest": manifest, "agent_dir": str(agent_dir)}


def _ensure_gitignore(root: Path) -> None:
    """Ensure .agent/ is ignored, without touching the project's tracked files.

    For git repos we write `.git/info/exclude` (a LOCAL, never-committed ignore
    file) so research/experiment repos are never modified in a way that shows up
    in `git diff` or `git status` on tracked content. For non-git dirs we do
    nothing (there is nothing to ignore against).
    """
    git_dir = root / ".git"
    line = ".agent/"
    try:
        if git_dir.is_dir():
            info = git_dir / "info"
            info.mkdir(exist_ok=True)
            exclude = info / "exclude"
            content = exclude.read_text(encoding="utf-8", errors="replace") if exclude.exists() else ""
            if ".agent" in content:
                return
            exclude.write_text(
                content.rstrip() + f"\n# project-hardness causal layer (local)\n{line}\n",
                encoding="utf-8")
    except OSError:
        pass


def harden(project_path: str, requirement: str, task_id: str | None = None,
           rescan: bool = False) -> dict:
    """Run task-hardening against a project's model, writing a task spec."""
    root = Path(project_path).resolve()
    agent_dir = root / AGENT_DIRNAME
    model = _load_or_scan(root, rescan)
    spec = harden_task(model, requirement, task_id=task_id)
    md_path = write_task(agent_dir, spec)
    return {"task_id": spec["id"], "task_file": str(md_path), "spec": spec}


def _load_or_scan(root: Path, rescan: bool) -> ProjectModel:
    """Rebuild the model (cheap, deterministic). Always reflects current code."""
    model = scan_project(str(root))
    model.engine_version = __version__
    analyze(model)
    return model


def impact(project_path: str, module_name: str) -> dict:
    """Report the blast radius of a module without writing anything."""
    model = scan_project(project_path)
    analyze(model)
    return blast_radius(model, module_name)


def sync(project_path: str, lessons: list[str], dry_run: bool = True) -> dict:
    """Sync cross-project lessons to agentmemory (project facts are rejected)."""
    name = Path(project_path).resolve().name
    return sync_lessons(lessons, project=name, dry_run=dry_run)
