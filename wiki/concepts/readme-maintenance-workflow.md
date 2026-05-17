---
title: README Maintenance Workflow
type: concept
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - wiki-workflow
  - maintenance
  - readme
source_pages:
  - AGENTS.md
---

# README Maintenance Workflow

## Rule

The root `README.md` is a living entry point for `vipin wiki`, not a one-time bootstrap file.

Future agents should periodically refresh it when the wiki's structure, automation rules, major workflows, or public/private safety boundaries materially change.

## Refresh Triggers

- A new durable workflow is added, especially one future agents must follow.
- Automation behavior changes, including crawl, ingest, catalog, lint, commit, or push policy.
- Major wiki sections, source types, or local project categories are added.
- Useful commands or validation expectations change.
- `README.md` no longer reflects `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `wiki/index.md`, or `wiki/overview.md`.

## Required Procedure

1. Read `README.md`, `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `wiki/index.md`, and recent `wiki/log.md`.
2. Compare the README against current wiki structure and major workflows.
3. Update only the public-safe, high-level README content.
4. Do not expose private-layer paths, sensitive raw paths, secrets, personal identifiers, or private document contents.
5. Update any relevant wiki workflow page, `wiki/index.md`, and `wiki/log.md` if the README maintenance rule itself changes.
6. Run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`.
7. Stage the scoped README/wiki updates, commit, and push.

## Cadence

- INFERRED: Check README freshness after substantial wiki maintenance, new automation setup, new public-corpus ingest workflows, or major local tooling changes.
- INFERRED: If no material drift is found, do not churn the README; record only when a real refresh or rule update occurred.

## Counterpoints And Gaps

- README refreshes should improve navigation and onboarding, not duplicate the whole wiki index.
- README commits still need scope discipline; do not stage unrelated generated outputs just because the README was touched.
- The public README should stay concise and should point to maintained pages for details.

## Related Pages

- [[public-corpus-ingest-workflow]]
- [[agent-skill-installation-workflow]]
- [[feishu-material-access-workflow]]
