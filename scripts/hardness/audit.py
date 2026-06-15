"""audit.py — canonical disk-audit ledger writer (Feature B).

Builds an ADVISORY keep/quarantine ledger from the data the hardness auto-scan
already computed, and writes it atomically to a single canonical file that every
agent reads BEFORE moving/deleting/cleaning a D:-drive project.

Hard safety rules (do not relax):
  * Verdict is ONLY ever ``keep`` or ``quarantine``. ``safe-delete`` is NEVER a
    machine output — deletion is always a human decision made outside this file.
  * Default is ``keep``. An incomplete/unreadable scan forces ``keep`` (an unknown
    is never deletion license).
  * ``quarantine`` means "advisory: move to a review area / look at this", never
    "delete". It is only emitted for non-git dirs that look like obvious scratch
    (name match) AND are demonstrably stale AND hold almost no code.
  * A human-owned ``overrides.json`` always wins and can only force ``keep``-style
    safety, never make the writer emit a delete.

Pure stdlib. No new dependencies.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
from datetime import datetime
from pathlib import Path

# Canonical home (overridable for tests via env). git history is the rotation.
AUDIT_DIR = Path(os.environ.get("WIKI_DISK_AUDIT_DIR", r"D:\AGENT_RESOURCE\disk-audit"))
AUDIT_FILE = "projects-audit.json"
OVERRIDES_FILE = "overrides.json"

MAX_FP_FILES = 8000  # keep in sync with auto.fingerprint cap
STALE_DAYS = 180
# obvious-scratch name signals; conservative — anything not matching stays ``keep``
_QUARANTINE_NAME_RE = re.compile(r"(?i)(^|[\W_])(tmp|temp|backup|bak|old|copy)([\W_]|$)|新建文件夹|副本")


def _now() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def _git_unpushed(root: Path) -> bool | None:
    """Best-effort: are there local commits not on any remote? None if unknown."""
    try:
        r = subprocess.run(
            ["git", "-C", str(root), "log", "--branches", "--not", "--remotes",
             "--oneline", "-1"],
            capture_output=True, text=True, timeout=8)
        if r.returncode != 0:
            return None
        return bool(r.stdout.strip())
    except (OSError, subprocess.SubprocessError):
        return None


def _root_age_days(root: Path) -> float | None:
    """Cheap staleness proxy from the dir's own mtime (no walk)."""
    try:
        mtime = root.stat().st_mtime
        return (datetime.now().timestamp() - mtime) / 86400.0
    except OSError:
        return None


def _load_overrides(audit_dir: Path) -> dict:
    p = audit_dir / OVERRIDES_FILE
    try:
        data = json.loads(p.read_text(encoding="utf-8")) if p.exists() else {}
    except (OSError, ValueError):
        return {}
    # accept either {"D:/path": {"verdict": "keep", "reason": ...}} or {"overrides": {...}}
    if isinstance(data, dict) and "overrides" in data and isinstance(data["overrides"], dict):
        data = data["overrides"]
    return data if isinstance(data, dict) else {}


def _norm_root(root: str) -> str:
    return str(root).replace("\\", "/").rstrip("/")


