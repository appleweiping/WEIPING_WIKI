---
title: R2-real-LLM subgate provider is now approved.
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

# R2-real-LLM subgate provider is now approved.

## Metadata

- Stable ID: `codex-user-prompt:de0fdd7a5a32897b`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-02T13:00:16.756Z`
- Semantic hash: `de0fdd7a5a32897bad9a035566b2766dc7ed54a08d9e34bd489662464f5201a7`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
R2-real-LLM subgate provider is now approved.

Use DeepSeek OpenAI-compatible API.

Provider values:

model: deepseek-v4-flash
base_url: https://api.deepseek.com
api_key_env: DEEPSEEK_API_KEY

Important:
- Do not print, log, commit, or ask for the actual API key.
- The actual API key will be provided only through the environment variable DEEPSEEK_API_KEY.
- base_url must be exactly https://api.deepseek.com and must not include /chat/completions.
- Use OpenAI-compatible chat completions.
- This is DeepSeek v4 flash, not deepseek-chat or deepseek-reasoner.

Budget:
- Budget is approved for this subgate.
- Still enforce max_requests, subset_size, cache, resume, and cost/latency tracking for experiment control and reproducibility.
- Do not remove safety guards.
- Do not run unlimited requests.
- For this subgate, use a controlled subset and high-throughput but safe concurrency.

Execution policy:
- We are approving the R2-real-LLM subgate only, not full multi-dataset experiments.
- Do not run multi-dataset experiments.
- Do not run LoRA.
- Do not download HF models.
- Do not change OursMethod core mechanism.
- Do not write paper claims.
- Do not fabricate results.

# Update Config

Update:

configs/experiments/r2_movielens_1m_real_llm_subgate.yaml

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
 max_requests: 200
 cost_limit_usd: 999999
 concurrency: 8
 request_timeout_seconds: 90
 max_retries: 3
 backoff_seconds: 2

Notes:
- Pricing values are config-level estimates for cost tracking. Do not hard-code them in source.
- If the provider returns cache-hit/cache-miss token details, preserve them in cost_latency.json.
- If rate limits or instability occur, automatically reduce effective concurrency from 8 to 4, then 2, rather than failing the whole experiment immediately.
- If repeated 429/5xx errors persist after retries, stop and report partial artifacts.

# Method Set

Run only the R2-real-LLM subgate on the approved MovieLens subset.

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

Do not run full MovieLens real API yet.
Do not run multi-seed real API yet.
Use seed [13] only for this subgate.

# Preflight First

Before execution, run:

.\.venv\bin\python.exe scripts/validate_experiment_ready.py --config configs/experiments/r2_movielens_1m_real_llm_subgate.yaml
.\.venv\bin\python.exe scripts/list_required_artifacts.py --config configs/experiments/r2_movielens_1m_real_llm_subgate.yaml
git diff --check

If DEEPSEEK_API_KEY is not set in the environment, stop with BLOCKER and tell me to set it. Do not ask me to paste the key.

# Execute Only If Preflight Passes

If preflight passes and DEEPSEEK_API_KEY exists, run:

.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/r2_movielens_1m_real_llm_subgate.yaml

Then run:

.\.venv\bin\python.exe scripts/export_tables.py --input outputs/runs --output outputs/tables
.\.venv\bin\python.exe scripts/aggregate_runs.py --input outputs/runs --output outputs/tables

Then run regression:

.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/smoke_phase6_all.yaml
.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/smoke_phase5_all.yaml
.\.venv\bin\python.exe -m pytest
git diff --check

# Required Artifacts

Each real-LLM run must contain:

- resolved_config.yaml
- environment.json
- logs.txt
- predictions.jsonl
- metrics.json
- metrics.csv
- cost_latency.json
- raw LLM outputs or response cache artifact
- artifacts/

Predictions must preserve:

- raw_output
- generated_title
- confidence
- parse_success
- grounded_item_id
- grounding_success
- hallucination flag
- uncertainty_decision
- fallback_method
- prompt_template_id
- prompt_hash
- provider
- model
- token_usage
- latency_seconds
- cache_hit

# Required Review

After the run, output reviewer verdict:

## Verdict

Choose one:

- PASS: real LLM subgate trustworthy enough to scale
- PASS WITH MINOR FIXES
- MAJOR FIXES REQUIRED
- BLOCKER

## Provider used

Must state:

- provider: DeepSeek OpenAI-compatible
- model: deepseek-v4-flash
- base_url: https://api.deepseek.com
- api_key_env: DEEPSEEK_API_KEY
- key was not printed or committed

## Dataset / subset

Report:

- dataset path
- subset size
- candidate size
- target inclusion rate
- methods run

## Commands run

Exact commands.

## Artifact summary

Run dirs and table files.

## Key metrics

Report actual metrics:

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
- cost
- latency p50/p95
- token usage
- cache hit rate

## OursMethod behavior

Report:

- accept / fallback / abstain / rerank ratio
- fallback method distribution
- echo_risk count
- popularity bucket behavior
- whether Ours full differs from fallback-only

## Leakage/fairness audit

Must confirm:

- target title not in prompt
- target item ID not in prompt
- future interactions not used
- target included in candidate set
- same candidate protocol across methods
- train-only popularity
- grounding catalog-only
- confidence policy does not inspect target correctness

## Failures / retries

Report:

- API errors
- retry counts
- rate-limit events
- timeout events
- partial failures
- skipped examples if any

## Scaling recommendation

Choose one:

- scale to full single-dataset real LLM experiment
- run candidate sensitivity first
- repair protocol before scaling

## Next recommended action

Exactly one next action.

If PASS, write:

Run candidate sensitivity before full real-LLM scaling.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
