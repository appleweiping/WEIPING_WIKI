---
title: 2026-05-16 Skill Source Repository Trace
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - agent-skills
  - local-projects
source_files:
  - D:/Skill
source_pages:
  - https://github.com/anbeime/skill
  - https://github.com/titanwings/colleague-skill
  - https://github.com/alchaincyf/darwin-skill
  - https://github.com/mattpocock/skills
  - https://github.com/alchaincyf/nuwa-skill
---

# 2026-05-16 Skill Source Repository Trace

## Provenance

- Source: user request in chat to trace local `D:/Skill` folders back to original repositories and classify the corpus as `skill`.
- Inspection mode: local git remote/status/log checks plus public GitHub API metadata for upstream repositories.
- Scope: repository-level provenance, not full content mirroring.

## Primary Skill Repositories

| Local root | Vipin fork/origin | Original upstream | Local branch | Local HEAD | Upstream relation |
| --- | --- | --- | --- | --- | --- |
| `D:/Skill/anbeime-skill` | `appleweiping/skill` | `anbeime/skill` | `main` | `6646c3a64cd3e2a4f8cb3703c3a298086d4c6dc9` | local HEAD differs from upstream `049efd5f29fb47c9165871caac4e61b4c67cb2c9` |
| `D:/Skill/colleague-skill` | `appleweiping/colleague-skill` | `titanwings/colleague-skill` | `dot-skill` | `97c75c55449fb1ce9e11ad8967f30d04008554fc` | matches upstream HEAD |
| `D:/Skill/darwin-skill` | `appleweiping/darwin-skill` | `alchaincyf/darwin-skill` | `master` | `2056abfccd924d68ae6baa9193cafff0f666260b` | matches upstream HEAD |
| `D:/Skill/mattpocock-skills` | `appleweiping/skills` | `mattpocock/skills` | `main` | `e74f0061bb67222181640effa98c675bdb2fdaa7` | matches upstream HEAD |
| `D:/Skill/nuwa-skill` | `appleweiping/nuwa-skill` | `alchaincyf/nuwa-skill` | `main` | `ea4b9abfe0e60e5051ed946c70e51434402d3545` | matches upstream HEAD; untracked `scripts/__pycache__/` cache ignored |

## Classification

- EXTRACTED: These repositories belong under the `skill` category because their durable unit is `SKILL.md`-style agent behavior, skill stores, skill creation, or skill optimization.
- EXTRACTED: `origin` points to Vipin's fork or local mirror; `upstream` points to the original public repository when configured.
- INFERRED: Future updates should compare against upstream first, then decide whether Vipin's fork needs sync, adaptation, or local-only preservation.

## Non-Primary Skill Adjacent Folders

- EXTRACTED: `D:/Skill/canon-pianist-ai-video-project` is a non-git AI video prompt package, not currently a source skill repo.
- EXTRACTED: `D:/Skill/deepseek-mcp` is a local MCP server folder, not currently a git-traced skill repo.
- EXTRACTED: `D:/Skill/CHARACTER` and `D:/Skill/_video_style_analysis` are local non-git folders and were not treated as source skill repositories in this trace.

## Public Handling

- Do not mirror full upstream repos into the public wiki.
- Preserve provenance, repository role, upstream/fork relationship, current HEAD, source confidence, and usage routing.
- Re-scan live remotes before making current claims because these upstream projects are active.

## Counterpoints And Gaps

- Individual `SKILL.md` files inside the repositories were not audited for safety or quality in this pass.
- Upstream star counts and descriptions can change; refresh public GitHub metadata before citing current popularity.
- Non-git skill-adjacent folders may still be valuable, but they require separate provenance before public wiki ingestion.

## Related

- [[agent-skill-repositories]]
- [[anbeime-skill]]
- [[colleague-skill]]
- [[darwin-skill]]
- [[mattpocock-skills]]
- [[nuwa-skill]]
