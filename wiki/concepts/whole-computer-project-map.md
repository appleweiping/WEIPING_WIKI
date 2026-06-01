---
title: Whole-Computer Project Map
type: concept
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - local-projects
  - computer-map
  - maintenance
  - vipin-wiki
source_pages:
  - AGENTS.md
  - d-drive-project-map
  - local-project-roots
source_files:
  - scripts/computer-inventory.ps1
---

# Whole-Computer Project Map

## Rule

EXTRACTED: Future agents should read this page first for whole-computer maintenance, project routing, old-content refresh, or local file-organization work.

This page is a routing map, not permission to edit every drive. It tells agents where to look, how deeply to inspect, and which boundaries must stay intact.

## Current Machine Shape

EXTRACTED: A shallow inventory on 2026-06-01 found three filesystem drives: `C:/`, `D:/`, and `G:/`.

| Drive/root | Role | Default depth |
| --- | --- | --- |
| `C:/` | Windows system drive, installed applications, user profile entrypoints, and junctions into D-drive agent homes. | Shallow. Do not reorganize system/app folders. Inspect only explicit user-profile or launcher paths. |
| `C:/Users/admin` | User profile with many tool dotfolders; `.claude`, `.codex`, and `.openhands` are junctions into `D:/devtools`. | Medium for junction routing; shallow for personal/tool state unless explicitly asked. |
| `D:/` | Primary workspace for agent infrastructure, knowledge base, research, projects, portfolios, games, healthcare, coursework, media, and caches. | Detailed for active roots; bucket summaries for archives/system/cache/media. |
| `G:/` | Google Drive-style cloud drive rooted at `G:/我的云端硬盘`. | Shallow. Treat as synced/cloud material; inspect only when explicitly relevant. |

## Importance-Based Depth

| Tier | What qualifies | Wiki treatment |
| --- | --- | --- |
| Tier 0: operating contract | `vipin wiki`, `AGENTS.md`, skill roots, agentmemory, `D:/devtools`, `D:/agent-resources`, `D:/devtools-public` | Detailed routing, current commands, safety gates, update rules, related pages, validation status. |
| Tier 1: active projects | Research workbenches, active product/app/game/healthcare/company roots, current public exports | Dedicated entity/topic page or refreshed section with purpose, root, status, entry docs, safety boundary, last verified date. |
| Tier 2: useful archives | Portfolio, coursework, study archives, old project roots, media packages, local backups | Public-safe summary of content nature, discovery clues, and edit caution. |
| Tier 3: bulk/system/noise | OS folders, caches, downloads, package stores, toolchains, virtual machines, temp dirs, binaries | One-line bucket summary unless the user asks for storage cleanup or a specific file. |
| Private/sensitive | Credentials, account state, raw private docs/chats, medical/financial/personal records | Private-only minimal metadata or no public record. Never expose raw contents in public pages. |

When uncertain, start shallow. Promote a root to more detail only after live evidence shows repeated use, active work, or high consequence.

## Tier 0 Roots

