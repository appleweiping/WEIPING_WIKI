---
name: skills-directory-layout
description: |
  Explains the whole-computer/D-drive skill layout, shared agent-resources library, implicit skill triggering, and the retired Agent Hub boundary for future agents.
metadata:
  type: reference
---

# Skills Directory Layout

## Active Model

Skills are chosen by task intent. Agents should inspect skill metadata, read the matched `SKILL.md`, and follow the workflow even when the user did not name the skill.

`agentmemory` is the active memory/collaboration layer. Agent Hub is retired and should not be registered as an active MCP server.

For whole-computer maintenance, project routing, or organization tasks, read `wiki/concepts/whole-computer-project-map.md` first. For D-drive infrastructure detail, also read `wiki/concepts/d-drive-project-map.md`, which separates public exports, private runtime state, skills/resources, and research isolation. For physical C:/D:/G: file moves, use `D:\agent-resources\skills\vipin\workstation-maintenance` before trusting any manifest or type-grouped age-gated move plan, and run its full-plan or exact-batch non-moving preflight before approval. Broad user approval can cover all currently passing low-risk batches.

## Skill Roots

| Path | Purpose |
| --- | --- |
| `D:\agent-resources\SKILL-INDEX.md` | Curated routing index for shared reusable skills. |
| `D:\agent-resources\skills\` | Canonical shared skill/resource library. |
| `D:\Research\vipin's knowledgebase\.claude\skills\` | Claude Code / OpenCode-visible project skills. |
| `D:\Research\vipin's knowledgebase\.codex\skills\` | Codex-visible project skills, including ARIS audit skills. |
| `D:\devtools\claude\skills\` | D-drive Claude home skill links for globally installed agent resources. |
| `D:\devtools\codex\home\skills\` | D-drive Codex home skill links for globally installed agent resources. |

`C:\Users\admin\.claude\skills\` and `C:\Users\admin\.codex` should be junctions into D-drive targets. C drive should not hold the real skill or agent-home payload.

## Routing Rules

- Research audit, paper review, experiment audit, and citation work must use the corresponding ARIS skill when present.
- Whole-computer maintenance, local project routing, wiki refresh, and `vipinknowledge` skill upgrades should use `vipin-wiki`.
- Physical C:/D:/G: file organization should use `workstation-maintenance`; `vipin-wiki` records only the public-safe routing/documentation updates afterward. Full-plan and exact-batch preflights do not authorize movement by themselves.
- README and public-repo presentation work should use `readme-blueprint-generator`.
- Agent/tool/memory architecture work should use an agent architecture audit skill when present.
- Skill creation or frontmatter/trigger optimization should use `skill-creator`.
- Browser, frontend, document, security, and debugging tasks should search `D:\agent-resources\SKILL-INDEX.md` before improvising.

If a task is trivial and no workflow value is added, a skill is optional. If the task is complex, unfamiliar, safety-sensitive, or repetitive, skill lookup is mandatory.

## Installing Or Updating Skills

1. Inspect the upstream source and license.
2. Install the usable skill into `D:\agent-resources\skills\<group>\`.
3. Link it into supported agent homes when it should be globally available.
4. Update `D:\agent-resources\SKILL-INDEX.md` with a concise `What`, `When`, and `Path`.
5. Keep generated caches, toolchains, browser profiles, and account state out of Git.
6. Validate frontmatter and a non-destructive smoke path when possible.

## VipinKnowledge Maintenance Skill

Claude Code and OpenCode can trigger `D:\Research\vipin's knowledgebase\.claude\skills\vipin-wiki\SKILL.md`.

Codex uses `D:\Research\vipin's knowledgebase\.codex\skills\vipin-wiki\SKILL.md` as the full orchestrator. Both routes point to the same canonical command:

```powershell
python scripts/wiki.py maintain --scope whole-computer --json
```

The command writes ignored reports under `.wiki-tmp/vipinknowledge-maintenance/`; curated wiki/skill/doc changes still require validation, scoped staging, commit, and push.

## Retired Agent Hub Boundary

`D:\devtools\agent-hub\` was a custom collaboration experiment. It is historical only.

Do not add old Agent Hub tool instructions, daemon startup requirements, port `9800` dependencies, or MCP server registrations. Use agentmemory signals/actions plus git state instead.

## PixelCat / CC Health Check

Before relying on Opus, Sonnet, or Haiku through Claude Code, run from the vipin wiki root when available:

```powershell
.\scripts\Test-LocalCcPartner.ps1
```

If PixelCat's upstream credentials are disabled, do not debug skill folders or prompts. State the limitation and use Codex-owned review or another available partner when acceptable.
