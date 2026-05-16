---
title: R2-real-LLM subgate returned PASS WITH MINOR FIXES.
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

# R2-real-LLM subgate returned PASS WITH MINOR FIXES.

## Metadata

- Stable ID: `codex-user-prompt:1add83f8a5d5e350`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-02T16:40:05.729Z`
- Semantic hash: `1add83f8a5d5e350ea71c66bbfe8d138de701708e927757e175c32d0955dba50`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

````text
R2-real-LLM subgate returned PASS WITH MINOR FIXES.

This is not a blocker. Do not rerun live DeepSeek API calls. Do not expand scope. Do not change OursMethod. Do not change prompts. Do not change evaluator definitions. Do not change candidate protocol. Do not run candidate sensitivity yet.

Only patch the minor issue:

cache-hit replays should carry original live cost/latency into cost_latency.json and metrics summaries. The response cache already has the actual values, but final replay summaries currently report zero live latency/cost.

# Goal

Fix cache replay accounting so that final accepted cached/replayed runs report both:

1. replay/runtime latency and cost, which may be near zero;
2. original live provider latency, token usage, and estimated cost from the cached DeepSeek responses.

This patch should allow R2-real-LLM subgate artifacts to preserve real DeepSeek cost/latency evidence without making new live API calls.

# Scope

Allowed:
- src/llm4rec/llm/response_cache.py
- src/llm4rec/llm/cost_tracker.py
- src/llm4rec/metrics/efficiency.py
- src/llm4rec/evaluation/evaluator.py if needed
- src/llm4rec/experiments/runner.py if needed
- tests related to response cache / cost tracker / efficiency metrics
- docs or artifact notes only if necessary

Forbidden:
- no live API calls
- no prompt changes
- no OursMethod changes
- no model/method matrix changes
- no candidate protocol changes
- no real LoRA/HF/API expansion
- no paper claims
- no fabricated metrics

# Required behavior

When a provider response is served from cache, the LLMResponse or equivalent metadata must preserve:

- cache_hit: true
- provider
- model
- prompt_hash / cache key
- original usage:
 - prompt_tokens
 - completion_tokens
 - total_tokens
 - prompt_cache_hit_tokens if available
 - prompt_cache_miss_tokens if available
- original live latency_seconds
- original estimated_cost_usd
- replay latency_seconds
- replay estimated_cost_usd, normally 0
- source: cache

cost_latency.json must distinguish:

```json
{
 "total_requests": ...,
 "live_provider_requests": ...,
 "cache_hit_requests": ...,
 "cache_hit_rate": ...,

 "live_cost_usd": ...,
 "replay_cost_usd": ...,
 "effective_cost_usd": ...,
 "original_cached_cost_usd": ...,

 "live_latency_seconds_sum": ...,
 "replay_latency_seconds_sum": ...,
 "original_cached_latency_seconds_sum": ...,

 "latency_p50_seconds": ...,
 "latency_p95_seconds": ...,
 "original_live_latency_p50_seconds": ...,
 "original_live_latency_p95_seconds": ...
}

Terminology:

live_cost_usd: cost incurred during this exact run.
replay_cost_usd: cost incurred by cache replay, usually 0.
original_cached_cost_usd: estimated cost of the original live calls represented by cache hits.
effective_cost_usd: live_cost_usd + original_cached_cost_usd, useful for reporting what the API run would cost or did cost when cache was first populated.

If naming differs, use equivalent names, but make the distinction explicit.

Cache-only rerun safety

Add or use a cache-only replay mode if not already present.

For this fix validation, the R2-real-LLM subgate must run from existing cache only and must not make new DeepSeek API calls.

If a cache entry is missing, stop with a clear error instead of calling the provider.

Suggested config option if needed:

llm:
 cache:
 enabled: true
 require_hit: true
 resume:
 enabled: true
safety:
 allow_api_calls: false

If an existing equivalent option exists, use that.

Tests to add/update

Add or update tests:

tests/unit/test_response_cache.py
tests/unit/test_cost_tracker.py
tests/unit/test_efficiency_metrics.py if exists
tests/smoke/test_real_llm_cache_replay_accounting.py if appropriate

Required test cases:

A cached response with original usage and latency returns cache_hit=true.
Cached response preserves original token usage.
Cached response preserves original estimated cost.
Cached response distinguishes replay latency from original live latency.
cost_latency aggregation includes original cached cost/latency.
cache-only replay fails if cache entry is missing.
cache-only replay does not initialize or call the real provider.
Existing mock/smoke tests still pass.
Commands to run

Use repo venv.

Run:

.\.venv\bin\python.exe -m pytest tests/unit/test_response_cache.py
.\.venv\bin\python.exe -m pytest tests/unit/test_cost_tracker.py

If you add an efficiency/cache replay test, also run it:

.\.venv\bin\python.exe -m pytest tests/unit/test_efficiency_metrics.py
.\.venv\bin\python.exe -m pytest tests/smoke/test_real_llm_cache_replay_accounting.py

Then run the R2-real-LLM subgate in cache-only replay mode. Do not make live API calls.

If the existing config supports cache-only replay, use it. Otherwise create a dedicated safe replay config:

configs/experiments/r2_movielens_1m_real_llm_subgate_cache_replay.yaml

Run:

.\.venv\bin\python.exe scripts/run_all.py --config configs/experiments/r2_movielens_1m_real_llm_subgate_cache_replay.yaml
.\.venv\bin\python.exe scripts/export_tables.py --input outputs/runs --output outputs/tables
.\.venv\bin\python.exe scripts/aggregate_runs.py --input outputs/runs --output outputs/tables
.\.venv\bin\python.exe -m pytest
git diff --check
Completion report

Report only:

Verdict

Choose one:

PASS: minor fix resolved, ready for candidate sensitivity
PASS WITH MINOR FIXES
MAJOR FIXES REQUIRED
BLOCKER
Files changed
Commands run
Test results
Cache accounting behavior

Explain how final cost_latency.json now distinguishes:

live run cost;
replay cost;
original cached live cost;
replay latency;
original live latency.
Real API safety

Confirm:

no new DeepSeek API calls were made for this patch validation;
cache-only replay was used;
missing cache would fail rather than call provider.
Artifact summary

List updated run dirs and cost_latency.json fields.

Next recommended action

If PASS, write exactly:

Run candidate sensitivity before full real-LLM scaling.
````

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
