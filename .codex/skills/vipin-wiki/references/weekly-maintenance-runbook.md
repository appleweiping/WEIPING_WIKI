# Weekly Maintenance Runbook

Use this for the `Maintain WEIPING_WIKI` automation and for manual whole-computer maintenance. `Maintain VipinKnowledge` is the historical automation label.

## Cadence

Default schedule: weekly Tuesday afternoon, local time. Use `gpt-5.5` with `xhigh` reasoning for cron automations that support model and reasoning fields. If a runtime rejects `xhigh`, keep `gpt-5.5`, record the downgrade, and use the strongest accepted reasoning level.

## Report First

Run:

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
```

The command writes ignored artifacts under `.wiki-tmp/vipinknowledge-maintenance/` for historical compatibility and prints a structured report with:

- git dirty summary
- agentmemory health
- shallow computer inventory
- wiki maintenance audit
- wiki health/lint/catalog status
- recommendations

Treat the report as evidence and triage, not as an instruction to blindly edit.

## Deep Constellation Pass

When the goal is whole-system maintenance rather than a narrow wiki edit, inspect live entry evidence for the agentic project constellation:

| Root | Treat as | Read first |
| --- | --- | --- |
| `D:/Research/WEIPING_WIKI` | Canonical wiki repo | `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `wiki/concepts/whole-computer-project-map.md` |
| `D:/Research/vipin's knowledgebase` | Compatibility junction to `WEIPING_WIKI` | Resolve junction target before editing |
| `D:/devtools` | Private agent runtime/workstation repo | `README.md`, `health-check.ps1`, `codex/home/automations/` summaries, git status |
| `D:/devtools-public` | Public-safe export repo | `README.md`, `docs/`, safety scripts |
| `D:/AGENT_RESOURCE` | Canonical resource/skill repo | `README.md`, `SKILL-INDEX.md`, `docs/skill-provenance-audit-*.md` |
| `D:/agent-resources` | Compatibility junction to `AGENT_RESOURCE` | Resolve junction target before editing |
| `D:/AGENTIC_SCIENCE` | Workflow factory repo | `README.md`, `AGENTS.md`, `uupf/UniversalUpgradeForge.zip` |
| `D:/Research/WEIPING_LAB` | Research workbench repo | `README.md`, `CLAUDE.md`, `.codex/skills/weiping-lab/SKILL.md`, `pyproject.toml` |
| `D:/Research/WEIPING_COUNCIL` | Multi-model deliberation repo | `README.md`, `CLAUDE.md`, `.codex/skills/weiping-council/SKILL.md`, `pyproject.toml` |

The pass should update routing, aliases, safety boundaries, and cross-project relationship notes. It should not edit external project source code, generated artifacts, private runtime state, local workspaces, or experiment outputs.

## Importance And Coupling Rules

Classify roots by evidence, not by folder-name vibes:

- Tier 0 operating roots affect agent identity, storage, skill routing, automations, or public/private safety.
- Tier 1 roots have active README/AGENTS/package evidence, recent meaningful git activity, repeated user interest, or high consequence.
- Tier 2 roots are useful archives or dormant projects.
- Tier 3 roots are caches, downloads, vendor/system bulk, or scratch folders.

Connect important projects tightly by maintaining routes, aliases, source-of-truth docs, optional handoff artifacts, and explicit relationship pages. Forbid high coupling:

- Do not make one repo require another repo's private cache, `.env`, database, run folder, or generated report to start.
- Do not copy source, datasets, secrets, or runtime state across repos just to make links convenient.
- Prefer environment-variable hooks, documented artifact formats, explicit import/export commands, and wiki route pages over hidden path dependencies.
- When a relationship is optional, document degraded behavior and manual recovery steps.

## Curated Update Pass

Update durable files only when evidence changed:

- whole-computer and D-drive maps
- active local project roots
- skill references or trigger descriptions
- central maintenance-system page
- index, log, catalog
- scripts or wrappers needed by the canonical command
- periodic automation prompts and reasoning settings when the maintenance contract changes
- public-safe relationship pages for important roots when a new canonical project or alias appears

Do not create a noisy commit when no meaningful route, rule, or status changed.

## UUPF Upgrade Pass

For major skill or maintenance-system upgrades, run UUPF offline from `D:/AGENTIC_SCIENCE/uupf/UniversalUpgradeForge.zip` after reading its `AGENTS.md` / `CODEX.md`:

```powershell
$env:PYTHONIOENCODING = "utf-8"
python -m uupgrade.cli doctor
python -m uupgrade.cli plan "<target>" --goal "<goal>" --iterations 108 --output ".wiki-tmp/uupf-runs/<name>"
python -m uupgrade.cli upgrade "<target>" --goal "<goal>" --iterations 108 --provider offline --output ".wiki-tmp/uupf-runs/<name>"
```

Keep UUPF runs under ignored `.wiki-tmp/`. Summarize `FINAL_REPORT.md`, `ITERATION_LOG.md`, and `PROVENANCE.md` in the maintenance note or final report, but only hand-apply reviewed changes.

## Validation Gate

Before auto commit/push:

```powershell
python scripts/wiki.py catalog
python scripts/wiki.py lint
python scripts/wiki.py health --json
powershell .\scripts\Test-PrePushSafety.ps1
git diff --check
```

If any validation fails, stop before staging and leave the report. If validation changes only ignored `.wiki-tmp` files, do not commit.

## Scoped Commit Rule

Stage only files that belong to the maintenance pass. Exclude unrelated dirty work, memory session dumps, raw private material, caches, generated runtime artifacts, and external project files.

Suggested commit message:

```text
Upgrade WEIPING_WIKI maintenance system
```
