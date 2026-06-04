---
name: weiping-wiki
description: >-
  Maintain and upgrade `WEIPING_WIKI` / `Weiping Wiki` as a durable knowledge system, whole-computer project map, and self-maintaining agent workflow. Use for answering from or ingesting into the wiki, refreshing stale pages, weekly maintenance, C:/D:/G: project routing, public/private safety, index/log/catalog updates, automation validation, and skill self-upgrades. Also use for deep, low-coupling routes among `D:/devtools`, `D:/devtools-public`, `D:/AGENT_RESOURCE` / `D:/agent-resources`, `D:/AGENTIC_SCIENCE` / UUPF, `D:/Research/WEIPING_LAB`, and `D:/Research/WEIPING_COUNCIL`. Historical aliases are `vipin wiki`, `vipinknowledge`, and `vipin-wiki`. Pair with `workstation-maintenance` for physical drive organization.
---

# WEIPING_WIKI

## Mission

Keep `WEIPING_WIKI` useful without a bespoke prompt. The system should answer from maintained knowledge, preserve reusable results, route future agents into the right local projects, and continuously improve its own workflow. Treat `vipin wiki`, `vipinknowledge`, and `vipin-wiki` as historical aliases.

## First Moves

1. Work from the repo root containing `AGENTS.md`, `.wiki-schema.md`, and `purpose.md`.
2. Run `git status --short --branch`; preserve unrelated dirty work.
3. Read `AGENTS.md`, `.wiki-schema.md`, and `purpose.md` before substantial maintenance, ingest, skill, script, automation, or operating-rule edits.
4. For whole-computer/project routing, read `wiki/concepts/whole-computer-project-map.md` first, then `wiki/concepts/d-drive-project-map.md`, `wiki/topics/local-active-project-roots.md`, and `wiki/topics/local-project-roots.md` as needed.
5. For interpretation or prioritization, read `reader-context.md`.
6. Search active agentmemory when past state can affect the task.
7. For deep maintenance of the agentic project constellation, inspect entry evidence for `WEIPING_WIKI`, `D:/devtools`, `D:/devtools-public`, `D:/AGENT_RESOURCE` / `D:/agent-resources`, `D:/AGENTIC_SCIENCE`, `WEIPING_LAB`, and `WEIPING_COUNCIL` before editing maps or automations.

## Mode Router

- **Query**: answer from `wiki/index.md`, `wiki/catalog.json`, `python scripts/wiki.py search`, and the smallest relevant maintained pages. Crystallize reusable answers.
- **Ingest**: treat `raw/` as immutable; create/update source notes, then propagate durable facts into concepts, entities, topics, analyses, index, log, and catalog.
- **Maintain**: compare current pages to live evidence, stronger sources, and current rules. Update existing pages before creating duplicates. Propose deletions only after explicit user approval.
- **Whole-computer map**: shallow-scan all drives, classify roots by importance, deep-read only important roots, and keep low-value/system/cache/download roots as brief bucket summaries.
- **Physical file organization**: delegate manifests, full-plan, exact-batch, or D-root organization non-moving preflights, type-grouped age-gated move plans, approval packets, approved batch moves, D-root move-with-junction organization, and rollbacks to `D:\agent-resources\skills\vipin\workstation-maintenance`; this skill records only public-safe routing updates after dry-run evidence or actual changes. Broad user approval can cover all currently passing low-risk batches.
- **Obsidian compatibility**: maintain `.obsidian/`, `.base`, `.canvas`, command-palette, template, dashboard, workspace, slide, backlink/search/outline/preview/tag/property/task/word-count, and `wiki.py obsidian ...` support so the repo works as a real local-first vault without depending on Obsidian's proprietary core.
- **Skill upgrade**: when this skill feels prompt-dependent, misses a repeatable step, or fails validation, update the skill and references in the same scoped maintenance pass.
- **Automation run**: use `python scripts/wiki.py maintain --scope whole-computer --json` as the canonical report, then make curated wiki/skill/doc updates only when evidence changed.
- **Agentic constellation maintenance**: maintain tight routing links among WEIPING_WIKI, devtools, agent-resources, AGENTIC_SCIENCE/UUPF, WEIPING_LAB, and WEIPING_COUNCIL while forbidding high coupling. Public pages may describe roles, aliases, entry docs, handoff artifacts, optional environment variables, and validation commands; they must not make one repository require another repository's private state, runtime cache, secrets, local DBs, or generated reports to function.

## Whole-Computer Depth

Use importance tiers before opening files:

