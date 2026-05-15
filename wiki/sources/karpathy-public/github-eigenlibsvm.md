---
title: "EigenLibSVM"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - minimal-implementation
source_pages:
  - https://github.com/karpathy/EigenLibSVM
---

# EigenLibSVM

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/EigenLibSVM
- Discovery source: https://github.com/karpathy/EigenLibSVM
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `5c5b2cfb86913dd5eec33b4758158076bc5c8908aa8191ad9d60b033f92a9957`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Minimal implementations
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

EigenLibSVM Andrej Karpathy 1 May 2012 This is a small C++ wrapper to call libsvm if you use the Eigen matrix library. Dependencies consist of libsvm and eigen3 library. Current support is only for dense matrices with linear kernel svm. Usage where X is an Eigen::MatrixXf NxD matrix, y is an Eigen::MatrixXf Nx1 matrix of labels (-1 or 1), or a vector of labels. You can also save and load the models: there is now also functionality to directly get the weights: See demo for details. Install where the last line will run a tiny demo that makes sure everything installed ok (it runs almost instantly) License BSD

## What This Teaches

- How a complex idea can be compressed into a minimal but working implementation.
- Useful as a reference style for serious small systems rather than decorative demos.

## Why It Matters

This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts.

## Repository Snapshot

- Full name: `karpathy/EigenLibSVM`
- Default branch: `master`
- HEAD: `1e4b84cfa899e2cc6f4c57dccddc4a611d575a6a`
- Stars at crawl: 108
- Forks at crawl: 34
- File count: 6
- README path: `Readme.md`
- License path: ``
- Created: 2012-05-02T08:48:39Z
- Updated: 2026-04-21T08:41:05Z
- Pushed: 2016-03-29T13:29:21Z

### Top-Level Structure

- `[root]`: 2
- `include`: 2
- `src`: 1
- `test`: 1

### File Extension Profile

- `.cpp`: 2
- `.h`: 2
- `.md`: 1
- `.txt`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `CMakeLists.txt`
- `include/eigenlibsvm/eigen_extensions.h`
- `include/eigenlibsvm/svm_utils.h`
- `Readme.md`
- `src/svm_utils.cpp`
- `test/svm_test.cpp`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
