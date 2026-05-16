# Paper Fidelity Map

A design-decision → paper-page map. For every non-trivial choice in this
repo, this document points to the section/page/appendix of arXiv:2604.05018
that motivates it.

The arXiv URL: <https://arxiv.org/pdf/2604.05018>

## Verbatim reproductions (not paraphrased)

Every prompt below is reproduced **verbatim** from the paper's appendix.
The header of each file in the repo cites its source page.

| Prompt | Repo location | Paper page |
|---|---|---|
| Anti-Leakage Prompt | `skills/paper-orchestra/references/anti-leakage-prompt.md` | App. D.4, p.25 |
| Outline Agent | `skills/outline-agent/references/prompt.md` | App. F.1, pp.40-44 |
| Outline example output | `skills/outline-agent/references/example-output.json` | App. F.1, pp.43-44 |
| Plotting Caption Generation | `skills/plotting-agent/references/caption-prompt.md` | App. F.1, p.45 |
| Literature Review Agent | `skills/literature-review-agent/references/prompt.md` | App. F.1, p.46 |
| Section Writing Agent | `skills/section-writing-agent/references/prompt.md` | App. F.1, pp.47-49 |
| Content Refinement Agent | `skills/content-refinement-agent/references/prompt.md` | App. F.1, pp.49-51 |
| Sparse Idea Generation | `skills/paper-writing-bench/references/sparse-idea-prompt.md` | App. F.2, p.54 |
| Dense Idea Generation | `skills/paper-writing-bench/references/dense-idea-prompt.md` | App. F.2, pp.55-56 |
| Experimental Log Generation | `skills/paper-writing-bench/references/experimental-log-prompt.md` | App. F.2, p.57 |
| Citation F1 P0/P1 Partition | `skills/paper-autoraters/references/citation-f1-prompt.md` | App. F.3, p.58 |
| LitReview Quality Autorater | `skills/paper-autoraters/references/litreview-quality-prompt.md` | App. F.3, pp.59-63 |
| SxS Paper Quality Autorater | `skills/paper-autoraters/references/sxs-paper-quality-prompt.md` | App. F.3, pp.63-64 |
| SxS LitReview Quality Autorater | `skills/paper-autoraters/references/sxs-litreview-prompt.md` | App. F.3, pp.64-65 |

## Engineering decisions traced to the paper

