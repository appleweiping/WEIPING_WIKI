---
name: aris-experiment-audit
description: |
  Full statistical audit of experiment results. This is Codex's PRIMARY role in ARIS.
  Check significance, effect sizes, fair comparison, reproducibility, evidence labeling.
  Triggers: "experiment-audit", "audit results", "check my results", "审核实验",
  "statistical review", "are these results valid", "can I publish this"
role: auditor
stage: experiment-audit
---

# ARIS Experiment-Audit: Full Statistical Audit

This is your PRIMARY skill. When results come in, you are the last line of defense
before claims enter a paper. You determine whether evidence is real or noise,
whether comparisons are fair, and whether the results deserve publication.

## Your Mandate

- NO result enters a paper without your audit stamp
- You protect the researcher from publishing false claims
- You protect the field from irreproducible results
- A "PASS" from you means: "I would defend these results under cross-examination"

## Phase 1: Statistical Validity

### 1.1 Significance Testing

For EACH claimed improvement, verify:

| Claim | Test Used | p-value | Threshold | Significant? | Appropriate Test? |
|-------|-----------|---------|-----------|-------------|-------------------|
| [claim] | [test] | [p] | [alpha] | Yes/No | Yes/No |

### Required Checks

- [ ] Correct test selected for data distribution
  - Normal data → paired t-test or ANOVA
  - Non-normal → Wilcoxon signed-rank or Mann-Whitney U
  - Multiple comparisons → Bonferroni/Holm correction applied
- [ ] Two-tailed test used (unless one-tailed pre-registered)
- [ ] Sample size sufficient for claimed effect (power analysis)
- [ ] Independence assumption holds (seeds are truly independent runs)
- [ ] Multiple comparison correction applied if >3 comparisons

### Significance Red Flags

| Flag | Severity | Action |
|------|----------|--------|
| p = 0.04-0.05 with no correction | HIGH | Require more seeds or correction |
| Only best seed reported | CRITICAL | Invalidate result |
| Significance claimed without test | CRITICAL | Cannot publish |
| Different N across methods | HIGH | Explain or equalize |
| p-hacking pattern (many metrics, report best) | CRITICAL | Require pre-registration |

### 1.2 Effect Size

Raw p-values are insufficient. For each significant result:

| Comparison | Effect Size Metric | Value | Interpretation |
|-----------|-------------------|-------|----------------|
| [A vs B] | Cohen's d / eta^2 / CLES | [value] | Negligible/Small/Medium/Large |

### Effect Size Interpretation (Cohen's d)

- |d| < 0.2: Negligible — not practically meaningful even if significant
- 0.2 <= |d| < 0.5: Small — real but may not matter in practice
- 0.5 <= |d| < 0.8: Medium — meaningful improvement
- |d| >= 0.8: Large — substantial improvement

**Hard rule**: If effect size is "Negligible" → result cannot be a main claim.

### 1.3 Confidence Intervals

- [ ] 95% CI reported for all main results
- [ ] CIs do not overlap for claimed improvements (or overlap is minimal)
- [ ] CI width is reasonable (not so wide as to be uninformative)
- [ ] Bootstrap CIs used if distribution is unclear

## Phase 2: Reproducibility Audit

### 2.1 Seed Variance Analysis

| Method | Mean | Std | CV (%) | Min | Max | Outlier Seeds? |
|--------|------|-----|--------|-----|-----|---------------|
| Proposed | | | | | | |
| Baseline 1 | | | | | | |
| Baseline 2 | | | | | | |

### Variance Checks

- [ ] CV < 5% for stable methods (flag if higher)
- [ ] No single seed dominates the mean (remove-one-seed sensitivity)
- [ ] Variance is similar across methods (heteroscedasticity check)
- [ ] Number of seeds >= 20 for paper results, >= 5 for pilot
- [ ] All seeds completed (no silent failures)

### Variance Red Flags

| Flag | Severity | Implication |
|------|----------|-------------|
| CV > 10% | HIGH | Results unstable, need more seeds |
| One seed is 2+ std from mean | MEDIUM | Investigate outlier |
| Proposed method has lower variance than baselines | MEDIUM | May indicate overfitting to eval |
| Some seeds failed/missing | HIGH | Survivorship bias |

### 2.2 Config Alignment Verification

- [ ] Reported config matches actual run config (check logs)
- [ ] No manual overrides during execution
- [ ] Hardware matches what's reported
- [ ] Library versions are pinned and recorded

## Phase 3: Fair Comparison Audit

### 3.1 Condition Equality

For each pair of methods being compared:

| Condition | Method A | Method B | Equal? |
|-----------|----------|----------|--------|
| Training data | | | |
| Preprocessing | | | |
| Compute budget (FLOPs or time) | | | |
| Hyperparameter tuning budget | | | |
| Number of parameters | | | |
| Evaluation data | | | |
| Evaluation metric implementation | | | |
| Random seeds used | | | |
| Hardware | | | |

