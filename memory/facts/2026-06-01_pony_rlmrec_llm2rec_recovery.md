---
title: Pony sports RLMRec completed and LLM2Rec valid-history fix
project: pony-rec-uncertainty
date: 2026-06-01
tags:
  - pony
  - official-baselines
  - rlmrec
  - llm2rec
  - evidence
---

# Pony sports RLMRec completed and LLM2Rec valid-history fix

On 2026-06-01 13:43 CST, sports `rlmrec_graphcl` completed as an official
same-candidate row: `implementation_status=official_completed`, `blockers=[]`,
`score_coverage_rate=1.0`, server-final audit PASS, lightweight sync PASS, and
local-light audit PASS.

Metrics over 10,000 users and 101 candidates:

- HR@5/10/20: `0.1212 / 0.1879 / 0.3009`
- NDCG@5/10/20: `0.078580389191345 / 0.10001773336299705 / 0.12818232277286493`
- MRR: `0.09720456858848743`

Server row counts passed: `scores.csv` has 1,010,001 lines,
`predictions/rank_predictions.jsonl` has 10,000 lines, and
`tables/ranking_eval_records.csv` has 10,001 lines. Local lightweight evidence
is under
`D:\Research\Uncertainty\outputs\baselines\official_adapters\sports_large10000_100neg_rlmrec_graphcl_official_qwen3base_same_candidate`.

The next sports row, `llm2rec_sasrec`, stopped during adapter export because
the exporter used test-task train histories for validation candidate events.
At least one validation user exists in
`sports_large10000_100neg_valid_same_candidate/train_interactions.csv` but not
in the test task train/candidate files. The local exporter now uses
`valid_task_dir/train_interactions.csv` for validation histories when present,
while preserving test-task histories for test events. Targeted unit test:

```powershell
$env:PYTHONPATH='scripts/build;scripts/audit;scripts/adapters;.'
python -m pytest tests\test_llm2rec_same_candidate_export.py -q
```

Result: `3 passed`.

Update at 2026-06-01 14:03 CST: commit `657929e` was pushed. Because the
server worktree was dirty and behind GitHub, the fixed exporter was copied as a
targeted file rather than pulling/resetting the full worktree. Server
`py_compile` passed; server lacks `pytest`. Sports `llm2rec_sasrec` was
resumed as a single-row job under PID `2870575`, passed the previous adapter
export blocker, and entered Qwen3 `hf_mean_pool` embedding generation at about
`3432/283760`. The row is still not table-eligible until final
scores/provenance/audits/imported metrics pass.

Update at 2026-06-01 14:09 CST: server adapter audit passed
`ready_for_llm2rec_upstream_wrapper` with zero missing mapped candidates and
`valid_history_source=valid_task_train_interactions`. Embedding progress reached
about `28736/283760`. The completed RLMRec intermediate adapter directory was
removed after absolute-path and RLMRec server-final-audit checks, recovering
about `4.5G`; final RLMRec outputs and local lightweight evidence were
preserved.

Update at 2026-06-01 15:14 CST: sports `llm2rec_sasrec` completed Qwen3 item
embedding (`283760/283760`), and both the Pony adapter embedding and upstream
LLM2Rec embedding files are 4,649,140,352 bytes. The run then stopped before
official SASRec training because `_train_with_official_entrypoint` invoked
bare `python` and the server subprocess environment could not resolve it:
`FileNotFoundError: [Errno 2] No such file or directory: 'python'`. No related
Python experiment is currently active; GPU is idle and disk has about `22G`
free. Local fix changes the official-entrypoint command to `sys.executable`
while preserving the `evaluate_with_seqrec.py` entrypoint and SASRec
arguments. Targeted tests passed:

```powershell
$env:PYTHONPATH='scripts/build;scripts/audit;scripts/adapters;.'
python -m pytest tests\test_llm2rec_upstream_adapter.py -q
python -m pytest tests\test_llm2rec_same_candidate_export.py -q
```

Results: `5 passed` and `3 passed`. The next step is targeted server copy of
`src/baselines/official_runner/llm2rec.py`, server `py_compile`, then resume
only sports LLM2Rec with existing upstream embedding
`/home/ajifang/projects/LLM2Rec/item_info/SportsSameCandidate100Neg/pony_qwen3_8b_title_item_embs.npy`.

