---
title: Research Project Workbench
type: concept
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - research
  - project-workbench
  - llm-recommendation
  - agent-workflow
source_pages:
  - 2026-05-17-research-project-roots-deep-review
  - 2026-05-17-research-project-workbench-audit
---

# Research Project Workbench

## Purpose

This page is the routing layer for three local LLM4Rec research projects:

| Project | Local root | Role | Start page |
| --- | --- | --- | --- |
| [[uncertainty]] | `D:/Research/Uncertainty` | Pony-Rec / task-grounded calibrated uncertainty and official same-candidate baseline evidence | `AGENTS.md`, `README.md`, `docs/milestones/README.md` |
| [[truce-rec]] | `D:/Research/TRUCE-Rec` | CURE/TRUCE uncertainty-aware generative recommendation and Pony official baseline reuse | `AGENTS.md`, `docs/PROJECT_MEMORY.md`, `docs/RESEARCH_IDEA.md` |
| [[tgl-rec]] | `D:/Research/TGL-Rec` | Phase 10 temporal graph-to-language evidence and Pony official baseline migration | `docs/codex_project_memory.md`, `docs/phase10_master_plan.md` |

Vipin wiki is the upper-level workbench: it remembers routing, claim boundaries, collaboration norms, and cross-project context. Once work enters a target project, that project's own `AGENTS.md`, `.codex/skills`, canonical docs, and live git state take priority.

## Collaboration Priority

- EXTRACTED: Codex is the main coordinator and the only writer for wiki changes in this repository.
- EXTRACTED: User-facing collaboration should describe Opus, Sonnet, DeepSeek/Whale, and Codex parallel selves as partners rather than impersonal tools.
- INFERRED: Project-local multi-agent rules do not conflict with Vipin wiki. Interpret them as: Codex coordinates; Opus/Sonnet/Whale or Codex parallel selves provide bounded review, exploration, or implementation perspectives; the target project's evidence gates decide claim status.
- EXTRACTED: For the three research repos, do not modify project files from the wiki workbench unless the user explicitly asks for project edits. Always inspect live git status first.

## Shared Evidence Rule

All three projects are governed by the same paper-safety principle:

```text
No smoke run, diagnostic, scaffold, pilot, wrapper name, or raw output becomes paper evidence until the canonical project gates pass.
```

Common gates:

- same candidate rows, split discipline, and event IDs;
- exact score schema such as `source_event_id,user_id,item_id,score` when using the shared external baseline lane;
- finite scores with no missing, extra, or duplicate candidate keys;
- provenance for official code, pinned commit, backbone/adaptation policy, score path, and artifact status;
- validation-only tuning for project methods;
- paired/statistical checks where the project declares them necessary;
- clear labels for `diagnostic`, `controlled_adapter_pilot`, `official_completed`, `completed_result`, and `paper_result`.

## Project Routes

### Uncertainty / Pony-Rec

Use [[uncertainty]] when the task is about C-CRP, SRPD, Shadow, official external baselines, same-candidate score export/import, or the task-grounded uncertainty paper claim.

Startup packet:

- `README.md`
- `docs/milestones/README.md`
- `docs/paper_claims_and_status.md`
- `docs/top_conference_review_gate.md`
- `docs/server_runbook.md`
- for baseline work: `docs/baseline_protocol.md`, `OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md`, `configs/official_external_baselines.yaml`, `PROJECT_LINEAGE_AND_FILE_INDEX_2026-05-06.md`
- project skill: `.codex/skills/uncertainty-rec-research/SKILL.md`

Claim boundary:

- Safe: task-grounded calibrated uncertainty improves controlled candidate ranking/reranking reliability under same-schema evaluation.
- Unsafe until separately completed: full-catalog recommender SOTA, generative-title recommender, universal LoRA distillation claim, or treating partial official adapters as official completed rows.

### TRUCE-Rec

Use [[truce-rec]] when the task is about CURE/TRUCE, uncertainty-aware generative recommendation, Ours adapter/ablations, Pony official baseline import, or TRUCE-side evaluation/export.

Startup packet:

