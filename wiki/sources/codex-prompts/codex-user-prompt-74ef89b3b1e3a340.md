---
title: Phase 9C main accuracy multi-seed aggregation is complete.
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

# Phase 9C main accuracy multi-seed aggregation is complete.

## Metadata

- Stable ID: `codex-user-prompt:74ef89b3b1e3a340`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-03T22:25:02.265Z`
- Semantic hash: `74ef89b3b1e3a340f2c4f496f43ed484f71740ad3a5850d0789e5510ddd8a296`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Phase 9C main accuracy multi-seed aggregation is complete.

The following limitations are now removed:
- seed=0 only
- no significance/std yet

Do not remove this methodological note:
- shared-pool scoring is an efficiency fix, not a protocol change.

Now enter Phase 9D: DeepSeek V4 Flash API LLM Experiments.

Goal:
Remove the no-API-LLM limitation by integrating DeepSeek V4 Flash as an OpenAI-compatible API backend and running controlled LLM reranking / temporal evidence prompt experiments.

This phase should produce API LLM results as a separate paper table, not overwrite the main non-LLM accuracy table.

# Current status

Main accuracy table is complete for:
- MovieLens full
- Amazon filtered iterative k=3
- seeds [0,1,2,3,4]
- methods:
 - popularity
 - bm25
 - mf_bpr
 - sasrec
 - temporal_graph_encoder
 - time_graph_evidence
 - time_graph_evidence_dynamic

Known result interpretation:
- MovieLens: time_graph_evidence is strongest.
- Amazon: popularity has higher Recall@5, while time_graph_evidence has better ranking quality on NDCG/MRR.
- time_graph_evidence_dynamic is currently weak and should be diagnosed, not used as a positive claim.

# Phase 9D Scope

Allowed:
- DeepSeek V4 Flash provider
- async batch API runner
- cache-first execution
- 429 retry/backoff
- strict JSON parsing
- LLM rerank experiments
- temporal evidence prompt experiments
- API cost/latency tracking
- grounding/hallucination evaluation
- paper-ready LLM table export

Forbidden:
- do not rerun Phase 9C main matrix
- do not change frozen split/candidate artifacts
- do not change candidate_size
- do not run LoRA yet
- do not write final paper conclusions
- do not store API key
- do not run unlimited uncontrolled API calls
- do not mix API LLM rows into the non-LLM main table without clear labeling

# DeepSeek provider requirements

Implement or update:

src/llm4rec/llm/deepseek_provider.py
src/llm4rec/llm/async_batch.py
src/llm4rec/llm/rate_limit.py
src/llm4rec/llm/api_cache.py
src/llm4rec/llm/api_cost.py
src/llm4rec/llm/json_parser.py

configs/llm/deepseek_v4_flash.yaml
configs/experiments/paper_deepseek_llm_rerank.yaml
configs/experiments/paper_deepseek_temporal_evidence.yaml

scripts/run_deepseek_llm_matrix.py
scripts/estimate_deepseek_cost.py
scripts/export_deepseek_tables.py

tests/unit/test_deepseek_provider.py
tests/unit/test_deepseek_rate_limit.py
tests/unit/test_deepseek_cache.py
tests/unit/test_deepseek_json_parser.py
tests/smoke/test_deepseek_dry_run.py

Provider config:

base_url: https://api.deepseek.com
model: deepseek-v4-flash
api_key_env: DEEPSEEK_API_KEY
temperature: 0
top_p: 1
max_tokens: 512
stream: false by default
timeout: 120
max_retries: 8
retry_on_status: [429, 500, 502, 503, 504]
cache_enabled: true
resume: true

Concurrency config:

max_concurrency: 32
adaptive_concurrency: true
min_concurrency: 4
max_concurrency_hard_cap: 128
backoff_initial_seconds: 2
backoff_max_seconds: 60
jitter: true

Important:
DeepSeek rate limit is dynamic. If 429 occurs, reduce concurrency and retry with backoff. Do not fail the whole matrix unless error budget is exceeded.

# API key safety

Read key only from env var:

DEEPSEEK_API_KEY

Never save:
- API key
- authorization header
- raw secret env
- full request headers

Sanitize:
- resolved_config.yaml
- logs.txt
- api_requests.jsonl
- api_raw_outputs.jsonl
- cache files

# Experiments

Run DeepSeek experiments as separate LLM matrices.

Datasets:
1. movielens_full
2. amazon_multidomain_filtered_iterative_k3

Use frozen protocol_v1 artifacts.

Use compact_ref_v1 for Amazon.

Candidate handling:
- Do not pass all 1000 candidates to LLM unless prompt length is safe.
- Use first-stage retriever candidate reduction:
 - top_m_candidates_for_llm: 50 by default
 - source from frozen candidates + method scores/evidence scores
 - target inclusion audit must be recorded.
- The LLM reranker reranks top_m candidates only.
- Save the upstream retrieval source and top_m selection policy.

Prompt variants:
1. history_only
2. history_with_order
3. history_with_time_buckets
4. history_with_transition_evidence
5. history_with_contrastive_evidence
6. time_graph_evidence_prompt

LLM methods:
1. deepseek_history_only_rerank
2. deepseek_order_rerank
3. deepseek_time_bucket_rerank
4. deepseek_transition_evidence_rerank
5. deepseek_contrastive_evidence_rerank
6. deepseek_tge_evidence_rerank

# Execution stages

## Phase 9D-0: dry-run and cost estimate

Run:

py -3.12 scripts/estimate_deepseek_cost.py \
 --config configs/experiments/paper_deepseek_llm_rerank.yaml

py -3.12 scripts/run_deepseek_llm_matrix.py \
 --config configs/experiments/paper_deepseek_llm_rerank.yaml \
 --dry-run

Dry-run must output:
outputs/paper_runs/protocol_v1/deepseek_llm/dry_run/
├── cost_estimate.json
├── planned_requests.jsonl
├── prompt_length_report.csv
├── target_inclusion_audit.csv
└── api_safety_report.json

## Phase 9D-1: pilot API run

Run small pilot first:

datasets:
- movielens_full
- amazon_multidomain_filtered_iterative_k3

max_users_per_dataset: 500
max_requests: 3000
max_concurrency: 32
cache_enabled: true
resume: true

Output:
outputs/paper_runs/protocol_v1/deepseek_llm/pilot/

Acceptance:
- parse_success_rate >= 0.95
- hallucination_rate reported
- candidate_adherence_rate reported
- target inclusion audit present
- cache works
- cost/latency saved
- 429 handling works or no 429 occurred

## Phase 9D-2: full API LLM run

Only start after pilot passes.

Full output:
outputs/paper_runs/protocol_v1/deepseek_llm/full/

Required files:
resolved_config.yaml
environment.json
api_requests.jsonl
api_raw_outputs.jsonl
predictions.jsonl
metrics.json
metrics.csv
cost_latency.json
cache_report.json
failure_report.json
grounding_report.csv
hallucination_cases.jsonl
parse_failures.jsonl
table_deepseek_llm.csv
table_deepseek_llm.tex

# Metrics

Compute:

Recall@1/5/10
NDCG@1/5/10
MRR@10
validity_rate
hallucination_rate
candidate_adherence_rate
parse_success_rate
evidence_grounding_rate
transition_evidence_usage_rate
time_evidence_usage_rate
semantic_evidence_usage_rate
contrastive_evidence_usage_rate
latency_mean
latency_p50
latency_p95
total_tokens
prompt_tokens
completion_tokens
estimated_cost
cache_hit_rate
requests_per_minute

# Comparison table

Export a separate API LLM table:

table_deepseek_llm.csv
table_deepseek_llm.tex

Compare:
- best non-LLM baseline from Phase 9C
- time_graph_evidence
- deepseek_history_only_rerank
- deepseek_transition_evidence_rerank
- deepseek_contrastive_evidence_rerank
- deepseek_tge_evidence_rerank

Do not merge into main accuracy table unless clearly labeled API LLM.

# Tests and validation

Run:

py -3.12 -m pytest tests/unit/test_deepseek_provider.py
py -3.12 -m pytest tests/unit/test_deepseek_rate_limit.py
py -3.12 -m pytest tests/unit/test_deepseek_cache.py
py -3.12 -m pytest tests/unit/test_deepseek_json_parser.py
py -3.12 -m pytest tests/smoke/test_deepseek_dry_run.py
py -3.12 -m pytest -q

Run:

py -3.12 scripts/validate_project.py

# Acceptance criteria

Phase 9D is complete only if:

1. DeepSeek provider implemented.
2. Dry-run works without API call.
3. Cost estimate works.
4. API key is read only from DEEPSEEK_API_KEY.
5. Logs/configs/cache do not contain API key.
6. Async runner supports adaptive concurrency.
7. 429 backoff is implemented.
8. Pilot run succeeds before full run.
9. Full run writes predictions/metrics/cost/latency.
10. API LLM table is exported separately.
11. No LoRA training is run.
12. Frozen artifacts unchanged.
13. validate_project passes.
14. pytest -q passes.

# Output report

When finished, report:

## Files changed
## Commands run
## Test results
## DeepSeek provider summary
## Dry-run cost estimate
## Pilot API summary
## Full API run summary
## API LLM metrics
## Cost and latency summary
## Grounding/hallucination summary
## Failure audit summary
## Artifact integrity
## Known limitations

After Phase 9D, remove:
- no API LLM yet

Still include:
- no LoRA yet
- shared-pool scoring is an efficiency fix, not a protocol change

## Next recommended step

Exactly:
Phase 9E: Local 8B LoRA / QLoRA experiments.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
