---
title: Implicit Skill Routing
type: concept
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - agent-skills
  - agent-workflow
  - routing
source_pages:
  - AGENTS.md
  - D:/agent-resources/SKILL-INDEX.md
---

# Implicit Skill Routing

## Rule

EXTRACTED: Agents should invoke skills by task intent, not only when the user names a skill.

For non-trivial tasks, the agent should inspect available skill metadata, read the matched `SKILL.md`, and follow the workflow before improvising.

## Routing Sources

| Source | Use |
| --- | --- |
| `D:\agent-resources\SKILL-INDEX.md` | Broad shared skill catalog and routing map. |
| `D:\agent-resources\skills\` | Canonical shared skill library. |
| `.codex/skills/` | Codex project-local skills, including ARIS audit skills. |
| `.claude/skills/` | Claude Code / OpenCode-visible project skills. |

## Practical Triggers

- Research audit, paper review, citation check, and experiment audit → ARIS skills.
- README refresh, public repository presentation, onboarding documentation → `readme-blueprint-generator`.
- Agent memory, tool routing, wrapper failures, or multi-agent infrastructure → agent architecture audit skills.
- Skill creation or trigger/frontmatter optimization → `skill-creator`.
- Debugging, testing, security review, frontend design, browser automation, documents, slides, and spreadsheets → search the shared skill index before acting.

## Quality Bar

- Read the `SKILL.md` body after selecting a skill.
- Use the skill's scripts or references when they exist and are relevant.
- Do not bulk-load whole skill repositories when a specific file is enough.
- If no skill fits a complex task, search curated resources or public GitHub sources before inventing a new workflow.
- Record useful new skill-routing knowledge in `D:\agent-resources\SKILL-INDEX.md` and the wiki.

## Counterpoints And Gaps

- AMBIGUOUS: Tiny wording edits and simple one-command tasks may not benefit from a skill; the routing cost should match task risk.
- INFERRED: Better frontmatter descriptions improve passive triggering more than long always-on prompt rules.
- UNVERIFIED: Some imported skills have not been fully smoke-tested on this Windows workstation and should be validated before high-stakes use.

## Related

- [[agent-skill-installation-workflow]]
- [[agent-skill-repositories]]
- [[agentmemory-first-agent-collaboration]]
