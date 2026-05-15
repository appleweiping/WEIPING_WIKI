---
title: "optim"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - minimal-implementation
source_pages:
  - https://github.com/karpathy/optim
---

# optim

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/optim
- Discovery source: https://github.com/karpathy/optim
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `333b23b6208ca3109888fc03217b1b2e1c78f74dbb89583fb40c5cf6e8109fda`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Minimal implementations
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

Optimization package This package contains several optimization routines for $1. Each optimization algorithm is based on the same interface: where: func : a user-defined closure that respects this API: f, df/dx = func(x) x : the current parameter vector (a 1D torch.Tensor ) state : a table of parameters, and state variables, dependent upon the algorithm x : the new parameter vector that minimizes f, x = argmin x f(x) {f} : a table of all f values, in the order they've been evaluated (for some simple algorithms, like SGD, f == 1 ) Important Note The state table is used to hold the state of the algorihtm. It's usua...

## What This Teaches

- How a complex idea can be compressed into a minimal but working implementation.
- Useful as a reference style for serious small systems rather than decorative demos.

## Why It Matters

This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts.

## Repository Snapshot

- Full name: `karpathy/optim`
- Default branch: `master`
- HEAD: `695ef7b7765453b2a3056ff87fc9719e23392c40`
- Stars at crawl: 41
- Forks at crawl: 7
- File count: 40
- README path: `README.md`
- License path: ``
- Created: 2015-04-15T23:28:55Z
- Updated: 2026-05-11T17:14:35Z
- Pushed: 2021-08-19T08:14:02Z

### Top-Level Structure

- `[root]`: 25
- `test`: 14
- `dok`: 1

### File Extension Profile

- `.lua`: 31
- `.rockspec`: 4
- `.txt`: 2
- `.dok`: 1
- `.dokx`: 1
- `.md`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.dokx`
- `adadelta.lua`
- `adagrad.lua`
- `adam.lua`
- `asgd.lua`
- `cg.lua`
- `checkgrad.lua`
- `CMakeLists.txt`
- `ConfusionMatrix.lua`
- `COPYRIGHT.txt`
- `dok/index.dok`
- `fista.lua`
- `init.lua`
- `lbfgs.lua`
- `Logger.lua`
- `lswolfe.lua`
- `nag.lua`
- `optim-1.0.3-0.rockspec`
- `optim-1.0.3-1.rockspec`
- `optim-1.0.4-0.rockspec`
- `optim-1.0.5-0.rockspec`
- `polyinterp.lua`
- `README.md`
- `rmsprop.lua`
- `rprop.lua`
- `sgd.lua`
- `test/l2.lua`
- `test/rosenbrock.lua`
- `test/sparsecoding.lua`
- `test/test_adadelta.lua`
- `test/test_adagrad.lua`
- `test/test_adam.lua`
- `test/test_cg.lua`
- `test/test_confusion.lua`
- `test/test_fista.lua`
- `test/test_lbfgs.lua`
- `test/test_lbfgs_w_ls.lua`
- `test/test_logger.lua`
- `test/test_rmsprop.lua`
- `test/test_sgd.lua`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
