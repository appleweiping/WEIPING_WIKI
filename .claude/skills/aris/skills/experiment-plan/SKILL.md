---
name: experiment-plan
description: Rigorous experiment planning that produces a complete, auditable experiment plan with blocks, baselines, milestones, decision gates, and compute estimates. Use when user says "experiment-plan", "实验计划", "plan experiments", "design experiments", or after research-refine is complete and the research question is crystallized.
---

# Experiment Plan

Design a complete experiment plan that a reviewer would call "thorough." No hand-waving, no "we'll figure it out later."

## Decision Gate

Before running:
- [ ] Research question is crystallized (`refine-logs/RESEARCH_QUESTION.md` exists)
- [ ] Baselines are identified (≥8 per quality standards)
- [ ] Compute resources are known (GPU type, hours available)
- [ ] Datasets are accessible

## Phase 1 — Experiment Block Design

Design 5-7 experiment blocks, each answering one sub-question:

1. **B1: Phenomenon validation** — Does the claimed phenomenon exist? (Sanity check)
2. **B2: Ablation / isolation** — Is our method responsible, not confounders?
3. **B3: Method comparison** — Head-to-head vs all baselines on primary metrics
4. **B4: Mechanism analysis** — Why does it work? (Interpretability, probing)
5. **B5: Robustness** — Does it hold across domains/scales/perturbations?
6. **B6: Downstream impact** — Does improvement on proxy metric translate to real value?
7. **B7: Extended / realistic** — Real-world simulation or deployment scenario

For each block:
- Hypothesis (falsifiable)
- Metrics (primary + secondary)
- Expected outcome range
- Failure mode (what would disprove the hypothesis)

Output: `refine-logs/EXPERIMENT_PLAN.md` (blocks section)

## Phase 2 — Baseline Specification

For each of the 8+ baselines:

| Baseline | Paper | Year | Implementation | Status |
|----------|-------|------|----------------|--------|
| ... | ... | ... | official/reimpl/ours | available/needed |

- Verify implementation availability (GitHub links, paper repos)
- Note any baselines that need reimplementation (flag as risk)
- Ensure fair comparison: same data splits, same preprocessing, same compute budget

## Phase 3 — Milestone & Decision Gate Design

Define sequential milestones with kill conditions:

```
M0 (sanity)     → M1 (phenomenon?) → M2 (full panel) → M3 (comparison) → M4 (mechanism) → M5 (robustness) → M6 (extended)
```

Decision gates:
- **M1 gate**: If phenomenon effect size < threshold → STOP or pivot
- **M3 gate**: If our method not statistically significant vs best baseline → fall back to analysis paper
- **M5 gate**: If robustness fails on >50% of perturbations → scope down claims

Each gate has: metric, threshold, action-if-fail.

## Phase 4 — Compute & Timeline

1. **Per-block compute estimate** (GPU-hours)
2. **Total compute** with 20% buffer
3. **Parallelization plan** (which blocks can run concurrently)
4. **Timeline** (weeks, with dependencies)
5. **Seed strategy**: 20+ seeds for final results, 3-5 for diagnostics

## Phase 5 — Tracker Setup

Create `refine-logs/EXPERIMENT_TRACKER.md`:

| Block | Milestone | Status | Seeds | Result | Notes |
|-------|-----------|--------|-------|--------|-------|
| B1 | M0 | pending | - | - | - |

## Phase 6 — Cross-Model Review

Submit plan to Codex (GPT-5.5) for audit:
- Send an explicit context pack through agentmemory signals/actions, or hand the same context to the current Codex session
- Codex scores: Evidence (1-10), Rigor (1-10), Gates (1-10), Feasibility (1-10), Paper-potential (1-10)
- If any score <6, iterate on that dimension

## Handoff

- Output: `refine-logs/EXPERIMENT_PLAN.md`, `refine-logs/EXPERIMENT_TRACKER.md`
- Update `memory/facts/<project>-status.md`
- Next ARIS step: **experiment-bridge**
- Handoff to: OpenCode (executor) for implementation

## Hard Rules

- Minimum 8 baselines (no exceptions)
- Statistical significance requires 20+ seeds for paper results
- Every block must have a falsifiable hypothesis
- Decision gates must have concrete thresholds, not "we'll see"
- Evidence labels: plan outputs are "diagnostic" until experiments run
- No mock/pilot results as paper evidence
