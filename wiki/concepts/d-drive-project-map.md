---
title: D-Drive Project Map
type: concept
status: active
created: 2026-06-01
updated: 2026-06-01
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
| `D:/agent-resources` | Public curated skill/resource library and implicit skill-routing index. | Public repo. Commit only provenance-cleared skills and docs. Keep unknown-license packs local-only. |
| `D:/Research/vipin's knowledgebase` | `vipin wiki`: public operating contract and durable knowledge layer. | Maintain `wiki/`, adapters, index, log, and validation; keep the private wiki layer out of Git. |

## Active Agent Substrate

| Component | Current rule |
| --- | --- |
| agentmemory | Active operational memory, signals, actions, checkpoints, and diagnostics. |
| Agent Hub | Deprecated historical experiment; do not start, register, or depend on it for new work. |
| Skills | Trigger by task intent. Inspect metadata, read matched `SKILL.md`, then act. |
| Git | Source-of-truth for file changes. Stage only scoped files and preserve unrelated dirty work. |

## Public And Private Boundaries

- Public-safe knowledge goes into `wiki/`, `agent-resources`, or `devtools-public`.
- Secrets, API keys, credentials, private chats, private account state, logs, SQLite DBs, session histories, browser profiles, caches, generated bulky artifacts, and local runtimes stay out of public Git.
- Private notes can live under ignored private paths when needed, but public pages should contain only masked fingerprints and operational conclusions.

## Research Isolation

Research repositories under `D:/Research` are not part of infrastructure cleanup. Agents must not move, rewrite, stage, or "tidy" experiment code, datasets, checkpoints, server logs, result files, or active experiment state while working on agent infrastructure.

Use [[research-project-workbench]] before opening a repeated research project. Then rescan the live target repo and follow its own instructions.

## D-Drive Organization Buckets

| Bucket | Examples | Rule |
| --- | --- | --- |
| Agent infrastructure | `D:/devtools`, `D:/devtools-public`, `D:/agent-resources` | Keep D-drive-first; separate public source from private runtime. |
| Knowledge base | `D:/Research/vipin's knowledgebase` | Public wiki plus ignored private layer. |
| Research workbench | `D:/Research/*` project repos | Isolate from infra cleanup; modify only on explicit research task. |
| Portfolio/course archives | `D:/Academic_portfolio`, `D:/Undergraduate_*` | Record public-safe metadata only unless explicitly asked. |
| Product/game/health roots | `D:/Project`, `D:/Game_develop`, `D:/Healthcare` | Rescan live roots before claims or edits. |
| Media/download/cache/system bulk | downloads, videos, tool caches, drivers, Docker, VirtualBox | Do not publish raw contents; cleanup only with explicit storage-maintenance scope. |

## Startup Use

For D-drive tasks:

1. Read this map.
2. Identify the target bucket.
3. Check the target repo's `git status`.
4. Load relevant skill metadata and read the matched `SKILL.md`.
5. Keep changes inside the requested bucket and validate before commit/push.

## Counterpoints And Gaps

- This is a routing map, not a complete D-drive inventory.
- Exact folder names and project states can drift; rescan the live target before editing or making current-state claims.
- Private-only details should stay in ignored private notes and should not be expanded into this public page.

## Related

- [[whole-computer-project-map]]
- [[agentmemory-first-agent-collaboration]]
- [[implicit-skill-routing]]
- [[agent-skill-installation-workflow]]
- [[local-project-roots]]
- [[research-project-workbench]]
