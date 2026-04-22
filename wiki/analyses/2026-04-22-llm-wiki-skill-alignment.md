---
title: LLM Wiki Skill Alignment
type: analysis
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - analysis
  - architecture
  - workflow
  - llm-wiki-skill
---

# LLM Wiki Skill Alignment

## Summary

This note records how `vipin wiki` was upgraded to match the operating model of the reference `llm-wiki-skill` repository while preserving this repository's public/private split.

## Aligned Capabilities

- `init`
  Creates or repairs the expected wiki layout and local cache file.
- `ingest`
  Uses a source registry, cache helpers, and source-page write helper.
- `batch-ingest`
  Supports collection-oriented source registration through the same registry and compatibility layer.
- `query`
  Remains grounded in `wiki/index.md`, `wiki/overview.md`, and maintained pages.
- `digest`
  Has explicit durable destinations in `wiki/analyses/`, `wiki/comparisons/`, `wiki/timelines/`, and `wiki/synthesis/`.
- `lint`
  Runs via both PowerShell and bash, checking links, index coverage, and public/private leaks.
- `status`
  Runs via both PowerShell and bash, summarizing public scale and private counts without exposing private details.
- `graph`
  Generates `wiki/graph-data.json` and `wiki/knowledge-graph.html` in addition to the markdown graph note.
- `delete`
  Uses `scripts/delete-helper.sh` to scan references before removal.
- `crystallize`
  Now has explicit durable homes such as `wiki/queries/`, `wiki/comparisons/`, and `wiki/synthesis/sessions/`.

## Repository-Specific Additions

- Public and private materials remain separated through dedicated local-only storage areas plus `.gitignore`.
- Public scripts are allowed to report private counts, but not private content or file references.
- The public repository keeps the serious operating system while the private layer stays local-only.

## Files Added Or Reworked

- `WORKFLOWS.md`
- `scripts/source-registry.sh`
- `scripts/adapter-state.sh`
- `scripts/cache.sh`
- `scripts/wiki-compat.sh`
- `scripts/lint-runner.sh`
- `scripts/build-graph-data.sh`
- `scripts/build-graph-html.sh`
- `scripts/wiki-status.sh`
- `wiki/overview.md`
- `wiki/topics/topics-home.md`
- `wiki/comparisons/comparisons-home.md`
- `wiki/synthesis/sessions/README.md`

## Validation Outcome

- `source-registry.sh validate` passed
- `wiki-compat.sh inspect .` passed
- `lint-runner.sh .` passed with only content-level section gaps
- `build-graph-data.sh .` generated `wiki/graph-data.json`
- `build-graph-html.sh .` generated `wiki/knowledge-graph.html`
- `wiki-status.sh .` reported both public and private counts correctly

## Remaining Content Gaps

The operating system is aligned, but some sections are still intentionally empty:

- no durable topic pages yet
- no durable comparison pages yet
- no crystallized synthesis session pages yet

Those are content gaps, not system gaps.

## Counterpoints and Gaps

- functional alignment with the reference repository does not guarantee the same design priorities are right for Vipin's long-term use
- graph generation and tooling completeness can distract from the more important problem of maintaining trustworthy synthesis pages
- the serious test is repeated real ingest and query work, not one-time feature parity

## Related

- [[home]]
- [[overview]]
- [[index]]
- [[log]]
- [[2026-04-21-vipin-wiki-bootstrap]]
