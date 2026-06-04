---
title: D-Drive Project Map
type: concept
status: active
created: 2026-06-01
updated: 2026-06-04
tags:
  - local-projects
  - d-drive
  - agent-workflow
  - infrastructure
source_pages:
  - AGENTS.md
  - README.md
---

# D-Drive Project Map

## Rule

EXTRACTED: Future agents should use this page as the first public-safe routing map before making D-drive infrastructure or project-organization changes.

This map is not a permission slip to edit everything on D drive. It is a routing layer that separates agent infrastructure, public exports, private runtime state, and research workbenches.

For whole-computer routing across `C:/`, `D:/`, `G:/`, user-profile junctions, active projects, archives, and low-detail system/cache buckets, start with [[whole-computer-project-map]] and use this page for D-drive infrastructure detail.

## Agent Infrastructure

| Path | Role | Edit policy |
| --- | --- | --- |
| `D:/devtools` | Private local agent workstation: launchers, agent homes, runtimes, caches, logs, local health checks. | Edit only scoped infrastructure files. Keep runtime/log/cache/auth/db local and ignored. |
| `D:/devtools-public` | Public-safe export of selected launchers, examples, docs, and safety checks. | Public repo. Run safety/history/pre-push gates before tag, commit, or push. |
| `D:/AGENT_RESOURCE` / `D:/agent-resources` | Public curated skill/resource library and implicit skill-routing index. The lowercase path is a compatibility junction. | Public repo. Commit only provenance-cleared skills and docs. Keep unknown-license packs local-only. |
| `D:/AGENTIC_SCIENCE` | Public agentic-science method repo. Currently contains UUPF, the Universal Upgrade Forge 108-pass audit/upgrade engine. | Treat UUPF as audit/planning evidence. Do not publish raw generated run reports without curation. |
| `D:/Research/WEIPING_WIKI` / `D:/Research/vipin's knowledgebase` | `WEIPING_WIKI` / `Weiping Wiki`: public operating contract and durable knowledge layer. The older path is a compatibility junction. Historical aliases: `vipin wiki`, `vipinknowledge`, `vipin-wiki`. | Maintain `wiki/`, adapters, index, log, and validation; keep the private wiki layer out of Git. |
| `D:/Research/WEIPING_LAB` / `D:/Research/vipin-lab` | Honest research workbench for project artifacts, evidence packets, validations, and research-state operations. | Route through its own README/skill before claims or edits. Do not make wiki maintenance depend on its private runtime state. |
| `D:/Research/WEIPING_COUNCIL` / `D:/Research/vipin-council` | Multi-model deliberation runtime and companion review layer for research/lab artifacts. | Route through its own README/skill. Keep handoffs artifact-based and avoid hidden runtime coupling. |
| `D:/agent-resources/skills/vipin/workstation-maintenance` | Shared workstation maintenance skill for inventory, classification, approved move batches, rollback, and cross-agent infrastructure sync. | Source of truth for physical C:/D:/G: organization workflow; exposed into Codex/Claude homes by local junctions. |

## Active Agent Substrate

| Component | Current rule |
| --- | --- |
| agentmemory | Active operational memory, signals, actions, checkpoints, and diagnostics. |
| Agent Hub | Deprecated historical experiment; do not start, register, or depend on it for new work. |
| Skills | Trigger by task intent. Inspect metadata, read matched `SKILL.md`, then act. |
| Workstation maintenance | Use shared `workstation-maintenance` for physical drive organization; use `weiping-wiki` for public-safe maps and logs. `vipin-wiki` remains a historical alias. |
| UUPF | Use `D:/AGENTIC_SCIENCE/uupf/UniversalUpgradeForge.zip` only as a planning/audit forge for skill and workflow upgrades. Run offline reports into ignored `.wiki-tmp/` and manually curate accepted changes. |
| Git | Source-of-truth for file changes. Stage only scoped files and preserve unrelated dirty work. |

## Agentic Project Constellation

EXTRACTED: The current high-importance agentic roots form a constellation, not a monorepo. Keep their routes and handoff expectations tight, but keep implementation coupling low.

- `WEIPING_WIKI` records public-safe maps, rules, aliases, first-read docs, and validation gates.
- `D:/devtools` stores private local agent homes, launchers, automation TOMLs, runtime caches, and local configuration.
- `D:/AGENT_RESOURCE` publishes reusable skills and resource indexes for multiple agents.
- `D:/AGENTIC_SCIENCE` publishes UUPF and related agentic-science methods used to audit skills/workflows.
- `D:/Research/WEIPING_LAB` owns research-workbench execution and evidence packets.
- `D:/Research/WEIPING_COUNCIL` owns deliberation/review workflows around artifacts.

