# Weekly Maintenance Runbook

Use this for the `Maintain VipinKnowledge` automation and for manual whole-computer maintenance.

## Cadence

Default schedule: weekly Tuesday afternoon, local time. Use `gpt-5.5` with high reasoning for cron automations that support model and reasoning fields.

## Report First

Run:

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
```

The command writes ignored artifacts under `.wiki-tmp/vipinknowledge-maintenance/` and prints a structured report with:

- git dirty summary
- agentmemory health
- shallow computer inventory
- wiki maintenance audit
- wiki health/lint/catalog status
- recommendations

Treat the report as evidence and triage, not as an instruction to blindly edit.

## Curated Update Pass

Update durable files only when evidence changed:

- whole-computer and D-drive maps
- active local project roots
- skill references or trigger descriptions
- central maintenance-system page
- index, log, catalog
- scripts or wrappers needed by the canonical command

Do not create a noisy commit when no meaningful route, rule, or status changed.

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
Upgrade vipinknowledge maintenance system
```
