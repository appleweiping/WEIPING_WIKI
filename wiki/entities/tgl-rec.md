---
title: TGL-Rec
type: entity
status: active
created: 2026-05-10
updated: 2026-05-17
tags:
  - entity
  - project
  - llm-recommendation
  - temporal-graph
  - tgl-rec
source_pages:
  - 2026-05-10-research-project-roots
  - 2026-05-17-research-project-roots-deep-review
  - 2026-05-17-research-project-workbench-audit
source_files:
  - D:/Research/TGL-Rec/AGENTS.md
  - D:/Research/TGL-Rec/README.md
  - D:/Research/TGL-Rec/docs/codex_project_memory.md
  - D:/Research/TGL-Rec/docs/phase10_master_plan.md
  - D:/Research/TGL-Rec/docs/server_runbook.md
  - D:/Research/TGL-Rec/docs/codex_handoff_phase9e.md
  - D:/Research/TGL-Rec/configs/baselines/pony_official_external.yaml
---

# TGL-Rec

## Summary

`TGL-Rec` is the temporal graph-to-language recommendation project. It asks whether LLM recommenders follow temporal need transitions or mostly retrieve semantically similar/popular items, then builds temporal directed item graph evidence that can be translated into candidate-grounded language for reranking.

## Current Contribution

- EXTRACTED: Working title: `Beyond Similarity: Time-Aware Graph Translation for LLM-based Sequential Recommendation`.
- EXTRACTED: Active phase is Phase 10: observation to original framework to full recommender system.
- EXTRACTED: The active framework lives under `src/llm4rec`; older `src/tglrec` is legacy/compatibility tooling unless explicitly targeted.
- EXTRACTED: Need-gated TDIG evidence includes transition probability, PMI, lift, direction asymmetry, recency, drift, contrastive evidence, and semantic-trap penalty.
- INFERRED: TGL's differentiator is temporal need-transition evidence, not uncertainty calibration alone and not a generic LoRA SFT control.

## Current Status And Gates

- EXTRACTED: `protocol_v1` artifacts remain useful for diagnostics but are too toy-like for final paper claims.
- EXTRACTED: The intended large protocol is the frozen Pony same-candidate four-domain suite: beauty smaller-N plus books/electronics/movies 10k-user 100-negative tasks.
- EXTRACTED: Active Pony official baseline suite for main comparison: completed candidates `llm2rec`, `llmesr`, `llmemb`, `rlmrec`, `irllrec`, `elmrec`, and `proex`; `promax` pending until all declared domains pass exact-score gates; `setrec` blocked/replaced.
- EXTRACTED: Current historical `reference_*_sft` variants are non-reportable containers and cannot satisfy the main baseline milestone.
- EXTRACTED: Do not call the experiment phase basically complete until large observation, Pony baseline reuse/migration, TGL framework ablations, paired statistics, leakage/reproducibility checks, failure cases, and top-conference reviewer gate pass.

## Canonical Startup Packet

Read before nontrivial work:

1. `docs/codex_project_memory.md`
2. `docs/phase10_master_plan.md`
3. `docs/server_runbook.md`
4. `docs/week8_large_same_candidate_protocol.md`
5. `docs/reference_baseline_fidelity.md`
6. `docs/reference_method_adaptation_map.md`
7. `docs/method_card_time_graph_evidence.md`

Also useful:

- `docs/codex_handoff_phase9e.md` for historical provenance only. Phase 10 docs win on conflict.
- `configs/baselines/pony_official_external.yaml` for active baseline manifest.
- `.codex/skills/tgl-rec-research/SKILL.md` for project-local workflow.

## Module Map

