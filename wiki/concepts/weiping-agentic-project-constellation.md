---
title: WEIPING Agentic Project Constellation
type: concept
status: active
created: 2026-06-04
updated: 2026-06-04
tags:
  - weiping-wiki
  - agent-infrastructure
  - project-routing
  - low-coupling
source_pages:
  - weiping-wiki-maintenance-system
  - whole-computer-project-map
  - d-drive-project-map
source_files:
  - D:/Research/WEIPING_LAB/README.md
  - D:/Research/WEIPING_COUNCIL/README.md
  - D:/AGENT_RESOURCE/README.md
  - D:/AGENTIC_SCIENCE/README.md
---

# WEIPING Agentic Project Constellation

## Purpose

This page routes the local agentic infrastructure projects that should be maintained together but not fused into one high-coupling system.

## Root Map

| Canonical root | Compatibility alias | Role | First-read evidence |
| --- | --- | --- | --- |
| `D:/Research/WEIPING_WIKI` | `D:/Research/vipin's knowledgebase` | Public knowledge system, operating contract, project map, maintenance automations, and skill rules. | `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `.codex/skills/vipin-wiki/SKILL.md` |
| `D:/devtools` | `C:/Users/admin/.codex`, `C:/Users/admin/.claude`, other user-profile junctions | Private local agent runtime, Codex/Claude homes, automations, launchers, caches, health checks. | `AGENTS.md`, `README.md`, `health-check.ps1`, `codex/home/automations/` |
| `D:/DELVTOOLS_PUBLIC` | `D:/devtools-public`, GitHub `devtools-public` | Public-safe export of selected devtools docs and scripts. | `AGENTS.md`, `README.md`, `docs/`, safety scripts |
| `D:/AGENT_RESOURCE` | `D:/agent-resources` | Shared skill/resource library and implicit routing index. | `AGENTS.md`, `README.md`, `SKILL-INDEX.md`, `docs/skill-provenance-audit-*.md` |
| `D:/AGENTIC_SCIENCE` | none observed | Workflow factory repo; source for UUPF, URWF, and LWWF packs. | `README.md`, `AGENTS.md`, `uupf/UniversalUpgradeForge.zip` |
| `D:/Research/WEIPING_LAB` | `D:/Research/vipin-lab` | Honest research workbench for phenomenon-driven discovery, kill-first ideation, experiment planning, evidence-gated writing, and cross-model audit. | `AGENTS.md`, `README.md`, `CLAUDE.md`, `.codex/skills/weiping-lab/SKILL.md`, `pyproject.toml` |
| `D:/Research/WEIPING_COUNCIL` | `D:/Research/vipin-council` | Multi-model deliberation runtime and council/review companion. | `AGENTS.md`, `README.md`, `CLAUDE.md`, `.codex/skills/weiping-council/SKILL.md`, `pyproject.toml` |

## Compatibility Junctions

EXTRACTED: The local path `D:/Research/vipin's knowledgebase` is a junction to `D:/Research/WEIPING_WIKI`; `D:/Research/vipin-lab` is a junction to `D:/Research/WEIPING_LAB`; `D:/Research/vipin-council` is a junction to `D:/Research/WEIPING_COUNCIL`; and `D:/agent-resources` is a junction to `D:/AGENT_RESOURCE`.

EXTRACTED: `D:/Research/WEIPING_WIKI/skill` points to `D:/agent-resources/skills/vipin`. Codex and Claude workstation-maintenance skill exposures in `D:/devtools` point to `D:/agent-resources/skills/vipin/workstation-maintenance`.

## Relationship Model

- EXTRACTED: `WEIPING_LAB` names `WEIPING_COUNCIL` as its companion review/council layer.
- EXTRACTED: `WEIPING_COUNCIL` describes `WEIPING_LAB` as a broader lab/workbench layer that can consume council session artifacts, while council remains runnable on its own.
- EXTRACTED: `WEIPING_LAB` handoff artifacts include workspace session, idea, plan, paper, experiment-plan/tracker, result JSON, and redacted outbox files under the configured workspace root.
- EXTRACTED: `WEIPING_COUNCIL` handoff artifacts are saved session JSON files under `data/sessions/<uuid>.json`, but those saved sessions remain runtime state unless deliberately curated.
- EXTRACTED: `AGENT_RESOURCE` is the shared skill and workflow library; `D:/agent-resources` is a compatibility junction.
- EXTRACTED: `AGENTIC_SCIENCE` contains UUPF, which can produce offline 108-pass upgrade audits for skills and docs. The observed local UUPF ZIP SHA256 was `7DC22DA85DEFFE106C8D44114E047AD9D25BE35BE926A7A88B76D82B424F445A`.
- INFERRED: WEIPING_WIKI is the router and durable map; it should know how these projects relate but should not become their runtime dependency manager.

## Low-Coupling Rules

Good links:

- route pages and aliases in `wiki/`
- optional environment variables such as `WEIPING_WIKI_ROOT` or `AGENTMEMORY_URL`
- documented artifact contracts and import/export commands
- skill references and validation commands
- public-safe status summaries

Forbidden coupling:

- requiring another repo's `.env`, local DB, browser profile, cache, generated report, or active workspace to start
- copying secrets, raw data, private logs, UUPF run folders, or experiment outputs across repos
- treating a generated audit as proof of project state without live evidence
- changing external project files during general wiki maintenance

## Maintenance Use

During weekly maintenance, inspect only entry evidence and git status for these roots unless the user explicitly asks for project work. Update WEIPING_WIKI maps, skill references, and automation prompts when relationships, aliases, or safety gates change.

## Counterpoints And Gaps

- This page is a routing map, not a full architecture audit of every listed repository.
- Junction and alias state can drift; verify live paths before editing or making current-state claims.
- UUPF reports are useful pressure tests but do not replace manual review, local tests, and public/private safety gates.
- `WEIPING_LAB` and `WEIPING_COUNCIL` may evolve faster than the wiki map; trust their current repo-local docs for implementation work.

## Related

- [[weiping-wiki-maintenance-system]]
- [[whole-computer-project-map]]
- [[d-drive-project-map]]
- [[local-active-project-roots]]
