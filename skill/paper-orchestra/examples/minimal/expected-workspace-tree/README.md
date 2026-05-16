# Expected workspace tree after a successful run

After a host agent runs the paper-orchestra pipeline on `examples/minimal/inputs/`,
the workspace should look approximately like this:

```
workspace/
├── inputs/                                  ← from examples/minimal/inputs/
│   ├── idea.md
│   ├── experimental_log.md
│   ├── template.tex
│   ├── conference_guidelines.md
│   └── figures/                             ← empty for this example
│
├── outline.json                             ← STEP 1 output
│
├── figures/                                 ← STEP 2 output
│   ├── fig_framework_overview.png
│   ├── fig_main_results_nq.png
│   ├── fig_compute_quality_tradeoff.png
│   ├── fig_ablation_design_choices.png
│   └── captions.json
│
├── refs.bib                                 ← STEP 3 output
├── citation_pool.json                       ← STEP 3 internal record
│
├── drafts/
│   ├── intro_relwork.tex                    ← STEP 3 output (Intro + Related Work filled)
│   └── paper.tex                            ← STEP 4 output (all sections filled)
│
├── refinement/                              ← STEP 5 working dir
│   ├── worklog.json
│   ├── iter0/
│   │   ├── paper.tex
│   │   ├── paper.pdf
│   │   ├── review.json
│   │   └── score.json
│   ├── iter1/...
│   └── iter2/...                            ← typically halts at iter2 or iter3
│
├── final/                                   ← promoted best snapshot
│   ├── paper.tex
│   └── paper.pdf
│
└── provenance.json                          ← input/output hashes (optional)
```

## What each step typically produces for this example

### Step 1 (Outline)

`outline.json` should contain:

- `plotting_plan` with ~4 figures:
  - `fig_framework_overview` (diagram, the ATK-Attention block)
  - `fig_main_results_nq` (grouped bar chart, NQ-L F1 across methods)
  - `fig_compute_quality_tradeoff` (line chart, F1 vs FLOPs at K=32/64/128/256)
  - `fig_ablation_design_choices` (horizontal bar chart, ablation deltas from Table 4)
- `intro_related_work_plan` with 2-3 related work clusters around:
  - Block-sparse / fixed-pattern attention (BigBird, Longformer)
  - Hashing / random-feature attention (Reformer, Performer)
  - Learned / content-adaptive sparsity (the closest prior art for our method)
- `section_plan` with ~5 top-level sections matching the template
  (Abstract, Method, Experiments, Conclusion — plus the Intro/Related Work
  filled in by Step 3)

### Step 3 (Lit Review)

`refs.bib` should contain ~25-40 entries covering:

- Foundational: Vaswani et al. 2017 (Attention Is All You Need),
  Devlin et al. 2018 (BERT), Radford et al. 2019 (GPT-2)
- Sparse attention: Zaheer et al. 2020 (BigBird), Beltagy et al. 2020
  (Longformer), Kitaev et al. 2020 (Reformer), Choromanski et al. 2020
  (Performer), Tay et al. 2020 (Sparse Sinkhorn Attention)
- Long context: Tay et al. 2020 (Long Range Arena), Press et al. 2021
  (ALiBi), Su et al. 2021 (RoFormer / RoPE)
- Datasets: Kwiatkowski et al. 2019 (NaturalQuestions), Kočiský et al.
  2018 (NarrativeQA), Huang et al. 2021 (GovReport)
- Optimizer/standard: Loshchilov & Hutter 2017 (AdamW), Lin et al. 2004
  (ROUGE)

`drafts/intro_relwork.tex` should fill the Introduction and Related Work
sections of `template.tex` (everything else preserved verbatim) and cite
≥90% of the entries above.

### Step 4 (Section Writing)

`drafts/paper.tex` should add:

- Abstract (1 paragraph, ~200 words)
- Method section formalizing ATK-Attention with the scoring head, top-K
  mask, Gumbel-Softmax surrogate, and load-balancing loss
- Experiments section with three booktabs tables (one per dataset) and
  the ablation table, all values copied verbatim from
  `experimental_log.md`'s `## 2. Raw Numeric Data`
- Inline references to `Figure~\ref{...}` for each generated figure
- Conclusion paragraph

### Step 5 (Refinement)

Typically 2-3 refinement iterations. The worklog should show:

- iter0: baseline score (~60-65)
- iter1: ACCEPT_IMPROVED (clarity and figure-text alignment fixes)
- iter2: ACCEPT_IMPROVED or ACCEPT_TIED_NON_NEGATIVE
- iter3: HALT (iteration cap reached, OR REVERT)

`final/paper.pdf` should compile cleanly via `latexmk -pdf`.

## How to verify a run

After your host agent completes the pipeline, run the smoke checks:

```bash
# 1. inputs were validated
python skills/paper-orchestra/scripts/validate_inputs.py --workspace workspace/

# 2. outline schema is valid
python skills/outline-agent/scripts/validate_outline.py workspace/outline.json

# 3. every figure in the outline has a corresponding PNG
ls workspace/figures/*.png  # should match plotting_plan length

# 4. no orphan citations
python skills/section-writing-agent/scripts/orphan_cite_gate.py \
    workspace/final/paper.tex workspace/refs.bib

# 5. ≥90% citation coverage
python skills/literature-review-agent/scripts/citation_coverage.py \
    --tex workspace/final/paper.tex --pool workspace/citation_pool.json

# 6. anti-leakage clean
python skills/paper-orchestra/scripts/anti_leakage_check.py \
    workspace/final/paper.tex

# 7. latex sanity
python skills/section-writing-agent/scripts/latex_sanity.py \
    workspace/final/paper.tex
```

All seven should exit 0 on a successful run.