Good links are stable paths, aliases, README/AGENTS/skill entrypoints, artifact formats, optional environment variables, and validation commands. Bad links are copied private configs, required local DB/cache state, generated UUPF run directories, hidden secrets, or edits to one repo merely because another repo was inspected.

## Public And Private Boundaries

- Public-safe knowledge goes into `wiki/`, `agent-resources`, or `devtools-public`.
- Secrets, API keys, credentials, private chats, private account state, logs, SQLite DBs, session histories, browser profiles, caches, generated bulky artifacts, and local runtimes stay out of public Git.
- Private notes can live under ignored private paths when needed, but public pages should contain only masked fingerprints and operational conclusions.

## Research Isolation

Research repositories under `D:/Research` are not part of infrastructure cleanup. Agents must not move, rewrite, stage, or "tidy" experiment code, datasets, checkpoints, server logs, result files, or active experiment state while working on agent infrastructure.

Use [[research-project-workbench]] before opening a repeated research project. Then rescan the live target repo and follow its own instructions.

## D-Drive Organization Buckets

EXTRACTED: On 2026-06-01, a drive-root `workstation-maintenance` plan classified 52 immediate `D:/` children and completed 25 move-with-junction root moves into `D:/_Organized/<bucket>/_RootDirs/...`. The old root paths remain usable as NTFS junctions. Five classified roots remain physically at `D:/` because Windows denied access or the roots appeared locked; they should be retried only after the lock or ACL issue is resolved.

| Bucket | Examples | Rule |
| --- | --- | --- |
| Agent infrastructure | `D:/devtools`, `D:/devtools-public`, `D:/AGENT_RESOURCE` / `D:/agent-resources`, `D:/AGENTIC_SCIENCE` | Keep D-drive-first; separate public source, reusable methods, and private runtime. |
| Knowledge base | `D:/Research/WEIPING_WIKI` / `D:/Research/vipin's knowledgebase` | WEIPING_WIKI public wiki plus ignored private layer. |
| Research/agentic workbenches | `D:/Research/WEIPING_LAB`, `D:/Research/WEIPING_COUNCIL` | High-importance roots with their own operating docs; link by artifacts and route pages, not by private runtime state. |
| Research workbench | `D:/Research/*` project repos | Isolate from infra cleanup; modify only on explicit research task. |
| Approved organization target | `D:/_Organized/Downloads`, `D:/_Organized/Media`, `D:/_Organized/Temp-Review`, `D:/_Organized/Coursework`, `D:/_Organized/Documents-Private`, `D:/_Organized/Games`, `D:/_Organized/Tools-Review` | Active target populated by approved `workstation-maintenance` batches and D-root move-with-junction organization on 2026-06-01; use ignored applied manifests for rollback if needed. Future use still goes through manifest/preflight gates. |
| Portfolio/course archives | Moved roots under `D:/_Organized/Coursework/_RootDirs` and `D:/_Organized/Documents-Private/_RootDirs`; locked exceptions remain at `D:/` | Record public-safe metadata only unless explicitly asked. Old `D:/<name>` paths may be junctions and remain valid. |
| Product/game/health roots | `D:/Project`, `D:/Game_develop`, `D:/Healthcare` | Rescan live roots before claims or edits. |
| Media/download/cache/system bulk | moved download/media/temp/tool roots under `D:/_Organized`; protected system roots such as Docker, VirtualBox, Program Files, pagefile, and `.pnpm-store` remain record-only | Do not publish raw contents; cleanup only with explicit storage-maintenance scope. |

## Startup Use

For D-drive tasks:

1. Read this map.
2. Identify the target bucket.
3. Check the target repo's `git status`.
4. Load relevant skill metadata and read the matched `SKILL.md`.
5. For physical moves, generate a `workstation-maintenance` manifest or D-root organization plan and run the relevant preflight. If the user gives broad approval, execute all currently passing low-risk batches without repeated per-batch prompts. For D-root directory moves, preserve old paths as junctions and record locked roots as classified exceptions.
6. Keep changes inside the requested bucket and validate before commit/push.

## Counterpoints And Gaps

- This is a routing map, not a complete D-drive inventory.
- Exact folder names and project states can drift; rescan the live target before editing or making current-state claims.
- Private-only details should stay in ignored private notes and should not be expanded into this public page.

## Related

- [[whole-computer-project-map]]
- [[agentmemory-first-agent-collaboration]]
- [[implicit-skill-routing]]
- [[agent-skill-installation-workflow]]
- [[weiping-agentic-project-constellation]]
- [[local-project-roots]]
- [[research-project-workbench]]
