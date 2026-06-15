"""auto.py — 自动增量 hardening。

判断每个项目是否需要 (重新) hardening：
  - 新项目 (没有 .agent/index.json)          -> harden (new)
  - git 仓库且 HEAD 变了 (发生过提交)         -> harden (git-change)
  - 代码文件数量变化 >= 阈值 (改动大了)        -> harden (content-change)
  - 非 git 项目结构指纹变了                    -> harden (content-change-nogit)
  - 已有 .agent 但没有 state (首次纳入自动)    -> 只建立基线, 不重扫 (baseline)
  - 其余                                       -> skip

状态存在 <project>/.agent/.hardness-state.json (在 .agent 内, 已被 git 忽略)。
只读项目 + 只写各自 .agent/, 绝不碰实验数据。
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
from pathlib import Path

from . import engine
from .discover import discover
from .scanner import CODE_EXT, IGNORE_DIRS, IGNORE_DIR_SUFFIXES

STATE_FILE = ".hardness-state.json"
DEFAULT_THRESHOLD = 15  # 代码文件增删达到这个数量算 "改动大了"
MAX_FP_FILES = 8000


def _git_head(root: Path) -> str | None:
    try:
        r = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"],
                           capture_output=True, text=True, timeout=10)
        return r.stdout.strip() if r.returncode == 0 else None
    except (OSError, subprocess.SubprocessError):
        return None


def fingerprint(root: Path) -> dict:
    """便宜的结构指纹: 代码文件 (相对路径+大小) 的数量与哈希, 外加 git HEAD。"""
    entries: list[str] = []
    count = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames
                       if (d not in IGNORE_DIRS
                           and not d.endswith(IGNORE_DIR_SUFFIXES)
                           and (not d.startswith(".") or d == ".github"))]
        for fn in filenames:
            ext = os.path.splitext(fn)[1].lower()
            if ext not in CODE_EXT:
                continue
            count += 1
            if count > MAX_FP_FILES:
                break
            fp = Path(dirpath) / fn
            try:
                size = fp.stat().st_size
            except OSError:
                size = 0
            rel = os.path.relpath(str(fp), str(root)).replace("\\", "/")
            entries.append(f"{rel}:{size}")
        if count > MAX_FP_FILES:
            break
    entries.sort()
    h = hashlib.sha1("\n".join(entries).encode("utf-8", "replace")).hexdigest()
    return {"git_head": _git_head(root), "code_file_count": count, "struct_hash": h}


def _read_state(agent_dir: Path) -> dict | None:
    sf = agent_dir / STATE_FILE
    if not sf.exists():
        return None
    try:
        return json.loads(sf.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def _write_state(agent_dir: Path, fp: dict) -> None:
    agent_dir.mkdir(parents=True, exist_ok=True)
    fp = dict(fp)
    fp["hardened_at"] = __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    (agent_dir / STATE_FILE).write_text(json.dumps(fp, ensure_ascii=False, indent=2),
                                        encoding="utf-8")


def decide(project: Path, threshold: int = DEFAULT_THRESHOLD) -> tuple[str, dict]:
    """返回 (decision, current_fingerprint)。decision ∈ new|git-change|content-change|baseline|skip"""
    agent_dir = project / ".agent"
    cur = fingerprint(project)
    if not (agent_dir / "index.json").exists():
        return "new", cur
    state = _read_state(agent_dir)
    if state is None:
        return "baseline", cur          # 已有 .agent 但还没纳入自动 -> 只建基线
    if cur["git_head"] and state.get("git_head") and cur["git_head"] != state["git_head"]:
        return "git-change", cur
    if abs(cur["code_file_count"] - state.get("code_file_count", 0)) >= threshold:
        return "content-change", cur
    if not cur["git_head"] and cur["struct_hash"] != state.get("struct_hash"):
        return "content-change-nogit", cur
    return "skip", cur


def auto_scan(roots: list[str] | None = None, threshold: int = DEFAULT_THRESHOLD,
              dry_run: bool = False) -> dict:
    projects = discover(roots)
    results = []
    audit_inputs: list[dict] = []
    for p in projects:
        try:
            decision, fp = decide(p, threshold)
        except Exception as e:
            results.append({"project": p.name, "status": "error",
                            "error": f"{type(e).__name__}: {e}"})
            audit_inputs.append({"name": p.name, "root": str(p), "fp": None,
                                 "state": None, "decision": "error"})
            continue
        agent_dir = p / ".agent"
        audit_inputs.append({"name": p.name, "root": str(p), "fp": fp,
                             "state": _read_state(agent_dir), "decision": decision})
        if decision == "skip":
            results.append({"project": p.name, "decision": "skip"})
            continue
        if dry_run:
            results.append({"project": p.name, "decision": decision, "would_harden":
                            decision != "baseline"})
            continue
        if decision == "baseline":
            _write_state(agent_dir, fp)
            results.append({"project": p.name, "decision": "baseline"})
            continue
        # new / git-change / content-change[-nogit] -> 真正重扫
        try:
            engine.scan(str(p))
            _write_state(agent_dir, fp)
            results.append({"project": p.name, "decision": decision, "hardened": True})
        except Exception as e:
            results.append({"project": p.name, "status": "error",
                            "error": f"{type(e).__name__}: {e}"})
    # Feature B: refresh the canonical advisory disk-audit ledger. Never let a
    # ledger failure break hardening; dry-run previews write nothing.
    audit_written = None
    if not dry_run:
        try:
            from . import audit as _audit
            audit_written = _audit.export_audit(audit_inputs)
        except Exception as e:
            audit_written = f"error: {type(e).__name__}: {e}"
    return {
        "checked": len(projects),
        "hardened": sum(1 for r in results if r.get("hardened")),
        "baselined": sum(1 for r in results if r.get("decision") == "baseline"),
        "skipped": sum(1 for r in results if r.get("decision") == "skip"),
        "errors": sum(1 for r in results if r.get("status") == "error"),
        "audit_written": audit_written,
        "projects": results,
    }