| Area | Role |
| --- | --- |
| `src/llm4rec/baselines` | Pony official baseline reuse and baseline interfaces. |
| `src/llm4rec/data`, `scripts/import_week8_same_candidate.py`, `scripts/merge_lora_sft_data.py` | Frozen same-candidate import and SFT materialization. |
| `src/llm4rec/evidence`, `src/llm4rec/graph`, `src/llm4rec/methods`, `src/llm4rec/scoring` | Temporal graph evidence, graph-to-language factors, scoring, and methods. |
| `src/llm4rec/trainers`, `scripts/train_lora_8b.py`, `scripts/run_lora_rerank_eval.py` | Qwen3-8B LoRA/QLoRA controls and evaluation. |
| `src/tglrec` | Legacy/compatibility CPU tooling. Inspect before touching. |
| `docs/`, `configs/experiments/`, `tests/unit/` | Phase 10 plans, experiment configs, and guard tests. |
| `outputs/`, `artifacts/`, `runs/`, `*.tgz` | Generated artifacts. Inventory only from the wiki. |

## File Inventory Baseline

2026-05-17 live scan:

| Measure | Count / summary |
| --- | --- |
| `git ls-files` | 588 tracked paths |
| `rg --files` | 575 visible searchable paths |
| tracked text-like paths | 586 |
| tracked non-text/artifact marker paths | 2 |
| category counts | source 203; test 149; config 106; doc 60; script 58; prompt 6; artifact-pointer 4; other 2 |
| largest local artifacts | `TGL-Rec-phase9e-lora-results.tgz` about 2.8 GB; raw Video Games JSONL about 2.6 GB; protocol prediction JSONL outputs commonly 1.4-1.7 GB |

## File Area Rules

- Safe to edit when working inside TGL: active `src/llm4rec`, configs, tests, scripts, and docs relevant to the task.
- Caution: `src/tglrec` and Phase 9E docs are legacy/historical unless the task explicitly targets them.
- Inventory only: `data/raw/`, large `data/processed/`, `outputs/`, `runs/`, `artifacts/`, root `TGL-Rec-*.tgz`, PDFs/zips under `references/`, private server configs, and model artifacts.
- Do not copy into public wiki: raw datasets, full predictions/logs, model weights, PDFs, private server configs, or raw evidence archive contents.

## Current Git Reminder

2026-05-17 status:

```text
## codex/phase9e-lora-rerank-eval...origin/codex/phase9e-lora-rerank-eval
```

Working tree was clean during this wiki audit. The branch name is historical; Phase 10 docs are the active project memory.

## Future Agent Entry

Useful guard commands from current docs:

```bash
python -m pytest \
  tests/unit/test_pony_official_baselines.py \
  tests/unit/test_week8_lora_configs.py \
  tests/unit/test_four_domain_plan.py \
  tests/unit/test_run_compare.py -q

python scripts/plan_four_domain_runs.py \
  --external-root ~/projects/pony-rec-rescue-shadow-v6/outputs/baselines/external_tasks \
  --output outputs/plans/four_domain_server_plan.json \
  --shell-output outputs/plans/four_domain_server_runbook.sh
```

For server work, start from `docs/server_runbook.md`; preserve old outputs before reruns and do not infer success without pasted logs.

## Difference From Sibling Projects

- [[uncertainty]] owns the C-CRP/task-grounded uncertainty and Pony official baseline evidence lane.
- [[truce-rec]] owns uncertainty-aware generative recommendation and catalog-grounding/fallback policy.
- TGL-Rec owns temporal transition evidence, graph-to-language translation, need gating, and temporal-vs-semantic diagnosis.

## Counterpoints and Gaps

- The live branch name still references Phase 9E; future agents must not let that override Phase 10 docs.
- Current large output files are not final paper evidence by themselves.
- This wiki pass inventoried large artifacts by path/size/purpose only and did not read raw predictions, logs, PDFs, or datasets fully.

## Related

- [[research-project-workbench]]
- [[2026-05-17-research-project-roots-deep-review]]
- [[2026-05-17-research-project-workbench-audit]]
- [[uncertainty]]
- [[truce-rec]]
- [[llm-based-recommendation]]
