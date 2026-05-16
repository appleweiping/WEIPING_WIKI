---
title: PaperOrchestra
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - entity
  - agent-skills
  - paper-writing
  - research-workflow
source_pages:
  - 2026-05-17-paper-orchestra-github
---

# PaperOrchestra

## Role In The Wiki

`PaperOrchestra` is a project-local D-drive skill pack for turning research ideas, experiment logs, templates, and guidelines into LaTeX research-paper drafts through a multi-agent workflow.

## Current Claims

- EXTRACTED: The source repository is `https://github.com/Ar9av/PaperOrchestra.git`.
- EXTRACTED: The inspected remote HEAD was `5eda989cc284a32e27dfd08f881e958a3b317406`.
- EXTRACTED: The repository was mirrored locally under `skill/paper-orchestra/` inside `vipin wiki`.
- EXTRACTED: The repository contains 9 installable `SKILL.md` folders plus a non-skill `shared` reference folder.
- EXTRACTED: The local Codex installation copied the 9 skill folders into `.codex/skills/` and copied `shared` into `.codex/skills/shared/`.
- EXTRACTED: The skill pack implements the PaperOrchestra paper-writing pipeline: outline generation, plotting, literature review, section writing, and content refinement.
- EXTRACTED: The project also includes support skills for agent-log aggregation, PaperWritingBench-style benchmark construction, and PaperOrchestra-style autorating.
- EXTRACTED: The repository's design uses instruction files and deterministic helpers rather than embedded LLM or API clients.
- INFERRED: This is especially relevant for Vipin's paper digestion, literature mapping, and research-project write-up workflows because it provides a structured path from messy experimental material to reviewable paper artifacts.

## Local Routing

- Source mirror: `D:/Research/vipin's knowledgebase/skill/paper-orchestra/`.
- Installed skill root: `D:/Research/vipin's knowledgebase/.codex/skills/`.
- Main installed skill: `.codex/skills/paper-orchestra/SKILL.md`.
- Supporting installed skills:
  - `.codex/skills/agent-research-aggregator/`
  - `.codex/skills/outline-agent/`
  - `.codex/skills/plotting-agent/`
  - `.codex/skills/literature-review-agent/`
  - `.codex/skills/section-writing-agent/`
  - `.codex/skills/content-refinement-agent/`
  - `.codex/skills/paper-writing-bench/`
  - `.codex/skills/paper-autoraters/`
  - `.codex/skills/shared/`

## When To Use

- Use `paper-orchestra` when the goal is to produce an end-to-end LaTeX manuscript from research materials.
- Use `agent-research-aggregator` first when the user has scattered coding-agent logs or project directories rather than clean `idea.md` and `experimental_log.md` inputs.
- Use `literature-review-agent` alone when the immediate task is bibliography construction, citation verification, or Intro/Related Work drafting.
- Use `paper-autoraters` when comparing paper drafts or scoring literature-review quality with the PaperOrchestra evaluation framing.
- Use `paper-writing-bench` when turning an existing paper into benchmark raw materials for testing a paper-writing pipeline.

## Contribution Summary

- EXTRACTED: PaperOrchestra contributes a host-agent-pluggable implementation of a five-agent research-paper writing process.
- EXTRACTED: It separates LLM-dependent reasoning from deterministic checks, which makes the skills portable across coding-agent hosts.
- EXTRACTED: It encodes paper-fidelity mappings, schemas, prompts, gates, and refinement rules in a reusable local skill structure.
- INFERRED: Its practical value is strongest when paired with a disciplined evidence/provenance workflow: agent logs become structured inputs, citations are verified, figures and tables are grounded in experiment logs, and revisions are constrained by explicit review gates.

## Counterpoints And Gaps

- UNVERIFIED: No full local manuscript-generation run has been completed yet in this wiki.
- AMBIGUOUS: The best local workspace convention for PaperOrchestra outputs has not been chosen yet.
- AMBIGUOUS: Large literature-review runs may need explicit rate-limit handling or API keys depending on Semantic Scholar availability.
- INFERRED: For serious use, the wiki should pair this skill with project-specific evidence pages so generated paper claims do not outrun verified results.

## Related Pages

- [[2026-05-17-paper-orchestra-github]]
- [[agent-skill-repositories]]
- [[research-projects]]