LLM2Rec resume follow-up at 2026-06-01 15:51 CST: the fixed `sys.executable` runner was present on `pony-rec-gpu` and passed server `py_compile`. The first direct single-row launch timed out locally but did start sports `llm2rec_sasrec`; a follow-up safety launcher detected the active process and refused to duplicate it. Active processes are adapter PID `2875446` and upstream official `evaluate_with_seqrec.py` PID `2875559`. The upstream command uses existing embedding `/home/ajifang/projects/LLM2Rec/item_info/SportsSameCandidate100Neg/pony_qwen3_8b_title_item_embs.npy`, not regeneration. `llm2rec_official_training.log` reached epoch 15 validation and saved checkpoints at epochs 5 and 10. GPU sample was `7%`, `9363 MiB / 49140 MiB`; disk was `22G` free. No final `scores.csv`, final provenance, score audit, imported metrics, or row-count gates exist yet, so LLM2Rec is running and not table-eligible.

LLM2Rec completion follow-up at 2026-06-01 15:56 CST: sports `llm2rec_sasrec` completed as the seventh sports official row with `implementation_status=official_completed`, `blockers=[]`, `score_coverage_rate=1.0`, server-final audit PASS, lightweight sync PASS, and local-light audit PASS. Official training early-stopped at epoch 45 and loaded the best epoch 25 checkpoint. Full metrics over 10,000 users and 101 candidates: HR@5/10/20=`0.1105/0.206/0.3657`, NDCG@5/10/20=`0.06514778914391295/0.09566791850988236/0.13561659669926907`, MRR=`0.08828933028385053`. Row counts passed: `scores.csv` has 1,010,001 lines, `predictions/rank_predictions.jsonl` has 10,000 lines, and `tables/ranking_eval_records.csv` has 10,001 lines. Local lightweight evidence is under `D:\Research\Uncertainty\outputs\baselines\official_adapters\sports_large10000_100neg_llm2rec_sasrec_official_qwen3base_same_candidate`. Disk on server is now about `17G` free (`91%` used), so preflight disk/process review is required before launching sports `llmesr_sasrec`; do not delete final scores/provenance/audits/imported tables/predictions/checkpoints.

Storage and LLM-ESR launch follow-up at 2026-06-01 16:28 CST: after LLM2Rec server-final and local-light audits passed, the completed LLM2Rec intermediate adapter directory `outputs/baselines/paper_adapters/sports_large10000_100neg_llm2rec_official_adapter` was removed from the server. This recovered about `5.3G` and did not touch final LLM2Rec scores, final provenance, audits, imported tables, predictions, checkpoints, or the upstream embedding under `/home/ajifang/projects/LLM2Rec/item_info/`. Disk recovered from about `17G` to `23G` free, then sports `llmesr_sasrec` was launched as the eighth sports official row with runner PID `2877443` and adapter PID `2877452`. It is currently in Qwen3 `hf_mean_pool` embedding at about `51472/233470`; GPU sample `95%`, `16285 MiB / 49140 MiB`; disk about `22G` free. LLM-ESR is running and not table-eligible until final score/provenance/audit/import gates pass.

Monitoring/gate follow-up at 2026-06-01 16:50 CST: sports `llmesr_sasrec`
remains active under runner PID `2877443` and adapter PID `2877452`; Qwen3
embedding progress was about `141696/233470`, GPU `95%` with
`16285 MiB / 49140 MiB`, and disk about `22G` free. No final LLM-ESR scores,
provenance, score audit, imported table, or predictions exist yet. Seven
sports official rows are complete and full-metric checked, not just @10/MRR:
each completed row has HR@5/@10/@20, NDCG@5/@10/@20, MRR,
`sample_count=10000`, `avg_candidates=101.0`, exact score coverage, final
provenance, score audit, and imported `ranking_eval_records.csv`. The earliest
four rows (`llmemb`, `proex_profile`, `promax_profile`, `elmrec_graph`) lacked
only the newer standardized `server_final_evidence_audit.json`; server-final
audits were backfilled with `ok=true`, copied into local lightweight packages,
and local-light audits passed. No metric values or running experiment processes
were changed.

Training follow-up at 2026-06-01 17:15 CST: sports `llmesr_sasrec` completed
Qwen3 embedding (`233470/233470`) and entered official training. Logged losses
are epoch 1 `1.374167` and epoch 5 `0.361412`; runner PID `2877443` and
adapter PID `2877452` remain active. GPU sample was `100%` with
`21215 MiB / 49140 MiB`, disk was about `15G` free (`93%` used), and no final
LLM-ESR scores/provenance/audit/imported tables exist yet. Read-only storage
review found no meaningful safe deletion: the large active adapter is required
for the current run, and completed-row final evidence remains protected.

