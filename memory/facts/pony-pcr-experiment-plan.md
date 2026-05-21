---
title: "Pony PCR Experiment Plan — Calibration Cliffs in LLM Recommendation"
type: fact
created: 2026-05-21T23:00:00+08:00
updated: 2026-05-21T23:00:00+08:00
agent: claude
tags: [pony, PCR, experiment-plan, ARIS, calibration-cliff, critical]
related: [pony-current-status.md, pony-experiment-plan.md, research-hard-rules.md]
---

## Experiment Plan: Position-Calibrated Recommendation (PCR)

### Key Advantage: Most data already exists

Unlike previous pivots, PCR can reuse ALL existing baseline predictions (8+ methods × 4 domains already computed). No new LLM inference needed for core analysis. This dramatically reduces compute and timeline.

---

## Experiment Blocks (5 blocks)

### B1: Calibration Cliff Characterization (8+ methods × 4 domains)

**Already have data for:**
- IRLLRec official (beauty: 973 users, books/electronics/movies: 10000 users each)
- ProEx official (beauty + 3 domains)
- LLM2Rec official (4 domains)
- LLM-ESR official (4 domains)
- LLMEmb official (4 domains)
- RLMRec official (4 domains)
- ELMRec official (4 domains)
- SETRec-style, IRLLRec-style, LLM2Rec-style, LLMEmb-style, RLMRec-style (embedding baselines)

**Protocol:**
1. For each method × domain, compute position-wise precision: P(pos at rank k) / P(random)
2. Identify cliff position: first rank where precision drops below 1.0x random
3. Compute "reliable depth": number of positions where precision > 1.5x random
4. Plot calibration curves for all methods on same axes
5. Statistical test: is cliff position significantly different across methods?

**Metrics:**
- Cliff position (rank where precision first drops below random)
- Reliable depth (ranks with >1.5x random precision)
- Area under calibration curve (AUCC) — total "useful ranking mass"
- Cliff sharpness (slope of precision drop at cliff)

**Compute:** Near-zero (just analysis of existing predictions). ~10 minutes.

**Decision gate:** If ALL methods have cliff at rank 0-1 (no useful ranking at all), the phenomenon is trivial. Need at least 3 methods with cliff > 3 to proceed.

---

### B2: Protocol Sensitivity (address Codex concern)

**Question:** Is the cliff an artifact of the 101-candidate protocol?

**Experiments:**
1. **Candidate set size:** Subsample to 20, 50, 101, 200 candidates (if data allows) and recompute cliffs
2. **Negative sampling strategy:** Compare random negatives vs popularity-sampled negatives
3. **Multiple relevance definitions:** Binary (hit/miss) vs graded (NDCG-style position value)
4. **Cross-dataset:** Compare cliff patterns across Beauty, Books, Electronics, Movies

**Compute:** Minimal (resampling existing data). ~30 minutes.

**Decision gate:** If cliff disappears with different candidate sizes → it's a protocol artifact → STOP. If cliff persists across sizes and datasets → robust phenomenon → PROCEED.

---

### B3: Conformal Adaptive Depth

**Method:**
1. Split users into calibration (50%) and test (50%)
2. On calibration set: estimate the calibration curve P(relevant | rank k)
3. For target coverage α: find minimum depth d such that P(pos in top-d) ≥ 1-α on calibration
4. Apply d to test set: output top-d recommendations
5. Verify: actual coverage on test ≥ 1-α (conformal guarantee holds)

**Comparison baselines:**
- Fixed top-5 (standard practice)
- Fixed top-10 (standard practice)
- Oracle top-k (k = actual positive rank, upper bound)
- Marginal conformal (global quantile, no position awareness)

