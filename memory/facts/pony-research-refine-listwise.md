---
title: "Pony Research Refine — Listwise Conformal Recommendation"
type: fact
created: 2026-05-21T21:00:00+08:00
updated: 2026-05-21T21:00:00+08:00
agent: claude
tags: [pony, research-refine, listwise, conformal-prediction, LLM4Rec, critical]
related: [pony-current-status.md, pony-ccrp-decision-point.md, research-hard-rules.md]
---

## Refined Research Direction

**Title (working):** Rank-Conformal Listwise Recommendation: Uncertainty-Aware LLM Reranking with Coverage Guarantees

**Core Insight:** LLM listwise rerankers get the RANKING right even when their scores are poorly calibrated. Conformal prediction on RANKS (not scores) can provide coverage guarantees for set-valued recommendation without needing calibrated pointwise scores.

## Problem Reframing (original → new)

- **Old (C-CRP v1):** Pointwise uncertainty scores → conformal sets → hope sets are useful for ranking
- **New:** Listwise LLM reranking (strong discriminative signal) → rank-based conformal prediction → set-valued recommendation with provable coverage

**Why this works:** The 77% gap proved pointwise scoring can't discriminate. Listwise CAN discriminate (0.614 NDCG@10). Conformal prediction on ranks doesn't need calibrated scores — it only needs correct ordering, which listwise provides.

## Method Sketch

1. **Listwise LLM Reranker** — Qwen3-8B (or larger) does listwise reranking of candidates
2. **Rank-Based Nonconformity Score** — Instead of `1 - softmax_prob`, use `rank_position / total_candidates`
3. **Conformal Calibration** — Split calibration set, compute rank quantile threshold
4. **Set-Valued Output** — "Top-k items where k is adaptively chosen to guarantee 95% coverage of user's true preference"
5. **Adaptive Set Size** — Easy users get small sets (confident), hard users get larger sets (uncertain)

## Novelty Claims

1. **First to apply rank-based conformal prediction to LLM recommendation** (not score-based)
2. **Listwise + conformal hybrid** — uses listwise for discrimination, conformal for uncertainty
3. **Adaptive set size** — personalized uncertainty per user (vs fixed top-k)
4. **Task-grounded** — uncertainty directly serves the recommendation task (set size = decision support)

## Closest Papers (differentiation needed)

1. **CPFT (2024)** — Conformal prediction for sequential rec, but pointwise + fine-tuning approach. We do listwise + inference-time.
2. **Self-Calibrated Listwise Reranking (2024)** — Listwise + calibration, but no conformal guarantees. We add formal coverage.
3. **Rank-Based Conformal Sets (2024)** — Rank-based CP for classification, not recommendation. We extend to ranking/rec.
4. **InvariRank (2025)** — Position-invariant listwise reranking, no uncertainty. We add uncertainty layer.

## Feasibility

- **Data:** Same Amazon datasets (Beauty, etc.) already available
- **Compute:** Qwen3-8B listwise inference on RTX 4090 — feasible (already verified vLLM works)
- **Baselines:** ProEx, SETRec, ELMRec, IRLLRec (already run) + CPFT, standard CP
- **Timeline:** 3-4 weeks to full results if method works

## Risk Assessment

- **Main risk:** Listwise reranking might not produce stable enough rankings for conformal calibration (position bias)
- **Mitigation:** InvariRank-style permutation averaging, or multiple listwise passes
- **Kill condition:** If rank-based conformal sets are always size=N (no discrimination), the method adds nothing

## Next Steps (ARIS)

1. ✅ research-refine (this document)
2. → experiment-plan (design blocks, baselines, milestones)
3. → Send to Codex for cross-model review before proceeding
