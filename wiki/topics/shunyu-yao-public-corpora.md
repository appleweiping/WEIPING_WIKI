---
title: Shunyu Yao Public Corpora
type: topic
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - shunyu-yao
  - public-corpus
  - agents
  - physics-to-ai
source_pages:
  - https://ysymyth.github.io/
  - https://alfredyao.github.io/
---

# Shunyu Yao Public Corpora

This hub tracks two different public people who are both written as Shunyu Yao in English.

## Identity Guard

- [[yao-shunyu-ysymyth]] is the ysymyth identity: OpenAI, language agents, ReAct, ToT, SWE-agent, SWE-bench, tau-bench, CUA, Deep Research.
- [[yao-shunyu-alfred]] is the alfredyao identity: Google DeepMind / Anthropic, physics-to-AI, quantum physics, RL, agentic coding, non-Hermitian skin effect.
- Future agents must keep separate manifests, item pages, and source claims for the two corpora.

## Corpus Shape

- alfredyao: 16
- ysymyth: 57

## Source Kinds

- blog-index: 1
- canonical-homepage: 2
- cv-pdf-metadata: 1
- github-repository: 11
- linked-github-repository: 7
- paper: 25
- paper-or-pdf: 5
- person-profile: 2
- post: 3
- project-or-public-release: 12
- talk-or-slides: 4

## Maintenance Rules

- Use stable IDs and `semantic_hash` for no-noise updates.
- Do not mirror unclear-license full PDFs, webpages, or code into public wiki pages.
- Prefer metadata, summaries, source URLs, hashes, categories, and license notes.
- When another same-name Shunyu Yao appears, create a new identity key rather than merging records.

## Related

- [[2026-05-16-yao-shunyu-public-corpora]]
- [[shunyu-yao-project-taxonomy]]
- [[shunyu-yao-paper-map]]
- [[public-corpus-ingest-workflow]]

## Counterpoints And Gaps

- This hub is an index and routing surface, not a substitute for reading the item pages and source URLs.
- GitHub API access can be rate-limited; `scripts/ingest-shunyu-yao-public.ps1` uses `GITHUB_TOKEN` or `GH_TOKEN` when available, then falls back to the public GitHub HTML repository listing if API access still fails.