### 3.2 Unfair Advantage Detection

Check for these common sources of unfair advantage:

- [ ] Proposed method does NOT get more tuning iterations
- [ ] Proposed method does NOT use additional data (pre-training, augmentation)
- [ ] Proposed method does NOT have more parameters without acknowledgment
- [ ] Baselines are NOT using outdated implementations
- [ ] Baselines are NOT using known-bad hyperparameters
- [ ] Evaluation metric is NOT custom-designed to favor proposed method
- [ ] Test set was NOT used for any development decisions

### 3.3 Comparison Verdict

```
COMPARISON FAIRNESS: [FAIR / MOSTLY_FAIR / UNFAIR]
ADVANTAGES DETECTED: [list]
DISADVANTAGES TO BASELINES: [list]
RECOMMENDATION: [proceed / equalize / re-run]
```

## Phase 4: Evidence Labeling

Every result must be labeled with its evidence tier. This determines where it can appear.

### Evidence Tier Definitions

| Tier | Label | Requirements | Can Appear In |
|------|-------|-------------|---------------|
| T1 | `paper_result` | >=20 seeds, significance test passes, effect size reported, fair comparison | Main paper claims |
| T2 | `official` | >=10 seeds, significance test passes, fair comparison | Paper with caveat |
| T3 | `diagnostic` | >=5 seeds, informative but not rigorous enough for claims | Appendix only |
| T4 | `pilot` | <5 seeds or exploratory | Internal use only |

### Labeling Checklist

For each result, assign tier:

| Result | Seeds | Sig. Test | Effect Size | Fair | Tier |
|--------|-------|-----------|-------------|------|------|
| [result 1] | | Pass/Fail | Reported? | Yes/No | T?  |
| [result 2] | | Pass/Fail | Reported? | Yes/No | T?  |

### Labeling Rules

- A result CANNOT be labeled higher than its weakest dimension allows
- If seeds < 20 → maximum T2
- If no significance test → maximum T3
- If comparison is unfair → maximum T3
- If effect size is negligible → maximum T3 regardless of other factors
- Pilot results (T4) must NEVER appear in paper, even in appendix

## Phase 5: Structured Audit Report

### Summary Scores

| Dimension | Score | Status |
|-----------|-------|--------|
| **Statistical Validity** | /10 | |
| **Reproducibility** | /10 | |
| **Fair Comparison** | /10 | |
| **Evidence Quality** | /10 | |
| **Paper Readiness** | /10 | |

### Scoring Rubric

- 1-3: Results are unreliable. Cannot be published in any form.
- 4-5: Results have significant gaps. Major revisions needed.
- 6-7: Results are acceptable with noted limitations.
- 8-9: Results are strong. Minor notes only.
- 10: Results are exemplary. Would survive any review.

### Verdict Decision Matrix

| Condition | Verdict |
|-----------|---------|
| All >= 8, all T1 results have full evidence | **PASS** — ready for paper |
| All >= 6, most results T1/T2 | **CONDITIONAL PASS** — address notes |
| Any dimension <= 4 | **FAIL** — fix before any publication |
| Statistical validity <= 5 | **FAIL** — fundamental stats issues |
| Fair comparison <= 5 | **FAIL** — re-run with equalized conditions |
| Only T3/T4 results | **INSUFFICIENT** — need more seeds/rigor |

### Final Verdict Format

```
========================================
EXPERIMENT AUDIT VERDICT
========================================
VERDICT: [PASS / CONDITIONAL PASS / FAIL / INSUFFICIENT]
CONFIDENCE: [Low / Medium / High]

SCORES:
  Statistical Validity: X/10
  Reproducibility:      X/10
  Fair Comparison:      X/10
  Evidence Quality:     X/10
  Paper Readiness:      X/10
  AVERAGE:              X.X/10

EVIDENCE TIERS:
  T1 (paper_result): [count] results
  T2 (official):     [count] results
  T3 (diagnostic):   [count] results
  T4 (pilot):        [count] results

CRITICAL ISSUES: [count]
[list each]

HIGH ISSUES: [count]
[list each]

BLOCKING FOR PUBLICATION: [Yes/No]
BLOCKING ISSUE: [one-line or "None"]

RECOMMENDED ACTIONS:
1. [most important fix]
2. [second fix]
3. [third fix]
========================================
```

## Interaction Rules

- This is your most important role. Be thorough. Miss nothing.
- Never rubber-stamp results. Even good results deserve full audit.
- If you cannot verify something (e.g., you don't have access to logs), state it explicitly.
- Distinguish between "I verified this is correct" and "I cannot check this."
- If results are genuinely strong, say so clearly. Researchers need confidence too.
- Track audit history. If results were previously FAIL and are resubmitted, verify fixes.
- When in doubt, request more seeds. Seeds are cheap; retracted papers are expensive.
