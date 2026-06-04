# Safety And Automation Gates

Use this before a maintenance automation stages, commits, or pushes.

## Public Boundary

Public wiki pages may contain:

- project purpose and root path
- source-of-truth entry files
- public-safe status
- safety boundaries
- links to maintained wiki pages
- evidence dates and validation results

Public wiki pages must not contain:

- secrets, API keys, tokens, credentials
- private chats, raw personal journals, account state
- medical, financial, legal-client, or other sensitive private records
- browser profiles, local DB contents, logs, raw server outputs
- bulky datasets, checkpoints, binaries, or generated artifacts

## Automation Commit Gate

Automation may commit and push only if all are true:

- changes are scoped to wiki/skill/script/doc maintenance
- `python scripts/wiki.py lint` passes
- `python scripts/wiki.py health --json` has no critical wiki failures
- `powershell .\scripts\Test-PrePushSafety.ps1` passes
- `git diff --check` passes
- no unrelated dirty work is staged
- no raw private or ignored runtime material is staged
- no raw UUPF, workstation-maintenance, CI, browser, or project-generated report folders are staged; commit curated summaries and source changes only

For WEIPING_WIKI recurring maintenance, cron automations should use `model = "gpt-5.5"` and `reasoning_effort = "xhigh"` when supported. The prompt must explicitly preserve unrelated dirty work and must not stage external project files merely because it inspected them.

## Stop Conditions

Stop before staging when:

- validation fails
- report output is inconclusive
- a change would require editing an external project
- a deletion is needed but the user has not approved it
- sensitive material appears in a public candidate diff
- only ignored report artifacts changed
- only UUPF offline report artifacts changed
- a physical file move is proposed without a `workstation-maintenance` manifest, age-gated user-approved batch, and rollback manifest
- a proposed cross-project link would make one repository depend on another repository's private `.env`, database, runtime cache, generated report, or active workspace state

## Cross-Project Coupling Gate

Before publishing or automating a relationship between WEIPING_WIKI, devtools, AGENT_RESOURCE, AGENTIC_SCIENCE, WEIPING_LAB, and WEIPING_COUNCIL, check:

- Is the relationship recorded as routing, optional integration, artifact format, or validation command?
- Can each repo still run its basic status/verification path when the neighbor repo is absent or degraded?
- Are secrets, local DBs, generated reports, caches, and raw workspaces kept local to their owning repo?
- Are historical aliases preserved as compatibility notes rather than new canonical names?

If any answer is no, keep the relationship private or redesign it before committing.

## Agentmemory

Use agentmemory as live operational memory when available. If unavailable, continue from git/wiki evidence and record the degraded state. Do not store secrets or raw private material in agentmemory.

## Workstation Manifests

Keep workstation inventory, preflight, move-plan, applied-batch, and rollback artifacts in ignored local report directories such as `.wiki-tmp/workstation-maintenance/`. Do not stage them or publish raw sensitive filenames.
