---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - coding-agent-workflow
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:ba3d86b5fa9d6b8f`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-06T13:55:24.016Z`
- Semantic hash: `ba3d86b5fa9d6b8f58874f7ddada03830e0ab1d478c986ccb500d27ba0b7de44`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# origin-plot-agent Production Alpha Plan

## Summary
Build a complete production-grade first version from the provided GitHub repo. Current local folder is empty and not a git repo, while remote `appleweiping/origin-plot-agent` exists with only `LICENSE`, so implementation starts by cloning/initializing into `D:\Research\Agent-Origin`.

Grounding decisions:
- Use FastAPI backend, static web UI served by API, typed Python 3.11+, Pydantic v2, pytest, ruff, mypy.
- Use OpenAI Responses API Structured Outputs / strict JSON Schema so the model emits only ChartRecipe JSON, never executable code. Source: [OpenAI Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs?api-mode=chat), [Responses API](https://platform.openai.com/docs/api-reference/responses/object).
- Keep Origin runtime isolated to Windows worker because OriginLab documents external `originpro` as Windows-only and requiring local Origin 2021+. Source: [Origin external Python](https://docs.originlab.com/externalpython), [originpro docs](https://docs.originlab.com/python/documentation-for-originpro-package).

## Key Changes
Create the requested monorepo layout:
- `apps/api`: FastAPI API, auth dependency, upload handling, request IDs, static UI mount.
- `apps/worker`: Windows worker CLI with `run`, `dry-run`, `diagnose`, `capabilities`.
- `apps/web`: static production-alpha UI assets.
- `packages/*`: common utilities, auth, ChartRecipe schema, agent orchestrator, Origin adapter, quality checker, job store, templates, worker protocol.
- `examples`, `docs`, `tests`, `.github/workflows`, root project files.

Public interfaces:
- API endpoints: `POST /v1/jobs`, job/status/recipe/manifest/artifacts getters, `GET /v1/templates`, `POST /v1/recipes/validate`, `GET /health`, `GET /ready`.
- CLI commands: `origin-plot-worker`, `origin-plot-schema`, `origin-plot-recipe-validate`, `origin-plot-profile-dataset`.
- Core models: versioned `ChartRecipe`, `DatasetProfile`, `WorkerJobRequest`, `WorkerJobResult`, `ArtifactManifest`, `Artifact`, `WorkerCapabilities`, `WorkerError`, structured API errors.

## Implementation Details
Security and storage:
- Implement `OPAG_API_KEYS` local auth with hashed-key abstraction, tenant IDs, scopes, and no absolute filesystem paths in API responses.
- Filesystem job store uses tenant-separated directories, generated IDs, safe path joins, explicit status transitions, manifests, errors, and artifact registry.
- Uploads accept CSV only, enforce size limits, sanitize names, and store required audit artifacts.

Planning and recipes:
- ChartRecipe DSL supports line, scatter, bar, grouped_bar, error_bar, histogram, box, heatmap, multi_panel, overlay, dual_axis with chart-specific validation and human-readable errors.
- Dataset profiler safely reads CSV, infers numeric/categorical/date columns, samples rows, detects missing values, and suggests likely x/y columns.
- Multi-stage planner implements IntentParser, DatasetMapper, ChartDesigner, OriginCapabilityChecker, RecipeValidator, RepairAgent, ExplanationAgent.
- Planner uses OpenAI only when `OPENAI_API_KEY` exists; tests use deterministic fallback/mocks. Store `planner_trace.json` without secrets.

Origin and worker:
- Deterministic recipe-to-script generator creates `generated_script.py` from validated recipe only.
- Script imports `originpro`, creates/imports workbook data, builds graph, applies style/template/labels/legend/axes, exports formats, saves `.opju`, and logs progress.
- Worker validates job dirs, supports dry-run without Origin, detects unsupported OS/missing `originpro`, runs with timeout, captures stdout/stderr, and writes `run.log`, `status.json`, `manifest.json`, `quality_report.json`, and `error.json` on failure.
- Auto-repair attempts one safe repair after classified rendering failure, preserving original and repaired recipes/scripts.

Templates, UI, docs:
- Built-in templates: publication, thesis, presentation, minimal, dark, journal_bw.
- UI supports API key entry, CSV upload, prompt, template selection, submit, status, recipe/manifest preview, and artifact links.
- Documentation covers architecture, API, agent design, ChartRecipe, Origin automation, Windows worker setup, deployment, security, roadmap, troubleshooting.
- README uses formal status wording: `Status: Production Alpha`; avoid old positioning terms throughout source/docs.

## Test Plan
Required local verification:
- `pytest`
- `ruff check .`
- `mypy packages apps`
- `origin-plot-worker diagnose`
- `origin-plot-worker dry-run --job-dir <example job>`
- API import/start smoke test.

Test coverage:
- Auth: unauthorized, forbidden scope, authorized tenant access.
- Schema: valid/invalid recipes, columns, exports, dimensions, panels, error bars, dual-axis.
- Profiler: CSV inference, bad extension rejection, size limits, missing values.
- Job store: tenant isolation, path traversal rejection, status transitions, artifacts/errors.
- Origin adapter: script structure unit tests plus golden script comparisons for supported chart types.
- Worker: dry-run, diagnostics, missing-Origin behavior, unsupported platform messaging.
- API: job creation, validation endpoint, template listing, artifact path redaction.
- Origin integration tests marked `@pytest.mark.origin` and skipped unless `ORIGIN_AVAILABLE=1`.

## Commits, Push, And Assumptions
Commit sequence:
1. Scaffold packaging, layout, AGENTS.md, README, docs skeleton, CI, Makefile.
2. Implement schemas, templates, profiler, validation, examples, schema CLI.
3. Implement auth, job store, API, web UI, artifact responses.
4. Implement agent orchestrator, OpenAI structured-output integration, deterministic fallback.
5. Implement Origin adapter, worker protocol, worker CLI, quality checker, repair loop.
6. Add tests/golden fixtures, finish docs, run checks, fix failures, push `main`.

Assumptions:
- Use the existing remote `https://github.com/appleweiping/origin-plot-agent.git`; preserve its current `LICENSE`.
- Push succeeds if local GitHub credentials are already available; otherwise leave all commits local and report the auth blocker.
- Linux CI never installs or runs Origin; Windows Origin execution is documented and isolated in `apps/worker`.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
