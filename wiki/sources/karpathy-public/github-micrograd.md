---
title: "micrograd"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - education
  - karpathy
  - neural-networks
source_pages:
  - https://github.com/karpathy/micrograd
---

# micrograd

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/micrograd
- Discovery source: https://github.com/karpathy/micrograd
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `938393af4bf76c454bd05b744fb1006133b08877992af860a26f2a7490f3cc17`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Neural network fundamentals
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

micrograd !$1 A tiny Autograd engine (with a bite! :)). Implements backpropagation (reverse-mode autodiff) over a dynamically built DAG and a small neural networks library on top of it with a PyTorch-like API. Both are tiny, with about 100 and 50 lines of code respectively. The DAG only operates over scalar values, so e.g. we chop up each neuron into all of its individual tiny adds and multiplies. However, this is enough to build up entire deep neural nets doing binary classification, as the demo notebook shows. Potentially useful for educational purposes. Installation Example usage Below is a slightly contrived...

## What This Teaches

- How core neural network ideas can be rebuilt from first principles.
- Useful for grounding later LLM work in gradients, activations, optimization, and model internals.

## Why It Matters

This is high-priority for Vipin because it supports durable first-principles understanding instead of shallow API use.

## Repository Snapshot

- Full name: `karpathy/micrograd`
- Default branch: `master`
- HEAD: `c911406e5ace8742e5841a7e0df113ecb5d54685`
- Stars at crawl: 15849
- Forks at crawl: 2448
- File count: 13
- README path: `README.md`
- License path: `LICENSE`
- Created: 2020-04-13T04:31:18Z
- Updated: 2026-05-15T20:30:33Z
- Pushed: 2024-08-08T12:54:44Z

### Top-Level Structure

- `[root]`: 9
- `micrograd`: 3
- `test`: 1

### File Extension Profile

- `.py`: 5
- `.ipynb`: 2
- `.gitignore`: 1
- `.jpg`: 1
- `.md`: 1
- `.png`: 1
- `.svg`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `demo.ipynb`
- `gout.svg`
- `LICENSE`
- `micrograd/__init__.py`
- `micrograd/engine.py`
- `micrograd/nn.py`
- `moon_mlp.png`
- `puppy.jpg`
- `README.md`
- `setup.py`
- `test/test_engine.py`
- `trace_graph.ipynb`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
