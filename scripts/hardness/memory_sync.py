"""agentmemory sync — cross-project lessons only.

Boundary rule (hard): project *facts* live in .agent/ and never go to global
memory. Only generalized, cross-project *lessons* are synced to agentmemory,
and only when explicitly produced. This module fails gracefully if the
agentmemory service (localhost:3111) is unreachable — the engine never depends
on it.
"""
from __future__ import annotations

import json
import urllib.error
import urllib.request

DEFAULT_ENDPOINT = "http://localhost:3111"

# Patterns that mark something as a PROJECT FACT (must NOT be synced).
_FACT_SIGNALS = ("file ", "module ", "path ", "line ", "this project", "this repo",
                 "/", "\\", ".py", ".ts", ".js", ".go")


def is_cross_project_lesson(text: str) -> bool:
    """Heuristic guard: reject text that looks like a project-specific fact."""
    low = text.lower().strip()
    if len(low) < 12:
        return False
    # If it names concrete files/paths/modules, it's a project fact, not a lesson.
    concrete = sum(1 for sig in _FACT_SIGNALS if sig in low)
    return concrete <= 1


def _post(endpoint: str, path: str, payload: dict, timeout: float = 6.0) -> dict | None:
    url = endpoint.rstrip("/") + path
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST",
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            if resp.status not in (200, 201):
                return None
            body = resp.read().decode("utf-8", "replace")
            return json.loads(body) if body else {}
    except (urllib.error.URLError, OSError, ValueError):
        return None


def health(endpoint: str = DEFAULT_ENDPOINT) -> bool:
    try:
        with urllib.request.urlopen(endpoint.rstrip("/") + "/agentmemory/health",
                                    timeout=6.0) as resp:
            return resp.status == 200
    except (urllib.error.URLError, OSError):
        return False


def sync_lessons(lessons: list[str], project: str,
                 endpoint: str = DEFAULT_ENDPOINT, dry_run: bool = False) -> dict:
    """Sync only cross-project lessons. Returns a report.

    Rejected items (project facts) are reported, never sent.
    """
    accepted, rejected = [], []
    for raw in lessons:
        text = raw.strip()
        if is_cross_project_lesson(text):
            accepted.append(text)
        else:
            rejected.append(text)

    report = {
        "project": project,
        "accepted": accepted,
        "rejected_as_project_facts": rejected,
        "synced": 0,
        "endpoint": endpoint,
        "dry_run": dry_run,
        "reachable": False,
    }
    if dry_run or not accepted:
        report["reachable"] = health(endpoint)
        return report
    if not health(endpoint):
        report["error"] = "agentmemory unreachable; lessons NOT synced (engine continues)."
        return report

    report["reachable"] = True
    synced = 0
    for text in accepted:
        # tag clearly via concepts so global memory stays auditable and un-polluted
        payload = {
            "content": text,
            "type": "lesson",
            "concepts": ["project-hardness", "cross-project-lesson", project],
            "project": project,
        }
        res = _post(endpoint, "/agentmemory/remember", payload)
        if res is not None:
            synced += 1
    report["synced"] = synced
    return report
