# Minimal example: Adaptive Top-K Attention

A small, self-contained, **realistic** end-to-end example for the
paper-orchestra pipeline. The "research" topic is **Adaptive Top-K
Attention** — a content-adaptive sparse-attention mechanism that learns
which keys to attend to per-query. The example exercises every step of the
pipeline:

- The idea has 4 conceptual sections (Problem / Hypothesis / Method /
  Contribution), enough to drive Step 1 outline generation.
- The experimental log has 4 markdown tables, 5 baselines, 3 datasets, and
  ~8 qualitative observations — enough to populate Step 4's tables.
- The conference guidelines specify a cutoff date (2024-10-01) so the
  Literature Review Agent has a real boundary to enforce.
- The template is a minimal `\documentclass{article}` skeleton with empty
  section commands so the writing agents have a real skeleton to fill.

The "results" in `experimental_log.md` are **fabricated** for example
purposes — they are designed to be plausible (the trends are coherent
across tables and the ablation tells a self-consistent story) but they
do not come from any real experiment. **Do not** treat them as real.

## Inputs

```
inputs/
├── idea.md                       # Sparse variant — high-level concept note
├── experimental_log.md           # 3 datasets, 4 tables, 8 observations
├── template.tex                  # minimal article-class skeleton
└── conference_guidelines.md      # 9-page limit, cutoff Oct 1 2024
```

## Run it

### With Claude Code

```bash
# 1. Scaffold a workspace next to this example
python ~/paper-orchestra/skills/paper-orchestra/scripts/init_workspace.py \
    --out /tmp/po-minimal/

# 2. Copy the example inputs
cp -r ~/paper-orchestra/examples/minimal/inputs/* /tmp/po-minimal/inputs/

# 3. Validate
python ~/paper-orchestra/skills/paper-orchestra/scripts/validate_inputs.py \
    --workspace /tmp/po-minimal/

# 4. Ask Claude:
#    "Run the paper-orchestra pipeline on /tmp/po-minimal/"
```

Claude reads `skills/paper-orchestra/SKILL.md`, follows the 5-step
pipeline, and produces `/tmp/po-minimal/final/paper.pdf`. Expected
runtime: ~15-30 minutes depending on parallelism support.

### With other hosts

See `skills/paper-orchestra/references/host-integration.md` for Cursor,
Antigravity, Cline, Aider, and OpenCode setup.

### Smoke test only (no LLM)

If you just want to verify the deterministic scripts run cleanly without
involving an LLM:

```bash
cd ~/paper-orchestra
python skills/paper-orchestra/scripts/init_workspace.py --out /tmp/po-smoke/
cp -r examples/minimal/inputs/* /tmp/po-smoke/inputs/
python skills/paper-orchestra/scripts/validate_inputs.py --workspace /tmp/po-smoke/
python skills/section-writing-agent/scripts/extract_metrics.py \
    --log /tmp/po-smoke/inputs/experimental_log.md \
    --out /tmp/po-smoke/metrics.json
cat /tmp/po-smoke/metrics.json
```

This should print 4 extracted tables. The validate-inputs script should
exit 0.

## Expected output

See `expected-workspace-tree/README.md` for a step-by-step breakdown of
what each pipeline step should produce on this example.
