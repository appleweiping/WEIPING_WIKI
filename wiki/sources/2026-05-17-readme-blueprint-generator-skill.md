---
title: README Blueprint Generator Skill
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - readme
  - github
source_files:
  - skill/readme-blueprint-generator/
  - .codex/skills/readme-blueprint-generator/
---

# README Blueprint Generator Skill

## Provenance

- Source repository: `https://github.com/github/awesome-copilot`
- Source path: `skills/readme-blueprint-generator/SKILL.md`
- Checked commit: `4e4b34c48d3f50934a7a073aed0d05fd46e99b09`
- License: MIT.
- Local source mirror: `skill/readme-blueprint-generator/`
- Local installed skill: `.codex/skills/readme-blueprint-generator/`

## Extracted Function

- EXTRACTED: The upstream skill is a README generation prompt that analyzes repository documentation and creates well-structured Markdown documentation.
- EXTRACTED: It covers project description, technology stack, architecture, getting started, project structure, key features, workflow, coding standards, testing, contributing, and license.

## Local Adaptation

- INFERRED: The upstream skill was too generic for this wiki's current README quality problem, so the installed version was adapted into a stronger README rewrite workflow.
- INFERRED: The local version emphasizes audience, information architecture, visual rhythm, public/private boundaries, maintainer quick-start value, and validation against repository operating docs.

## Contribution To This Wiki

- Provides a dedicated README specialist skill for future README rewrites and critiques.
- Supports the README maintenance workflow by giving future agents a concrete specialist skill to load before substantial README edits.
- Helped rewrite the root `README.md` into a more polished public entry point and maintainer guide.

## Usage

Trigger `readme-blueprint-generator` when the task involves:

- README rewrite or generation;
- README aesthetic critique;
- repository documentation polish;
- onboarding or maintainer quick-start improvements;
- aligning README with project rules, workflows, validation, or safety boundaries.

## Validation

- Verified upstream reachability with `git ls-remote`.
- Read upstream `SKILL.md` through `git show`.
- Mirrored the upstream file and license under `skill/readme-blueprint-generator/`.
- Installed `.codex/skills/readme-blueprint-generator/SKILL.md`.
- Used the skill in this session to rewrite `README.md`.

## Related Pages

- [[readme-blueprint-generator]]
- [[readme-maintenance-workflow]]
- [[agent-skill-installation-workflow]]
- [[durable-agent-rule-memory]]
