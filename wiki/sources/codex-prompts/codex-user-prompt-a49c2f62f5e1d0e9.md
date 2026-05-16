---
title: 更新到github main，
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - coding-agent-workflow
source_pages:
  - codex-prompt-corpus
---

# 更新到github main，

## Metadata

- Stable ID: `codex-user-prompt:a49c2f62f5e1d0e9`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-02T17:20:57.732Z`
- Semantic hash: `a49c2f62f5e1d0e9fb06ba9a21b5366fd5a91b13303217f5efb1b1237a1b7db1`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
更新到github main，
R2-real-LLM cache accounting patch PASS。现在进入 candidate sensitivity before full real-LLM scaling。

不要再讨论 provider、budget、max_requests、cache accounting。
不要改 OursMethod core mechanism。
不要改 prompt。
不要改 evaluator definitions。
不要跑多数据集。
不要写论文结论。
不要下载 HF。
不要 LoRA。
不要让 MockLLM 进入 real LLM evidence。

目标：在 MovieLens 1M 上做 candidate sensitivity，检查 sampled-ranking protocol 对方法排序、OursMethod fallback/uncertainty behavior、confidence/calibration、popularity/long-tail 结论的影响。

Context:
- R2 full single-dataset with sampled candidate size 100 PASS。
- R2-real-LLM subgate with DeepSeek v4 flash PASS WITH MINOR FIXES，minor fix已解决。
- DeepSeek provider:
 - model: deepseek-v4-flash
 - base_url: https://api.deepseek.com
 - api_key_env: DEEPSEEK_API_KEY
- Existing DeepSeek cache must be reused whenever prompts are identical.
- For new candidate sizes, new prompts may require new API calls. That is approved for this candidate sensitivity gate.

# Candidate Sensitivity Scope

Run candidate sizes:

- 50
- 100
- 500

Use dataset:

data/processed/movielens_1m/r2_full_single_dataset

Use subset:

- subset_size: 200
- seed: 13
- sampled candidates with target included
- save candidate sets
- same split across sizes
- same methods across sizes where feasible

Methods:

- popularity
- bm25
- sequential_markov
- llm_generative_real
- llm_rerank_real
- llm_confidence_observation_real
- ours_uncertainty_guided_real
- ours_fallback_only
- ours_ablation_no_uncertainty
- ours_ablation_no_grounding

Do not include full method expansion beyond this.

# Configs to create/update

Create:

configs/experiments/r2_movielens_1m_candidate_sensitivity.yaml

It should define candidate_sizes: [50, 100, 500] or equivalent multi-run configs.

If the runner cannot support candidate_sizes list directly, create explicit configs:

configs/experiments/r2_movielens_1m_candidate50.yaml
configs/experiments/r2_movielens_1m_candidate100.yaml
configs/experiments/r2_movielens_1m_candidate500.yaml

But prefer one umbrella config if supported.

# Safety / API Controls

DeepSeek API is approved for this candidate sensitivity gate.

Set:

llm:
 provider: openai_compatible
 model: deepseek-v4-flash
 base_url: https://api.deepseek.com
 api_key_env: DEEPSEEK_API_KEY
 cache:
 enabled: true
 resume:
 enabled: true
 pricing:
 input_per_1m_tokens: 0.14
 output_per_1m_tokens: 0.28

safety:
 dry_run: false
 requires_confirm: false
 allow_api_calls: true
 subset_size: 200
 max_examples: 200
 cost_limit_usd: 999999
 concurrency: 16
 request_timeout_seconds: 120
 max_retries: 3
 backoff_seconds: 2

Set max_requests high enough for the planned matrix.

Do not stop on trivial max_requests mismatch. Compute estimated requests first and set max_requests with buffer.

Rule:
- max_requests must be at least estimated_requests * 1.25.
- If estimated_requests is 6600, set max_requests >= 8250.
- Use 10000 unless the estimate is higher.

If rate limits occur:
- reduce concurrency 16 -> 8 -> 4 -> 2.
- preserve partial artifacts.
- retry only configured retries.
- do not corrupt completed runs.

# Required Preflight

Run:

.\.venv\bin\python.exe scripts/validate_experiment_ready.py --config configs/experiments/r2_movielens_1m_candidate_sensitivity.yaml
.\.venv\bin\python.exe scripts/list_required_artifacts.py --config configs/experiments/r2_movielens_1m_candidate_sensitivity.yaml
git diff --check

If the umbrella config is not supported and explicit configs are used, validate all explicit configs.

# Execute

Run candidate sensitivity:

.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/r2_movielens_1m_candidate_sensitivity.yaml

Then export:

.\.venv\bin\python.exe scripts/export_tables.py --input outputs/runs --output outputs/tables
.\.venv\bin\python.exe scripts/aggregate_runs.py --input outputs/runs --output outputs/tables

Then regression:

.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/smoke_phase6_all.yaml
.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/smoke_phase5_all.yaml
.\.venv\bin\python.exe -m pytest
git diff --check

# Required Artifacts

For every candidate size and method, run dirs must include:

- resolved_config.yaml
- environment.json
- logs.txt
- predictions.jsonl
- metrics.json
- metrics.csv
- cost_latency.json
- raw_llm_outputs.jsonl or response cache artifact for real LLM methods
- artifacts/

Export candidate sensitivity summary:

outputs/tables/candidate_sensitivity.csv
outputs/tables/candidate_sensitivity.md
outputs/tables/candidate_sensitivity.tex

If existing export_tables cannot produce these, add a narrow table export function.

# Required Analysis

Report actual metrics by candidate size and method:

- Recall@10
- NDCG@10
- MRR@10
- validity_rate
- hallucination_rate
- parse_success_rate
- grounding_success_rate
- mean_confidence
- ECE
- Brier
- high-confidence wrong count
- low-confidence correct count
- coverage
- novelty
- long-tail recall/hit
- cost
- latency p50/p95
- cache hit rate

# Candidate Sensitivity Questions

Answer using actual artifacts:

1. Does method ranking change between candidate size 50, 100, and 500?
2. Does Ours full still behave mostly like fallback-only?
3. Does Ours full differ from BM25/fallback as candidate size grows?
4. Does llm_generative_real remain near-zero or improve with candidate protocol?
5. Does llm_rerank_real become useful at larger/smaller candidate sizes?
6. Does confidence calibration change with candidate size?
7. Does high-confidence wrong count change?
8. Does tail/head performance change with candidate size?
9. Are grounding and parse failures stable?
10. Is candidate size 100 acceptable for paper-candidate results, or should final experiments use 500 or full ranking?

# Leakage/Fairness Audit

Confirm for each candidate size:

- target inclusion rate is 100%;
- candidate set size matches config;
- all methods use same candidate sets;
- target title/ID not in prompts;
- future interactions not used;
- train-only popularity;
- grounding catalog-only;
- confidence policy does not inspect target correctness;
- evaluator shared.

# Completion Report

Report:

## Verdict

Choose one:

- PASS: candidate sensitivity supports scaling
- PASS WITH MINOR FIXES
- MAJOR FIXES REQUIRED
- BLOCKER

## Candidate sizes run

## Provider used

State DeepSeek v4 flash and confirm key was not printed/logged/committed.

## Commands run

## Test results

## Artifact summary

## Candidate sensitivity table

Compact actual metrics by candidate size/method.

## Stability analysis

Answer the 10 sensitivity questions.

## OursMethod behavior

Report accept/fallback/abstain/rerank ratio by candidate size.

## Cost/latency summary

Report live calls, cache hits, cost, token usage, p50/p95 latency.

## Leakage/fairness audit

Pass/fail with evidence.

## Issues

Blockers/major/minor.

## Scaling recommendation

Choose one:

- scale to full single-dataset real LLM experiment with candidate size X
- run another sensitivity pass
- repair protocol before scaling

## Next recommended action

Exactly one next action.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
