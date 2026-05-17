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

## Official Usage Pattern

Normal usage starts from the orchestrator, not from manually invoking all 9 skills.

### Prepare A Workspace

Create or scaffold a workspace with the required input tuple:

```text
workspace/
  inputs/
    idea.md
    experimental_log.md
    template.tex
    conference_guidelines.md
    figures/                 optional existing figures
```

- `idea.md`: the paper idea, method summary, and target contribution.
- `experimental_log.md`: experiment setup, raw numeric results, observations, ablations, and constraints.
- `template.tex`: the target conference or journal LaTeX template.
- `conference_guidelines.md`: page limit, formatting rules, mandatory sections, deadline notes, and submission constraints.
- `figures/`: optional pre-existing figures; if absent, `plotting-agent` attempts to create the needed visuals.

The source repo provides a scaffold helper:

```powershell
python .codex/skills/paper-orchestra/scripts/init_workspace.py --out workspace/
python .codex/skills/paper-orchestra/scripts/validate_inputs.py --workspace workspace/
```

### Main Invocation

Once the four required files are present, ask Codex or another host agent:

```text
Run the paper-orchestra pipeline on ./workspace.
```

or, with an absolute path:

```text
Use paper-orchestra to turn D:/path/to/workspace into a complete LaTeX paper.
```

The orchestrator then loads and coordinates the sub-skills:

1. `outline-agent` writes `workspace/outline.json`.
2. `plotting-agent` writes `workspace/figures/*.png` and `workspace/figures/captions.json`.
3. `literature-review-agent` writes `workspace/refs.bib` and `workspace/drafts/intro_relwork.tex`.
4. `section-writing-agent` writes a complete `workspace/drafts/paper.tex`.
5. `content-refinement-agent` iterates and promotes the best version to `workspace/final/paper.tex`, then the workflow compiles `workspace/final/paper.pdf` when LaTeX tooling is available.

Steps 2 and 3 are independent; official guidance says to run them in parallel when the host supports parallel agents. If not, run literature review first because citation discovery and verification are slower.

### If Inputs Are Messy

If the project has scattered notes, coding-agent logs, or experiment folders instead of clean `idea.md` and `experimental_log.md`, use the optional aggregator first:

```text
Use agent-research-aggregator on D:/path/to/project, create PaperOrchestra inputs, then run paper-orchestra on the resulting workspace.
```

`agent-research-aggregator` should produce:

- `workspace/inputs/idea.md`
- `workspace/inputs/experimental_log.md`
- `workspace/ara/aggregation_report.md`

The user still needs to supply `template.tex` and `conference_guidelines.md`.

### Targeted Invocation

The support skills can also be used individually:

- `literature-review-agent`: use when only citations, BibTeX, Introduction, or Related Work are needed.
- `plotting-agent`: use when only paper figures and captions are needed from an existing outline or experiment log.
- `section-writing-agent`: use when outline, figures, references, and Intro/Related Work already exist and the task is to fill the rest of the paper.
- `content-refinement-agent`: use when a draft already exists and the task is review-style revision.
- `paper-autoraters`: use to score or compare paper drafts.
- `paper-writing-bench`: use to reverse-engineer benchmark raw materials from an existing paper.

## Output Convention

Official output paths are workspace-relative:

- `workspace/outline.json`
- `workspace/figures/`
- `workspace/refs.bib`
- `workspace/drafts/intro_relwork.tex`
- `workspace/drafts/paper.tex`
- `workspace/refinement/worklog.json`
- `workspace/final/paper.tex`
- `workspace/final/paper.pdf`
- `workspace/provenance.json`

For this wiki's D-drive setup, prefer placing the workspace under the relevant research project folder or another explicit D-drive path, then invoke the installed project-local skills from `.codex/skills/`.

## Contribution Summary

- EXTRACTED: PaperOrchestra contributes a host-agent-pluggable implementation of a five-agent research-paper writing process.
- EXTRACTED: It separates LLM-dependent reasoning from deterministic checks, which makes the skills portable across coding-agent hosts.
- EXTRACTED: It encodes paper-fidelity mappings, schemas, prompts, gates, and refinement rules in a reusable local skill structure.
- INFERRED: Its practical value is strongest when paired with a disciplined evidence/provenance workflow: agent logs become structured inputs, citations are verified, figures and tables are grounded in experiment logs, and revisions are constrained by explicit review gates.

## Counterpoints And Gaps

- UNVERIFIED: No full local manuscript-generation run has been completed yet in this wiki.
- AMBIGUOUS: The best long-term local workspace convention for PaperOrchestra outputs across multiple projects has not been standardized yet.
- AMBIGUOUS: Large literature-review runs may need explicit rate-limit handling or API keys depending on Semantic Scholar availability.
- INFERRED: For serious use, the wiki should pair this skill with project-specific evidence pages so generated paper claims do not outrun verified results.

## Related Pages

- [[2026-05-17-paper-orchestra-github]]
- [[agent-skill-repositories]]
- [[research-projects]]
