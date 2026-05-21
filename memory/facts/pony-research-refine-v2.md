---
title: "Pony Research Refine v2 — Ranking Stability as Uncertainty"
type: fact
created: 2026-05-21T21:15:00+08:00
updated: 2026-05-21T21:15:00+08:00
agent: claude
tags: [pony, research-refine, listwise, ranking-stability, conformal-prediction, LLM4Rec, critical]
related: [pony-research-refine-listwise.md, pony-ccrp-decision-point.md]
---

## Refined Direction (post Codex review)

**Title (working):** Ranking Stability as Uncertainty: Conditional Conformal Prediction for LLM-Based Recommendation

**Core Insight:** LLM listwise rerankers are sensitive to input permutation — the same candidates in different orders produce different rankings. This instability IS the uncertainty signal. Users whose rankings are stable = model is confident. Users whose rankings fluctuate = model is uncertain → larger prediction sets.

## Method (revised after GPT-5.5 kill argument)

### Why v1 failed (Codex review)
- Pure rank position as nonconformity score → collapses to global top-k cutoff
- No per-user uncertainty → "adaptive set size" claim was mathematically false
- Coverage guarantee was trivially weak (just recall over fixed candidate pool)

### v2 Method

1. **Listwise LLM Reranker** — Qwen3-8B reranks 101 candidates per user
2. **Multi-pass permutation probing** — Run K (e.g., 5-10) listwise passes with different input orderings
3. **Per-user ranking stability score** — For each item, compute rank variance across K passes. For each user, aggregate stability:
   - `user_stability = mean(item_rank_variance)` across their candidate set
   - High variance = uncertain user, low variance = confident
4. **User-conditional nonconformity score** — `s(user, item) = rank_variance(item) / user_stability_quantile`
   - Items with high rank variance relative to the user's baseline → high nonconformity
5. **Conditional conformal calibration** — Group users by stability quantile, calibrate separately per group
   - Stable users → small conformal sets (model knows what they want)
   - Unstable users → large conformal sets (model is unsure)
6. **Set-valued output** — Per-user adaptive prediction set with conditional coverage guarantee

### Why this is NOT trivial top-k
- Different users get genuinely different set sizes based on model's internal uncertainty
- The uncertainty signal comes from the LLM's own behavior (permutation sensitivity), not external
- Conditional conformal provides group-conditional coverage, not just marginal

## Novelty (revised, stronger)

1. **Permutation sensitivity as uncertainty signal** — Novel framing: the known "position bias" problem in LLM reranking is recast as a FEATURE (uncertainty indicator), not a bug
2. **Conditional conformal for recommendation** — User-group-conditional coverage (not marginal)
3. **No training modification needed** — Pure inference-time method, works on any listwise LLM reranker
4. **Dual contribution** — Both a practical UQ method AND a new lens on LLM position bias

## Differentiation from closest work

| Paper | How we differ |
|-------|--------------|
| CPFT (2024) | They modify training with CP losses. We're inference-time only, no retraining. |
| Self-Calibrated Listwise (2024) | They calibrate scores. We use ranking INSTABILITY as signal. Fundamentally different. |
| Rank-Based CP (2024) | They use rank in classification. We use rank VARIANCE across permutations in rec. |
| InvariRank (2025) | They try to REMOVE position sensitivity. We EXPLOIT it as uncertainty. Opposite philosophy. |

## Kill condition

If rank variance across permutations is near-zero for all users (LLM is perfectly stable), there's no uncertainty signal to exploit. Preliminary check: run 5 permutations on 100 users, measure variance. If CV < 0.05 → method won't work.

## Next ARIS step

→ experiment-plan (design blocks with this revised method)
