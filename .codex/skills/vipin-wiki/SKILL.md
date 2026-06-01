---
name: vipin-wiki
description: Maintain and upgrade `vipin wiki` / `vipinknowledge` as a long-lived personal knowledge system, whole-computer project map, and self-maintaining agent workflow. Use when Codex needs to answer from the wiki, ingest or crystallize sources, refresh stale pages, run weekly maintenance, maintain project/root maps across C:/D:/G:, classify important vs low-value files or folders, protect public/private boundaries, update index/log/catalog, create or validate maintenance automations, or improve this skill so future agents do not need a fresh prompt.
---

# Vipin Wiki

## Mission

Keep `vipinknowledge` useful without a bespoke prompt. The system should answer from maintained knowledge, preserve reusable results, route future agents into the right local projects, and continuously improve its own workflow.

## First Moves

1. Work from the repo root containing `AGENTS.md`, `.wiki-schema.md`, and `purpose.md`.
2. Run `git status --short --branch`; preserve unrelated dirty work.
3. Read `AGENTS.md`, `.wiki-schema.md`, and `purpose.md` before substantial maintenance, ingest, skill, script, automation, or operating-rule edits.
4. For whole-computer/project routing, read `wiki/concepts/whole-computer-project-map.md` first, then `wiki/concepts/d-drive-project-map.md`, `wiki/topics/local-active-project-roots.md`, and `wiki/topics/local-project-roots.md` as needed.
5. For interpretation or prioritization, read `reader-context.md`.
6. Search active agentmemory when past state can affect the task.

## Mode Router

- **Query**: answer from `wiki/index.md`, `wiki/catalog.json`, `python scripts/wiki.py search`, and the smallest relevant maintained pages. Crystallize reusable answers.
- **Ingest**: treat `raw/` as immutable; create/update source notes, then propagate durable facts into concepts, entities, topics, analyses, index, log, and catalog.
- **Maintain**: compare current pages to live evidence, stronger sources, and current rules. Update existing pages before creating duplicates. Propose deletions only after explicit user approval.
- **Whole-computer map**: shallow-scan all drives, classify roots by importance, deep-read only important roots, and keep low-value/system/cache/download roots as brief bucket summaries.
- **Obsidian compatibility**: maintain `.obsidian/`, `.base`, `.canvas`, template, dashboard, and `wiki.py obsidian ...` support so the repo works as a real local-first vault without depending on Obsidian's proprietary core.
- **Skill upgrade**: when this skill feels prompt-dependent, misses a repeatable step, or fails validation, update the skill and references in the same scoped maintenance pass.
- **Automation run**: use `python scripts/wiki.py maintain --scope whole-computer --json` as the canonical report, then make curated wiki/skill/doc updates only when evidence changed.

## Whole-Computer Depth

Use importance tiers before opening files:

| Tier | Qualifies | Depth |
| --- | --- | --- |
| Tier 0 | `vipin wiki`, operating docs, skill roots, agentmemory, `D:/devtools`, `D:/agent-resources` | Detailed routing, commands, safety gates, update rules, log/catalog/index changes |
| Tier 1 | Active research/product/app/game/health/company repos | Dedicated page or detailed section with purpose, root, status, entry docs, safety boundary |
| Tier 2 | Portfolio, coursework, study archives, old projects, media packages | Public-safe summary and discovery clues |
| Tier 3 | OS folders, caches, downloads, binaries, package stores, temp dirs | One-line bucket summary; do not deep-read unless asked |
| Private/sensitive | Credentials, private chats/docs, account state, medical/financial records | Private-only minimal metadata or no public record |

Read `references/whole-computer-depth.md` before broad inventory or local organization work.

## Recurring Maintenance

Default cadence is weekly Tuesday afternoon with `gpt-5.5` and high reasoning. Automation may commit and push only after scoped curated changes and validation.

Run:

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
python scripts/wiki.py catalog
python scripts/wiki.py lint
python scripts/wiki.py health --json
powershell .\scripts\Test-PrePushSafety.ps1
git diff --check
```

Read `references/weekly-maintenance-runbook.md` for automation behavior and `references/safety-and-automation.md` for commit/push gates.

Read `references/obsidian-compatibility.md` before Obsidian-style vault, Bases, Canvas, backlink, tag, property, task, daily note, template, or web-clip upgrades.

## Self-Upgrade Loop

Upgrade this skill when:

- a user has to explain a workflow that should be automatic
- a future agent would need to invent a prompt to maintain the wiki
- a maintenance report shows repeated manual triage
- validation, safety, or automation rules are stale
- the whole-computer map gains a new important root or risk boundary

Keep `SKILL.md` compact. Put detailed procedures in `references/`, scripts in `scripts/`, and user-facing docs in `wiki/`. Regenerate/validate `agents/openai.yaml` when trigger wording changes. Read `references/skill-upgrade-loop.md` before editing this skill.

## Safety Rules

- Do not edit external projects during whole-computer maintenance; read only entry evidence unless the user explicitly asks for project work.
- Never expose secrets, tokens, credentials, private chats, account state, sensitive documents, raw private material, logs, DBs, or bulky artifacts in public pages or Git.
- Do not move, rewrite, or clean research experiment code, datasets, checkpoints, server logs, or result files during general wiki maintenance.
- Keep reports in ignored `.wiki-tmp/vipinknowledge-maintenance/`; commit curated wiki/skill/script/doc changes only.
- If validation fails, stop before commit/push and leave a clear report.

## Canonical Outputs

- Updated wiki pages with YAML frontmatter and confidence labels where useful.
- Updated `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.
- Scoped commits that exclude unrelated dirty work.
- Agentmemory save for important decisions, findings, and next steps when available.
