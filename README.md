<div align="center">
<img src="banner.png" alt="Vipin's Knowledgebase" width="720" />
</div>

# vipin wiki

A source-backed knowledge system for turning research, conversations, and agent work into maintained, interlinked Markdown.

The wiki is the public crystallization layer. Day-to-day agent memory and collaboration now live in `agentmemory`; stable facts, rules, source notes, and reusable answers are promoted back into `wiki/` when they deserve a durable public home.

## Start Here

| You are | First step | Then |
| --- | --- | --- |
| Vipin | Open Codex, Claude Code, or OpenCode | Talk naturally. Agents choose skills, use agentmemory, update the wiki, and make scoped commits when useful. |
| A future agent | Read `AGENTS.md` | For whole-computer maintenance or local project routing, read `wiki/concepts/whole-computer-project-map.md`; for D-drive infrastructure detail, read `wiki/concepts/d-drive-project-map.md`; for physical C:/D:/G: organization, use `D:\agent-resources\skills\vipin\workstation-maintenance`; then check `wiki/index.md`, `wiki/catalog.json`, and recent `wiki/log.md`; use agentmemory for active recall/collaboration. |
| A human reader | Open `wiki/index.md` | Follow entities, concepts, sources, analyses, and saved query pages. |
| A maintainer | Run `python scripts/wiki.py maintain --scope whole-computer --json` | Review the ignored maintenance report, make curated updates only when evidence changed, then validate before committing. |

## What This Repo Holds

| Layer | Path | Purpose |
| --- | --- | --- |
| Operating contract | `AGENTS.md`, `CLAUDE.md`, `.opencode/OPENCODE.md` | Rules for agent behavior, wiki edits, collaboration, skills, commits, and public/private boundaries. |
| Public wiki | `wiki/` | Maintained knowledge graph: entities, concepts, topics, sources, analyses, queries, timelines, and logs. |
| Private layer | `wiki-private/` | Local-only sensitive material; never indexed into the public wiki or public Git. |
| Raw sources | `raw/` | Immutable public-safe source packages and manifests. |
| Automation | `scripts/` | The canonical CLI is `python scripts/wiki.py <command>`. |
| Publishing | `site/` | Quartz adapter for GitHub Pages; `wiki/` remains the source of truth. |
| Skills | `.codex/skills/`, `.claude/skills/` | Project-local skills; broader reusable skills live in `D:\agent-resources`. |

## Agentmemory-First Collaboration

