---
name: paper-write
description: Structured academic paper writing following top-venue conventions. Produces publication-ready LaTeX with proper structure, claims backed by evidence, and clear narrative. Use when user says "paper-write", "写论文", "write paper", "draft the paper", or after experiment-audit passes.
---

# Paper Write

Write a top-venue paper. Every sentence must be backed by evidence or clearly marked as motivation/intuition.

## Decision Gate

Before running:
- [ ] `refine-logs/AUDIT_REPORT.md` exists with verdict PASS or CONDITIONAL PASS
- [ ] `refine-logs/RESEARCH_QUESTION.md` exists
- [ ] `refine-logs/EXPERIMENT_PLAN.md` exists
- [ ] Results with `paper_result` evidence label are available
- [ ] Target venue is identified (page limit, format, deadline)

## Phase 1 — Paper Skeleton

Create the LaTeX structure:

```
paper/
  main.tex          # Master file
  sections/
    abstract.tex
    introduction.tex
    related-work.tex
    method.tex
    experiments.tex
    results.tex
    analysis.tex
    conclusion.tex
  figures/
  tables/
  references.bib
```

Define the narrative arc:
1. **Hook**: What's the problem? Why should anyone care?
2. **Gap**: What's missing in current approaches?
3. **Contribution**: What do we do differently? (1-3 bullet points)
4. **Evidence**: How do we prove it works?
5. **Impact**: What does this enable?

## Phase 2 — Section Drafting (in order)

### Method (write first — it's the core)
- Algorithm description with mathematical notation
- Architecture diagram (describe for figure generation)
- Complexity analysis
- Connection to theory (if applicable)

### Experiments
- Experimental setup (datasets, metrics, baselines, implementation details)
- Main results table (from audit-approved `paper_result` data)
- Ablation studies
- Analysis (why does it work / when does it fail)

### Introduction
- Motivating example or statistic
- Problem statement
- Brief description of approach
- Summary of results
- Contribution list (3 bullets max)

### Related Work
- Organize by theme, not chronologically
- Position our work clearly relative to each group
- Be fair to prior work — acknowledge strengths before noting gaps

### Abstract (write last)
- 150-250 words
- Problem → Approach → Results → Impact
- Include one concrete number (best improvement)

## Phase 3 — Evidence-Claim Alignment

For every claim in the paper:
1. **Find the supporting evidence** (table, figure, or citation)
2. **Verify the evidence label** is `paper_result` (not diagnostic/pilot)
3. **Check the claim strength** matches the evidence strength:
   - Strong evidence (large effect, high significance) → strong claim
   - Marginal evidence → hedged claim ("suggests", "indicates")
   - No evidence → remove the claim

Create a claim-evidence map: `paper/CLAIM_MAP.md`

## Phase 4 — Figure & Table Design

For each figure/table:
1. **Purpose**: What question does it answer?
2. **Key takeaway**: What should the reader conclude?
3. **Design**: Clean, readable, publication-quality
4. **Caption**: Self-contained (reader should understand without reading text)

Tables: Bold best results, underline second-best. Include std dev.

## Phase 5 — Internal Review

Before submission:
1. **Compile** — verify LaTeX builds without errors
2. **Page check** — within venue limit
3. **Self-review** — read as a hostile reviewer, note weaknesses
4. **Send to auto-review-loop** for multi-agent review

## Handoff

- Output: `paper/` directory with complete LaTeX source
- Output: `paper/CLAIM_MAP.md`
- Next ARIS step: **paper-compile** → **auto-review-loop**
- Handoff to: Codex (reviewer) for auto-review-loop

## Hard Rules

- Every claim must have evidence with `paper_result` label
- No results from <20 seeds in main paper (supplementary only)
- No A+B stitching narrative — frame as original problem reframing
- Related work must be fair and comprehensive (≥30 citations for top venue)
- Figures must be vector graphics (PDF/SVG), not raster
- All numbers in tables must be reproducible from code + config