**Metrics:**
- Coverage (must be ≥ target)
- Average set size (smaller = better at same coverage)
- Set efficiency = coverage / avg_set_size
- Wasted recommendations = set_size - 1 (items shown that aren't the positive)

**Compute:** ~1 hour (calibration + evaluation across methods/domains).

---

### B4: Cross-Method Cliff Analysis (the "why" block)

**Questions:**
1. What makes some methods more deeply calibrated? (ProEx cliff=? vs LLM2Rec cliff=2)
2. Does cliff depth correlate with overall method quality (NDCG)?
3. Do embedding-based methods have different cliff patterns than LLM-generation methods?
4. Is cliff depth related to: model size, prompt design, scoring mechanism, training data?

**Experiments:**
1. Scatter plot: method NDCG@10 vs cliff position (expect positive correlation)
2. Group by method type: pointwise-generation vs embedding-reranking vs hybrid
3. Analyze score distributions at cliff position (what happens to scores at the cliff?)
4. Decompose by user difficulty: do easy users have deeper cliffs?

**Compute:** ~30 minutes (analysis only).

---

### B5: Practical Value

**Experiments:**
1. **Adaptive vs fixed recommendation:** Compare PCR (adaptive depth per method) vs fixed top-10
   - Metric: precision@depth (what fraction of shown items are relevant?)
   - PCR should have higher precision because it stops before unreliable positions
2. **Method selection:** Given multiple recommenders, choose the one with deepest cliff for each user
3. **Cost analysis:** PCR reduces wasted computation (don't need to score 101 items if only top-3 matter)
4. **User experience simulation:** Fewer but more reliable recommendations vs more but noisy

**Compute:** ~1 hour.

---

## Milestones & Decision Gates

```
B1 (characterize) → B2 (robustness) → B3 (conformal) → B4 (analysis) → B5 (value)
    1 day              1 day             2 days            1 day           1 day
```

**Total timeline: ~6 days** (dramatically shorter than previous plan because data exists)

| Gate | Condition | Action if FAIL |
|------|-----------|----------------|
| B1 | ≥3 methods with cliff > rank 3 | Phenomenon too weak → STOP |
| B2 | Cliff persists across ≥2 candidate sizes AND ≥3 datasets | Protocol artifact → STOP |
| B3 | Conformal coverage holds (within ±3%) AND set size < fixed top-10 | Method doesn't add value → analysis paper only |

---

## Compute Budget

| Block | Time | Notes |
|-------|------|-------|
| B1 | 10 min | Pure analysis of existing data |
| B2 | 30 min | Resampling + reanalysis |
| B3 | 1 hour | Calibration + conformal + evaluation |
| B4 | 30 min | Analysis + visualization |
| B5 | 1 hour | Simulation + comparison |
| **Total** | **~3.5 hours** | Almost no GPU needed |

---

## Paper Framing (per Codex suggestion)

**Title:** Calibration Cliffs in LLM-Based Recommendation: Where Rankings Stop Being Reliable

**One-sentence contribution:**
> We discover that LLM recommenders exhibit sharp "calibration cliffs" where ranking precision drops below random after just a few positions, and propose Position-Calibrated Recommendation (PCR) to provide formal guarantees on recommendation depth.

**Paper structure:**
1. Introduction: LLM recommenders are assumed to produce useful top-k lists, but do they?
2. The Calibration Cliff Phenomenon: systematic study across 8+ methods × 4 domains
3. Position-Calibrated Recommendation: conformal framework for adaptive depth
4. Why Cliffs Exist: cross-method analysis of cliff determinants
5. Practical Implications: adaptive depth improves precision, reduces waste
6. Related Work: calibration in classification, conformal prediction, LLM4Rec evaluation
7. Conclusion

---

## Output Artifacts

- `experiments/rsc/pcr_analysis.py` — cliff characterization + visualization
- `experiments/rsc/pcr_conformal.py` — conformal adaptive depth
- `experiments/rsc/pcr_robustness.py` — protocol sensitivity tests
- `experiments/rsc/results/pcr/` — all outputs
- `paper/` — LaTeX source (after B3 passes)

---

## Next ARIS Step

→ experiment-bridge: implement pcr_analysis.py (B1 can run immediately on existing data)
→ B1 results determine if we proceed
