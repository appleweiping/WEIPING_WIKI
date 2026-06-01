---
title: Pony toys official-baseline progress
tags:
  - pony
  - official-baselines
  - toys
  - evidence
  - server
updated: 2026-06-01
---

# Pony toys official-baseline progress

As of 2026-06-01 21:13 CST, toys `proex_profile` is the first completed toys
official-baseline row. Evidence status:

- `implementation_status=official_completed`
- `blockers=[]`
- `score_coverage_rate=1.0`
- full metrics over 10,000 users and 101 candidates:
  HR@5/10/20=`0.0895/0.1615/0.3017`,
  NDCG@5/10/20=`0.058141214365017416/0.0810170703641553/0.11607709818340411`,
  MRR=`0.08121671352544663`
- row counts: `scores.csv` 1,010,001 lines,
  predictions 10,000 lines, `tables/ranking_eval_records.csv` 10,001 lines
- server-final evidence audit PASS, lightweight sync PASS, local-light audit PASS

Local lightweight evidence:

`D:\Research\Uncertainty\outputs\baselines\official_adapters\toys_large10000_100neg_proex_profile_official_qwen3base_same_candidate`

Large server-only final files are protected on the server and recorded by
`server_large_artifact_manifest.sha256`: `scores.csv`,
`predictions/rank_predictions.jsonl`, and `proex_official_model.pt`.

After those gates passed, the completed intermediate adapter directory
`outputs/baselines/paper_adapters/toys_large10000_100neg_proex_official_adapter`
was safely removed, recovering about 4.5G and leaving about 18G free. Final
scores, provenance, audits, predictions, imported tables, and model were not
deleted.

Next active row: toys `promax_profile`, launched 2026-06-01 21:28 CST with
runner PID `2899989`, adapter PID `2899998`, and log
`baselines_new_domains_toys_promax_20260601_212808.log`. It was in Qwen3
`hf_mean_pool` embedding at the first post-launch check and is not
table-eligible until the same final gates pass.
