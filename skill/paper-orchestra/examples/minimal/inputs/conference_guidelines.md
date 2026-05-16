# Conference Guidelines (toy ICLR-like)

This is a minimal stub conference for the paper-orchestra example. It
mimics ICLR submission guidelines closely enough to exercise the full
pipeline without copying real venue text.

## Submission deadline

October 1, 2024.

The Literature Review Agent should derive `cutoff_date = 2024-10-01` from
this deadline. Papers published after this date may be cited only as
concurrent work, never as prior baselines.

## Page limit

The main paper is limited to **9 pages** of single-column text, excluding
references and appendices. The appendix may be unlimited but the reviewer
is not obligated to read past the page limit.

## Mandatory sections

The submission MUST contain, in this order:

1. Abstract (single paragraph, ~150-250 words)
2. Introduction
3. Related Work
4. Method (or Methodology)
5. Experiments
6. Conclusion
7. References
8. Appendix (optional)

## Formatting rules

- Single-column, 11pt font, 1in margins
- Use `\documentclass{article}` (the bundled `template.tex` is the
  canonical skeleton)
- Citations via natbib or biblatex; use `\cite{...}` commands
- Figures saved at 300 DPI minimum
- Tables use the booktabs package (`\toprule`, `\midrule`, `\bottomrule`)
- All figures and tables MUST appear before the Conclusion section unless
  placed in the Appendix
- Anonymized for double-blind review: do not include author names,
  affiliations, or acknowledgements

## Topic scope

Submissions on machine learning methodology, benchmarks, evaluation, and
applications. Particularly welcomed: efficient transformers, long-context
modeling, parameter-efficient fine-tuning.

## Review criteria

Reviewers will assess: scientific soundness, novelty, clarity,
significance, reproducibility (implementation details, hyperparameters,
seeds reported).
