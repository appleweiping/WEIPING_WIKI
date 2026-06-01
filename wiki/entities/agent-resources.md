---
title: Agent Resources
type: entity
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - agent-skills
  - local-projects
  - infrastructure
source_pages:
  - D:/agent-resources/README.md
  - D:/agent-resources/SKILL-INDEX.md
---

# Agent Resources

## Summary

EXTRACTED: `D:/agent-resources` is the canonical shared D-drive library for reusable agent skills, workflow templates, reference repositories, and skill-routing metadata.

EXTRACTED: Its public-facing role is to help agents choose relevant skills implicitly by task intent rather than waiting for the user to name a skill.

## Current Role

- Skill catalog and install root for reusable `SKILL.md` bundles.
- Public-safe README and `SKILL-INDEX.md` for routing.
- Source/provenance record for skill packs that are mirrored or adapted locally.
- Shared dependency for Codex, Claude Code, OpenCode, and related local agents.

## Open-Source Boundary

INFERRED: The repository can be public only if it excludes vendored caches, broad toolchains, private account state, generated runtime artifacts, secrets, and unlicensed/provenance-unclear payloads.

Before public visibility changes, run secret scans and preserve upstream license/provenance notes for included skill packs.

## Related

- [[agent-skill-repositories]]
- [[agent-skill-installation-workflow]]
- [[implicit-skill-routing]]
- [[agentmemory-first-agent-collaboration]]