LLM-ESR completion follow-up at 2026-06-01 18:42 CST: sports
`llmesr_sasrec` completed as the eighth sports official row with
`implementation_status=official_completed`, `blockers=[]`,
`score_coverage_rate=1.0`, server-final audit PASS, lightweight sync PASS, and
local-light audit PASS. Full metrics over 10,000 users and 101 candidates:
HR@5/10/20=`0.0916/0.1564/0.2650`,
NDCG@5/10/20=`0.054919833257876506/0.0758115528438973/0.10310478593304104`,
MRR=`0.0751149958885503`. Row counts passed: `scores.csv` 1,010,001 lines,
predictions 10,000 lines, `tables/ranking_eval_records.csv` 10,001 lines,
summary table 2 lines. Local lightweight evidence is under
`D:\Research\Uncertainty\outputs\baselines\official_adapters\sports_large10000_100neg_llmesr_sasrec_official_qwen3base_same_candidate`.
After final evidence and no-active-process checks, the completed intermediate
adapter directory
`outputs/baselines/paper_adapters/sports_large10000_100neg_llmesr_official_adapter`
was removed from the server, recovering disk from 9.4G to 14G free while
preserving final server outputs and local evidence. Sports official baselines
are now 8/8 complete; next gate is sports comparison table plus paired tests.

Sports completeness gate follow-up at 2026-06-01 19:08 CST: the new read-only
domain gate `scripts/audit/main_audit_domain_official_gate.py` passed on
`pony-rec-gpu` for sports. Outputs
`outputs/summary/sports_official_ccrp_gate_20260601.json` and `.csv` were
generated server-side and copied to local. Gate summary:
`official_ok_count=8`, `official_all_ok=true`, `ccrp_ok=true`, `gate_ok=true`,
and `stray_official_like_dirs=[]` after removing the previously confirmed
empty malformed `TRAIN_METHODS_OVERRIDE=` directory. The compact metrics table
shows C-CRP and all eight official rows with HR@5/@10/@20, NDCG@5/@10/@20,
MRR, `sample_count=10000`, `avg_candidates=101.0`, `score_coverage_rate=1.0`,
`scores_csv_lines=1010001`, `predictions_jsonl_lines=10000`, and
`ranking_eval_records_csv_lines=10001`. Server health after gate: no active
Pony/baseline Python experiment process, GPU `0%` and `15 MiB / 49140 MiB`,
disk `14G` free (`93%` used). Sports is result-complete for this domain gate
but still needs the comparison table and paired tests before SOTA wording.

Sports comparison/statistical gate follow-up at 2026-06-01 19:20 CST:
`scripts/experiments/main_build_domain_official_comparison.py` generated and
synced
`outputs/summary/sports_official_ccrp_20260601_comparison.csv`,
`outputs/summary/sports_official_ccrp_20260601_comparison.md`,
`outputs/summary/sports_official_ccrp_20260601_paired_tests.csv`, and
`outputs/summary/sports_official_ccrp_20260601_paired_summary.json`. C-CRP is
rank 1 by NDCG@10 and observed-best on all seven full metrics versus the eight
official baselines. The paired-test table has 56 rows (8 baselines x 7
metrics), all `n_paired_events=10000`, positive deltas, paired-bootstrap 95%
CIs above zero, and Holm-significant p-values. Best official row for every
metric is `llmemb`; closest C-CRP margin is HR@20 delta `0.0272`, CI
`[0.0164, 0.0386]`, Holm p `1.219129314796352e-06`. Sports now has a
sports-domain statistical pass. Do not generalize to paper-wide SOTA until the
declared domain set, aligned official baselines, paired tests, and ARIS review
are complete.

Next-domain baseline follow-up at 2026-06-01 19:48 CST: toys official baselines
started with a storage-aware single-row run. Server had no active
Pony/baseline experiment process, C-CRP reports existed for sports/toys/home/tools,
and sports official baselines were 8/8 complete; toys/home/tools official rows
were still 0/8. Disk preflight found only `14G` free, so disposable user caches
under `/home/ajifang/.cache` (`vllm`, `torch`, `google-chrome`, `mozilla`,
`JetBrains`) were removed after absolute-path verification, recovering to about
`19G` free and not touching project evidence. Toys `proex_profile` launched
with runner PID `2893793`, adapter PID `2893803`, PID file
`baselines_new_domains_toys_proex.pid`, and log
`baselines_new_domains_toys_proex_20260601_194414.log`. At the 19:48 check it
was running Qwen3 `hf_mean_pool` embedding at about `7088/215034`, GPU `95%`,
disk about `18G` free. It is not table-eligible until final scores, provenance,
audit/import metrics, row counts, server-final audit, local-light sync, and
local-light audit pass.
