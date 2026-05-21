---
name: auto-review-loop
description: Multi-agent paper review loop simulating top-venue peer review. Iterates until the paper passes quality gates. Use when user says "auto-review", "自动审稿", "review loop", "review the paper", or after paper-write produces a draft.
---

# Auto Review Loop

Simulate a hostile peer review. Iterate until the paper would survive top-venue reviewers.

## Decision Gate

Before running:
- [ ] Paper draft exists (`paper/main.tex` compiles)
- [ ] `paper/CLAIM_MAP.md` exists
- [ ] Experiment audit passed

## Phase 1 — Structured Review (Codex as Reviewer 1)

Invoke Codex (via hub_invoke_gpt55 or hub_send_message) with the paper and this rubric:

### Review Rubric (score 1-10 each)

| Dimension | Question |
|-----------|----------|
| Novelty | Is this a genuine new insight, or incremental/stitching? |
| Clarity | Can a PhD student in the field understand the method in one read? |
| Soundness | Are claims supported by evidence? Any logical gaps? |
| Significance | Would this change how people think about the problem? |
| Reproducibility | Could someone reimplement from the paper alone? |
| Completeness | Are baselines comprehensive? Ablations sufficient? |
| Presentation | Figures clear? Tables readable? Writing concise? |

### Required Output

```markdown
## Review Summary
Overall: Accept / Weak Accept / Borderline / Weak Reject / Reject

## Strengths (3-5 bullets)
## Weaknesses (3-5 bullets, ranked by severity)
## Questions for Authors
## Minor Issues (typos, formatting, unclear sentences)

## Scores
Novelty: X/10
Clarity: X/10
...
```

## Phase 2 — Kill Argument (Codex as Adversary)

Ask Codex to write the strongest possible rejection argument:
- "Why should this paper be rejected?"
- "What's the fatal flaw?"
- "What experiment would disprove the main claim?"

If the kill argument is valid and unanswerable → the paper needs fundamental revision.

## Phase 3 — Sonnet Quick Scan (Reviewer 2)

Invoke Sonnet (via hub_invoke_sonnet) for a fast second opinion:
- Focus on: clarity, missing references, presentation issues
- Sonnet is cost-effective for surface-level review

## Phase 4 — Author Response & Revision

For each weakness identified:
1. **Classify**: Fatal (blocks acceptance) / Major (needs fix) / Minor (nice to have)
2. **Plan fix**: What specific change addresses this?
3. **Execute fix**: Make the change in the paper
4. **Verify**: Does the fix actually resolve the concern?

## Phase 5 — Re-Review (if needed)

If any score was <7 or any fatal weakness was found:
1. Make revisions
2. Re-run Phase 1-3
3. Repeat until all scores ≥7 and no fatal weaknesses

Maximum 3 iterations. If still failing after 3, escalate to user for strategic decision.

## Handoff

- Output: `paper/REVIEW_LOG.md` (all reviews + responses)
- Output: Updated paper with revisions
- If PASS (all scores ≥7): Next ARIS step → **citation-audit** → **paper-claim-audit**
- If FAIL after 3 iterations: Escalate to user

## Hard Rules

- Review must be done by different agent than the one who wrote the paper
- Kill argument must be attempted honestly — don't softball
- Never skip the kill argument phase
- All review scores and responses must be logged
- Minimum 2 reviewers (Codex + Sonnet)
