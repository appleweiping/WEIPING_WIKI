---
title: Agent Skill Repositories
type: topic
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - topic
  - agent-skills
  - local-projects
source_pages:
  - 2026-05-15-d-drive-healthcare-and-skill-roots
---

# Agent Skill Repositories

## Scope

This topic tracks local repositories under `D:/Skill` that collect, generate, install, evaluate, or optimize agent skills.

## Current Source Base

- [[2026-05-15-d-drive-healthcare-and-skill-roots]] - Read-only public-safe survey of the D-drive skill roots.

## Current Roots

| Page | Local root | Main purpose |
| --- | --- | --- |
| [[anbeime-skill]] | `D:/Skill/anbeime-skill` | Skill store / skill-library crawler and local collected skill inventory. |
| [[colleague-skill]] | `D:/Skill/colleague-skill` | `dot-skill` meta-skill for distilling people/context into reusable skills. |
| [[darwin-skill]] | `D:/Skill/darwin-skill` | Autonomous skill optimizer and scoring loop. |
| [[mattpocock-skills]] | `D:/Skill/mattpocock-skills` | Small composable engineering and productivity skills. |
| [[nuwa-skill]] | `D:/Skill/nuwa-skill` | Research-driven person-perspective skill creation. |

## Practical Takeaways

- EXTRACTED: All five inspected roots are git repositories with clean working trees at inspection time.
- INFERRED: Use [[anbeime-skill]] for broad skill discovery and inventory.
- INFERRED: Use [[colleague-skill]] or [[nuwa-skill]] when the goal is to build a skill that represents a person, relationship, or perspective.
- INFERRED: Use [[darwin-skill]] when the goal is to review or optimize an existing `SKILL.md`.
- INFERRED: Use [[mattpocock-skills]] when looking for disciplined engineering workflow patterns.

## Operating Rules

- Rescan the live repository before claiming current branch, cleanliness, file count, or installability.
- Do not assume local forks exactly match upstream projects.
- If installing or modifying skills from these repos, inspect each repo's own instructions first.

## Counterpoints And Gaps

- This page records repository-level routing only.
- Individual skills inside these repositories were not validated for correctness, safety, dependency availability, or host compatibility.
- Some repositories contain generated assets, demos, or examples that may not be needed for normal skill use.

## Related Pages

- [[local-project-roots]]
- [[2026-05-15-d-drive-healthcare-and-skill-roots]]
