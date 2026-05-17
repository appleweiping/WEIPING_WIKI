---
title: 2026-05-17 PaperOrchestra GitHub
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - paper-writing
  - research-workflow
source_files:
  - "D:/Research/vipin's knowledgebase/skill/paper-orchestra/README.md"
  - "D:/Research/vipin's knowledgebase/skill/paper-orchestra/docs/architecture.md"
  - "D:/Research/vipin's knowledgebase/skill/paper-orchestra/docs/paper-fidelity.md"
source_pages:
  - https://github.com/Ar9av/PaperOrchestra
  - https://arxiv.org/pdf/2604.05018
---

# 2026-05-17 PaperOrchestra GitHub

## Provenance

- Source: user request to record `https://github.com/Ar9av/PaperOrchestra.git` in the wiki and install its skills locally.
- Inspection mode: public GitHub remote check plus local clone inspection.
- Local source mirror: `skill/paper-orchestra/`.
- Local installed skill root: `.codex/skills/`.
- Remote HEAD at inspection: `5eda989cc284a32e27dfd08f881e958a3b317406`.
- Public handling: this page records project structure, function, and contribution claims; it does not mirror long prompt bodies or source files into the wiki.

## What The Project Is

- EXTRACTED: PaperOrchestra is a pluggable skill pack that lets a host coding agent run the PaperOrchestra multi-agent pipeline from Song et al. 2026, `arXiv:2604.05018`.
- EXTRACTED: The project turns unstructured research materials into a submission-ready LaTeX manuscript.
- EXTRACTED: The repository is organized as `SKILL.md` instruction documents plus `references/` material and deterministic `scripts/` helpers.
- EXTRACTED: The repository deliberately does not embed LLM clients, SDK dependencies, or default API-key requirements; reasoning, web search, PDF reading, and optional vision are delegated to the host coding agent.
- INFERRED: For Vipin's wiki, this belongs under both agent-skill infrastructure and paper-writing / literature-mapping research workflow support.

## Pipeline Function

PaperOrchestra's core workflow is a five-step paper-production pipeline:

| Step | Skill | Role |
| --- | --- | --- |
| 1 | `outline-agent` | Converts an idea, experimental log, LaTeX template, and conference guidelines into a strict outline JSON. |
| 2 | `plotting-agent` | Executes the visualization plan, renders plots or diagrams, and creates captions. |
| 3 | `literature-review-agent` | Discovers candidate papers, verifies them with Semantic Scholar-style checks, builds BibTeX, and drafts Introduction plus Related Work. |
| 4 | `section-writing-agent` | Drafts the remaining sections, builds tables from experiment logs, integrates figures, and merges into LaTeX. |
| 5 | `content-refinement-agent` | Simulates peer review and applies accept/revert refinement loops with snapshots and halt rules. |

The top-level `paper-orchestra` skill coordinates these steps. The README and architecture docs state that plotting and literature review are intended to run in parallel after outline generation.

## Installed Skills

The following folders were copied from `skill/paper-orchestra/skills/` into `.codex/skills/`:

| Installed skill | Purpose |
| --- | --- |
| `paper-orchestra` | End-to-end orchestrator for the full paper-writing pipeline. |
| `agent-research-aggregator` | Optional pre-pipeline bridge from scattered coding-agent logs to `idea.md` and `experimental_log.md`. |
| `outline-agent` | Step 1 outline generation. |
| `plotting-agent` | Step 2 figure and caption generation. |
| `literature-review-agent` | Step 3 literature discovery, verification, BibTeX, and Intro/Related Work drafting. |
| `section-writing-agent` | Step 4 remaining-section drafting, table extraction, and figure integration. |
| `content-refinement-agent` | Step 5 peer-review simulation and refinement. |
| `paper-writing-bench` | Benchmark-case construction by reverse-engineering raw materials from existing papers. |
| `paper-autoraters` | PaperOrchestra-style autoraters for citation F1, literature-review quality, and side-by-side quality checks. |

`skills/shared/` was also copied into `.codex/skills/shared/` as shared reference material because some installed skills point to shared writing-quality, failure-mode, and handoff-schema checklists.

## Official Invocation Summary

- EXTRACTED: The normal user-facing invocation is to ask the host agent to run `paper-orchestra` on a workspace; users are not expected to manually call all 9 skills in sequence.
- EXTRACTED: A valid workspace needs `workspace/inputs/idea.md`, `workspace/inputs/experimental_log.md`, `workspace/inputs/template.tex`, and `workspace/inputs/conference_guidelines.md`; `workspace/inputs/figures/` is optional.
- EXTRACTED: The source repository provides `skills/paper-orchestra/scripts/init_workspace.py` to scaffold a workspace and `validate_inputs.py` to check required inputs.
- EXTRACTED: If `idea.md` or `experimental_log.md` is missing but the user points to a project/log directory, the orchestrator can call `agent-research-aggregator` first to synthesize those inputs.
- EXTRACTED: Official expected outputs include `workspace/outline.json`, generated figures and captions, `workspace/refs.bib`, `workspace/drafts/paper.tex`, `workspace/final/paper.tex`, `workspace/final/paper.pdf`, and `workspace/provenance.json`.
- INFERRED: In this D-drive local setup, the practical pattern is to create the workspace under the relevant project directory or another explicit D-drive path, then invoke the installed `.codex/skills/paper-orchestra/SKILL.md` entry by natural language.

## Concrete Contributions

- EXTRACTED: The repository packages the PaperOrchestra paper's appendix prompts, schemas, rubrics, halt rules, and validation flows as host-agent-executable skills.
- EXTRACTED: The project uses deterministic scripts for tasks such as JSON schema validation, Levenshtein title matching, BibTeX formatting, deduplication, citation coverage, LaTeX sanity checks, anti-leakage checks, orphan-cite gates, and refinement snapshots.
- EXTRACTED: `docs/paper-fidelity.md` maps non-trivial engineering choices back to the arXiv paper and marks out-of-paper hardening additions.
- EXTRACTED: The project includes a pre-pipeline `agent-research-aggregator` that can scan agent caches or project directories and synthesize structured PaperOrchestra inputs.
- EXTRACTED: The README reports the PaperOrchestra paper's PaperWritingBench results as a 50-58 percentage-point absolute win margin on literature review quality and a 14-18 point margin on overall paper quality over cited baselines.
- INFERRED: Its most reusable contribution for this knowledge base is not just "write a paper", but a decomposed agent workflow for transforming messy experiment traces into paper sections, references, figures, and review-driven revisions with mechanical gates.

## Limitations And Boundaries

- EXTRACTED: The repository does not ship PaperBanana, MinerU, PDFFigures 2.0, Gemini/Vertex clients, or the PaperOrchestra paper's Streamlit human-evaluation UI.
- EXTRACTED: PDF extraction, web search, vision critique, LaTeX compilation, and optional Semantic Scholar use are left to the host agent and local environment.
- EXTRACTED: The public unauthenticated Semantic Scholar path is described as sufficient for individual papers, while large-scale benchmarking may benefit from a key.
- UNVERIFIED: The full PaperOrchestra pipeline has not yet been executed locally in this wiki session; the installation was verified at the file-copy and source-inspection level.

## Related

- [[paper-orchestra]]
- [[agent-skill-repositories]]
- [[research-projects]]
