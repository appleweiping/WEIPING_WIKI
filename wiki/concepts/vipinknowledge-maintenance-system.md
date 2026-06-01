---
title: VipinKnowledge Maintenance System
type: concept
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - vipin-wiki
  - maintenance
  - whole-computer
  - automation
  - skills
source_pages:
  - whole-computer-project-map
  - d-drive-project-map
  - local-active-project-roots
source_files:
  - .codex/skills/vipin-wiki/SKILL.md
  - .claude/skills/vipin-wiki/SKILL.md
  - scripts/wiki.py
  - scripts/wiki-maintain.ps1
---

# VipinKnowledge Maintenance System

## Purpose

EXTRACTED: `vipinknowledge` should function as a maintained whole-computer project map and durable knowledge system, not as a wiki that depends on a fresh prompt every time.

The maintenance system has three jobs:

- keep important project roots detailed enough for a future agent to start work safely
- keep low-value/system/cache/download roots summarized instead of over-reading them
- improve the `vipin-wiki` skill, scripts, and docs whenever maintenance becomes prompt-dependent
- coordinate with the shared `workstation-maintenance` skill when physical C:/D:/G: organization is required

## Defaults

EXTRACTED: The default maintenance policy is weekly automatic maintenance, safe auto commit and push, and shallow all-drive scanning.

| Decision | Default |
| --- | --- |
| Schedule | Weekly Tuesday afternoon local time |
| Model | `gpt-5.5` |
| Reasoning | `high` |
| Scan boundary | Shallow `C:/`, `D:/`, and `G:/` scan |
| Deep reads | Only important roots and only entry evidence |
| Commit policy | Commit and push scoped validated changes |
| Report storage | Ignored `.wiki-tmp/vipinknowledge-maintenance/` |
| Physical file moves | `workstation-maintenance` manifest plus user-approved batch; no broad deletion |

## Canonical Command Surface

The canonical dry-run/report command is:

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
```

It collects:

- git dirty summary
- agentmemory health
- shallow computer inventory
- wiki maintenance audit
- wiki health, lint, and catalog status
- recommendations for curated maintenance

The thin PowerShell wrapper is:

```powershell
powershell .\scripts\wiki-maintain.ps1 -Scope whole-computer -Json
```

## Skill Layer

EXTRACTED: Codex uses `.codex/skills/vipin-wiki/SKILL.md`; Claude Code and OpenCode can use `.claude/skills/vipin-wiki/SKILL.md`.

EXTRACTED: Physical drive organization is delegated to `D:/agent-resources/skills/vipin/workstation-maintenance`, which is exposed through `D:/devtools/codex/home/skills/workstation-maintenance` and `D:/devtools/claude/skills/workstation-maintenance` by local junctions.

The Codex skill is the full orchestrator. Its references split the recurring procedures:

- `whole-computer-depth.md` - importance tiers and evidence depth
- `weekly-maintenance-runbook.md` - recurring automation behavior
- `skill-upgrade-loop.md` - how to improve the skill itself
- `safety-and-automation.md` - public/private and commit/push gates
- `maintenance-model.md` - broad maintenance model

The shared workstation skill owns dry-run C:/D:/G: inventory manifests, risk classification, `D:/Research` resolved-path exclusion, type-grouped and age-gated user-approved move batches, rollback manifests, and devtools/agent-resources/vipinknowledge skill-link sync checks.

## Whole-Computer Routing

Use [[whole-computer-project-map]] first for all whole-computer maintenance. It decides how deeply to inspect each drive/root.

Use [[d-drive-project-map]] for D-drive infrastructure detail, [[local-active-project-roots]] for active non-research projects, [[local-project-roots]] for broader local roots, and [[research-project-workbench]] before repeated research project work.

Important roots should record path, purpose, current activity status, first-read files, safety boundary, related wiki pages, and last verified evidence. Low-value roots should stay as bucket summaries.

If the work involves moving files, generate the workstation manifest and conservative move plan first. Live move plans defer recent files and cap batch sizes by default; exact batches may be preflighted without moving files. Update wiki pages after dry-run evidence or after an approved batch changes the filesystem. Public pages should summarize bucket-level state and safety rules, not raw sensitive file names.

## Automation Contract

Automation may commit and push only after:

- `python scripts/wiki.py catalog`
- `python scripts/wiki.py lint`
- `python scripts/wiki.py health --json`
- `powershell .\scripts\Test-PrePushSafety.ps1`
- `git diff --check`

Automation must stage only scoped wiki/skill/script/doc changes. It must not stage unrelated dirty work, ignored report artifacts, workstation manifests, preflight manifests, move plans from `.wiki-tmp`, memory session dumps, raw private material, caches, generated runtime artifacts, or external project files.

EXTRACTED: Obvious same-session or cross-chat wiki/raw/memory/doc outputs should not be left behind just because they look like adjacent dirty work. If inspection shows they are deliberate, public-safe, validated, and part of the user's ongoing knowledge work, include them in a scoped commit. Hold them back only when they are source-unclear, sensitive, conflicting, incomplete, external-project edits, or validation-failing.

If validation fails, the automation stops before commit/push and leaves the report for a future agent.

## Counterpoints And Gaps

- The system is intentionally not a full-disk deep crawler; deep crawling would be slower, noisier, and riskier around private material.
- The maintenance command produces evidence and recommendations, but curated wiki/skill edits still require agent judgment.
- Whole-computer maps can drift as folders move or projects become active; future agents should rescan live evidence before making current-state claims.
- CC-family review may be unavailable if local partner tooling or upstream credentials are down; in that case Codex should state the limitation and perform a bounded self-review.

## Related

- [[whole-computer-project-map]]
- [[d-drive-project-map]]
- [[local-active-project-roots]]
- [[local-project-roots]]
- [[agentmemory-first-agent-collaboration]]
- [[implicit-skill-routing]]
- [[agent-skill-installation-workflow]]
