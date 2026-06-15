"""task-hardening: turn a vague requirement into a hardened task spec.

Given a free-text requirement and a hardened ProjectModel, produce a task
spec with: clarified goal, involved modules, likely edit paths, risk points,
acceptance criteria, and test commands. Written to .agent/tasks/<id>.md.

This is deliberately heuristic and transparent — it surfaces candidates and
the agent (or user) refines them. It never guesses silently: low-confidence
matches are labeled.
"""
from __future__ import annotations

import datetime as _dt
import json
import re
from pathlib import Path

from .analyzer import blast_radius
from .model import ProjectModel

_STOP = set("a an the of to for and or in on with into from this that these those "
            "add new make change update fix support feature please can we i need want "
            "should would like able implement create build set get use using via".split())


def _keywords(text: str) -> list[str]:
    words = re.findall(r"[A-Za-z_][A-Za-z0-9_]{2,}", text.lower())
    seen, out = set(), []
    for w in words:
        if w in _STOP or w in seen:
            continue
        seen.add(w)
        out.append(w)
    return out


def _score_module(m, keywords: list[str]) -> int:
    hay = " ".join([m.name, m.responsibility, " ".join(m.public_symbols),
                    " ".join(m.files)]).lower()
    return sum(hay.count(k) for k in keywords)


def _detect_test_cmd(model: ProjectModel) -> list[str]:
    cmds: list[str] = []
    langs = set(model.primary_languages)
    fws = " ".join(model.frameworks).lower()
    if "python" in langs:
        cmds.append("pytest -q   # or: python -m pytest <path>")
    if {"javascript", "typescript"} & langs:
        cmds.append("npm test   # or: pnpm test / yarn test")
    if "go" in langs:
        cmds.append("go test ./...")
    if "rust" in langs:
        cmds.append("cargo test")
    if not cmds:
        cmds.append("# No standard test runner auto-detected — verify manually.")
    return cmds


def harden_task(model: ProjectModel, requirement: str, task_id: str | None = None) -> dict:
    keywords = _keywords(requirement)
    scored = sorted(((m, _score_module(m, keywords)) for m in model.modules),
                    key=lambda kv: kv[1], reverse=True)
    hits = [(m, s) for m, s in scored if s > 0][:6]
    involved = [m for m, _ in hits] or [m for m, _ in scored[:3]]
    low_conf = not any(s > 0 for _, s in hits)

    # edit paths
    edit_paths: list[str] = []
    for m in involved[:4]:
        edit_paths.extend(m.files[:3])
    edit_paths = sorted(set(edit_paths))[:12]

    # risk points: blast radius of involved modules + matched constraints
    risks: list[str] = []
    impacted_tests: set[str] = set()
    for m in involved[:4]:
        br = blast_radius(model, m.name)
        if br["impacted_total"] >= 3:
            risks.append(f"`{m.name}` is high-blast: ~{br['impacted_total']} modules depend on it "
                         f"(dependents: {', '.join(br['direct_dependents'][:5]) or 'n/a'}).")
        impacted_tests.update(br["related_tests"])
    for c in model.constraints:
        if any(k in c.scope.lower() or k in c.rule.lower() for k in keywords) or \
           any(m.name in c.scope for m in involved):
            risks.append(f"[{c.severity}] {c.rule} (source: {c.source})")
    if not risks:
        risks.append("No high-blast modules or constraints matched. Re-verify scope before editing.")

    # entities touched
    entities = sorted({e.name for e in model.entities
                       for m in involved if m.name in e.touched_by})

    tid = task_id or _dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    spec = {
        "id": tid,
        "created_at": _dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "requirement": requirement,
        "clarified_goal": _clarify(requirement, involved, entities),
        "keywords": keywords,
        "match_confidence": "LOW (no keyword hits — review manually)" if low_conf else "INFERRED",
        "involved_modules": [{"name": m.name, "responsibility": m.responsibility} for m in involved],
        "edit_paths": edit_paths,
        "entities_touched": entities,
        "risk_points": risks,
        "acceptance_criteria": _acceptance(requirement, involved),
        "test_commands": _detect_test_cmd(model),
        "related_tests": sorted(impacted_tests),
    }
    return spec


def _clarify(requirement: str, involved, entities) -> str:
    mods = ", ".join(m.name for m in involved[:4]) or "the codebase"
    ent = f" affecting entities: {', '.join(entities[:4])}" if entities else ""
    return (f"Deliver: '{requirement.strip()}'. Likely localized to {mods}{ent}. "
            f"Confirm scope and behavior with existing tests before changing code.")


def _acceptance(requirement: str, involved) -> list[str]:
    return [
        f"Requirement satisfied: {requirement.strip()}",
        "All existing tests still pass (no regressions in dependents).",
        "New behavior covered by at least one new/updated test.",
        f"No edits to files marked `block` in constraints.md.",
        "Build/lint passes for the affected modules.",
    ]


def render_task_md(spec: dict) -> str:
    out = [f"# Hardened Task — {spec['id']}\n",
           f"> Created {spec['created_at']} · match confidence: {spec['match_confidence']}\n",
           "## Original requirement\n", f"> {spec['requirement']}\n",
           "## Clarified goal\n", spec["clarified_goal"], "",
           "## Involved modules\n"]
    for m in spec["involved_modules"]:
        out.append(f"- `{m['name']}` — {m['responsibility']}")
    out.append("\n## Likely edit paths\n")
    out += [f"- `{p}`" for p in spec["edit_paths"]] or ["- _none inferred_"]
    if spec["entities_touched"]:
        out.append("\n## Entities touched\n")
        out += [f"- {e}" for e in spec["entities_touched"]]
    out.append("\n## Risk points\n")
    out += [f"- {r}" for r in spec["risk_points"]]
    out.append("\n## Acceptance criteria\n")
    out += [f"- [ ] {c}" for c in spec["acceptance_criteria"]]
    out.append("\n## Test commands\n```\n" + "\n".join(spec["test_commands"]) + "\n```")
    if spec["related_tests"]:
        out.append("\n## Related test modules\n")
        out += [f"- `{t}`" for t in spec["related_tests"]]
    out.append("\n---\n_Generated by project-hardness task-hardening. Refine before executing._\n")
    return "\n".join(out)


def write_task(agent_dir: Path, spec: dict) -> Path:
    tasks_dir = agent_dir / "tasks"
    tasks_dir.mkdir(parents=True, exist_ok=True)
    md_path = tasks_dir / f"{spec['id']}.md"
    md_path.write_text(render_task_md(spec), encoding="utf-8")
    (tasks_dir / f"{spec['id']}.json").write_text(
        json.dumps(spec, ensure_ascii=False, indent=2), encoding="utf-8")
    return md_path
