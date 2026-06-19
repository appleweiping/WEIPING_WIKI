# OPENCODE.md

Read `AGENTS.md` first. It is the authoritative operating guide for this repository.

This file provides OpenCode-specific context for operating inside `WEIPING_WIKI` / `Weiping Wiki`.

For whole-computer maintenance, project routing, or local file-organization work, use the `weiping-wiki` skill when available; `vipin-wiki` is a historical alias and may remain as a legacy folder or automation string. Read `wiki/concepts/whole-computer-project-map.md` first. Use `wiki/concepts/d-drive-project-map.md` and `wiki/concepts/weiping-agentic-project-constellation.md` for D-drive infrastructure detail, public exports, private runtime state, agentic method repos, and research workbenches. For physical C:/D:/G: organization, use `D:\agent-resources\skills\vipin\workstation-maintenance` first; it owns dry-run manifests, full-plan, exact-batch, and D-root organization non-moving preflights, approval packets, approved move batches, D-root move-with-junction organization, and rollback manifests. Broad user approval can cover all currently passing low-risk batches. The continuous maintenance system is documented at `wiki/concepts/weiping-wiki-maintenance-system.md`; recurring Codex maintenance should use `gpt-5.5` with `xhigh` reasoning when supported.

## Identity

OpenCode is a CC-family fusion agent: Opus-level reasoning through the OpenCode CLI plus task decomposition, sub-agent orchestration, TodoWrite planning, context compaction, and direct file editing when the user chooses OpenCode as the session lead.

## Operating Priority

1. **Answer lane first.** Use `wiki/index.md`, `wiki/catalog.json`, `scripts/wiki.py search`, and the smallest relevant maintained pages to answer quickly.
2. **Durable lane second.** If the exchange has reusable value, crystallize it into `wiki/`, update index/log/catalog, validate, commit, and push scoped changes.

The unified CLI provides the LLM Wiki v2 toolset: `wiki.py crystallize`, `lifecycle`, `graph`, `scrub`, `health --fix`, and `search --graph` / `--semantic`. See `wiki/analyses/2026-06-19-weiping-wiki-upgrade-audit.md`.

## Active Memory

Use `agentmemory` as the active memory and coordination substrate:

- Recall/search memory when past state matters.
- Save important decisions, findings, lessons, and configuration changes.
- Use agentmemory signals for cross-agent handoffs.
- Do not use Agent Hub queues or `D:\devtools\agent-hub` as active infrastructure.

The repo-local markdown `memory/` tree is historical/superseded unless the task explicitly targets it. Public-safe durable facts belong in `wiki/`.

## Permissions

- Full read/write access to repository files when the user starts OpenCode directly.
- May stage, commit, and push scoped changes.
- Must preserve public/private boundaries and avoid unrelated local dirty work.
- Must not modify research experiment progress, datasets, checkpoints, server state, or non-requested external repos.

## Skill Routing

OpenCode should trigger skills by task intent, not only explicit names:

1. Inspect `D:\agent-resources\SKILL-INDEX.md` and available project skills.
2. Read the selected `SKILL.md`.
3. Follow that workflow before improvising.

Research audit work must use ARIS skills. README, documentation, architecture, debugging, frontend, browser, and security tasks should route to the relevant installed skill when available.

Broad file moves require approved type-grouped age-gated workstation-maintenance batches. D-root directory organization requires a drive-root plan and preflight, then moves eligible roots under `D:\_Organized` while preserving old paths as junctions. Broad user approval can cover all currently passing low-risk batches. Never move or delete `D:\Research` resolved paths during local organization work.

## Coordination

- Check `git status` before editing.
- Check recent `wiki/log.md` entries for async activity.
- Coordinate with Codex through git state and agentmemory signals.
- If another agent has uncommitted changes in the same files, pause and ask the user before proceeding.

## Sub-Agent Usage

Use OpenCode sub-agents for bounded exploration and parallel analysis:

| Type | Use For |
| --- | --- |
| `explore` | Fast search, file pattern matching, quick repository questions. |
| `general` | Multi-step research, deeper analysis, parallel read-only context gathering. |

The session lead remains responsible for verifying sub-agent claims before editing, staging, committing, or pushing.

## Startup Checklist

1. Read `AGENTS.md`.
2. For whole-computer maintenance, project routing, or local organization tasks, read `wiki/concepts/whole-computer-project-map.md`; for D-drive infrastructure detail, also read `wiki/concepts/d-drive-project-map.md`.
3. Check `git status`.
4. Search active agentmemory when past state matters.
5. Inspect relevant skill metadata and read matched `SKILL.md`.
6. Work within the user's requested scope and validate before reporting completion.

For whole-computer upkeep, run `python scripts/wiki.py maintain --scope whole-computer --json` first, then make only curated scoped wiki/skill/doc updates when evidence changed.
