---
title: LLM-Based Recommendation
type: concept
status: active
created: 2026-04-21
updated: 2026-04-21
tags:
  - concept
  - llm
  - recommendation
  - research
source_pages:
  - 2026-04-21-nh-baseline-paper-set
  - 2026-04-21-nr-baseline-paper-set
  - 2026-04-21-recommendation-paper-library
---

# LLM-Based Recommendation

`LLM-based recommendation` is the research area concerned with using large language models inside recommender systems, recommendation pipelines, or recommendation-oriented evaluation tasks.

## Typical Problem Settings

- sequential recommendation
- conversational recommendation
- explainable recommendation
- multimodal recommendation
- knowledge-aware recommendation
- recommendation evaluation and benchmarking
- bias, fairness, and controllability in recommendation

## Typical Roles For The LLM

- encoder or feature extractor
- generator of explanations or recommendations
- reasoning module
- user simulator
- controller or agent layer between user and system
- teacher model for distillation into smaller recommenders

## Common Research Tensions

- accuracy versus efficiency
- reasoning quality versus latency
- personalization versus generality
- controllability versus open-ended generation
- robustness versus hallucination risk
- fairness and bias under deployment constraints

## Current Local Evidence

The current local paper collections suggest especially strong coverage in:

- sequential recommendation
- explainable recommendation
- conversational recommendation
- robustness and data correction
- reasoning-enhanced recommendation
- controllable or proactive recommendation

## Open Questions

- Which subareas are most central to Vipin's own research direction?
- How should uncertainty be represented in LLM-driven recommendation pipelines?
- Which papers are core baselines versus peripheral reading?

## Counterpoints and Gaps

- the current local collections show breadth, but not yet a settled hierarchy of which papers truly anchor Vipin's own work
- large language models can improve reasoning or explanation quality while still worsening latency, controllability, or reproducibility
- some apparent progress in `LLM-based recommendation` may collapse once systems are compared under stronger evaluation, smaller budgets, or stricter uncertainty handling

## Related

- [[vipin]]
- [[2026-04-21-nh-baseline-paper-set]]
- [[2026-04-21-nr-baseline-paper-set]]
- [[2026-04-21-recommendation-paper-library]]
- [[2026-04-21-llm-rec-research-map]]
