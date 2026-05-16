# Examples

End-to-end examples of running the paper-orchestra pipeline.

## `minimal/`

A realistic stub research project on **Adaptive Top-K Attention** — a
content-adaptive sparse-attention mechanism. The example contains all
four required input files (idea, experimental log, template, conference
guidelines) and exercises every step of the pipeline.

The numeric "results" are fabricated for example purposes, but they are
internally consistent: the ablation trends, scaling tables, and
qualitative observations all tell a coherent story so the writing agents
have something coherent to write about.

See `minimal/README.md` for run instructions and
`minimal/expected-workspace-tree/README.md` for what a successful run
should produce.

## Future examples

Additions welcome:

- A Dense-variant idea example (preserves LaTeX equations from the source).
- A 2-column CVPR-style example with a non-trivial template.
- A worked PaperWritingBench reverse-engineering example: take a real
  arXiv paper, run `paper-writing-bench` to extract `(idea_sparse,
  idea_dense, experimental_log)`, then run `paper-orchestra` and compare
  with `paper-autoraters`.
