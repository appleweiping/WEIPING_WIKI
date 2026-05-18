---
title: Research Project Roots
type: source
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - source
  - research
  - project-map
origin: local-filesystem
provenance: Read-only inspection of `D:/Research` project roots requested by the user.
source_files:
  - D:/Research/Agent-AI4EDA/analog-agent/README.md
  - D:/Research/Uncertainty/README.md
  - D:/Research/TRUCE-Rec/README.md
  - D:/Research/TGL-Rec/README.md
  - D:/Research/DoneBench/README.md
  - D:/Research/UncertaintyProtein-AI4S/README.md
---

# Research Project Roots

## Source Summary

This source note records a read-only survey of Vipin's active research projects under `D:/Research`, especially [[analog-agent]], [[uncertainty]], [[truce-rec]], [[tgl-rec]], [[donebench]], and [[uncertaintyprotein-ai4s]] / [[protein-optimization-feedback-shift]].

## Key Claims

- EXTRACTED: `D:/Research/Agent-AI4EDA/analog-agent` is the mature AI4EDA / analog-agent project root.
- EXTRACTED: `D:/Research/Uncertainty` is the current main root for task-grounded uncertainty in LLM-based recommendation.
- EXTRACTED: `D:/Research/Uncertainty-LLM4Rec` is an older or archival predecessor of the current `Uncertainty` root.
- EXTRACTED: `D:/Research/TRUCE-Rec` and `D:/Research/TGL-Rec` are adjacent LLM4Rec projects using stricter same-candidate, official-baseline, and evidence-label governance.
- EXTRACTED: `D:/Research/DoneBench` is a benchmark project for specification grounding in tool-using agents.
- EXTRACTED: `D:/Research/UncertaintyProtein-AI4S` is the AI4S protein optimization project about uncertainty under feedback distribution shift.
- EXTRACTED: `D:/Research/AI for Science` had no visible project files in the inspected top-level pass.

## Evidence / Important Details

- `analog-agent` centers on a six-layer analog design agent with specification compilation, task formalization, world-model services, planning, SPICE-backed verification, and memory/reflection.
- `Uncertainty` centers on C-CRP, same-candidate candidate ranking/reranking, official external baselines, and task-grounded calibrated uncertainty.
- `TRUCE-Rec` is a CURE/TRUCE uncertainty-aware generative recommendation system, currently guarded against paper claims until official-native controlled baselines and four-domain runs are complete.
- `TGL-Rec` studies whether LLM recommenders use temporal next-need transitions rather than mainly semantic similarity/popularity.
- `DoneBench` evaluates whether agents can infer and satisfy executable completion criteria before acting in stateful tool environments.
- `UncertaintyProtein-AI4S` frames protein optimization as sequential uncertainty under feedback shift, where calibration and decision quality can diverge.

## Confidence

- EXTRACTED: Project purposes and status labels are taken from README/AGENTS/docs files in the inspected roots.
- INFERRED: `Uncertainty-LLM4Rec` is best treated as predecessor/archive relative to `Uncertainty`.
- AMBIGUOUS: PDF-only folders under AI4EDA likely contain drafts, references, and generated reports; they need separate source-specific ingest before being treated as evidence.
- UNVERIFIED: No claim was checked by running experiments or tests in the external project roots.

## Tensions / Uncertainties

- Several projects contain generated outputs, ignored artifacts, and server-run paths. These are status signals but not automatically paper-facing evidence.
- Names containing `official`, `paper`, or `final` are not sufficient proof of final evidence unless the project's own audit/provenance rules mark them complete.

## Related Pages

- [[vipin-research-project-map]]
- [[analog-agent]]
- [[uncertainty]]
- [[truce-rec]]
- [[tgl-rec]]
- [[donebench]]
- [[uncertaintyprotein-ai4s]]
- [[protein-optimization-feedback-shift]]
