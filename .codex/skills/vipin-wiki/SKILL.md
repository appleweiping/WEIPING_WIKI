---
name: vipin-wiki
description: Maintain and evolve `vipin wiki` / `vipinknowledge` as a long-lived personal knowledge system and whole-computer project map. Use when Codex needs to answer from the wiki, ingest sources, refresh stale pages, maintain project/root maps across C:/D:/G:, classify important vs low-value files or folders, preserve research/project memory, update wiki indexes/logs/catalogs, protect public/private boundaries, or improve the wiki/skill itself so future agents do not need a fresh prompt.
---

# Vipin Wiki

## Mission

Maintain `vipin wiki` as a compounding knowledge system, not a one-off note dump.

The skill has four jobs:

1. Answer quickly from maintained wiki pages.
2. Crystallize reusable knowledge into durable pages.
3. Keep project maps current across the whole computer.
4. Refresh old content when stronger evidence, changed project state, or better organization makes it stale.

## First Moves

1. Work from the repository root containing `AGENTS.md`, `.wiki-schema.md`, and `purpose.md`.
2. Check `git status --short --branch`; do not stage unrelated local changes.
3. Read `AGENTS.md`, `.wiki-schema.md`, and `purpose.md` before substantial maintenance, ingest, synthesis, or structural changes.
4. For interpretation, prioritization, or recommendation work, also read `reader-context.md`.
5. For whole-computer or local-project work, read `wiki/concepts/whole-computer-project-map.md`, then `wiki/topics/local-active-project-roots.md`, `wiki/concepts/d-drive-project-map.md`, and `wiki/topics/local-project-roots.md` if the task touches D-drive roots.
6. Use `wiki/index.md`, `wiki/catalog.json`, and recent `wiki/log.md` as the lightweight route before opening broad source material.

## Operating Modes

- **Query**: answer from maintained pages first; preserve reusable answers under `wiki/queries/`, `wiki/analyses/`, `wiki/comparisons/`, or an existing concept/topic page.
- **Ingest**: treat `raw/` as immutable. Create or update source notes, then propagate durable facts into entities, concepts, topics, analyses, index, and log.
- **Maintain / refresh**: compare old pages to live evidence, stronger sources, current project state, and current operating rules. Rewrite stale sections, merge duplicates, add supersession notes, and propose deletions when needed.
- **Whole-computer project mapping**: classify roots by importance and sensitivity. Important active projects get detailed routing; low-value/system/cache/download roots get brief bucket summaries.
- **Skill upgrade**: when this skill fails, feels prompt-dependent, or misses a repeatable workflow, update this skill and its reference files in the same maintenance pass.

## Importance-Based Depth

Use this depth policy for computer/project inventory:

| Tier | What qualifies | Wiki depth |
| --- | --- | --- |
| Tier 0: operating contract | `vipin wiki`, `AGENTS.md`, skill roots, agentmemory/devtools/agent-resources | Detailed page, current commands, safety gates, update rules, links, log entry |
| Tier 1: active projects | research workbenches, active product/app/game/healthcare/company repos | Dedicated entity/topic page or refreshed section with purpose, root, status, entry docs, safety boundaries |
| Tier 2: useful archives | portfolio, coursework, study archives, old project roots, media packages | Summary with content nature, discovery clues, and edit caution |
| Tier 3: bulk/system/noise | OS folders, caches, downloads, binaries, package stores, temp dirs | One-line bucket summary; do not deep-read unless explicitly asked |
| Private/sensitive | credentials, account state, medical/financial/private docs, raw private chats | Private-only minimal metadata or no public record |

When unsure, start shallow and promote a root to more detail only after evidence shows repeated use, active work, or high consequence.

## Whole-Computer Maintenance Loop

For recurring maintenance, run this loop:

1. **Route**: identify the target drive/root and importance tier.
2. **Inspect**: read the smallest live evidence that proves current state. Use `scripts/computer-inventory.ps1` for shallow machine maps.
3. **Compare**: check existing wiki pages for stale paths, stale status, duplicates, weak claims, or missing links.
4. **Refresh**: update existing pages before creating new ones. Mark superseded history instead of blindly deleting.
5. **Index**: update `wiki/index.md`, section homes, and `wiki/catalog.json`.
6. **Log**: append `wiki/log.md` with what changed and why.
7. **Validate**: run the narrowest relevant validation.
8. **Commit**: stage only scoped files, commit, and push unless the user explicitly asks not to.

Read `references/maintenance-model.md` when doing a broad refresh, whole-computer inventory, stale-page cleanup, or skill iteration.

## Safety Rules

- Default to the public wiki layer. Use private layers only when the user explicitly asks for private material or the task truly requires it.
- Never expose secrets, tokens, private chats, credentials, private account state, sensitive documents, or raw private material through public pages, public indexes, public logs, or staged Git content.
- Do not move, rewrite, or clean research experiment code, datasets, checkpoints, server logs, or result files during general wiki/infrastructure maintenance.
- For external project edits, rescan the live repo, read its own instructions, and check its `git status` first.
- Deletions require explicit user approval after a concrete deletion proposal.

## Page And Log Conventions

- Use lowercase kebab-case filenames.
- Use YAML frontmatter when practical: `title`, `type`, `status`, `created`, `updated`, `tags`, `source_files`, `source_pages`.
- Mark non-trivial claims with `EXTRACTED`, `INFERRED`, `AMBIGUOUS`, or `UNVERIFIED`.
- Use Obsidian links like `[[page-name]]`.
- Append log entries as `## [YYYY-MM-DD HH:MM] operation | title`.

## Useful Commands

```powershell
python scripts/wiki.py status
python scripts/wiki.py search "query text"
python scripts/wiki.py catalog
python scripts/wiki.py lint
powershell .\scripts\computer-inventory.ps1
powershell .\scripts\wiki-maintenance-audit.ps1
powershell .\scripts\Test-PrePushSafety.ps1
```

After durable wiki, script, skill, or site changes, run validation, stage only scoped files, commit, and push when appropriate.
