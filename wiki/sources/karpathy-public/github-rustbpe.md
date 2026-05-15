---
title: "rustbpe"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - language-modeling
  - tokenization
source_pages:
  - https://github.com/karpathy/rustbpe
---

# rustbpe

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/rustbpe
- Discovery source: https://github.com/karpathy/rustbpe
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `4a2d81dd19cb54ad2d637e39726c04a0b19a54f11612d014b95a4f5324dbda06`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Tokenization and language modeling
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

rustbpe $1](https://github.com/karpathy/rustbpe/actions/workflows/ci.yml) $1](https://pypi.org/project/rustbpe/) $1](https://opensource.org/licenses/MIT) The missing tiktoken training code A lightweight Rust library for training GPT-style BPE tokenizers. The $1 library is excellent for inference but doesn't support training. The HuggingFace $1 library supports training but carries significant complexity from years of accumulated tokenizer variants. My $1 library handles both training and inference, but only in Python and not optimized for speed. rustbpe fills this gap: a simple, efficient BPE training implementat...

## What This Teaches

- How tokenization and sequence modeling mechanics connect to practical LLM behavior.
- Useful when debugging prompts, corpora, token budgets, or tokenizer-dependent failures.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/rustbpe`
- Default branch: `master`
- HEAD: `ddf848f6961a0655dc8693742fc338e5682c0d3b`
- Stars at crawl: 454
- Forks at crawl: 52
- File count: 11
- README path: `README.md`
- License path: `LICENSE`
- Created: 2026-01-03T21:20:46Z
- Updated: 2026-05-12T05:30:15Z
- Pushed: 2026-01-03T22:24:54Z

### Top-Level Structure

- `[root]`: 7
- `.github`: 2
- `src`: 1
- `tests`: 1

### File Extension Profile

- `.toml`: 2
- `.yml`: 2
- `.gitignore`: 1
- `.lock`: 1
- `.md`: 1
- `.py`: 1
- `.python-version`: 1
- `.rs`: 1
- `[none]`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `.gitignore`
- `.python-version`
- `Cargo.lock`
- `Cargo.toml`
- `LICENSE`
- `pyproject.toml`
- `README.md`
- `src/lib.rs`
- `tests/python/test_tokenizer.py`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
