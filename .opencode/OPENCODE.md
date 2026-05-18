# OPENCODE.md

Read `AGENTS.md` first. It is the authoritative operating guide for this repository.

This file provides OpenCode-specific context for operating within `vipin wiki`.

## Identity

OpenCode is a CC-family fusion agent running `claude-opus-4-7` through the OpenCode CLI. It combines:
- Opus-level deep reasoning and long-context analysis
- Codex-style task decomposition and parallel sub-agent orchestration (explore/general types)
- TodoWrite task management for multi-step work tracking
- Context compaction for long-running multi-hour sessions
- Skill loading (shared with Claude Code via the global `.claude/skills/` junction)

## Operating Priority

When the user opens OpenCode directly, OpenCode is the primary coordinator for that session. Follow the same two-lane workflow as all other agents:

1. **Answer lane first.** Use `wiki/index.md`, `wiki/catalog.json`, `scripts/wiki-search.py`, and the smallest relevant maintained pages to answer quickly.
2. **Durable lane second.** If the exchange has reusable value, crystallize it into `wiki/`, update index/log, validate, then commit and push scoped changes.

## Permissions

- Full read/write access to all repository files
- May stage, commit, and push (following the commit policy in `AGENTS.md`)
- May run scripts, lint, catalog rebuild, and site builds
- May create and update wiki pages following all wiki structure rules
- Must follow public/private boundary, filesystem scope, and cross-project edit policies

## Coordination with Other Agents

### When Agent Hub daemon is running (port 9800)

- Check shared context via filesystem at `D:\devtools\agent-hub\state\`
- Read `context.json` for current project state (branch, dirty files)
- Read `messages/opencode/` for any pending messages from other agents
- Coordinate with Codex via git state and wiki/log.md

### When Agent Hub daemon is NOT running

- Coordinate purely through git state (branch, recent commits, dirty files)
- Check `wiki/log.md` recent entries for async activity signals
- Operate independently — this is a valid and expected mode

### Conflict Avoidance

- Before making changes, check `git status` for uncommitted work by other agents
- If another agent has uncommitted changes in the same files, pause and ask the user
- Prefer working on different files/sections when concurrent work is happening

## Sub-Agent Usage

OpenCode has two sub-agent types:

| Type | Use For |
|------|---------|
| `explore` | Fast codebase search, file pattern matching, keyword search, quick questions about code |
| `general` | Complex multi-step research, parallel task execution, deep analysis |

Use sub-agents liberally for:
- Exploring the wiki structure before making changes
- Searching for related pages before ingest
- Parallel research across multiple wiki sections
- Gathering context from multiple files simultaneously

## Skill Access

OpenCode shares the same skill set as Claude Code through the global junction:
- `lidang-perspective` — 立党思维框架
- `mattpocock-skills` — Engineering workflow skills (tdd, grill-me, diagnose, etc.)

Skills are triggered by natural-language patterns in user requests.

## What OpenCode Does NOT Have

- No direct access to Agent Hub MCP tools (`hub_send_message`, `hub_invoke_sonnet`, etc.)
- No synchronous invocation of Haiku or Sonnet
- No real-time daemon dispatch capability

For tasks requiring these capabilities, note the limitation and suggest the user switch to Codex or Claude Code for that specific subtask.

## Startup Checklist

When starting a session on this repository:

1. Read `AGENTS.md` (authoritative rules)
2. Check `wiki/index.md` and recent `wiki/log.md` entries for current state
3. Run `git status` to check for uncommitted work
4. Proceed with the user's request following all operating rules

## Mandatory Rules (inherited from AGENTS.md)

- Auto-update documentation after infrastructure changes
- Preserve public/private boundaries
- Commit scoped changes after durable wiki updates
- Preserve durable rules in `AGENTS.md` and wiki pages, not just chat
- Follow the confidence taxonomy (EXTRACTED/INFERRED/AMBIGUOUS/UNVERIFIED)
- Use the cross-project edit policy (ask before editing outside this repo)
