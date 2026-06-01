---
title: Agent Skill Installation Workflow
type: concept
status: active
created: 2026-05-17
updated: 2026-06-01
tags:
  - concept
  - agent-skills
  - workflow
source_pages:
  - 2026-05-17-anbeime-frontend-design-and-chrome-automation
  - 2026-05-17-content-creation-publisher-skill
  - 2026-05-17-paper-orchestra-github
  - 2026-05-17-larksuite-cli-feishu-bridge
  - 2026-05-17-readme-blueprint-generator-skill
---

# Agent Skill Installation Workflow

## Rule

Installing a skill means making it usable and discoverable by intent, not merely archiving its files.

## Required Workflow

When the user asks to install a skill from GitHub or another source:

1. Inspect current git status.
2. Fetch the narrowest relevant upstream path, preferably with sparse checkout when the user provides a subdirectory URL.
3. Preserve a source mirror under `D:\agent-resources\repos\<name>` or another documented D-drive source path when useful.
4. Install usable skill files under `D:\agent-resources\skills\<group>\<skill-name>` and link them into supported agent homes when they should be global.
5. If a pack contains independently triggerable sub-skills, install those sub-skills directly as well when that improves usability.
6. Read the upstream `SKILL.md` and nearby references/scripts before summarizing.
7. Install or download missing narrow dependencies into `.wiki-tmp/` or another D-drive project-local cache when practical.
8. Run realistic validation:
   - Guidance-only skills: verify install paths, frontmatter, trigger intent, and enough content to be discoverable.
   - Scripted skills: run help/version commands and at least one non-destructive smoke test.
   - Browser or publishing skills: verify runtime setup, but require explicit user confirmation before account actions, submissions, or live posts.
9. Update `D:\agent-resources\SKILL-INDEX.md` with concise `What`, `When`, and `Path` entries so future agents can trigger the skill implicitly.
10. Record function, contribution, concrete usage, local paths, dependencies, smoke-test results, and limitations in wiki pages when public-safe and durable.
11. Update `wiki/index.md`, relevant entity/topic pages, `wiki/log.md`, and `wiki/catalog.json` when wiki pages change.
12. Run `python scripts/wiki.py catalog` and `python scripts/wiki.py lint`.
13. Stage only scoped resource installs, links, docs, and wiki updates.
14. Commit and push.

## Anti-Toyification Rule

- Do not skip dependency installation or runtime verification just to finish faster.
- Do not report a skill as usable when only files were copied and executable dependencies were not checked.
- If a dependency cannot be fully installed, record the exact blocker and the highest non-destructive validation achieved.
- Prefer D-drive local/cache installs over C-drive or global installs unless the user explicitly asks otherwise.
- Do not commit downloaded toolchains, build artifacts, browser profiles, account state, or caches unless they are deliberate source files.

## Current Examples

- [[paper-orchestra]]: source mirror plus 9 installed skills and wiki usage pattern.
- [[content-creation-publisher]]: aggregate skill plus 5 direct sub-skills, Bun runtime validation, and publishing safety boundary.
- [[frontend-design]]: guidance-only frontend aesthetic skill installed and documented.
- [[chrome-automation]]: executable browser automation skill installed with D-drive agent-browser runtime and real CDP smoke test.
- [[feishu-bridge]] and [[lark-cli]]: official Lark/Feishu CLI runtime installed on D drive, selected official lark-* skills installed, router skill added, command-level smoke tests passed, and OAuth-gated live-resource tests explicitly marked pending.
- [[readme-blueprint-generator]]: GitHub `awesome-copilot` README specialist skill mirrored locally, installed under `.codex/skills`, enhanced for top-tier README rewrites, and used to refresh the project README.

## Counterpoints And Gaps

- AMBIGUOUS: Some skills are pure instruction documents; their "test" is necessarily install/discovery and future-output quality rather than a deterministic command.
- AMBIGUOUS: Some executable skills need account access, credentials, paid APIs, or public posting; validation should stop at non-destructive smoke tests unless the user explicitly approves live actions.
- INFERRED: The workflow should not force broad global toolchain installs when a narrow D-drive local runtime can validate the skill.

## Related Pages

- [[agent-skill-repositories]]
- [[anbeime-skill]]
- [[content-creation-publisher]]
- [[chrome-automation]]
- [[feishu-bridge]]
- [[lark-cli]]
