---
title: "Readme"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - agents
  - agent-workflows
  - cookbook
  - example
  - markdown-source
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/agents_sdk/deployment_manager/readme
  - https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/deployment_manager/README.md
---

# Readme

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/agents_sdk/deployment_manager/readme
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/deployment_manager/README.md
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/agents_sdk/deployment_manager/README.md
- Source path: `examples/agents_sdk/deployment_manager/README.md`
- Source kind: `examples`
- Source format: `.md`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `5d09fafe36424f07215c147150514633ea912bbbe22d7b44e1fb60542805b5a8`

## Classification

- Primary category: Agents SDK / agent workflows
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Agents SDK Deployment Manager Local control-plane app for running and observing Agents SDK demo projects. Prerequisites - uv - npm - Docker, when using the default local-docker target Run Open: Vite builds the React UI from frontend/ into dist/ , and the Flask backend serves dist/ plus /api/ . Screenshots Deployments !$1 App details !$1 Traces !$1 Scope - Im...

## What This Teaches

- How to structure agent workflows, tool use, memory, evaluation, or multi-agent coordination.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Agents SDK Deployment Manager

Local control-plane app for running and observing Agents SDK demo projects.

## Prerequisites

- `uv`
- `npm`
- Docker, when using the default `local-docker` target

## Run

```bash
make run
```

Open:

```text
http://127.0.0.1:8732
```

Vite builds the React UI from `frontend/` into `dist/`, and the Flask backend
serves `dist/` plus `/api/*`.

## Screenshots

### Deployments

![Deployments](docs/screenshots/deployments.png)

### App details

![App details](docs/screenshots/app-details.png)

### Traces

![Traces](docs/screenshots/traces.png)

## Scope

- Import a local Agents SDK project.
- Inspect entrypoints, dependencies, env vars, and sandbox usage.
- Create a local deployment record.
- Start and stop the app/orchestrator as a labeled Docker container by default.
- Generate or reuse an app-level Dockerfile for containerized deployment.
- Show deployment logs, traces, app events, and Docker container activity.
- Label sandbox containers with `agents-sdk.*` metadata so the manager can map a
  Docker container back to its deployment and run.

For Docker deployments, the default target builds an app Dockerfile and runs the
orchestrator with:

```bash
docker run -p 127.0.0.1:<app-port>:<app-port> -v /var/run/docker.sock:/var/run/docker.sock ...
```

The Docker socket mount lets `SandboxAgent` create sandbox containers through Docker.

The manager sets `AGENTS_SDK_MANAGER`, `AGENTS_SDK_PROJECT`,
`AGENTS_SDK_DEPLOYMENT_DATA_DIR`, and `AGENTS_SDK_MANAGER_TRACE_ENDPOINT` on the
app process. Trace capture is posted back to the manager and stored in the
manager-owned SQLite database.

## Deployable App Contract

Apps deployed through this manager should have:

- `pyproject.toml` with `openai-agents` in the dependencies.
- `main.py` as the app entrypoint.
- `PORT` support for local startup.
- `uv run python main.py` starting the HTTP service when `PORT` is set.
- A `/health` readiness endpoint.

Keep CLI-only smoke behavior behind explicit arguments or the no-`PORT` path so
the generated Dockerfile can start the service reliably.

## Tracing

Tracing is captured locally through the manager's HTTP ingestion endpoint while
the Agents SDK still streams traces to the OpenAI Platform through its default
processor.

When the manager starts an app it adds `runtime/trace_capture` to `PYTHONPATH`
and sets:

```text
AGENTS_SDK_MANAGER_TRACE_ENDPOINT=http://<manager-host>:8732/api/traces/ingest
AGENTS_SDK_DEPLOYMENT_ID=<deployment-id>
AGENTS_SDK_PROJECT_ID=<project-id>
```

For local-process deployments `<manager-host>` is `127.0.0.1`. For Docker
deployments it is `host.docker.internal` so the container can reach the manager
running on the host.

The runtime package uses `sitecustomize.py` to install a lightweight Agents SDK
trace processor inside the app process with `add_trace_processor()`. That adds a
second local destination without replacing the SDK's default OpenAI Platform
exporter. The local processor posts exported trace records to the manager:

- `trace_start`
- `trace_end`
- `span_start`
- `span_end`

The manager stores traces in `state/traces.sqlite3`. The backend reads that
SQLite store in `app/timeline.py`, groups records by `trace_id`, derives the run
key from trace metadata (`expense_id`, `run_id`, or `session_id`), then falls
back to `group_id` and finally the `trace_id`. The UI uses those reconstructed
records for the Traces view, nested span list, event detail pane, trace deep
links via `?trace_id=...`, and JSON export.

This means local tracing keeps working without bind-mounting trace files into app
containers and without fetching spans from the OpenAI Platform dashboard API.

## Make Targets

```bash
make start
make health
make deploy PROJECT_PATH=/path/to/agents-sdk-app APP_PORT=8421 SANDBOX_BACKEND=docker
make deploy PROJECT_PATH=/path/to/agents-sdk-app APP_PORT=8421 TARGET=local-process
make stop
```
