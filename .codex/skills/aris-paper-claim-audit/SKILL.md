---
name: aris-paper-claim-audit
description: |
  Codex's FINAL gate role. Extract every claim, verify evidence backing,
  detect overclaims, check consistency. This is the last check before
  submission — nothing passes without a READY verdict from this audit.
triggers:
  - "paper-claim-audit"
  - "final audit"
  - "论文声明审核"
  - "pre-submission"
  - "claim verification"
  - "overclaim check"
role: auditor
agent: codex
---

# ARIS Paper Claim Audit: Final Submission Gate

## Role

You are the FINAL GATEKEEPER. This audit runs LAST, after all revisions.
If a paper passes this audit with READY status, it is cleared for submission.
If not, it goes back for revision — no exceptions.

Your mandate: **No overclaim survives. No unsupported claim ships.**

## Phase 1: Claim Extraction

### Process

1. Read the abstract — extract every factual claim
2. Read the introduction — extract every contribution claim
3. Read the conclusion — extract every summary claim
4. Read section headers and topic sentences — extract method claims
5. Compile into the master claim table

### Claim Categories

| Category | Definition | Example |
|----------|-----------|---------|
| **Performance** | Quantitative improvement claims | "achieves 15% better accuracy" |
| **Novelty** | First/new/original claims | "first method to combine X and Y" |
| **Generality** | Scope/applicability claims | "works across all circuit topologies" |
| **Efficiency** | Speed/resource claims | "10x faster than baseline" |
| **Theoretical** | Proof/guarantee claims | "provably converges in O(n)" |
| **Qualitative** | Subjective quality claims | "significantly improves" |

### Master Claim Table

| # | Claim (verbatim quote) | Location | Category | Evidence Location | Status |
|---|----------------------|----------|----------|-------------------|--------|
| 1 | | §X, line Y | | §Z, Table/Fig N | Supported/Weak/Unsupported |

## Phase 2: Evidence Verification

For EACH claim in the master table, verify:

### Verification Criteria

| Evidence Type | Sufficient For | Insufficient For |
|---------------|---------------|-----------------|
| Single experiment | Specific narrow claim | General claims |
| Multiple experiments | Method works in tested cases | "Always" / "all" claims |
| Ablation study | Component contribution | Overall superiority |
| Statistical test | Significance claims | Practical importance |
| Proof/theorem | Theoretical guarantees | Empirical performance |
| Qualitative example | Illustration | Performance claims |

### Verification Output

For each claim, assign one status:

- **SUPPORTED**: Clear, direct evidence exists. Claim matches evidence scope.
- **WEAKLY SUPPORTED**: Evidence exists but doesn't fully cover the claim's scope.
- **UNSUPPORTED**: No evidence found for this claim.
- **OVERCLAIMED**: Evidence exists but claim overstates what evidence shows.
- **CONTRADICTED**: Evidence actually contradicts the claim.

## Phase 3: Overclaim Detection

### Automatic Red-Flag Words

Scan for these words/phrases and verify each has backing:

| Red-Flag Term | Requires | Found? | Backed? |
|---------------|----------|--------|---------|
| "significantly" | Statistical test (p-value) or large margin | | |
| "state-of-the-art" / "SOTA" | Comparison to ALL recent methods | | |
| "first" / "novel" / "pioneering" | Literature search confirming no prior work | | |
| "outperforms all" | Comparison to ALL relevant baselines | | |
| "robust" | Testing under perturbation/noise/edge cases | | |
| "generalizes" | Testing on unseen domains/distributions | | |
| "optimal" | Proof of optimality or exhaustive search | | |
| "scalable" | Testing at multiple scales with timing | | |
| "efficient" | Comparison of computational cost | | |
| "superior" | Head-to-head comparison with statistical rigor | | |

### Overclaim Severity

- **Critical**: Claim is central to contribution and unsupported (submission blocker)
- **Major**: Claim is prominent but overclaimed (must fix before submission)
- **Minor**: Peripheral claim slightly overstated (fix if time permits)

## Phase 4: Consistency Check

### Cross-Section Consistency

Verify these match across the paper:

| Check | Sections Compared | Consistent? |
|-------|-------------------|-------------|
| Numbers match | Abstract vs. Tables | |
| Numbers match | Introduction claims vs. Experiments | |
| Numbers match | Conclusion vs. Tables | |
| Method described consistently | Method section vs. Experiments | |
| Contributions list | Introduction vs. Conclusion | |
| Baseline names | Related Work vs. Experiments | |
| Dataset details | Method vs. Experiments | |
| Notation | Throughout paper | |

### Common Inconsistencies

- [ ] Abstract says "15% improvement" but table shows 14.7%
- [ ] Introduction lists 3 contributions, conclusion mentions 4
- [ ] Method describes step X but experiments skip it
- [ ] Different notation for same variable in different sections
- [ ] Baseline called "Method-A" in one place and "MethodA" elsewhere

## Phase 5: Final Verdict

### Verdict Decision Matrix

| Condition | Verdict |
|-----------|---------|
| 0 critical overclaims, 0 unsupported claims, 0 contradictions | **READY** |
| 0 critical, 1-2 major overclaims, all fixable with word changes | **READY WITH EDITS** |
| 1+ critical overclaim OR 3+ major overclaims | **NEEDS REVISION** |
| Any contradicted claim | **NEEDS REVISION** |
| Systematic inconsistency across sections | **NEEDS REVISION** |

### Verdict Template

```
CLAIM AUDIT VERDICT: [READY / READY WITH EDITS / NEEDS REVISION]

Summary Statistics:
- Total claims extracted: N
- Supported: N
- Weakly supported: N
- Unsupported: N
- Overclaimed: N
- Contradicted: N

Critical Issues (submission blockers):
1. [Issue — exact location — required fix]

Major Issues (must fix):
1. [Issue — exact location — suggested fix]

Minor Issues (fix if time permits):
1. [Issue — exact location]

Consistency Errors:
1. [Mismatch — locations]

FINAL DECISION: [CLEARED FOR SUBMISSION / RETURN FOR REVISION]
```

## Execution Protocol

1. This audit runs AFTER aris-auto-review-loop issues have been addressed
2. This is a PASS/FAIL gate — there is no "close enough"
3. If verdict is NEEDS REVISION, specify exactly what must change
4. Do NOT suggest new experiments — only flag what's claimed vs. shown
5. Be literal: if the paper says "all", it must mean ALL
6. Re-run this audit after revisions until READY is achieved

## Interaction with Other Skills

- Runs AFTER: aris-paper-write (structural), aris-auto-review-loop (full review)
- Runs BEFORE: final submission
- Complements: aris-citation-audit (which checks references, not claims)
- This is the LAST gate. If this passes, the paper ships.
