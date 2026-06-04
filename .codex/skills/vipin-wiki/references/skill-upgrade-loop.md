# Skill Upgrade Loop

Use this when `weiping-wiki` itself is being improved. `vipin-wiki` is the historical alias and may still be the compatibility folder name.

## Upgrade Standard

A skill change is worthwhile only if it makes future agents less dependent on a freshly written prompt, safer around private material, or more reliable at preserving the wiki's project function.

## Inputs

Before editing the skill, inspect:

- current user request and failure mode
- `.codex/skills/vipin-wiki/SKILL.md` (compatibility folder for the `weiping-wiki` skill)
- relevant files in `.codex/skills/vipin-wiki/references/`
- `wiki/concepts/weiping-wiki-maintenance-system.md`
- latest `python scripts/wiki.py maintain --scope whole-computer --json` report when relevant
- `D:\devtools\codex\home\skills\.system\skill-creator\SKILL.md` for skill structure rules
- UUPF under `D:\AGENTIC_SCIENCE\uupf\UniversalUpgradeForge.zip` when the user asks for a deep upgrade or the maintenance workflow itself is being redesigned

## UUPF-Aided Upgrade

For non-trivial upgrades, run UUPF in offline mode before editing:

```powershell
$env:PYTHONIOENCODING = "utf-8"
$tools = ".wiki-tmp\uupf-tools"
$runs = ".wiki-tmp\uupf-runs"
Expand-Archive -LiteralPath "D:\AGENTIC_SCIENCE\uupf\UniversalUpgradeForge.zip" -DestinationPath $tools -Force
Push-Location "$tools\UniversalUpgradeForge"
python -m uupgrade.cli doctor --json
python -m uupgrade.cli plan "<target-skill-or-doc>" --goal "<upgrade-goal>" --iterations 108 --output "..\..\uupf-runs\<name>"
python -m uupgrade.cli upgrade "<target-skill-or-doc>" --goal "<upgrade-goal>" --iterations 108 --provider offline --output "..\..\uupf-runs\<name>"
Pop-Location
```

Keep expanded tools and run outputs under ignored `.wiki-tmp/`. Do not point UUPF at the whole wiki repo; pass the smallest skill or reference file that needs review. UUPF offline runs copy inputs into their own workspaces, do not patch the original files, and do not prove the skill is upgraded.

Triage the generated `FINAL_REPORT.md`, `ITERATION_LOG.md`, and `PROVENANCE.md` as an audit checklist:

- Which findings are supported by live project files?
- Which findings would increase private-data exposure or cross-repo coupling?
- Which changes belong in `SKILL.md`, `references/`, `scripts/`, wiki pages, adapters, or automation prompts?
- Which raw reports must remain ignored and summarized only?

The responsible agent must still inspect live evidence, hand-apply concise changes, validate, and preserve public-safe provenance.

## Edit Pattern

- Keep `SKILL.md` short and mode-oriented.
- Put long procedures in `references/`.
- Put deterministic repeated operations in `scripts/` or the repo CLI.
- Update `agents/openai.yaml` when frontmatter trigger wording or user-facing prompt changes.
- Add or update wiki documentation when the behavior is durable for all agents.
- Update Claude/OpenCode adapters when the skill should trigger outside Codex.
- Update maintenance automations when the recurring workflow, model, reasoning effort, root list, or validation gate changes.
- Encode tight-but-low-coupling relationships: route pages, optional interfaces, artifact contracts, and degraded-state rules are good; hidden runtime dependencies and cross-repo private-state reads are not.

## Forward Test

After non-trivial skill edits, test at least one realistic task path:

```powershell
python D:\devtools\codex\home\skills\.system\skill-creator\scripts\quick_validate.py .codex\skills\vipin-wiki
python scripts/wiki.py maintain --scope whole-computer --json
python scripts/wiki.py context L1 --query "whole-computer maintenance"
```

If available, ask a read-only partner to critique the skill. If partner tooling is unavailable or returns unusable output, say so and use a Codex-owned review pass.

## Versioning Rule

Do not leave skill changes as local-only tweaks. Validate, update docs/index/log/catalog, stage scoped files, commit, and push unless the user explicitly asks not to.
