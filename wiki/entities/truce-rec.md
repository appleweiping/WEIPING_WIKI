---
title: TRUCE-Rec
type: entity
status: active
created: 2026-05-10
updated: 2026-05-17
tags:
  - entity
  - project
  - llm-recommendation
  - uncertainty
  - truce-rec
source_pages:
  - 2026-05-10-research-project-roots
  - 2026-05-17-research-project-roots-deep-review
  - 2026-05-17-research-project-workbench-audit
source_files:
  - D:/Research/TRUCE-Rec/AGENTS.md
  - D:/Research/TRUCE-Rec/README.md
  - D:/Research/TRUCE-Rec/docs/PROJECT_MEMORY.md
  - D:/Research/TRUCE-Rec/docs/RESEARCH_IDEA.md
  - D:/Research/TRUCE-Rec/docs/submission_roadmap.md
  - D:/Research/TRUCE-Rec/docs/top_conference_review_plan.md
  - D:/Research/TRUCE-Rec/docs/qwen3_lora_controlled_baselines.md
  - D:/Research/TRUCE-Rec/docs/server_execution_matrix.md
  - D:/Research/TRUCE-Rec/docs/server_next_commands.md
  - D:/Research/TRUCE-Rec/configs/baselines/pony_official_external_baselines.yaml
---

# TRUCE-Rec

## Summary

`TRUCE-Rec` is the uncertainty-aware generative recommendation project. Its route is generative recommendation observation -> CURE/TRUCE framework -> Qwen3-8B-LoRA Ours and ablations -> official/fair baseline families -> shared same-candidate evaluator -> four-domain paper-scale experiments.

## Current Contribution

- EXTRACTED: The project studies recommendation-specific uncertainty around generated titles, catalog grounding, validity, popularity confounding, long-tail under-confidence, history/echo risk, and conservative fallback-aware routing or learning.
- EXTRACTED: Ours/CURE/TRUCE must not become a generic LLM reranker, generic RAG recommender, prompt-engineering baseline, or stitched clone of TALLRec, OpenP5, DEALRec, LC-Rec, LLaRA, LLM-ESR, or another reference project.
- EXTRACTED: Current strategic spine uses Pony/Uncertainty official-qwen3base same-candidate evidence as the default paper-facing external baseline path.
- INFERRED: TRUCE's differentiator is not just calibrated confidence; it is uncertainty-aware generative recommendation with catalog grounding and fallback policy pressure.

## Current Status And Gates

- EXTRACTED: Current paper-baseline action is Pony/Uncertainty evidence import, not rerunning legacy TRUCE controlled adapters by default.
- EXTRACTED: The active baseline manifest lists reusable Pony official evidence with score schema `source_event_id,user_id,item_id,score` and eligibility requiring `completed_result`, `same_schema_external_baseline`, and `official_completed`.
- EXTRACTED: Legacy controlled-adapter scripts remain diagnostic or historical unless the user explicitly reopens that route.
- EXTRACTED: Ours v2 uses a residual policy SFT objective and remains incomplete for paper claims until four-domain training, import/evaluation, and ablations pass.
- EXTRACTED: Experiment phase remains open until four-domain runs, official/fair baselines, Ours ablations, statistical tests, efficiency/cost artifacts, failure cases, and reviewer pass show no fatal gaps.

## Canonical Startup Packet

Read before nontrivial work:

1. `AGENTS.md`
2. `docs/PROJECT_MEMORY.md`
3. `docs/RESEARCH_IDEA.md`
4. `docs/submission_roadmap.md`
5. `docs/top_conference_review_plan.md`

Task-specific reads:

- Baselines/protocol: `docs/qwen3_lora_controlled_baselines.md`
- Server work: `docs/server_execution_matrix.md`, `docs/server_next_commands.md`
- Skill router: `.codex/skills/truce-rec/SKILL.md`, especially `references/task-startup.md` and `references/research-evidence.md`

## Module Map

