---
title: "hn-time-capsule"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - inference
  - karpathy
  - llm
  - training
source_pages:
  - https://github.com/karpathy/hn-time-capsule
---

# hn-time-capsule

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/hn-time-capsule
- Discovery source: https://github.com/karpathy/hn-time-capsule
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `80105c6659cf9573fe4cfc79ae46cf8b3cd719f46666f5c211a80ff4a8beab4b`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: LLM training and inference systems
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

HN Time Capsule !$1 A Hacker News time capsule project that pulls the HN frontpage from exactly 10 years ago, analyzes articles and discussions using an LLM to evaluate prescience with the benefit of hindsight, and generates an HTML report. Also see $1 for more context. What it does 1. Fetches the HN frontpage from 10 years ago (e.g., https://news.ycombinator.com/front?day=2015-12-09 ) 2. For each article, fetches the original article content and all HN comments 3. Generates prompts asking an LLM to analyze what happened with hindsight 4. Parses LLM responses to extract grades for each commenter 5. Renders an HTM...

## What This Teaches

- How modern LLM training or inference can be reduced to compact, inspectable systems.
- Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.

## Why It Matters

This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment.

## Repository Snapshot

- Full name: `karpathy/hn-time-capsule`
- Default branch: `master`
- HEAD: `ca02ebb4de5e953bf1629689abd1f82b454b6905`
- Stars at crawl: 627
- Forks at crawl: 61
- File count: 7
- README path: `README.md`
- License path: ``
- Created: 2025-12-10T16:10:52Z
- Updated: 2026-05-14T05:08:08Z
- Pushed: 2025-12-10T16:59:29Z

### Top-Level Structure

- `[root]`: 7

### File Extension Profile

- `.gitignore`: 1
- `.lock`: 1
- `.md`: 1
- `.png`: 1
- `.py`: 1
- `.python-version`: 1
- `.toml`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `.python-version`
- `hnhero.png`
- `pipeline.py`
- `pyproject.toml`
- `README.md`
- `uv.lock`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
