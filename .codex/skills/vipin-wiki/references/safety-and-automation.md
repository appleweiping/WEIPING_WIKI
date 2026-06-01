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

## Stop Conditions

Stop before staging when:

- validation fails
- report output is inconclusive
- a change would require editing an external project
- a deletion is needed but the user has not approved it
- sensitive material appears in a public candidate diff
- only ignored report artifacts changed
- a physical file move is proposed without a `workstation-maintenance` manifest, user-approved batch, and rollback manifest

## Agentmemory

Use agentmemory as live operational memory when available. If unavailable, continue from git/wiki evidence and record the degraded state. Do not store secrets or raw private material in agentmemory.

## Workstation Manifests

Keep workstation inventory, move-plan, applied-batch, and rollback artifacts in ignored local report directories such as `.wiki-tmp/workstation-maintenance/`. Do not stage them or publish raw sensitive filenames.
