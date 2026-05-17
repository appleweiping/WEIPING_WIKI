---
title: README Blueprint Generator
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - agent-skills
  - readme
  - documentation
source_pages:
  - 2026-05-17-readme-blueprint-generator-skill
---

# README Blueprint Generator

`readme-blueprint-generator` is a README-focused Codex skill installed locally for high-quality repository README creation, critique, and rewrites.

## Local Installation

- Source mirror: `skill/readme-blueprint-generator/`
- Installed skill: `.codex/skills/readme-blueprint-generator/`
- Upstream source: `github/awesome-copilot`, path `skills/readme-blueprint-generator/SKILL.md`
- Upstream commit checked: `4e4b34c48d3f50934a7a073aed0d05fd46e99b09`
- License: MIT, from the upstream repository.

## Function

- EXTRACTED: The upstream skill generates README documentation by analyzing repository instructions, project structure, architecture, stack, testing, workflow, and standards.
- INFERRED: The local installed version extends the upstream prompt into a stronger README rewrite workflow for this wiki: audience selection, narrative hierarchy, public/private safety, maintainer quick-start value, and visual rhythm.

## Usage

Use this skill when a user asks to:

- rewrite or polish `README.md`;
- improve README aesthetics or information architecture;
- make a project README feel more professional on GitHub;
- align README content with `AGENTS.md`, project purpose, workflows, validation, or contribution rules.

## Smoke Test

- Verified the upstream path and commit with `git ls-remote` and `git show`.
- Mirrored the upstream skill source under the project `skill/` directory.
- Installed a Codex-discoverable `SKILL.md` under `.codex/skills/readme-blueprint-generator/`.
- Used the installed workflow to rewrite this repository's root `README.md`.

## Related Pages

- [[readme-maintenance-workflow]]
- [[agent-skill-installation-workflow]]
- [[durable-agent-rule-memory]]
