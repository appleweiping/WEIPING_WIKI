---
title: 这不是 BLOCKER，不要继续在 max_requests 这种 trivial safety mismatch 上停住。
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - automation
source_pages:
  - codex-prompt-corpus
---

# 这不是 BLOCKER，不要继续在 max_requests 这种 trivial safety mismatch 上停住。

## Metadata

- Stable ID: `codex-user-prompt:7832b29cb044ac0c`
- Source kind: `codex-session-user`
- Category: `automation`
- Timestamp: `2026-05-02T13:16:06.715Z`
- Semantic hash: `7832b29cb044ac0c74b595e4a4bded040fe9c596df18ec986ebacb7dd17c1478`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
这不是 BLOCKER，不要继续在 max_requests 这种 trivial safety mismatch 上停住。

我已批准 R2-real-LLM subgate 使用 DeepSeek v4 flash，并批准本次 200-example method matrix 的真实 API 执行。

Provider:

model: deepseek-v4-flash
base_url: https://api.deepseek.com
api_key_env: DEEPSEEK_API_KEY

Important:
- Do not print, log, commit, or ask for the actual API key.
- The actual key is available only through the environment variable DEEPSEEK_API_KEY.
- base_url must be exactly https://api.deepseek.com, not including /chat/completions.
- This approval is only for R2-real-LLM subgate, not multi-dataset experiments, not LoRA, not HF downloads.

The previous preflight estimated 2200 real LLM requests for subset_size=200. That is expected and approved.

Update configs/experiments/r2_movielens_1m_real_llm_subgate.yaml:

safety:
 dry_run: false
 requires_confirm: false
 allow_api_calls: true
 subset_size: 200
 max_examples: 200
 max_requests: 3000
 cost_limit_usd: 999999
 concurrency: 16
 request_timeout_seconds: 120
 max_retries: 3
 backoff_seconds: 2

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

Execution policy:
- Run the approved 200-example R2-real-LLM subgate.
- Use seed [13].
- Keep cache/resume enabled.
- Keep raw output saving enabled.
- Keep cost/latency tracking enabled.
- Use concurrency 16 initially.
- If 429/5xx/timeouts occur repeatedly, reduce effective concurrency to 8, then 4, then 2.
- Do not fail the whole experiment on transient API errors unless retries are exhausted.
- If partial failure occurs, save partial artifacts and report exact failed examples/methods.

Do not change:
- OursMethod core mechanism
- evaluator definitions
- candidate protocol
- split protocol
- prompt leakage safeguards
- method matrix

Run preflight again:

.\.venv\bin\python.exe scripts/validate_experiment_ready.py --config configs/experiments/r2_movielens_1m_real_llm_subgate.yaml
.\.venv\bin\python.exe scripts/list_required_artifacts.py --config configs/experiments/r2_movielens_1m_real_llm_subgate.yaml
git diff --check

If and only if preflight passes and DEEPSEEK_API_KEY exists, execute:

.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/r2_movielens_1m_real_llm_subgate.yaml

Then run:

.\.venv\bin\python.exe scripts/export_tables.py --input outputs/runs --output outputs/tables
.\.venv\bin\python.exe scripts/aggregate_runs.py --input outputs/runs --output outputs/tables
.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/smoke_phase6_all.yaml
.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/smoke_phase5_all.yaml
.\.venv\bin\python.exe -m pytest
git diff --check

Completion report must include:

## Verdict

Choose one:
- PASS: real LLM subgate trustworthy enough to scale
- PASS WITH MINOR FIXES
- MAJOR FIXES REQUIRED
- BLOCKER

Do not call max_requests a blocker again unless the request estimate exceeds 3000.

## Provider used

State:
- provider: DeepSeek OpenAI-compatible
- model: deepseek-v4-flash
- base_url: https://api.deepseek.com
- api_key_env: DEEPSEEK_API_KEY
- key was not printed/logged/committed

## Dataset / subset

Report:
- dataset path
- subset size
- candidate size
- target inclusion rate
- methods run
- estimated requests
- actual requests
- cache hits

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
- token usage
- cost
- latency p50/p95
- cache hit rate

## OursMethod behavior

Report:
- accept / fallback / abstain / rerank ratio
- fallback method distribution
- echo_risk count
- popularity bucket behavior
- whether Ours full differs from fallback-only

## Leakage/fairness audit

Confirm:
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
- run candidate sensitivity before full real-LLM scaling
- scale to full single-dataset real LLM experiment
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