- `AGENTS.md`
- `docs/PROJECT_MEMORY.md`
- `docs/RESEARCH_IDEA.md`
- `docs/submission_roadmap.md`
- `docs/top_conference_review_plan.md`
- for baselines/protocol: `docs/qwen3_lora_controlled_baselines.md`
- for server work: `docs/server_execution_matrix.md`, `docs/server_next_commands.md`
- project skill: `.codex/skills/truce-rec/SKILL.md`

Claim boundary:

- Safe: TRUCE is a research-grade route from generative recommendation observation to CURE/TRUCE framework, shared same-candidate evaluator, and four-domain experiments.
- Unsafe until gates pass: calling legacy controlled adapters official-native baselines, promoting Ours v2 scaffolds to final paper results, or replacing Pony official evidence with TRUCE pilots.

### TGL-Rec

Use [[tgl-rec]] when the task is about temporal graph-to-language evidence, Phase 10, need-gated TDIG, local Qwen3 reranking, Pony baseline migration, or four-domain temporal evidence evaluation.

Startup packet:

- `docs/codex_project_memory.md`
- `docs/phase10_master_plan.md`
- `docs/server_runbook.md`
- `docs/week8_large_same_candidate_protocol.md`
- `docs/reference_baseline_fidelity.md`
- `docs/reference_method_adaptation_map.md`
- `docs/method_card_time_graph_evidence.md`
- project skill: `.codex/skills/tgl-rec-research/SKILL.md`

Claim boundary:

- Safe: Phase 10 aims to test whether LLM recommenders rely on semantic similarity/popularity more than temporal need transitions, then build a temporal graph-to-language framework.
- Unsafe until gates pass: treating `protocol_v1` diagnostics as final evidence, treating `reference_*_sft` scaffolds as main baselines, or saying the experiment phase is complete before four-domain observation, ablations, official baselines, paired statistics, and reviewer gates pass.

## File Area Rules

| Area | Workbench treatment |
| --- | --- |
| `AGENTS.md`, `README.md`, `docs/`, `.codex/skills/` | Read first; safe to summarize in public wiki. |
| `src/`, `scripts/`, `configs/`, `tests/` | Safe to inventory and route; edit only when the user asks to work inside that project. |
| `data/raw/`, large `data/processed/`, `outputs/`, `runs/`, `log/`, `log_tensorboard/`, `*.tar.gz`, `*.tgz`, model/checkpoint arrays | Inventory only: path pattern, size, purpose, and risk. Do not copy raw content into public wiki. |
| `.env`, private server configs, credentials, raw logs with possible tokens, model weights | Do not read or copy into public wiki. Mention only the generic boundary rule. |

## Server Collaboration

- Codex usually cannot see the shared server state directly.
- Future agents should provide copy-paste commands, ask for pasted logs or artifacts, and only claim completion from evidence.
- Long runs should use runbook patterns with output preservation, log paths, PID or process checks, and artifact gates.
- If a target project and Vipin wiki disagree, use the target project's current runbook for server commands, then update the wiki only after grounded changes.

## Cross-Project Boundaries

| Boundary | Keep separate |
| --- | --- |
| C-CRP vs CURE/TRUCE | C-CRP is Pony/Uncertainty's task-grounded calibrated uncertainty method; CURE/TRUCE is TRUCE-Rec's generative recommendation uncertainty framework. |
| TRUCE vs TGL | TRUCE centers catalog grounding, uncertainty, popularity, long-tail, echo, and conservative policy. TGL centers temporal directed item graph evidence and need transitions. |
| Pony official baselines vs project methods | Pony official baseline evidence can be reused by TRUCE/TGL only with manifest, provenance, exact score gates, and no copying of large archives into git. |

## Counterpoints and Gaps

- This workbench is a router, not a substitute for live repo inspection. Always rescan current files before editing or making time-sensitive claims.
- The 2026-05-17 pass classified every tracked path by category, but did not read huge raw/output files line by line.
- Some live artifacts may be newer than canonical docs. When manifests, tarballs, and docs disagree, use the most conservative status until the target project updates its own canonical memory.

## Related

- [[2026-05-17-research-project-roots-deep-review]]
- [[2026-05-17-research-project-workbench-audit]]
- [[uncertainty]]
- [[truce-rec]]
- [[tgl-rec]]
- [[agent-collaboration-tone-and-model-roles]]
- [[local-cc-sidecar-agent-workflow]]
