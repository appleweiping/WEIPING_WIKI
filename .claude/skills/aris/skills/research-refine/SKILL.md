---
name: research-refine
description: Disciplined idea refinement for research projects. Takes a raw idea and stress-tests it into a publishable research question with clear novelty, feasibility, and positioning. Use when user says "research-refine", "refine idea", "打磨想法", "refine this research direction", or presents a raw research idea that needs sharpening.
---

# Research Refine

Transform a raw research idea into a publication-ready research question. This is where most bad papers die — skip nothing.

## Decision Gate

Before running:
- [ ] Is there a raw idea or direction to refine? (If not, run idea-discovery first)
- [ ] Is the target venue clear? (NeurIPS/ICML/ICLR oral level)
- [ ] Do you have access to the project's `refine-logs/` directory?

## Phase 1 — Problem Decomposition

Break the idea into atomic claims:

1. **State the core claim** in one sentence: "We show that X improves Y by doing Z"
2. **Identify the gap**: What existing work fails to do? Why?
3. **Novelty check**: Is this a new problem framing (required) or just A+B stitching (forbidden)?
4. **Scope the contribution**: Theory? Method? System? Empirical finding?

Output: `refine-logs/CLAIM_DECOMPOSITION.md`

## Phase 2 — Literature Stress Test

Kill the idea before it kills your time:

1. **Search for prior art** that already solves this (or claims to)
2. **Find the 3 closest papers** — read abstracts + methods
3. **Differentiation matrix**: For each close paper, state exactly how your approach differs
4. **Kill argument**: Write the strongest reviewer objection. If you can't refute it, pivot.

Quality check: If differentiation from closest work is < 1 fundamental insight, STOP and reformulate.

Output: `refine-logs/LITERATURE_STRESS_TEST.md`

## Phase 3 — Feasibility Assessment

1. **Data**: What datasets? Available? Size sufficient for statistical significance (20+ seeds)?
2. **Compute**: GPU hours estimate. Can you run full experiments on available hardware?
3. **Baselines**: List 8+ baselines (minimum per quality standards). Are implementations available?
4. **Timeline**: Weeks to first meaningful result? Weeks to full paper?
5. **Risk factors**: What could make this impossible? (data access, compute, theoretical dead-end)

Quality check: If any risk factor has >30% probability of blocking, define a pivot plan.

Output: `refine-logs/FEASIBILITY.md`

## Phase 4 — Research Question Crystallization

1. **Write the final research question** (1 sentence, precise, testable)
2. **Write the hypothesis** (falsifiable, with clear success/failure criteria)
3. **Define the evaluation protocol** (metrics, datasets, baselines, statistical tests)
4. **Position in the field**: One paragraph explaining where this sits relative to SOTA

Quality check: Show to Codex for cross-model review (invoke via hub_invoke_gpt55 or hub_send_message). Codex must score ≥7/10 on novelty and feasibility.

Output: `refine-logs/RESEARCH_QUESTION.md`

## Phase 5 — Handoff

- Update `memory/facts/<project>-status.md` with refined research question
- Next ARIS step: **experiment-plan**
- Handoff to: CC (architect) for experiment planning

## Hard Rules

- No A+B stitching (forbidden per quality standards)
- Must have original problem reframing
- Kill argument must be attempted honestly — don't softball it
- If Codex review scores <6 on any dimension, iterate before proceeding
- Evidence labels: everything in refine-logs is "diagnostic" until experiment-plan passes