| Tier | Qualifies | Depth |
| --- | --- | --- |
| Tier 0 | `WEIPING_WIKI`, operating docs, skill roots, agentmemory, `D:/devtools`, `D:/agent-resources` | Detailed routing, commands, safety gates, update rules, log/catalog/index changes |
| Tier 1 | Active research/product/app/game/health/company repos | Dedicated page or detailed section with purpose, root, status, entry docs, safety boundary |
| Tier 2 | Portfolio, coursework, study archives, old projects, media packages | Public-safe summary and discovery clues |
| Tier 3 | OS folders, caches, downloads, binaries, package stores, temp dirs | One-line bucket summary; do not deep-read unless asked |
| Private/sensitive | Credentials, private chats/docs, account state, medical/financial records | Private-only minimal metadata or no public record |

Read `references/whole-computer-depth.md` before broad inventory or local organization work.
Read the shared `workstation-maintenance` skill before any physical C:/D:/G: move plan or D-root organization plan.

## Recurring Maintenance

Default cadence is weekly Tuesday afternoon with `gpt-5.5` and xhigh reasoning when the automation schema supports it. Automation may commit and push only after scoped curated changes and validation.

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

For deep infrastructure maintenance, also verify the current topology and entry evidence for:

- `D:/Research/WEIPING_WIKI` and the compatibility junction `D:/Research/vipin's knowledgebase`
- `D:/devtools` and `D:/devtools-public`
- `D:/AGENT_RESOURCE` and the compatibility junction `D:/agent-resources`
- `D:/AGENTIC_SCIENCE`, especially UUPF under `uupf/UniversalUpgradeForge.zip`
- `D:/Research/WEIPING_LAB` and the compatibility junction `D:/Research/vipin-lab`
- `D:/Research/WEIPING_COUNCIL` and the compatibility junction `D:/Research/vipin-council`

Read `references/obsidian-compatibility.md` before Obsidian-style vault, Bases, Canvas, backlink, search, quick-switcher, command-palette, outline, preview, footnote, tag, property, task, daily/unique note, template, slide, word-count, web-clip, or workspace upgrades.

## Self-Upgrade Loop

Upgrade this skill when:

- a user has to explain a workflow that should be automatic
- a future agent would need to invent a prompt to maintain the wiki
- a maintenance report shows repeated manual triage
- validation, safety, or automation rules are stale
- the whole-computer map gains a new important root or risk boundary
- an important root needs better cross-project routing without adding runtime coupling

For major upgrades, use UUPF from `D:/AGENTIC_SCIENCE/uupf/UniversalUpgradeForge.zip` in offline mode first:

```powershell
$env:PYTHONIOENCODING = "utf-8"
python -m uupgrade.cli doctor
python -m uupgrade.cli plan "<target-skill-or-doc-path>" --goal "<upgrade-goal>" --iterations 108 --output ".wiki-tmp/uupf-runs/<name>"
python -m uupgrade.cli upgrade "<target-skill-or-doc-path>" --goal "<upgrade-goal>" --iterations 108 --provider offline --output ".wiki-tmp/uupf-runs/<name>"
```

Treat UUPF reports as audit evidence and planning input. Do not publish raw generated run folders or claim that offline UUPF applied patches. Hand-apply only reviewed, source-grounded changes.

Keep `SKILL.md` compact. Put detailed procedures in `references/`, scripts in `scripts/`, and user-facing docs in `wiki/`. Regenerate/validate `agents/openai.yaml` when trigger wording changes. Read `references/skill-upgrade-loop.md` before editing this skill.

## Safety Rules

- Do not edit external projects during whole-computer maintenance; read only entry evidence unless the user explicitly asks for project work.
- Do not physically move files during whole-computer maintenance unless a `workstation-maintenance` manifest and user-approved age-gated batch exists. For D-root directory organization, require a drive-root plan, non-moving preflight, and rollback-capable move-with-junction execution.
- Never expose secrets, tokens, credentials, private chats, account state, sensitive documents, raw private material, logs, DBs, or bulky artifacts in public pages or Git.
- Do not move, rewrite, or clean research experiment code, datasets, checkpoints, server logs, or result files during general wiki maintenance.
- Keep reports in ignored `.wiki-tmp/vipinknowledge-maintenance/` for historical compatibility; commit curated wiki/skill/script/doc changes only.
- If validation fails, stop before commit/push and leave a clear report.

## Canonical Outputs

- Updated wiki pages with YAML frontmatter and confidence labels where useful.
- Updated `wiki/index.md`, `wiki/log.md`, and `wiki/catalog.json`.
- Scoped commits that exclude unrelated dirty work.
- Agentmemory save for important decisions, findings, and next steps when available.
