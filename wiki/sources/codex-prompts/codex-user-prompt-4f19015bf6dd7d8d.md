---
title: 当前状态：
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - research-workflow
source_pages:
  - codex-prompt-corpus
---

# 当前状态：

## Metadata

- Stable ID: `codex-user-prompt:4f19015bf6dd7d8d`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-04T10:28:14.394Z`
- Semantic hash: `4f19015bf6dd7d8d89abe6d81a7e9e81961b636da5d845a523060e6cdae1bc7f`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
当前状态：

- CU-GR v2 已在 MovieLens 和 Amazon Beauty 上通过 held-out seed42。
- Amazon Video Games 第三域已跑完，但 delta NDCG@10 = +0.008140，低于 +0.01 gate，因此不能宣称第三域验证通过。
- SASRec / LightGCN adapter 已接上，但当前环境未安装 RecBole，所以没有 paper-grade 强 baseline 指标。
- 下一步不是继续调 CU-GR v2，也不是强行优化 Video Games，而是 Fix baseline adapter，把 SASRec / LightGCN 真实跑出并通过 TRUCE evaluator。

现在执行：Strong Baseline Adapter Completion Gate。

Do not:
- change CU-GR v2 method;
- change evaluator definitions;
- tune Amazon Video Games on test;
- fabricate SASRec / LightGCN results;
- copy RecBole metrics as final paper numbers;
- commit large external reference files;
- silently mark unavailable baselines as passed.

# Goal

Install/enable optional RecBole baseline environment, run SASRec and LightGCN through the existing external baseline adapter, import predictions into TRUCE schema, and compute final metrics with TRUCE evaluator.

The final paper baseline numbers must come from TRUCE evaluator, not RecBole's own metric output.

# Baseline targets

Run at minimum on:

1. MovieLens 1M
2. Amazon Beauty

Optional after those pass:

3. Amazon Video Games

Baselines:

- SASRec via RecBole
- LightGCN via RecBole

Existing lightweight baselines remain:

- popularity
- BM25/fallback
- MF
- sequential_markov

# Environment plan

First inspect Python / torch / RecBole availability:

py -3 -c "import sys; print(sys.version)"
py -3 -c "import torch; print(torch.__version__)"
py -3 -c "import recbole; print(recbole.__version__)"

If RecBole is missing, install it as an optional baseline dependency in the active environment:

py -3 -m pip install recbole==1.2.1

If torch is missing or incompatible, report the exact issue and propose one command, but do not guess silently.

Do not add RecBole as a mandatory dependency. Keep it optional under baseline extra / docs.

Update docs if needed:

docs/baselines.md
docs/reference_baseline_audit.md
docs/reproduction.md

Document:

- RecBole optional dependency;
- tested RecBole version;
- torch version;
- command used;
- whether CPU or GPU;
- expected runtime.

# Adapter validation

Before training, run adapter unit checks:

py -3 scripts/export_recbole_data.py --config configs/experiments/baseline_sasrec_movielens.yaml
py -3 scripts/export_recbole_data.py --config configs/experiments/baseline_lightgcn_movielens.yaml

Check exported files:

- user/item mappings exist;
- interactions exist;
- train/valid/test split preserved;
- candidate sets preserved or export points to candidate set;
- no target leakage;
- timestamps preserved for SASRec.

Run:

py -3 -m pytest tests/unit/test_external_baseline_data_export.py
py -3 -m pytest tests/unit/test_external_prediction_import.py
py -3 -m pytest tests/unit/test_recbole_adapter_config.py

# Run SASRec / LightGCN

Run MovieLens first.

Commands:

py -3 scripts/run_external_baseline.py --config configs/experiments/baseline_sasrec_movielens.yaml
py -3 scripts/import_external_predictions.py --config configs/experiments/baseline_sasrec_movielens.yaml

py -3 scripts/run_external_baseline.py --config configs/experiments/baseline_lightgcn_movielens.yaml
py -3 scripts/import_external_predictions.py --config configs/experiments/baseline_lightgcn_movielens.yaml

Then run Amazon Beauty:

py -3 scripts/run_external_baseline.py --config configs/experiments/baseline_sasrec_amazon_beauty.yaml
py -3 scripts/import_external_predictions.py --config configs/experiments/baseline_sasrec_amazon_beauty.yaml

py -3 scripts/run_external_baseline.py --config configs/experiments/baseline_lightgcn_amazon_beauty.yaml
py -3 scripts/import_external_predictions.py --config configs/experiments/baseline_lightgcn_amazon_beauty.yaml

If Amazon Video Games configs already exist and MovieLens/Beauty pass, run:

py -3 scripts/run_external_baseline.py --config configs/experiments/baseline_sasrec_amazon_videogames.yaml
py -3 scripts/import_external_predictions.py --config configs/experiments/baseline_sasrec_amazon_videogames.yaml

py -3 scripts/run_external_baseline.py --config configs/experiments/baseline_lightgcn_amazon_videogames.yaml
py -3 scripts/import_external_predictions.py --config configs/experiments/baseline_lightgcn_amazon_videogames.yaml

# Required behavior

For every external baseline:

1. Train with fixed seed.
2. Score the exact same candidate sets used by CU-GR v2.
3. Import predictions into TRUCE prediction schema.
4. Evaluate with TRUCE evaluator.
5. Save:

outputs/runs/<dataset>_<baseline>_<seed>/
- resolved_config.yaml
- environment.json
- logs.txt
- predictions.jsonl
- metrics.json
- metrics.csv
- artifacts/
- external_baseline_manifest.json
- recbole_config.yaml
- checkpoint path or training artifact reference

Metadata must include:

- external_baseline: true
- library: RecBole
- recbole_version
- model_name: SASRec or LightGCN
- training_config
- seed
- dataset
- candidate_protocol
- score_import_method
- truce_evaluator_used: true

# Fairness requirements

Confirm:

- same split as CU-GR v2;
- same candidate set per dataset/seed;
- target inclusion preserved;
- same TRUCE evaluator;
- no RecBole metric copied into paper tables;
- SASRec uses chronological/sequential history only;
- LightGCN uses train interactions only;
- validation is used only for early stopping / model selection;
- test seed is not used for tuning.

# Table update

After baselines finish, update:

outputs/tables/paper_main_results_strong_baselines.csv
outputs/tables/paper_main_results_strong_baselines.md
outputs/tables/paper_main_results_strong_baselines.tex
outputs/tables/paper_baseline_runtime.csv
outputs/tables/paper_strong_baseline_audit.csv

Also update:

docs/baselines.md
docs/cu_gr_v2_experiment_summary.md
docs/cu_gr_v2_reviewer_checklist.md
docs/cu_gr_v2_limitations.md
paper/related_positioning.md

Keep old unavailable rows for provenance only if clearly marked superseded. Do not leave SASRec / LightGCN as unavailable if they now ran.

# Comparison rules

The main paper table must compare:

- popularity
- BM25/fallback
- MF
- sequential_markov
- SASRec
- LightGCN
- LLM direct generation
- LLM listwise panel
- CU-GR v2 fusion

For each dataset:

- MovieLens
- Amazon Beauty
- Amazon Video Games if completed

If SASRec or LightGCN beats CU-GR v2, report honestly. Do not hide it.

If CU-GR v2 beats fallback but not SASRec/LightGCN, paper framing becomes:
"LLM preference fusion improves over text/retrieval fallback but does not replace strong collaborative/sequential recommenders."

If CU-GR v2 beats strong baselines on some datasets, report only those datasets.

# Tests / regression

Run:

py -3 -m pytest tests/unit/test_external_baseline_data_export.py
py -3 -m pytest tests/unit/test_external_prediction_import.py
py -3 -m pytest tests/unit/test_recbole_adapter_config.py
py -3 -m pytest tests/smoke/test_external_baseline_adapter_smoke.py
py -3 -m pytest
git diff --check

# Completion report

Report:

## Verdict

Choose:
- PASS: strong baselines ready for paper tables
- PASS WITH MINOR FIXES
- MAJOR FIXES REQUIRED
- BLOCKER

## Environment

Python, torch, RecBole version, CPU/GPU.

## Commands run

Exact commands.

## Baseline status

For each dataset × baseline:
- trained
- predictions imported
- TRUCE evaluator run
- metrics saved

## Main table update

Compact metrics:

Dataset | Method | Recall@10 | NDCG@10 | MRR@10 | source

## Fairness/evaluator audit

Confirm same split/candidates/evaluator.

## Runtime

Training time and scoring time.

## Issues

Blockers/major/minor.

## Paper framing impact

Say whether CU-GR v2 remains:
- stronger than strong baselines;
- stronger than fallback only;
- complementary to strong baselines;
- weakened by strong baselines.

## Next recommended action

Exactly one:
- Draft Results section.
- Fix remaining baseline issue.
- Run third-domain CU-GR v2 refinement.
- Add one more strong baseline.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
