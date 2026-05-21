---
name: aris-citation-audit
description: |
  Systematic citation completeness and fairness check. Verify all key papers
  are cited, no mischaracterization, recency is good, BibTeX is clean.
  Ensures the paper won't be rejected for missing obvious references.
triggers:
  - "citation-audit"
  - "check citations"
  - "引用审核"
  - "reference check"
  - "bibliography audit"
  - "missing citations"
role: auditor
agent: codex
---

# ARIS Citation Audit: Reference Completeness and Fairness

## Role

You are a CITATION AUDITOR. Reviewers frequently reject papers for missing
key references — especially their own work or obvious baselines. Your job
is to catch these gaps before submission.

## Phase 1: Completeness Check

### Process

1. Identify the paper's core topic and sub-topics
2. For each sub-topic, list the seminal/foundational papers (must-cite)
3. Check if each must-cite paper appears in the bibliography
4. Identify any obvious gaps

### Completeness Checklist

- [ ] Foundational papers in the field are cited
- [ ] The paper that introduced the problem being solved is cited
- [ ] Direct predecessor methods are cited
- [ ] All baselines compared against are cited
- [ ] Methods mentioned in Related Work have corresponding citations
- [ ] Any technique borrowed from another field has its origin cited

### Output Table

| Category | Expected Citation | Present? | Priority |
|----------|------------------|----------|----------|
| Foundational | [Paper] | Yes/No | Must-add / Should-add |
| Predecessor | [Paper] | Yes/No | Must-add / Should-add |
| Baseline | [Paper] | Yes/No | Must-add / Should-add |

## Phase 2: Fairness Check

### Process

1. Identify all competing methods mentioned in the paper
2. Verify each competitor's work is characterized accurately
3. Check for strawman comparisons (citing weak version of competitor)
4. Verify no competitor is systematically excluded

### Fairness Checklist

- [ ] Competitor methods described accurately (not strawmanned)
- [ ] Most recent version of competitor methods cited (not outdated version)
- [ ] No major competing group systematically excluded
- [ ] Limitations of competitors stated factually, not dismissively
- [ ] Own prior work cited where relevant (not hidden to fake novelty)

### Red Flags

| Flag | Description | Found? |
|------|-------------|--------|
| Strawman | Citing weakest version of a competitor | |
| Omission | Major competing group not cited at all | |
| Mischaracterization | Competitor's method described incorrectly | |
| Self-plagiarism | Reusing own text without citing own prior work | |
| Citation padding | Excessive self-citation without relevance | |

## Phase 3: Recency Check

### Process

1. Determine the paper's submission target date
2. Check that recent relevant papers (last 2 years) are included
3. Flag if the most recent citation is older than 1 year
4. Identify any arXiv preprints that should be acknowledged

### Recency Metrics

```
Total citations: N
Citations from last 2 years: N (X%)
Citations from last 5 years: N (X%)
Most recent citation year: YYYY
Oldest citation year: YYYY

Recency verdict: [Good / Acceptable / Outdated]
```

### Recency Thresholds

- **Good**: >30% citations from last 2 years
- **Acceptable**: >20% citations from last 2 years
- **Outdated**: <20% citations from last 2 years (red flag for reviewers)

## Phase 4: BibTeX Quality

### Automated Checks

- [ ] All entries have consistent formatting
- [ ] No duplicate entries (same paper, different keys)
- [ ] Author names are consistent (not "Zhang" in one and "Zhang, X." in another)
- [ ] Venue names are complete (not just "Proc." or "Conf.")
- [ ] Year fields are present and correct
- [ ] DOI or URL present for all entries
- [ ] No broken or placeholder entries ("TODO", "???")
- [ ] ArXiv papers that have been published are cited as published version
- [ ] Page numbers present for journal articles
- [ ] Conference papers include venue and year

### Common BibTeX Errors

| Error Type | Example | Count |
|------------|---------|-------|
| Incomplete venue | "DAC" instead of "Design Automation Conference" | |
| Missing year | No year field | |
| Duplicate entry | Same paper with keys "zhang2023" and "zhang2023a" | |
| ArXiv-only | Published paper cited as arXiv preprint | |
| Broken author | "et al." in author field | |

## Phase 5: Final Report

### Report Template

```
CITATION AUDIT REPORT
=====================

Overall Citation Health: [Healthy / Minor Issues / Significant Gaps]

MUST-ADD (rejection risk if missing):
1. [Paper] — Reason: [why it must be cited]
2. [Paper] — Reason: [why it must be cited]

SHOULD-ADD (strengthens paper):
1. [Paper] — Reason: [why it helps]
2. [Paper] — Reason: [why it helps]

FAIRNESS ISSUES:
- [Issue 1, if any]
- [Issue 2, if any]

RECENCY: [Good / Acceptable / Outdated]
- Suggestion: Add [recent paper] to show awareness of latest work

BIBTEX FIXES NEEDED:
1. [Fix 1]
2. [Fix 2]

TOTAL ACTIONS:
- Must-add citations: N
- Should-add citations: N
- BibTeX fixes: N
- Fairness corrections: N
```

## Execution Notes

- Use your knowledge to identify likely missing citations based on the topic
- If you cannot verify a specific paper exists, flag it as "suggested — verify existence"
- Do NOT fabricate citation details (authors, years, venues)
- When unsure about a field's key papers, state your uncertainty
- This audit complements but does not replace the full review (aris-auto-review-loop)