| Area | Role |
| --- | --- |
| `src/llm4rec/` | Active LLM4Rec framework: data, evaluators, methods, metrics, prompts, rankers, retrievers, trainers, grounding, external baselines. |
| `src/storyflow/` | Older Storyflow/TRUCE components for confidence, grounding, generation, providers, simulation, training, and triage. |
| `scripts/server/`, `scripts/*pony*`, `scripts/*week8*`, import/evaluate scripts | Server commands, Week8 conversion, Pony official baseline import, controlled baseline diagnostics, Ours import/evaluation. |
| `configs/baselines/pony_official_external_baselines.yaml` | Current paper-facing external baseline manifest. |
| `docs/PROJECT_MEMORY.md`, `docs/RESEARCH_IDEA.md`, `docs/server_*` | Canonical project memory and server handoff. |
| `outputs/pony_official_baselines/`, `outputs/server_training/`, `outputs/runs/` | Evidence and generated run artifacts. Inventory only from the wiki. |

## File Inventory Baseline

2026-05-17 live scan:

| Measure | Count / summary |
| --- | --- |
| `git ls-files` | 617 tracked paths |
| `rg --files` | 622 visible searchable paths |
| tracked text-like paths | 612 |
| tracked non-text/artifact marker paths | 5 |
| category counts | source 151; config 143; test 120; doc 100; script 75; artifact-pointer 19; prompt 7; other 2 |
| largest local artifacts | Amazon Video Games raw JSONL about 2.6 GB; observation examples and prompt inputs up to about 790 MB; Pony evidence tarballs up to about 379 MB; large `test_score_plan.jsonl` files about 253-255 MB |

## File Area Rules

- Safe to edit when working inside TRUCE: active `src/llm4rec`, configs, scripts, tests, and canonical docs for the requested subsystem.
- Caution: `src/storyflow` is still present; inspect before changing because it may be legacy or compatibility code.
- Inventory only: `data/raw/`, large `data/processed/`, `outputs/`, `log/`, `log_tensorboard/`, evidence packages, run predictions, and server training artifacts.
- Do not copy into public wiki: `.env`, raw logs, raw datasets, copied private server outputs, checkpoints, or raw evidence package contents.

## Current Git Reminder

2026-05-17 status:

```text
## main...origin/main
?? log/
?? log_tensorboard/
```

Do not stage untracked local logs from the wiki workbench. Treat the top-level `.env` as local/ignored sensitive configuration and do not read or copy it.

## Future Agent Entry

Recommended local commands from current docs:

```powershell
py -3 scripts\import_pony_official_baselines.py `
  --pony-root D:\Research\Uncertainty `
  --output-root outputs\pony_official_baselines `
  --manifest configs\baselines\pony_official_external_baselines.yaml

py -3 scripts\build_pony_baseline_comparison.py `
  --manifest-json outputs\pony_official_baselines\manifest.json `
  --output-root outputs\pony_official_baselines\tables `
  --output-name pony_official_baseline_comparison
```

Server-facing commands should come from `docs/server_execution_matrix.md` and `docs/server_next_commands.md`; do not guess server completion.

## Difference From Sibling Projects

- [[uncertainty]] owns the C-CRP/task-grounded uncertainty claim and the Pony official baseline evidence source.
- [[tgl-rec]] owns temporal graph-to-language evidence and need-transition modeling.
- TRUCE owns CURE/TRUCE: uncertainty-aware generative recommendation, grounding, and conservative policy/fallback logic.

## Counterpoints and Gaps

- TRUCE-side legacy controlled adapters can be useful diagnostics, but they are not current paper-facing official baselines.
- Ours v2 may still look heuristic until trainable objectives, ablations, and reviewer gates strengthen it.
- This wiki pass did not read raw output logs or run result files fully; it preserved metadata-level artifact inventory only.

## Related

- [[research-project-workbench]]
- [[2026-05-17-research-project-roots-deep-review]]
- [[2026-05-17-research-project-workbench-audit]]
- [[uncertainty]]
- [[tgl-rec]]
- [[llm-based-recommendation]]
