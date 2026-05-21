---
title: "Pony Experiment Plan — Ranking Stability as Uncertainty"
type: fact
created: 2026-05-21T21:30:00+08:00
updated: 2026-05-21T21:30:00+08:00
agent: claude
tags: [pony, experiment-plan, ARIS, listwise, conformal, critical]
related: [pony-research-refine-v2.md, research-hard-rules.md]
---

## Experiment Plan: Ranking Stability as Uncertainty for LLM-Based Recommendation

### Infrastructure

- Server: pony-rec-gpu (125.71.97.70:15302, user: ajifang)
- GPU: RTX 4090 (49GB VRAM, currently free)
- Model: Qwen3-8B at `/home/ajifang/models/Qwen/Qwen3-8B`
- Backend: vLLM (config exists at `configs/model/qwen3_8b_vllm.yaml`)
- Data: Amazon Beauty (leave-one-out split, 101 candidates per user)
- Code: `~/projects/pony-rec-rescue-shadow-v6/`

---

## Experiment Blocks (6 blocks)

### B1: Phenomenon Validation — Does rank instability correlate with errors?

**Hypothesis:** Users whose LLM rankings are unstable across permutations have higher prediction error (lower hit rate).

**Protocol:**
1. Sample 200 users from test set
2. For each user, run K=10 listwise reranking passes with random input permutations
3. Compute per-user metrics:
   - `rank_variance`: mean variance of each item's rank across 10 passes
   - `hit@10`: whether ground-truth item appears in top-10 of mean rank
4. Compute Pearson correlation between `rank_variance` and `1 - hit@10`

**Decision gate:**
- r > 0.3 → PROCEED (signal is meaningful)
- 0.1 < r < 0.3 → PROCEED with caution (signal is weak but usable)
- r < 0.1 → STOP or pivot to logit-based uncertainty

**Compute:** 200 users × 10 passes × 101 candidates = ~200K listwise inferences. At vLLM batch=512, ~30 min.

---

### B2: Method Implementation — Conditional Conformal Pipeline

**Protocol:**
1. Split test users into calibration (50%) and evaluation (50%)
2. On calibration users:
   - Run K=10 permutation passes
   - Compute per-user stability score
   - Divide users into Q=4 stability quartiles
   - Per quartile, compute conformal threshold at α=0.05, 0.10, 0.20
3. On evaluation users:
   - Run K=10 passes, compute stability, assign to quartile
   - Apply quartile-specific threshold → produce prediction set
4. Measure: coverage rate, average set size, set size by quartile

**Success criteria:**
- Coverage ≥ (1-α) per quartile (conditional coverage holds)
- Set size varies meaningfully across quartiles (ratio of Q4/Q1 set size > 2x)

**Compute:** Full test set × 10 passes. ~2 hours.

---

### B3: Baseline Comparison — Main Results

**Our method:** Rank-Stability Conformal (RSC)

**Baselines (8+):**

| # | Baseline | Type | Source |
|---|----------|------|--------|
| 1 | Fixed Top-K | Trivial | k chosen to match our avg set size |
| 2 | Marginal Conformal (score-based) | CP | Standard split CP on pointwise scores |
| 3 | Marginal Conformal (rank-based) | CP | Global rank threshold (v1 that was killed) |
| 4 | CPFT | CP+Training | Confidence-aware fine-tuning (reimpl) |
| 5 | ProEx | LLM4Rec | Already run (existing baseline) |
| 6 | SETRec | LLM4Rec | Already run |
| 7 | ELMRec | LLM4Rec | Already run |
| 8 | IRLLRec | LLM4Rec | Already run |
| 9 | Mean-Rank (no CP) | Aggregation | Average rank across permutations, top-k |
| 10 | Entropy-based CP | UQ | Use LLM logit entropy as nonconformity |

**Metrics:**
- Coverage@α (α=0.05, 0.10, 0.20)
- Average set size (smaller is better at same coverage)
- NDCG@10, Hit@10 (ranking quality of mean rank)
- Set efficiency = coverage / avg_set_size (higher is better)
- Conditional coverage gap = |actual_coverage - target| per quartile

**Seeds:** 20 random calibration/test splits

**Compute:** ~20 hours total (10 passes × full test × 20 seeds)

---

### B4: Mechanism Analysis — Why does it work?

**Experiments:**
1. **Stability vs user difficulty:** Correlate rank variance with user history length, item popularity, domain diversity
2. **K sensitivity:** How many permutation passes are needed? Test K=3,5,7,10,15,20
3. **Quartile granularity:** Test Q=2,4,8,16 stability groups
4. **Position bias decomposition:** Separate "meaningful uncertainty" from "arbitrary position bias" by comparing:
   - Random permutations (our method)
   - Systematic rotations (controlled position shift)
   - Reversed order only (single flip)

