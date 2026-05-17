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
  - 2026-05-17-readme-blueprint-generator-skill
---

# README Maintenance Workflow

## Rule

The root `README.md` is a living entry point for `vipin wiki`, not a one-time bootstrap file.

Future agents should periodically refresh it when the wiki's structure, automation rules, major workflows, or public/private safety boundaries materially change.

For high-impact README rewrites, aesthetic critiques, or information-architecture upgrades, future agents should use a dedicated README/documentation skill before editing. The current local specialist is `readme-blueprint-generator`, installed under `.codex/skills/readme-blueprint-generator/`.

## Refresh Triggers

- A new durable workflow is added, especially one future agents must follow.
- Automation behavior changes, including crawl, ingest, catalog, lint, commit, or push policy.
- Major wiki sections, source types, or local project categories are added.
- Useful commands or validation expectations change.
- `README.md` no longer reflects `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `wiki/index.md`, or `wiki/overview.md`.

## Required Procedure

1. Read `README.md`, `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `wiki/index.md`, and recent `wiki/log.md`.
2. Compare the README against current wiki structure and major workflows.
3. If the change is substantial, load the README specialist skill and use it to shape the hierarchy, narrative, and quality bar.
4. Update only the public-safe, high-level README content.
5. Do not expose private-layer paths, sensitive raw paths, secrets, personal identifiers, or private document contents.
6. Update any relevant wiki workflow page, `wiki/index.md`, and `wiki/log.md` if the README maintenance rule itself changes.
7. Run `scripts/wiki-catalog.ps1`, `scripts/wiki-lint.ps1`, and `git diff --check`.
8. Stage the scoped README/wiki updates, commit, and push.

## Cadence

- INFERRED: Check README freshness after substantial wiki maintenance, new automation setup, new public-corpus ingest workflows, or major local tooling changes.
- INFERRED: If no material drift is found, do not churn the README; record only when a real refresh or rule update occurred.

## Counterpoints And Gaps

- README refreshes should improve navigation and onboarding, not duplicate the whole wiki index.
- README commits still need scope discipline; do not stage unrelated generated outputs just because the README was touched.
- The public README should stay concise and should point to maintained pages for details.
- The README specialist skill is a design and information-architecture aid, not a license to ignore project-specific operating docs.

## Related Pages

- [[public-corpus-ingest-workflow]]
- [[agent-skill-installation-workflow]]
- [[feishu-material-access-workflow]]