| Decision | Repo location | Paper source |
|---|---|---|
| Five-agent pipeline structure | `skills/paper-orchestra/references/pipeline.md` | §4 (pp.4-5), Fig. 1 (p.4) |
| (I, E, T, G, F) input tuple | `skills/paper-orchestra/references/io-contract.md` | §3.1 Eq. 1 (p.3) |
| Steps 2 and 3 in parallel | `skills/paper-orchestra/references/pipeline.md` | §4 ("operating in parallel"), p.5 |
| Outline = 1 LLM call | `skills/outline-agent/SKILL.md` | App. B (p.14) |
| Plotting = ~20-30 LLM calls | `skills/plotting-agent/SKILL.md` | App. B (p.15) |
| Lit Review = ~20-30 LLM calls | `skills/literature-review-agent/SKILL.md` | App. B (p.15) |
| Section Writing = ONE single multimodal call | `skills/section-writing-agent/SKILL.md` | App. B (p.15) "single, comprehensive multimodal call" |
| Refinement = ~5-7 LLM calls, ~3 iterations | `skills/content-refinement-agent/SKILL.md` | App. B (p.15), Table 7 "3× content refinement loop" |
| Outline JSON schema (3 top-level keys) | `skills/outline-agent/references/outline_schema.json` | App. F.1 pp.43-44 (verbatim example) |
| 12 allowed aspect ratios | `skills/outline-agent/references/allowed-values.md`, `skills/plotting-agent/references/aspect-ratios.md` | App. F.1, p.41 (Outline prompt Directive 1) |
| `figure_id` snake_case + no "Figure" | `skills/outline-agent/scripts/validate_outline.py` | App. F.1, p.41 |
| 2-4 related work clusters | `skills/outline-agent/references/outline_schema.json` (`maxItems: 4`) | App. F.1, p.41 (Outline prompt Directive 2) |
| Citation hint format | `skills/outline-agent/references/allowed-values.md` | App. F.1, p.42 (Format Constraint & Anti-Hallucination Rule) |
| Levenshtein > 70 fuzzy match | `skills/literature-review-agent/scripts/levenshtein_match.py` | App. D.3, p.25 |
| Year-alignment bonus | `skills/literature-review-agent/references/verification-rules.md` | App. D.3, p.25 ("augmented by a point bonus for exact year alignment") |
| Must have abstract | `skills/literature-review-agent/references/verification-rules.md` | App. D.3, p.25 |
| Strict cutoff (months → day-1) | `skills/literature-review-agent/scripts/check_cutoff.py` | App. D.3, p.25 |
| Dedup by S2 paperId | `skills/literature-review-agent/scripts/dedupe_by_id.py` | App. D.3, p.25 |
| ≥90% citation integration | `skills/literature-review-agent/scripts/citation_coverage.py` | App. D.3, p.25 |
| 10 parallel discovery workers, 1 QPS verification | `skills/literature-review-agent/references/discovery-pipeline.md` | App. B, p.15 |
| CVPR 2025 cutoff = Nov 2024, ICLR 2025 = Oct 2024 | `skills/paper-writing-bench/references/bench-overview.md` | App. D.1, p.24 |
| Anti-Leakage Prompt prepended to every writing call | `skills/paper-orchestra/SKILL.md` | App. D.4, p.25 |
| Refinement halt rules (accept/revert/halt) | `skills/content-refinement-agent/scripts/score_delta.py`, `references/halt-rules.md` | §4 Step 5 (p.5) |
| Refinement: ignore new-experiment requests | `skills/content-refinement-agent/references/safe-revision-rules.md` | App. F.1, p.50 (Critical Execution Standards #2) |
| Refinement: never explicitly state limitation | `skills/content-refinement-agent/references/safe-revision-rules.md` | App. F.1, p.51 (anti-reward-hacking explanation) |
| AgentReview-style 6-axis rubric | `skills/content-refinement-agent/references/reviewer-rubric.md` | App. F.1, p.49 (Inputs: reviewer_feedback) and §5.4 (AgentReview citation) |
| Booktabs LaTeX tables | `skills/section-writing-agent/references/latex-table-patterns.md` | App. F.1, p.47 (Critical Instructions #2) |
| `\includegraphics` exact filenames | `skills/section-writing-agent/references/figure-integration.md` | App. F.1, p.48 (Figures And Visual Fidelity) |
| `\begin{figure*}` matched with `\end{figure*}` | `skills/section-writing-agent/scripts/latex_sanity.py` | App. F.1, p.49 (Important Note) |
| Don't change `cleveref` to `cleverref` | `skills/section-writing-agent/SKILL.md` | App. F.1, p.49 (Important Note) |
| All figs/tables before Conclusion | `skills/section-writing-agent/references/figure-integration.md` | App. F.1, p.48 (Item 5) |
| 200 papers in PaperWritingBench (100 CVPR + 100 ICLR) | `skills/paper-writing-bench/references/bench-overview.md` | §3 / App. C |
| Avg citation count: 58.52 (CVPR), 59.18 (ICLR) | `skills/paper-writing-bench/references/bench-overview.md` | Table 8, p.16 |
| LitReview overall = weighted axes | `skills/paper-autoraters/references/litreview-quality-prompt.md` | App. F.3, p.62 (Overall Score weights) |
| LitReview anti-inflation hard caps | `skills/paper-autoraters/references/litreview-quality-prompt.md` | App. F.3, p.60 |
| SxS double-call for positional bias | `skills/paper-autoraters/references/sxs-paper-quality-prompt.md` | §5.4, p.9 |

## Out-of-paper improvements (clearly marked as our additions)

These are deterministic hardening scripts we added on top of the paper.
None contradicts the paper; they enforce paper-stated constraints
mechanically rather than relying on prompt obedience.

| Improvement | Repo location | Why |
|---|---|---|
| Author/email/affiliation grep on final draft | `skills/paper-orchestra/scripts/anti_leakage_check.py` | Anti-Leakage Prompt (App. D.4) is aspirational; this enforces it after the fact |
| Orphan-cite gate | `skills/section-writing-agent/scripts/orphan_cite_gate.py` | Section Writing prompt mandates "use ONLY keys from refs.bib"; this enforces mechanically |
| Citation coverage gate (≥90%) | `skills/literature-review-agent/scripts/citation_coverage.py` | App. D.3 mandates this; this catches violations and re-prompts the writing step |
| Physical iteration snapshots | `skills/content-refinement-agent/scripts/snapshot.py` | Refinement halt rules require real rollback; symbolic noted-only is insufficient |
| Provenance hashes | `skills/paper-orchestra/references/io-contract.md` (`provenance.json`) | Reproducibility — out of paper |
| Levenshtein substring-bypass for short titles | `skills/literature-review-agent/scripts/levenshtein_match.py` `--substring-bypass` | Catches false-negatives like "Linformer" matching "Linformer: Self-Attention with Linear Complexity"; the paper doesn't specify this |
| `extract_metrics.py` markdown-table parser | `skills/section-writing-agent/scripts/extract_metrics.py` | The Section Writing prompt says "extract numerical data directly"; this gives the writing step a structured input |
| LaTeX sanity gate | `skills/section-writing-agent/scripts/latex_sanity.py` | Catches compile failures before invoking latexmk |
| Diminishing-returns refinement halt | `skills/content-refinement-agent/references/halt-rules.md` | The paper caps at iteration count; we additionally halt on `<1.0` overall delta to save wall-time |

## What's NOT implemented from the paper

A few paper components are intentionally out of scope or implemented as
stubs because they require external systems we don't ship:

| Paper component | Status | Why |
|---|---|---|
| PaperBanana visual generator | Replaced with matplotlib + diagram patterns + (optional) host VLM critique loop | PaperBanana (Zhu et al., 2026) is an external system not redistributable here. Our `plotting-agent` expresses the same loop in matplotlib + host LLM terms. |
| MinerU PDF extraction | Delegated to host agent's PDF reader | The `paper-writing-bench` skill assumes the host can extract markdown from a PDF — this is generally available in modern coding agents. |
| PDFFigures 2.0 | Delegated | Same — host extracts figures separately if needed. |
| Gemini-3-Flash with Google Search grounding | Replaced by host's web search tool | Any host with a `WebSearch`-equivalent tool can do this. |
| Semantic Scholar verification at exactly 1 QPS via authenticated workers | Public unauthenticated S2 endpoint, ≤1 QPS sustained | The public endpoint is sufficient for individual papers; large-scale benchmarking would benefit from a key but is out of scope here. |
| Streamlit human evaluation interface (Fig. 8) | Out of scope | This repo doesn't ship a human eval UI. |
| AgentReview as a separate package | Reproduced as a rubric prompt in `content-refinement-agent/references/reviewer-rubric.md` | We don't redistribute the AgentReview package; the rubric matches its output schema (strengths / weaknesses / questions / decisions). |

If any of these limitations affects your use case, the host coding agent
can usually fill the gap with its own tools — that is the entire point of
the host-agent-pluggable design.
