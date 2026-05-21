---
name: paper-claim-audit
description: Final pre-submission audit verifying every claim in the paper is backed by valid evidence. The last gate before submission. Use when user says "paper-claim-audit", "论文声明审核", "final audit", "pre-submission check", or as the final ARIS step before submission.
---

# Paper Claim Audit

The final gate. Every sentence that asserts something must have evidence. This is the difference between a paper that survives review and one that gets desk-rejected.

## Decision Gate

Before running:
- [ ] Paper is complete (all sections written)
- [ ] Auto-review-loop passed (all scores ≥7)
- [ ] Citation audit passed
- [ ] `paper/CLAIM_MAP.md` exists

## Phase 1 — Claim Extraction

Read the entire paper and extract every claim:

| # | Claim | Section | Type | Evidence | Label |
|---|-------|---------|------|----------|-------|
| 1 | "Our method outperforms X by Y%" | Results | Empirical | Table 2 | paper_result |
| 2 | "This is the first work to..." | Intro | Novelty | Literature survey | verified |
| 3 | "The complexity is O(n)" | Method | Theoretical | Proof in appendix | proven |

Claim types: Empirical, Theoretical, Novelty, Motivation, Assumption

## Phase 2 — Evidence Verification

For each claim:

### Empirical claims
- [ ] Number matches the actual result (check raw data)
- [ ] Statistical significance confirmed (p < 0.05)
- [ ] Seeds ≥ 20 for paper_result label
- [ ] Comparison is fair (same conditions)

### Novelty claims ("first to...", "novel...")
- [ ] Literature search confirms no prior work does exactly this
- [ ] Claim is scoped correctly (not overclaiming)

### Theoretical claims
- [ ] Proof is complete and correct
- [ ] Assumptions are stated explicitly
- [ ] Edge cases addressed

### Motivation claims ("X is important because...")
- [ ] Supported by citation or widely accepted fact
- [ ] Not overclaiming importance

## Phase 3 — Overclaim Detection

Common overclaims to flag:
- "significantly outperforms" without statistical test
- "state-of-the-art" without comparing ALL recent methods
- "first" without exhaustive literature search
- Generalizing from one dataset to "all" scenarios
- Causal language ("causes", "leads to") from correlational evidence

For each overclaim: suggest a hedged alternative.

## Phase 4 — Consistency Check

1. **Abstract vs Results**: Do numbers in abstract match tables?
2. **Introduction claims vs Experiments**: Does every intro claim have experimental support?
3. **Method description vs Code**: Does the paper describe what the code actually does?
4. **Figure captions vs Text**: Consistent terminology and numbers?

## Phase 5 — Final Verdict

```markdown
# Paper Claim Audit Report
Date: YYYY-MM-DD

## Verdict: READY FOR SUBMISSION / NEEDS REVISION

## Claim Summary
- Total claims: X
- Fully supported: Y
- Overclaims found: Z
- Unsupported claims: W

## Critical Issues (must fix before submission)
1. ...

## Overclaims (must hedge or remove)
1. Claim: "..." → Suggested: "..."

## Consistency Errors
1. ...
```

## Handoff

- Output: `paper/CLAIM_AUDIT.md`
- If READY: Paper can be submitted
- If NEEDS REVISION: Fix issues, re-run this audit
- Update `memory/facts/<project>-status.md` with submission readiness

## Hard Rules

- EVERY empirical claim must trace to a specific table/figure with paper_result label
- No "significantly" without a significance test
- No "state-of-the-art" without comprehensive comparison
- No "first" without documented literature search
- Numbers in abstract MUST match numbers in tables (exact, not rounded differently)
- This audit must be done by a different agent than the paper writer
