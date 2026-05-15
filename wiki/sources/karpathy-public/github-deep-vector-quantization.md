---
title: "deep-vector-quantization"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - minimal-implementation
source_pages:
  - https://github.com/karpathy/deep-vector-quantization
---

# deep-vector-quantization

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/deep-vector-quantization
- Discovery source: https://github.com/karpathy/deep-vector-quantization
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `85d9f0d4e7773836af7faced1b62bd664820bc299a8b123a64de51af6f8b83cb`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Minimal implementations
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

deep vector quantization Implements training code for VQVAE's, i.e. autoencoders with categorical latent variable bottlenecks, which are then easy to subsequently plug into existing infrastructure for modeling sequences of discrete variables (GPT and friends). dvq/vqvae.py is the entry point of the training script and a small training run can be called e.g. as: cd dvq; python vqvae.py --gpus 1 --data dir /somewhere/to/store/cifar10 This will reproduce the original DeepMind VQVAE paper (see references before) using a semi-small network on CIFAR-10. Work on this repo is ongoing and for now requires reading of code...

## What This Teaches

- How a complex idea can be compressed into a minimal but working implementation.
- Useful as a reference style for serious small systems rather than decorative demos.

## Why It Matters

This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts.

## Repository Snapshot

- Full name: `karpathy/deep-vector-quantization`
- Default branch: `main`
- HEAD: `c3c026a1ccea369bc892ad6dde5e6d6cd5a508a4`
- Stars at crawl: 645
- Forks at crawl: 56
- File count: 14
- README path: `README.md`
- License path: `LICENSE`
- Created: 2021-02-16T02:29:41Z
- Updated: 2026-05-13T03:12:37Z
- Pushed: 2021-11-20T19:01:41Z

### Top-Level Structure

- `dvq`: 9
- `[root]`: 5

### File Extension Profile

- `.py`: 9
- `.gitignore`: 1
- `.ipynb`: 1
- `.md`: 1
- `.txt`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `dvq/__init__.py`
- `dvq/data/__init__.py`
- `dvq/data/cifar10.py`
- `dvq/model/__init__.py`
- `dvq/model/deepmind_enc_dec.py`
- `dvq/model/loss.py`
- `dvq/model/openai_enc_dec.py`
- `dvq/model/quantize.py`
- `dvq/vqvae.py`
- `LICENSE`
- `README.md`
- `requirements.txt`
- `visualize.ipynb`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