def build_record(inp: dict, overrides: dict) -> dict:
    """Build one advisory project record. inp keys: name, root, fp(dict|None),
    state(dict|None), decision."""
    name = inp.get("name") or Path(inp.get("root", "")).name
    root = inp.get("root", "")
    fp = inp.get("fp") or {}
    state = inp.get("state") or {}
    git_head = fp.get("git_head")
    is_git = bool(git_head)
    code_file_count = fp.get("code_file_count")
    # incomplete if scan errored (no fp) or we hit the cap
    scan_complete = fp != {} and (code_file_count is None or code_file_count < MAX_FP_FILES)
    if inp.get("decision") == "error":
        scan_complete = False

    evidence: list[dict] = []
    verdict = "keep"  # fail-safe default

    if is_git:
        unpushed = _git_unpushed(Path(root)) if root else None
        detail = f"tracked git repo, HEAD {git_head[:8]}"
        if unpushed:
            detail += ", local-only commits present"
        evidence.append({"signal": "git-repo", "detail": detail})
        git_unpushed = unpushed
    else:
        git_unpushed = None

    if not scan_complete:
        evidence.append({"signal": "incomplete-scan",
                         "detail": "scan capped/errored — forced keep (unknown is not deletion license)"})

    age_days = _root_age_days(Path(root)) if root else None

    # quarantine ONLY when every conservative signal lines up (advisory move/review)
    if (verdict == "keep" and not is_git and scan_complete
            and _QUARANTINE_NAME_RE.search(name)
            and (code_file_count is not None and code_file_count < 5)
            and (age_days is not None and age_days > STALE_DAYS)):
        verdict = "quarantine"
        evidence.append({
            "signal": "scratch-name+stale+empty",
            "detail": f"non-git, name matches scratch pattern, {code_file_count} code files, "
                      f"~{int(age_days)}d since dir mtime",
        })

    decided_by = "heuristic"
    ov = overrides.get(_norm_root(root)) or overrides.get(name)
    if isinstance(ov, dict) and ov.get("verdict") in ("keep", "quarantine"):
        verdict = ov["verdict"]  # human can only force keep/quarantine, never delete
        decided_by = "override"
        evidence.append({"signal": "human-override",
                         "detail": str(ov.get("reason", "owner override"))})

    return {
        "name": name,
        "root": _norm_root(root),
        "is_git": is_git,
        "git_head": (git_head[:8] if git_head else None),
        "git_unpushed": git_unpushed,
        "code_file_count": code_file_count,
        "scan_complete": scan_complete,
        "last_hardened": state.get("hardened_at"),
        "verdict": verdict,                 # keep | quarantine  (NEVER safe-delete)
        "evidence": evidence,
        "decided_by": decided_by,
        "decided_at": _now(),
    }


def export_audit(audit_inputs: list[dict], audit_dir: Path | None = None) -> str:
    """Build + atomically write projects-audit.json. Returns the path written.

    Never raises into the caller's critical path: callers should wrap, but this is
    also internally defensive.
    """
    audit_dir = Path(audit_dir) if audit_dir else AUDIT_DIR
    audit_dir.mkdir(parents=True, exist_ok=True)
    overrides = _load_overrides(audit_dir)

    records = []
    for inp in audit_inputs:
        try:
            records.append(build_record(inp, overrides))
        except Exception as e:  # one bad project never poisons the ledger
            records.append({
                "name": inp.get("name"), "root": _norm_root(inp.get("root", "")),
                "verdict": "keep", "scan_complete": False, "decided_by": "heuristic",
                "evidence": [{"signal": "record-error",
                              "detail": f"{type(e).__name__}: {e} — forced keep"}],
                "decided_at": _now(),
            })

    payload = {
        "generated_at": _now(),
        "generator": "hardness/audit.py export_audit v1",
        "scan_caps": {"max_fp_files": MAX_FP_FILES,
                      "note": "projects over cap / in ignored dirs / unreadable are "
                              "recorded verdict=keep with scan_complete=false"},
        "verdict_legend": {
            "keep": "do not move/delete; active or unknown",
            "quarantine": "ADVISORY review/move-to-staging only — NEVER delete without explicit human approval",
        },
        "safety": "safe-delete is never machine-emitted. Absence of a project here is NOT permission to delete.",
        "count": len(records),
        "projects": sorted(records, key=lambda r: (r.get("verdict") != "quarantine", r.get("name") or "")),
    }

    out = audit_dir / AUDIT_FILE
    tmp = audit_dir / (AUDIT_FILE + ".tmp")
    tmp.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    os.replace(tmp, out)  # atomic on same volume
    return str(out)
