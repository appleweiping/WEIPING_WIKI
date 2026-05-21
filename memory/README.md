# Shared Agent Memory

All agents (Claude Code, Codex/GPT-5.5, DeepSeek Pro, OpenHands, OpenCode) share this directory as persistent memory. No server dependency — just read/write markdown files.

## Structure

```
memory/
  INDEX.md           ← Start here. Auto-maintained index of all memories.
  decisions/         Architectural decisions, plans, permanent rules
  facts/             Current state, project status, server mappings
  lessons/           Bugs found, patterns learned, what worked/failed
  preferences/       User preferences, agent behavior rules
  workflows/         Reusable procedures (ARIS steps, etc.)
  sessions/          Per-session summaries (significant sessions only)
```

## File Format

Every memory file uses YAML frontmatter + markdown body:

```yaml
---
title: "Short descriptive title"
type: decision | fact | workflow | lesson | preference | session
created: 2026-05-21T10:00:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: claude | codex | opencode | deepseek | openhands
tags: [tag1, tag2]
related: [other-file.md]
---

Content here. Plain markdown.
```

## Rules

1. **Any agent may read any memory file at any time.**
2. **Any agent may write new files or update existing ones.**
3. Use lowercase-kebab-case filenames.
4. Prefer updating an existing memory over creating a duplicate.
5. When a fact becomes outdated, update the file in-place (git preserves history).
6. Do not store secrets, API keys, or credentials.
7. After writing/updating, regenerate INDEX.md (scan all files, rebuild table).
8. Memory files are git-tracked. Commit with other wiki changes when practical.

## How to Read

1. **INDEX.md** — scan for relevant titles/tags, then read specific files
2. **Grep** — search across all files: `grep -r "keyword" memory/`
3. **Directory** — browse by category (facts/ for status, decisions/ for rules)
4. **Related field** — follow links between memories for context

## How to Write

1. Pick the right subdirectory based on content type
2. Create a `.md` file with valid YAML frontmatter
3. Use descriptive filename (e.g., `pony-current-status.md`)
4. Set `agent:` to your identity
5. Add relevant `tags:` for searchability
6. Update INDEX.md

## On Session Start

Read `INDEX.md` and any files relevant to the current task.

## On Session End (significant sessions only)

Write a brief summary to `sessions/YYYY-MM-DD_short-description.md`.