| Root | Purpose | First files/pages |
| --- | --- | --- |
| `D:/Research/vipin's knowledgebase` | `vipin wiki`, the maintained public crystallization layer and agent operating contract. | `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, this page, `wiki/index.md`, `wiki/log.md`. |
| `D:/devtools` | Private local agent workstation: launchers, agent homes, runtimes, logs, caches, health checks. | Private README/ignore policy; public-safe summary in [[d-drive-project-map]]. |
| `D:/devtools-public` | Clean public export of safe launchers, docs, templates, and safety checks. | README, safety gate scripts, Git tags. |
| `D:/agent-resources` | Public curated skill/resource library and implicit skill-routing index. | README, `SKILL-INDEX.md`, provenance/license notes. |
| `C:/Users/admin/.claude`, `C:/Users/admin/.codex`, `C:/Users/admin/.openhands` | Junction entrypoints into D-drive agent homes. | Verify junction target before changing agent storage. |

For active non-research project roots with more detailed entry docs, use [[local-active-project-roots]].

## D-Drive Working Roots

| Bucket | Examples | Rule |
| --- | --- | --- |
| Agent infrastructure | `D:/devtools`, `D:/devtools-public`, `D:/agent-resources`, `D:/.claude` | Keep runtime/log/cache/auth out of public Git; use [[d-drive-project-map]] for details. |
| Research workbench | `D:/Research` | Route through [[research-project-workbench]]. Do not touch experiments during general maintenance. |
| Product/app/project roots | `D:/Project`, `D:/frontend`, `D:/CS project`, `D:/Company`, `D:/Idea` | Rescan live README/config/status before claims or edits. Create pages only for repeated/active projects. |
| Healthcare roots | `D:/Healthcare` | Treat code and test data conservatively; avoid exposing health-sensitive material. |
| Game roots | `D:/Game_develop`, `D:/Terraria_doc`, `D:/girlvania` | Keep binaries/saves/assets outside public pages; record routing and content nature. |
| Portfolio/course archives | `D:/WeipingYan_portfolio`, `D:/Academic_portfolio`, `D:/Undergraduate_project_netherlands`, `D:/Undergraduate_study_netherlands`, `D:/tuelearning` | Public-safe metadata only unless explicitly asked. |
| Media/download/cache/system bulk | `D:/BaiduNetdiskDownload`, `D:/video creation`, `D:/微信`, `D:/Docker`, `D:/VirtualBox`, `D:/temp`, `.pnpm-store` | Bucket summaries by default. Cleanup requires explicit storage-maintenance scope. |

## C-Drive Handling

EXTRACTED: `C:/` holds Windows, installed applications, tool remnants, temporary folders, and user-profile entrypoints. It is not the canonical home for agent data.

- Do not install agent tools, models, caches, or bulk data directly onto `C:/` when a D-drive location is available.
- Before changing agent config from `C:/Users/admin`, check whether the path is a junction into `D:/devtools`.
- Treat Windows, Program Files, Python/MinGW/system tool folders, Xbox/game install roots, and DLL/log remnants as system/tooling buckets unless the user asks for a specific fix.

## Maintenance Loop

For whole-computer upkeep:

1. Run or mentally apply `scripts/computer-inventory.ps1` for a shallow map.
2. Identify the target tier and bucket before opening files.
3. Read existing wiki pages first: this page, [[d-drive-project-map]], [[local-project-roots]], and the relevant entity/topic page.
4. Inspect the smallest live evidence that proves current state.
5. Refresh existing pages before creating new ones.
6. Mark stale or superseded content instead of deleting useful history.
7. Run `scripts/wiki-maintenance-audit.ps1` when the task is about stale content or broad upkeep.
8. Update `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.
9. Validate, then stage only scoped files.

## Old-Content Refresh Triggers

Refresh pages when paths, project status, operating rules, public/private risk, or source-of-truth files have changed; when a page is too vague for future routing; or when several pages duplicate the same project state.

Deletion still requires explicit user approval. Most old content should be rewritten, archived, superseded, or retargeted.

## Safety Boundaries

- Do not modify research experiment code, datasets, checkpoints, logs, result files, or active experiment progress during general wiki/computer maintenance.
- Do not publish secrets, tokens, raw private chats, credentials, browser profiles, account state, DBs, logs, or sensitive private documents.
- Do not move external folders as part of wiki maintenance unless the user explicitly asks for file organization and the target scope is clear.
- Use live repo instructions before editing any external project.

## Counterpoints And Gaps

- This page is based on shallow top-level inventory, not a full content crawl.
- Important D-drive roots need periodic detail refresh as project activity changes.
- Cloud-drive contents under `G:/` are intentionally not inventoried here.

## Related

- [[d-drive-project-map]]
- [[local-active-project-roots]]
- [[local-project-roots]]
- [[research-project-workbench]]
- [[agentmemory-first-agent-collaboration]]
- [[implicit-skill-routing]]
