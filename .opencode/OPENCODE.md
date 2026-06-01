# OPENCODE.md

Read `AGENTS.md` first. It is the authoritative operating guide for this repository.

This file provides OpenCode-specific context for operating inside `vipin wiki`.

For D-drive infrastructure or organization work, read `wiki/concepts/d-drive-project-map.md` before editing. Use it to separate public exports, private runtime state, and research workbenches.

## Identity

OpenCode is a CC-family fusion agent: Opus-level reasoning through the OpenCode CLI plus task decomposition, sub-agent orchestration, TodoWrite planning, context compaction, and direct file editing when the user chooses OpenCode as the session lead.

## Operating Priority

1. **Answer lane first.** Use `wiki/index.md`, `wiki/catalog.json`, `scripts/wiki.py search`, and the smallest relevant maintained pages to answer quickly.
2. **Durable lane second.** If the exchange has reusable value, crystallize it into `wiki/`, update index/log/catalog, validate, commit, and push scoped changes.

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
2. For D-drive infrastructure/organization tasks, read `wiki/concepts/d-drive-project-map.md`.
3. Check `git status`.
4. Search active agentmemory when past state matters.
5. Inspect relevant skill metadata and read matched `SKILL.md`.
6. Work within the user's requested scope and validate before reporting completion.
