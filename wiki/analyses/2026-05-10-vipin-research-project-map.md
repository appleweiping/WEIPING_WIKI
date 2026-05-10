---
title: Vipin Research Project Map
type: analysis
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - analysis
  - research
  - project-map
aliases:
  - vipin-research-project-map
source_pages:
  - 2026-05-10-research-project-roots
---

# Vipin Research Project Map

## Question

What are Vipin's current main research projects, and how should the wiki remember their roles without modifying the project repositories?

## Summary

Vipin's current research portfolio has three main technical arcs:

1. **Decision-relevant uncertainty in recommendation:** [[uncertainty]], [[truce-rec]], and [[tgl-rec]].
2. **Closed-loop uncertainty-aware optimization:** [[analog-agent]] and [[protein-optimization-feedback-shift]].
3. **Agent task completion and specification grounding:** [[donebench]].

The most important wiki principle is to preserve each project's claim boundary. Many repos explicitly warn against turning diagnostics, smoke runs, or partial official-baseline wrappers into paper-facing conclusions.

## Project Roles

| Project | Role | Current wiki interpretation |
|---|---|---|
| [[analog-agent]] | AI4EDA analog design agent | Layered agent architecture for SPICE-grounded analog circuit optimization. |
| [[uncertainty]] | Main LLM4Rec uncertainty project | C-CRP and task-grounded calibrated uncertainty under same-candidate evaluation. |
| [[truce-rec]] | Uncertainty-aware generative recommendation system | CURE/TRUCE route with strict evidence labels and official-native baseline gate. |
| [[tgl-rec]] | Temporal recommendation evidence project | Tests temporal next-need transitions vs semantic similarity/popularity. |
| [[donebench]] | Agent benchmark | Specification grounding benchmark with deterministic DoneSpec grading. |
| [[uncertaintyprotein-ai4s]] / [[protein-optimization-feedback-shift]] | AI4S protein uncertainty project | Feedback-shift study where calibration and decision quality can diverge. |

## Cross-Project Pattern

- EXTRACTED: The recommendation projects share the rule that a method is not paper evidence until the same-candidate protocol, score coverage, provenance, and paired/statistical gates pass.
- EXTRACTED: [[donebench]] uses deterministic executable grading rather than LLM-as-judge, which fits the same evidence-discipline pattern.
- EXTRACTED: [[analog-agent]] and [[protein-optimization-feedback-shift]] both treat closed-loop decision quality as more important than passive prediction quality.
- INFERRED: The unifying research taste is controlled decision systems under uncertainty: when to trust a model, when to defer to truth/evidence, and how to make claims only after protocol gates pass.

## Immediate Use In The Wiki

- For quick questions about the research portfolio, start from [[research-projects]] and this map.
- For project-specific questions, open the relevant entity page first, then use the source paths recorded there.
- For paper-claim questions, prefer the external project's own canonical docs before relying on old chat memories or generated output folders.
- For research-idea questions, apply [[research-ideation-policy]]: do not merely stitch existing project parts together; be willing to propose radical reframing when it creates a stronger claim.

## Counterpoints and Gaps

- This pass did not ingest all project PDFs, paper drafts, result tables, or code-level algorithms.
- `AI for Science` as a folder did not show visible content in the inspected top-level pass; the active AI4S project appears to be [[protein-optimization-feedback-shift]].
- `Analog-RAPID`, `analog-uaas`, and `Analog-AEDA` should receive deeper lineage notes later if they still influence the current [[analog-agent]] paper.
- `Uncertainty-LLM4Rec` needs an archival source note if older Week7/Week8 evidence is reused.

## Related

- [[2026-05-10-research-project-roots]]
- [[research-projects]]
- [[research-ideation-policy]]
