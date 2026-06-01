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
| `C:/` | Windows system drive, installed applications, user profile entrypoints, and junctions into D-drive agent homes. | Inventory/classify broadly but move narrowly. Do not reorganize system/app folders; physical moves require `workstation-maintenance` batches. |
| `C:/Users/admin` | User profile with many tool dotfolders; `.claude`, `.codex`, and `.openhands` are junctions into `D:/devtools`. | Medium for junction routing; shallow for personal/tool state unless explicitly asked. |
| `D:/` | Primary workspace for agent infrastructure, knowledge base, research, projects, portfolios, games, healthcare, coursework, media, and caches. | Detailed for active roots; bucket summaries for archives/system/cache/media. |
| `G:/` | Google Drive-style cloud drive rooted at `G:/我的云端硬盘`. | Shallow. Treat as synced/cloud material; inspect only when explicitly relevant. |

## Latest Workstation Organization Pass

EXTRACTED: On 2026-06-01, `workstation-maintenance` generated a fresh local inventory under ignored `.wiki-tmp/workstation-maintenance/`. Before movement, it recorded 2,992 classified entries and 669 low-risk move-eligible file candidates. The conservative move plan applied a 30-day age gate and 100-item batch cap, leaving 531 executable approval candidates across 13 narrow batches and deferring 138 recent candidates for review. `D:/Research` entries were 0, and executable reparse points, directories, git worktree items, and files modified within 30 days were all 0.

Public-safe batch summary:

| Batch ID | Category | Items | Size | Destination root |
| --- | --- | ---: | ---: | --- |
| `batch-downloads-archives-old` | Downloads archives | 59 | 55.39 MB | `D:/_Organized` |
| `batch-downloads-code-old` | Downloads code/config | 6 | 18.03 KB | `D:/_Organized` |
| `batch-downloads-installers-old` | Downloads installers | 1 | 29.85 KB | `D:/_Organized` |
| `batch-downloads-markdown-old-part-001` | Downloads markdown | 100 | 1.36 MB | `D:/_Organized` |
| `batch-downloads-markdown-old-part-002` | Downloads markdown | 37 | 428.72 KB | `D:/_Organized` |
| `batch-downloads-media-old` | Downloads media | 1 | 10.82 KB | `D:/_Organized` |
| `batch-downloads-notebooks-old` | Downloads notebooks | 7 | 658.95 KB | `D:/_Organized` |
| `batch-downloads-office-data-old` | Downloads office/data | 38 | 65.41 MB | `D:/_Organized` |
| `batch-downloads-other-old` | Downloads other | 5 | 346.46 KB | `D:/_Organized` |
| `batch-downloads-pdf-old-part-001` | Downloads PDFs | 100 | 94.02 MB | `D:/_Organized` |
| `batch-downloads-pdf-old-part-002` | Downloads PDFs | 100 | 60.41 MB | `D:/_Organized` |
| `batch-downloads-pdf-old-part-003` | Downloads PDFs | 45 | 17.52 MB | `D:/_Organized` |
| `batch-mediaassets-old` | MediaAssets | 32 | 11.51 MB | `D:/_Organized` |

EXTRACTED: The user granted broad approval on 2026-06-01 to proceed without further trivial per-batch prompts. After a fresh all-batch non-moving preflight passed, all 13 batches were executed. The applied summary records 531 moved files, about 307.08 MB, into `D:/_Organized/Downloads` and `D:/_Organized/Media`. Post-move verification found 531 original sources absent, 531 moved destinations present, and 0 applied paths under `D:/Research`.

EXTRACTED: A post-move inventory on 2026-06-01 recorded 2,465 classified entries and 138 remaining move-eligible candidates. A fresh post-move move plan produced 0 executable batches and deferred all 138 recent candidates under the 30-day age gate. `D:/Research` entries remained 0, and move-eligible reparse points, directories, and git worktree items remained 0.

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
| `D:/agent-resources/skills/vipin/workstation-maintenance` | Shared skill for C:/D:/G: inventory, classification, batch-approved moves, rollback, and agent-infrastructure sync. | Read `SKILL.md`; dry-run first; broad user approval may cover all current low-risk preflighted batches. |

For active non-research project roots with more detailed entry docs, use [[local-active-project-roots]].

## D-Drive Working Roots

| Bucket | Examples | Rule |
| --- | --- | --- |
| Agent infrastructure | `D:/devtools`, `D:/devtools-public`, `D:/agent-resources`, `D:/.claude` | Keep runtime/log/cache/auth out of public Git; use [[d-drive-project-map]] for details. |
| Research workbench | `D:/Research` | Route through [[research-project-workbench]]. Do not touch experiments during general maintenance. |
| Organized low-risk files | `D:/_Organized/Downloads`, `D:/_Organized/Media` | Current target for applied low-risk workstation moves; keep rollback manifests in ignored `.wiki-tmp` if reversal is needed. |
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
- For broad C-drive cleanup, include C-drive paths in the dry-run inventory but move only manifest-listed, low-risk, user-approved batches. Broad approval can cover all currently preflighted low-risk batches, but Research/no-delete/reparse/git/age-gate checks still apply. Sensitive user downloads should be classified locally and summarized publicly only at bucket level.

## Maintenance Loop

For whole-computer upkeep:

1. Run or mentally apply `scripts/computer-inventory.ps1` for a shallow map.
2. Identify the target tier and bucket before opening files.
3. For physical file organization, use `D:/agent-resources/skills/vipin/workstation-maintenance` to generate the dry-run manifest and type-grouped, age-gated move plan. Run `Test-MovePlanBatches.ps1` for a full non-moving readiness check or `Invoke-ApprovedMoveBatch.ps1 -PreflightOnly` for an exact batch before approval. If the user grants broad approval, execute all currently passing low-risk batches without repeated per-batch prompts. Never include `D:/Research` resolved paths.
4. Read existing wiki pages first: this page, [[d-drive-project-map]], [[local-project-roots]], and the relevant entity/topic page.
5. Inspect the smallest live evidence that proves current state.
6. Refresh existing pages before creating new ones.
7. Mark stale or superseded content instead of deleting useful history.
8. Run `scripts/wiki-maintenance-audit.ps1` when the task is about stale content or broad upkeep.
9. Update `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.
10. Validate, then stage only scoped files.

## Old-Content Refresh Triggers

Refresh pages when paths, project status, operating rules, public/private risk, or source-of-truth files have changed; when a page is too vague for future routing; or when several pages duplicate the same project state.

Deletion still requires explicit user approval. Most old content should be rewritten, archived, superseded, or retargeted.

## Safety Boundaries

- Do not modify research experiment code, datasets, checkpoints, logs, result files, or active experiment progress during general wiki/computer maintenance.
- Do not move or delete any `D:/Research` resolved path during workstation organization.
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
