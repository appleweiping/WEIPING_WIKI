---
name: experiment-audit
description: Rigorous audit of experiment results before they become paper claims. Checks statistical validity, reproducibility, fair comparison, and evidence quality. Use when user says "experiment-audit", "审核实验", "audit results", "check my results", or after run-experiment produces results that need validation.
---

# Experiment Audit

Audit experiment results with the rigor of a hostile reviewer. Your job is to find problems BEFORE submission.

## Decision Gate

Before running:
- [ ] Results exist in `results/` or `refine-logs/EXPERIMENT_TRACKER.md` shows completed blocks
- [ ] At least one block has full seed runs (20+ seeds for paper claims)
- [ ] You have access to the experiment configs and code

## Phase 1 — Statistical Validity

For each reported result:

1. **Sample size check**: Are there 20+ seeds? (Required for paper evidence)
2. **Significance test**: Run paired t-test or Wilcoxon signed-rank between our method and each baseline
3. **Effect size**: Report Cohen's d or similar — is the improvement meaningful, not just significant?
4. **Confidence intervals**: Report 95% CI for all primary metrics
5. **Multiple comparison correction**: If testing against 8+ baselines, apply Bonferroni or Holm-Bonferroni

Verdict per comparison: PASS (p<0.05, meaningful effect) / MARGINAL (p<0.1) / FAIL (not significant)

## Phase 2 — Reproducibility Check

1. **Config audit**: Can you reproduce the exact run from config alone?
2. **Seed sensitivity**: Is variance across seeds reasonable? (CV < 20% for stable metrics)
3. **Hardware sensitivity**: Would different GPU/batch size change results?
4. **Code-result alignment**: Does the code actually implement what the paper claims?

Red flags:
- Results only work with specific seeds → cherry-picking
- Variance is huge → unstable method
- Config doesn't match paper description → misrepresentation

## Phase 3 — Fair Comparison

For each baseline:
1. **Same data splits?** (Must be identical)
2. **Same preprocessing?** (Must be identical)
3. **Same compute budget?** (Comparable training time/FLOPs)
4. **Best hyperparameters?** (Did you tune baselines fairly, or use defaults while tuning yours?)
5. **Official numbers match?** (If using official implementation, do you reproduce their reported numbers?)

Red flags:
- Our method gets 10x more compute → unfair
- Baselines use default hyperparams while ours is tuned → unfair
- Different data splits → incomparable

## Phase 4 — Evidence Classification

Label every result:

| Label | Meaning | Can use in paper? |
|-------|---------|-------------------|
| `paper_result` | Full seeds, statistically valid, fair comparison | YES |
| `official` | Full seeds but needs one more check | Almost |
| `diagnostic` | Partial seeds or preliminary | NO (supplementary only) |
| `pilot` | Quick test, not rigorous | NO |

Only `paper_result` labeled evidence goes into the main paper.

## Phase 5 — Audit Report

Produce a structured audit report:

```markdown
# Experiment Audit Report
Date: YYYY-MM-DD
Auditor: Codex (GPT-5.5)

## Summary Verdict: PASS / CONDITIONAL PASS / FAIL

## Per-Block Results
| Block | Seeds | Significance | Effect Size | Fair? | Evidence Label |
|-------|-------|-------------|-------------|-------|----------------|

## Issues Found
1. [CRITICAL/MAJOR/MINOR] Description...

## Recommendations
1. ...
```

## Handoff

- Output: `refine-logs/AUDIT_REPORT.md`
- Update `refine-logs/EXPERIMENT_TRACKER.md` with audit status
- If PASS → Next ARIS step: **paper-plan**
- If CONDITIONAL PASS → Fix issues, re-audit
- If FAIL → Back to experiment-bridge or pivot

## Hard Rules

- Never approve results with <20 seeds as paper evidence
- Never approve unfair comparisons (compute, tuning, data asymmetry)
- Always run significance tests — "looks better" is not evidence
- Audit must be done by a different agent than the one who ran experiments (cross-model review)
- Be adversarial — your job is to find problems, not confirm success