**Compute:** ~8 hours

---

### B5: Robustness — Does it generalize?

**Experiments:**
1. **Cross-domain:** Run on Amazon Sports, Toys, Tools (3 additional domains)
2. **Model size:** Test with Qwen3-1.5B and Qwen3-4B (if available) — does instability scale with model size?
3. **Candidate pool size:** Test with 20, 50, 101, 200 candidates
4. **Calibration set size:** How many calibration users are needed for stable thresholds?

**Compute:** ~15 hours

---

### B6: Practical Value — Downstream Decision Support

**Experiments:**
1. **Explore/exploit:** Use set size as exploration signal — large set → explore (show diverse items), small set → exploit (show top-1)
2. **User feedback simulation:** When set is large, simulate asking user for preference → measure improvement
3. **Computational cost analysis:** Compare cost of K passes vs single pass + other UQ methods

**Compute:** ~5 hours

---

## Milestones & Decision Gates (revised per Codex review)

```
M0 (setup)     → M1 (phenomenon?) → M2 (pipeline works) → M3 (beats baselines) → M4 (mechanism) → M5 (robustness)
   1 day            3 days              3 days                7 days                 3 days            4 days
```

**Total timeline: ~3 weeks**

| Gate | Condition | Action if FAIL |
|------|-----------|----------------|
| M1 | Spearman ρ > 0.2 between instability and error, AND error rate increases monotonically across quartiles, AND effect holds after controlling for user history length + item popularity | STOP or pivot to logit entropy |
| M2 | Marginal coverage within ±2% of target, AND no quartile below 87% for nominal 90% | Debug calibration, check exchangeability |
| M3 | RSC avg set size ≥5% smaller than marginal CP at valid coverage, AND NDCG@10 not degraded | Method doesn't add value → analysis paper |
| M5 | Valid coverage + efficiency gain on ≥2/3 domains | Scope claims to specific domains |

---

## Scope Reduction (per Codex feedback)

- **Domains:** Beauty (primary) + Sports + Tools (2 robustness, not 4)
- **Seeds:** 10 seeds with bootstrap CIs over users (not 20)
- **Baselines:** 8 core (drop 2 weakest if implementation quality uncertain)
- **B6:** Lightweight cost analysis only, not full downstream simulation
- **Model size:** Only if core results are strong (optional stretch)

---

## Critical Controls (per Codex feedback, mandatory)

B1 must include:
1. Random-order control (is instability just from arbitrary ordering?)
2. Reverse-order and cyclic-shift analysis
3. Partial correlation controlling for user history length, item popularity, candidate-pool difficulty
4. Decile plots: instability decile vs empirical error rate with CIs
5. Null baseline: compare LLM instability to random-ranker instability

---

## Codex Review Scores

| Dimension | Score |
|-----------|-------|
| Evidence quality | 7/10 |
| Rigor | 6/10 |
| Decision gates | 5/10 → revised above |
| Feasibility | 5/10 → scope reduced |
| Paper potential | 7/10 |

**Verdict:** PROCEED with revisions (gates tightened, scope reduced, controls added).

---

## Compute Budget (revised)

| Block | GPU-hours | Wall-clock (RTX 4090) |
|-------|-----------|----------------------|
| B1 | 1 | 1 hour (200 users × 10 passes + controls) |
| B2 | 2 | 2 hours |
| B3 | 12 | 12 hours (10 seeds, 8 baselines) |
| B4 | 6 | 6 hours |
| B5 | 10 | 10 hours (2 extra domains) |
| B6 | 2 | 2 hours (cost analysis only) |
| **Total** | **~33** | **~33 hours** |

Buffer (30%): **~43 GPU-hours total**

---

## Output Artifacts

- `refine-logs/EXPERIMENT_PLAN.md` (this document, copied to server)
- `refine-logs/EXPERIMENT_TRACKER.md` (progress tracking)
- `experiments/configs/` (per-block YAML configs)
- `experiments/scripts/run_permutation_probe.py` (core method)
- `experiments/scripts/conformal_calibrate.py` (CP pipeline)
- `experiments/scripts/evaluate_sets.py` (metrics)
- `experiments/results/` (all outputs, gitignored)

---

## Next ARIS Step

✅ research-refine (completed, Codex scored Novelty 7)
✅ experiment-plan (this document, Codex scored Paper 7, gates revised)
→ **experiment-bridge** (implement code on server)
   - Implement `run_permutation_probe.py`
   - Implement `conformal_calibrate.py`
   - Implement `evaluate_sets.py`
   - Run M0 sanity check
   - Then M1 phenomenon validation (the critical gate)

**Paper framing (per Codex suggestion):**
> "Permutation-induced ranking instability is a reliable, model-access-light uncertainty signal for LLM rerankers, and stability-stratified conformal prediction improves set efficiency while preserving coverage."
