---
name: vipin-wiki
description: Maintain and upgrade `vipin wiki` / `vipinknowledge` as a whole-computer project map and self-maintaining knowledge system. Use for answering from the wiki, refreshing stale pages, running or reviewing weekly maintenance, routing local project roots across C:/D:/G:, classifying important vs low-value folders, protecting public/private boundaries, updating index/log/catalog, or improving the vipin-wiki skill and maintenance workflow so future agents do not need bespoke prompts.
---

# Vipin Wiki Adapter

Read `AGENTS.md` first. This adapter makes Claude Code and OpenCode follow the same `vipinknowledge` workflow as Codex.

## Start Here

1. Check `git status --short --branch`.
2. Read `wiki/concepts/whole-computer-project-map.md` before whole-computer or local project routing.
3. Read `wiki/concepts/d-drive-project-map.md`, `wiki/topics/local-active-project-roots.md`, and `wiki/topics/local-project-roots.md` when D-drive or active project roots are involved.
4. Use `python scripts/wiki.py search "<query>"`, `wiki/index.md`, and `wiki/catalog.json` for retrieval.
5. Use agentmemory for active recall/signals when available.

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
- Upgrade the skill/workflow when a future agent would otherwise need a fresh prompt.

## Safety

Do not edit external project files during whole-computer maintenance. Do not expose secrets, private chats, credentials, account state, medical/financial/private docs, logs, DBs, or bulky artifacts in public pages or commits. Stage only scoped files and preserve unrelated dirty work.
