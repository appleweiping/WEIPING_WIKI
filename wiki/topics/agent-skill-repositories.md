---
title: Agent Skill Repositories
type: topic
status: active
created: 2026-05-15
updated: 2026-05-17
tags:
  - topic
  - agent-skills
  - local-projects
source_pages:
  - 2026-05-15-d-drive-healthcare-and-skill-roots
  - 2026-05-16-skill-source-repository-trace
  - 2026-05-17-paper-orchestra-github
  - 2026-05-17-content-creation-publisher-skill
  - 2026-05-17-anbeime-frontend-design-and-chrome-automation
---

# Agent Skill Repositories

## Scope

This topic tracks local repositories and project-local mirrors that collect, generate, install, evaluate, or optimize agent skills.

## Current Source Base

- [[2026-05-15-d-drive-healthcare-and-skill-roots]] - Read-only public-safe survey of the D-drive skill roots.
- [[2026-05-16-skill-source-repository-trace]] - Upstream/origin trace for migrated local skill repositories.
- [[2026-05-17-paper-orchestra-github]] - GitHub source note and local installation record for the PaperOrchestra paper-writing skill pack.
- [[2026-05-17-content-creation-publisher-skill]] - Source note and local installation record for the Anbeime content creation/publishing skill pack.
- [[2026-05-17-anbeime-frontend-design-and-chrome-automation]] - Source note, installation record, and smoke-test record for Anbeime frontend design and Chrome automation skills.

## Current Roots

| Page | Local root | Main purpose |
| --- | --- | --- |
| [[anbeime-skill]] | `D:/Skill/anbeime-skill` | Fork of `anbeime/skill`; skill store / skill-library crawler and local collected skill inventory. |
| [[colleague-skill]] | `D:/Skill/colleague-skill` | Fork of `titanwings/colleague-skill`; `dot-skill` meta-skill for distilling people/context into reusable skills. |
| [[darwin-skill]] | `D:/Skill/darwin-skill` | Fork of `alchaincyf/darwin-skill`; autonomous skill optimizer and scoring loop. |
| [[mattpocock-skills]] | `D:/Skill/mattpocock-skills` | Fork of `mattpocock/skills`; small composable engineering and productivity skills. |
| [[nuwa-skill]] | `D:/Skill/nuwa-skill` | Fork of `alchaincyf/nuwa-skill`; research-driven person-perspective skill creation. |
| [[paper-orchestra]] | `D:/Research/vipin's knowledgebase/skill/paper-orchestra` | Mirror of `Ar9av/PaperOrchestra`; multi-agent paper-writing skill pack installed into project-local `.codex/skills/`. |
| [[content-creation-publisher]] | `D:/Research/vipin's knowledgebase/skill/content-creation-publisher` | Sub-skill mirror from `anbeime/skill`; content capture, Markdown formatting, illustration, and WeChat/X publishing workflow installed into `.codex/skills/`. |
| [[frontend-design]] | `D:/Research/vipin's knowledgebase/skill/frontend-design` | Sub-skill mirror from `anbeime/skill`; distinctive production-grade frontend design guidance installed into `.codex/skills/`. |
| [[chrome-automation]] | `D:/Research/vipin's knowledgebase/skill/chrome-automation` | Sub-skill mirror from `anbeime/skill`; real Chrome CDP automation via agent-browser installed into `.codex/skills/` and smoke-tested. |

## Practical Takeaways

- EXTRACTED: All five primary inspected roots are git repositories with upstream remotes that point to their original public repositories.
- EXTRACTED: `nuwa-skill` had only an untracked `scripts/__pycache__/` cache at the 2026-05-16 trace; treat it as unrelated local cache.
- INFERRED: Use [[anbeime-skill]] for broad skill discovery and inventory.
- INFERRED: Use [[colleague-skill]] or [[nuwa-skill]] when the goal is to build a skill that represents a person, relationship, or perspective.
- INFERRED: Use [[darwin-skill]] when the goal is to review or optimize an existing `SKILL.md`.
- INFERRED: Use [[mattpocock-skills]] when looking for disciplined engineering workflow patterns.
- INFERRED: Use [[paper-orchestra]] when the goal is to transform research ideas, experiment logs, figures, citations, and templates into a structured LaTeX paper workflow.
- INFERRED: Use [[content-creation-publisher]] when the goal is to collect web content, format Markdown, add illustrations, or prepare/publish to WeChat and X.
- INFERRED: Use [[frontend-design]] for distinctive frontend/interface design work.
- INFERRED: Use [[chrome-automation]] when real visible Chrome automation is required.

## Operating Rules

- Rescan the live repository before claiming current branch, cleanliness, file count, or installability.
- Do not assume local forks exactly match upstream projects.
- If installing or modifying skills from these repos, inspect each repo's own instructions first.
- Treat `origin` as Vipin's fork/mirror and `upstream` as the original source repository when present.
- Classify this corpus as `skill`, not as generic local projects, because the durable unit is reusable agent behavior encoded in `SKILL.md` and related tooling.
- For project-local `.codex/skills/` installs, keep a source mirror under `skill/` when practical so future agents can inspect upstream docs and reinstall without using the C drive.
- Follow [[agent-skill-installation-workflow]] for future skill installs; do not treat untested skill files as usable.

## Counterpoints And Gaps

- This page records repository-level routing only.
- Individual skills inside these repositories were not validated for correctness, safety, dependency availability, or host compatibility.
- Some repositories contain generated assets, demos, or examples that may not be needed for normal skill use.
- `D:/Skill` also contains non-git/generated project folders such as video prompt packages and local MCP experiments; these should be ingested separately if they become durable skills.
- `PaperOrchestra` is stored under this wiki repository rather than the separate `D:/Skill` root, so future current-state checks should inspect both `skill/paper-orchestra/` and `.codex/skills/`.
- `content-creation-publisher` can create public posts, so live publishing should require explicit user confirmation.

## Related Pages

- [[local-project-roots]]
- [[2026-05-15-d-drive-healthcare-and-skill-roots]]
