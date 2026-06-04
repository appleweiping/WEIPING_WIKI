---
name: weiping-wiki
description: >-
  Maintain and upgrade `WEIPING_WIKI` / `Weiping Wiki` as a durable knowledge system, whole-computer project map, and self-maintaining agent workflow. Use for answering from or ingesting into the wiki, refreshing stale pages, weekly maintenance, C:/D:/G: project routing, public/private safety, index/log/catalog updates, automation validation, and skill self-upgrades. Also use for deep, low-coupling routes among `D:/devtools`, `D:/AGENT_RESOURCE` / `D:/agent-resources`, `D:/AGENTIC_SCIENCE` / UUPF, `D:/Research/WEIPING_LAB`, and `D:/Research/WEIPING_COUNCIL`. Historical aliases are `vipin wiki`, `vipinknowledge`, and `vipin-wiki`. Pair with workstation-maintenance for physical drive organization.
---

# WEIPING_WIKI Adapter

Read `AGENTS.md` first. This adapter makes Claude Code and OpenCode follow the same `WEIPING_WIKI` workflow as Codex. Treat `vipin wiki`, `vipinknowledge`, and `vipin-wiki` as historical aliases.

## Start Here

1. Check `git status --short --branch`.
2. Read `wiki/concepts/whole-computer-project-map.md` before whole-computer or local project routing.
3. Read `wiki/concepts/d-drive-project-map.md`, `wiki/topics/local-active-project-roots.md`, and `wiki/topics/local-project-roots.md` when D-drive or active project roots are involved.
4. Use `python scripts/wiki.py search "<query>"`, `wiki/index.md`, and `wiki/catalog.json` for retrieval.
5. Use agentmemory for active recall/signals when available.
6. For actual file moves, use `D:\agent-resources\skills\vipin\workstation-maintenance` to generate the manifest, full-plan or exact-batch preflight, approval packet, type-grouped age-gated move plan, approved batch, and rollback artifacts. For D-root directory organization, use the same shared skill's drive-root plan/invoke scripts so old paths remain junction-compatible. Broad user approval can cover all currently passing low-risk batches.
7. For deep agentic-constellation maintenance, read [[weiping-agentic-project-constellation]] and keep links public-safe, artifact-based, and low-coupling.

## Canonical Commands

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
python scripts/wiki.py context L1 --query "whole-computer maintenance"
python scripts/wiki.py catalog
python scripts/wiki.py lint
python scripts/wiki.py health --json
powershell .\scripts\Test-PrePushSafety.ps1
```

## Modes

- Query from maintained wiki pages first; crystallize reusable answers.
- Ingest sources into source notes and propagate durable facts.
- Maintain old pages by comparing them with live evidence and current operating rules.
- Map the whole computer shallowly, deep-reading only important roots.
- Maintain tight routes among WEIPING_WIKI, devtools, AGENT_RESOURCE, AGENTIC_SCIENCE/UUPF, WEIPING_LAB, and WEIPING_COUNCIL without making repositories depend on one another's private state.
- Delegate physical C:/D:/G: organization to the shared workstation-maintenance skill; update public-safe wiki maps after dry-run evidence or actual state changes, including D-root move-with-junction results.
- Maintain Obsidian-compatible vault artifacts (`.obsidian/`, `.base`, `.canvas`, commands, templates, dashboard, workspaces, slides, and `wiki.py obsidian ...`) when the task asks for Obsidian-style knowledge-system upgrades.
- Upgrade the skill/workflow when a future agent would otherwise need a fresh prompt.

## Safety

Do not edit external project files during whole-computer maintenance. Do not move files unless a workstation-maintenance manifest and user-approved age-gated batch exists. D-root directory moves require a drive-root plan, preflight, and rollback-capable move-with-junction execution. `D:\Research` resolved paths are a hard no-move boundary. Do not expose secrets, private chats, credentials, account state, medical/financial/private docs, logs, DBs, or bulky artifacts in public pages or commits. Stage only scoped files and preserve unrelated dirty work.
