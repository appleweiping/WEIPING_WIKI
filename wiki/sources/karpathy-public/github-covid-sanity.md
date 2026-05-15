---
title: "covid-sanity"
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - karpathy
  - papers
  - research-tooling
source_pages:
  - https://github.com/karpathy/covid-sanity
---

# covid-sanity

## Source

- Source kind: `github-repository`
- URL: https://github.com/karpathy/covid-sanity
- Discovery source: https://github.com/karpathy/covid-sanity
- License: `MIT`
- Distribution policy: `public-summary-plus-license-aware-excerpts`
- Public mirror status: `partial excerpt`
- Content hash: `d95320edf636d9f7fa761d768887f5dcf31dfb7f0190c5f4b85e1fb648458630`
- First seen: 2026-05-15
- Last changed: 2026-05-15

## Classification

- Primary category: Research tooling and paper workflows
- Corpus source note: [[2026-05-15-karpathy-public-corpus]]
- Project taxonomy: [[karpathy-project-taxonomy]]
- Idea map: [[karpathy-idea-map]]
- Topic hub: [[karpathy-public-work]]

## Summary

covid-sanity This project organizes COVID-19 SARS-CoV-2 preprints from medRxiv and bioRxiv. The raw data comes from the $1 page, but this project makes the data searchable, sortable, etc. The "most similar" search uses an exemplar SVM trained on tfidf feature vectors from the abstracts of these papers. The project is running live on $1. (I could not register covid-sanity.com because the term is "protected") !$1 Since I can't assess the quality of the similarity search I welcome any opinions on some of the hyperparameters. For instance, the parameter C in the SVM training and the size of the feature vector max fea...

## What This Teaches

- How tooling can compress research reading, search, filtering, and sense-making.
- Useful for improving this wiki's own ingest, ranking, and review workflows.

## Why It Matters

This is high-priority for Vipin because it informs agent workflows, paper digestion, wiki maintenance, and autonomous research loops.

## Repository Snapshot

- Full name: `karpathy/covid-sanity`
- Default branch: `master`
- HEAD: `c8a2ab52b2c7ce04097ad7200de5785e796896cd`
- Stars at crawl: 391
- Forks at crawl: 54
- File count: 14
- README path: `README.md`
- License path: `LICENSE.md`
- Created: 2020-03-30T01:20:10Z
- Updated: 2026-04-11T02:46:03Z
- Pushed: 2020-05-03T17:51:52Z

### Top-Level Structure

- `[root]`: 9
- `static`: 4
- `templates`: 1

### File Extension Profile

- `.png`: 3
- `.py`: 3
- `.md`: 2
- `.txt`: 2
- `.css`: 1
- `.gitignore`: 1
- `.html`: 1
- `.js`: 1

### Tags / Release-Like Markers

- No git tags found in the shallow local clone.

### Sample File Tree

- `.gitignore`
- `banned.txt`
- `LICENSE.md`
- `README.md`
- `requirements.txt`
- `run.py`
- `serve.py`
- `static/favicon.png`
- `static/paper_list.js`
- `static/search.png`
- `static/style.css`
- `templates/index.html`
- `twitter_daemon.py`
- `ui.png`

## Public Handling Notes

- EXTRACTED: This page records public metadata and a source-grounded summary.
- INFERRED: Full local preservation, when available, is for private/local use unless a license or explicit source policy makes public redistribution safe.
- Do not treat this page as permission to republish unlicensed source text or code wholesale.
