---
name: citation-audit
description: Systematic audit of all citations in a paper draft. Checks completeness, recency, fairness, and correct attribution. Use when user says "citation-audit", "引用审核", "check citations", "audit references", or as part of the pre-submission checklist after auto-review-loop passes.
---

# Citation Audit

Ensure the paper's citations are complete, fair, and correct. Missing a key citation is an easy reject signal.

## Decision Gate

Before running:
- [ ] Paper draft exists with a `references.bib`
- [ ] Related work section is written
- [ ] Auto-review-loop has passed (or running in parallel)

## Phase 1 — Completeness Check

For each major claim or method component:
1. **List the claim** and its supporting citations
2. **Search for missing citations**: Are there seminal papers in this area not cited?
3. **Check recency**: Are there 2025-2026 papers that should be cited? (Reviewers notice stale bibliographies)
4. **Check breadth**: Are all relevant sub-communities represented?

Minimum citation count for top venue: 30-50 references.

## Phase 2 — Fairness Check

1. **Closest competitors**: Are they cited AND discussed fairly?
2. **Acknowledged strengths**: Do you mention what prior work does well before noting gaps?
3. **No strawmanning**: Are baseline descriptions accurate to the original papers?
4. **Self-citation balance**: Not too many (looks narcissistic), not too few (looks disconnected)

Red flags:
- Closest competitor not cited → reviewer will notice
- Mischaracterizing prior work → ethical issue
- Only citing old papers → looks out of touch

## Phase 3 — Technical Verification

For each citation:
1. **Correct paper?** (Title, authors, year match the claim)
2. **Correct claim attribution?** (Does the cited paper actually say what you claim it says?)
3. **BibTeX quality**: Consistent format, no broken entries, venue names correct
4. **No predatory venues**: All cited venues are reputable

## Phase 4 — Gap Analysis

Identify citation gaps by category:

| Category | Expected | Found | Gap |
|----------|----------|-------|-----|
| Problem definition papers | 3-5 | ? | ? |
| Method papers (our approach family) | 5-8 | ? | ? |
| Baseline papers | 8+ | ? | ? |
| Evaluation methodology | 2-3 | ? | ? |
| Application domain | 3-5 | ? | ? |
| Theory/foundations | 2-4 | ? | ? |

## Phase 5 — Audit Report

```markdown
# Citation Audit Report
Date: YYYY-MM-DD

## Verdict: PASS / NEEDS ADDITIONS

## Missing Citations (must add)
1. [Paper] — Reason it must be cited

## Recommended Citations (should add)
1. [Paper] — Would strengthen the paper

## Fairness Issues
1. ...

## BibTeX Errors
1. ...
```

## Handoff

- Output: `paper/CITATION_AUDIT.md`
- Output: Updated `references.bib` with additions
- Next ARIS step: **paper-claim-audit**
- If issues found: fix and re-audit

## Hard Rules

- Closest 3 competitors MUST be cited and discussed
- No mischaracterization of prior work
- Minimum 30 citations for top venue
- All citations must be verified (paper actually says what you claim)
- Recency: at least 5 citations from the last 2 years