The old custom Agent Hub is retired. Historical pages may still describe it, but active coordination should use [agentmemory](https://github.com/rohitg00/agentmemory).

Agents should use:

- `memory_recall` / smart search for active memory retrieval.
- `memory_save` for important decisions, lessons, configurations, and findings.
- `memory_signal_send` / signal reads for cross-agent handoffs.
- action/checkpoint tools when a task needs coordination state.

Markdown files under `memory/` are now a historical/superseded layer unless the user explicitly asks to work with them. Reusable public-safe knowledge should be crystallized into `wiki/` pages instead of requiring every agent to dual-write session files.

## Implicit Skill Routing

Agents should not wait for the user to name a skill. For non-trivial work, classify the task intent, inspect available skill metadata, read the matched `SKILL.md`, and follow that workflow before acting.

Primary skill roots:

| Root | Use |
| --- | --- |
| `D:\agent-resources\SKILL-INDEX.md` | Broad curated skill index and routing map. |
| `D:\agent-resources\skills\` | Shared reusable skill library. |
| `D:\agent-resources\skills\vipin\workstation-maintenance` | Shared C:/D:/G: inventory, batch-move, rollback, and agent-infrastructure sync workflow. |
| `.codex/skills/` | Codex project-local skills, including ARIS research audit workflows. |
| `.claude/skills/` | Claude Code / OpenCode-visible project skills. |

Research-audit work remains strict: use the appropriate ARIS skill and preserve evidence labels, baseline boundaries, and experiment integrity.

## Common Commands

```powershell
python scripts/wiki.py status
python scripts/wiki.py health
python scripts/wiki.py catalog
python scripts/wiki.py lint
python scripts/wiki.py search "agentmemory"
python scripts/wiki.py context L1 --query "whole-computer maintenance"
python scripts/wiki.py maintain --scope whole-computer --json
python scripts/wiki.py obsidian export --json
python scripts/wiki.py obsidian commands --json
python scripts/wiki.py obsidian quick "whole-computer maintenance"
python scripts/wiki.py obsidian backlinks vipinknowledge-maintenance-system
powershell .\scripts\computer-inventory.ps1
powershell .\scripts\wiki-maintenance-audit.ps1
powershell .\scripts\wiki-maintain.ps1 -Scope whole-computer -Json
powershell D:\agent-resources\skills\vipin\workstation-maintenance\scripts\New-WorkstationInventory.ps1 -OutputDir ".wiki-tmp\workstation-maintenance"
powershell D:\agent-resources\skills\vipin\workstation-maintenance\scripts\New-MovePlan.ps1 -ManifestPath "<manifest.json>"
powershell D:\agent-resources\skills\vipin\workstation-maintenance\scripts\Test-MovePlanBatches.ps1 -MovePlanPath "<move-plan.json>"
powershell D:\agent-resources\skills\vipin\workstation-maintenance\scripts\Invoke-ApprovedMoveBatch.ps1 -MovePlanPath "<move-plan.json>" -BatchId "<batch-id>" -PreflightOnly
```

The move-plan command defaults to a 30-day age gate and 100-item batch cap for live manifests; recent files are deferred for review instead of placed in executable batches. `Test-MovePlanBatches.ps1` is a non-moving readiness check for every proposed batch, not approval to move files.

Compatibility wrappers still exist for older workflows, but `scripts/wiki.py` is the canonical surface.

## Knowledge Workflows

| Workflow | When | Output |
| --- | --- | --- |
| Answer | User asks a substantive question | Grounded answer from maintained pages and active memory when relevant. |
| Crystallize | A conversation produced reusable knowledge | Query, concept, analysis, source, or topic page plus log/catalog updates. |
| Ingest | A source should become durable knowledge | Source page plus linked entities, concepts, or topics. |
| Maintain | Pages drift, duplicate, or go stale | Non-destructive cleanup, supersession notes, and validation. |
| Publish | Public wiki changes | Catalog/lint checks, scoped commit, and GitHub push. |

## Quality Rules

- Use the `.wiki-schema.md` confidence taxonomy: `EXTRACTED`, `INFERRED`, `AMBIGUOUS`, `UNVERIFIED`.
- Preserve public/private boundaries. Public pages must not expose secrets, tokens, private chats, private docs, or sensitive personal data.
- Keep research project claims inside their evidence gates. Do not change experiment progress, datasets, checkpoints, or server state from this repo.
- Stage only scoped files. Existing unrelated dirty work belongs to its owner.
- Infrastructure changes must update the relevant operating docs in the same commit.
- Whole-computer maintenance, local project routing, or file-organization work should start from [whole-computer project map](wiki/concepts/whole-computer-project-map.md); D-drive infrastructure detail stays in [D-drive project map](wiki/concepts/d-drive-project-map.md) so agent runtime cleanup stays separate from research experiments. Physical drive organization must use the shared workstation-maintenance skill, produce a dry-run manifest first, defer recent files and cap batch sizes by default, optionally preflight the full plan or an exact batch, and move only user-approved batches with rollback manifests.
- Continuous VipinKnowledge maintenance is documented in [VipinKnowledge maintenance system](wiki/concepts/vipinknowledge-maintenance-system.md). Weekly automation should report first, update only curated scoped files, validate, then commit and push when real evidence changed.
- Obsidian-compatible local-first features are documented in [Obsidian feature parity](wiki/concepts/obsidian-feature-parity.md). Use `python scripts/wiki.py obsidian export --json` to refresh vault config, Bases, Canvas, command palette, templates, slides home, workspaces, and the dashboard.

## Related Repositories

| Repo | Purpose |
| --- | --- |
| [agent-resources](https://github.com/appleweiping/agent-resources) | Public curated skills, workflows, references, and implicit skill-routing guidance. |
| [devtools-public](https://github.com/appleweiping/devtools-public) | Clean public export of D-drive-first local agent infrastructure. |
| [agentmemory](https://github.com/rohitg00/agentmemory) | Upstream persistent memory and MCP coordination system. |

## For Agents

Read `AGENTS.md` first. It defines the mission, source hierarchy, collaboration tone, agentmemory policy, implicit skill routing, cross-project boundaries, validation gates, and commit discipline.

Agent Hub references in older pages are historical unless explicitly marked active by a newer rule. The current operating model is agentmemory-first.
