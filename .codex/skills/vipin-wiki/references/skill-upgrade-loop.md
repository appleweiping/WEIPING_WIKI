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

## Edit Pattern

- Keep `SKILL.md` short and mode-oriented.
- Put long procedures in `references/`.
- Put deterministic repeated operations in `scripts/` or the repo CLI.
- Update `agents/openai.yaml` when frontmatter trigger wording or user-facing prompt changes.
- Add or update wiki documentation when the behavior is durable for all agents.
- Update Claude/OpenCode adapters when the skill should trigger outside Codex.

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
