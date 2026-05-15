---
title: "gitstats"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - minimal-implementation
source_pages:
  - https://github.com/karpathy/gitstats
---

# gitstats

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/gitstats
- Discovery source: https://github.com/karpathy/gitstats
- License: `NOASSERTION`
- Distribution policy: `public-summary-local-archive-only`
- Public mirror status: `summary-only`
- Content hash: `9e4c33ae4450d9c5fe78a259a3a48d0c80bd8463795268570f91be43bcdd155f`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Minimal implementations
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

gitstats Reads any git repository and produces a nice and colorful summary for all of ongoing work in the repository, and convenient links to JIRA/BitBucket etc. To get working: 1. create a repos json configuration file by following the example in example repos.json 2. cd into the git repo of interest and git pull 3. run run.py to process all the commits and write json files of output to deploy/ directory 4. cd deploy 5. python -m http.server 6. visit the web browser 7. enter name of the json file in the box and click load. Ok this is a bit janky LOL. Ah well.

## What This Teaches

- How a complex idea can be compressed into a minimal but working implementation.
- Useful as a reference style for serious small systems rather than decorative demos.

## Why It Matters

This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts.

## Repository Snapshot

- Full name: `karpathy/gitstats`
- Default branch: `master`
- HEAD: `bf32befff18fb181c7c6708f091adcb38569ac20`
- Stars at crawl: 138
- Forks at crawl: 13
- File count: 7
- README path: `README.md`
- License path: ``
- Created: 2019-11-19T01:45:43Z
- Updated: 2026-04-23T10:16:13Z
- Pushed: 2020-04-02T02:16:46Z

### Top-Level Structure

- `[root]`: 5
- `deploy`: 2

### File Extension Profile

- `.gitignore`: 1
- `.html`: 1
- `.js`: 1
- `.json`: 1
- `.md`: 1
- `.py`: 1
- `.txt`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `deploy/index.html`
- `deploy/jquery-3.3.1.min.js`
- `example_repos.json`
- `README.md`
- `requirements.txt`
- `run.py`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
