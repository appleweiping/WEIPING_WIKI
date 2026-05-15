---
title: "Sandboxed Code Migration Agent"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - agents
  - agent-workflows
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/agents_sdk/sandboxed-code-migration/sandboxed_code_migration_agent
  - https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/sandboxed-code-migration/sandboxed_code_migration_agent.ipynb
---

# Sandboxed Code Migration Agent

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/agents_sdk/sandboxed-code-migration/sandboxed_code_migration_agent
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/sandboxed-code-migration/sandboxed_code_migration_agent.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/agents_sdk/sandboxed-code-migration/sandboxed_code_migration_agent.ipynb
- Source path: `examples/agents_sdk/sandboxed-code-migration/sandboxed_code_migration_agent.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `ab74e2b0c6b0e3fdd27d95048f44852541580cb129faf3c6e2daf399fe1e49fb`

## Classification

- Primary category: Agents SDK / agent workflows
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Migrate a Legacy Codebase with Sandbox Agents Code modernization never really ends. Outdated dependencies, security risks, compliance pressure, and legacy patterns keep accumulating across large codebases, and one massive migration PR is hard to review and risky to merge. A code-migration agent should work in a controlled environment, one scoped task at a ti...

## What This Teaches

- How to structure agent workflows, tool use, memory, evaluation, or multi-agent coordination.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Migrate a Legacy Codebase with Sandbox Agents

Code modernization never really ends. Outdated dependencies, security risks, compliance pressure, and legacy patterns keep accumulating across large codebases, and one massive migration PR is hard to review and risky to merge. A code-migration agent should work in a controlled environment, one scoped task at a time: inspect the relevant repo, edit files, run checks, and return a patch.

This cookbook uses the Agents SDK with the harness *outside* the sandbox: orchestration stays in the trusted host process, while shell commands and file edits run in isolated execution environments. This separation lets the host harness use secrets, tools, and external services while giving the sandbox only the files and commands needed for the task.

By the end of this cookbook, you'll be able to:

- Keep the agent harness outside the execution environment that runs shell commands and file edits
- Segment a modernization job into task-sized repo shards
- Validate each shard with tests, checks, artifacts, and an audit log
- Swap sandbox providers without rewriting the agent

The example is a two-service code migration. Each service runs in its own sandbox and returns its own patch bundle, the same shape you could use to open separate pull requests for review and CI. In each sandbox, the agent migrates an OpenAI client wrapper from [Chat Completions](https://platform.openai.com/docs/api-reference/chat) to the [Responses API](https://platform.openai.com/docs/api-reference/responses). Along the way it runs tests, patches the app and tests, runs a compile check, reruns tests, and returns a typed migration report with a patch.

We'll run the sandbox with Docker locally. Provider-specific code is isolated to sandbox creation, so the same harness and agent can point at hosted sandbox providers such as E2B or Cloudflare without changing the `SandboxAgent`, tools, manifest, or prompt.

## Architecture: sandbox as a tool

<img src="assets/sandbox-as-a-tool-architecture.svg" alt="Agents SDK harness running outside a swappable sandbox" width="900"/>

The trusted host process owns the Agents SDK harness, tools, MCP servers, credentials, policy, and audit. The execution environment receives only the scoped workspace for the current task and the sandbox-facing capabilities needed to run commands and edit files.

Another pattern is to launch a coding agent whose harness, agent loop, tools, and filesystem all live inside the sandbox. That can work, but it pushes orchestration and tool integration into the same environment that runs generated code.

In this pattern, the sandbox is something the harness calls when the agent needs a filesystem, terminal command, test run, or patch. The broader agent stack stays on the harness side.

Flow:

1. Your app receives a migration request and splits it into task-sized repo shards.
2. For each task, the host-side Agents SDK harness starts an agent and creates a fresh sandbox.
3. The harness stages that task's repo and migration brief into the sandbox.
4. The agent uses sandbox tools to inspect files, edit code, and run tests.
5. The host receives the task's report and patch, writes an audit log, deletes the sandbox, and moves to the next task.

## Requirements

- Python 3.10+
- Docker, running locally for the Docker sandbox example
- An OpenAI API key, exported as `OPENAI_API_KEY`
- The OpenAI Agents SDK with sandbox support
- Optional: hosted sandbox provider credentials, such as `E2B_API_KEY` for E2B or a Cloudflare Worker URL and API key for Cloudflare

Keep API keys in the host environment. Do not add them to the mounted repo or sandbox manifest.

## Install dependencies

Clone the cookbook and move into this example directory:

```bash
git clone https://github.com/openai/openai-cookbook.git
cd openai-cookbook/examples/agents_sdk/sandboxed-code-migration
```

Open `sandboxed_code_migration_agent.ipynb` from that directory and install the dependencies below. Start Docker before running the full agent demo.

```python
%pip install -r requirements.txt --quiet
```

## Import the host-side harness

Import the small host-side runner used by this example. It creates sandbox sessions, starts the agent loop, writes returned artifacts, records an audit log, and keeps provider credentials out of the mounted repo. The full file is included at [`src/run_migration_agent.py`](src/run_migration_agent.py); the notebook pulls the important pieces into the walkthrough below.

```python
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

from agents import ModelSettings
from agents.mcp import MCPServer
from agents.sandbox import Manifest, SandboxAgent
from agents.sandbox.capabilities import ApplyPatch, Shell
from agents.sandbox.entries import LocalDir, LocalFile

EXAMPLE_ROOT = Path.cwd()
sys.path.insert(0, str(EXAMPLE_ROOT))

from src.run_migration_agent import (
    AGENT_INSTRUCTIONS,
    DEFAULT_MIGRATION_TASKS,
    DEVELOPER_INSTRUCTIONS,
    MigrationResult,
    MigrationTask,
    OPENAI_RESPONSES_MIGRATION_DOC_URL,
    run_migration_campaign,
)

migration_tasks = list(DEFAULT_MIGRATION_TASKS)
task = migration_tasks[0]

print("Migration campaign:")
for migration_task in migration_tasks:
    print(f"- {migration_task.name}: {migration_task.repo_path}")
print(f"\nInspecting first task: {task.name}")
```

## 1. Define the migration tasks

This cookbook includes two small fixture repos in `repo_fixtures/`. If you run the notebook as-is, the host harness mounts each fixture repo into a fresh sandbox as `/workspace/repo` and asks the agent to follow that repo's `MIGRATION.md`.

The task list points each migration shard at a local repo:

```python
@dataclass(frozen=True)
class MigrationTask:
    name: str
    repo_path: Path

    @property
    def migration_brief_path(self) -> Path:
        return self.repo_path / "MIGRATION.md"

DEFAULT_MIGRATION_TASKS = (
    MigrationTask(
        name="support_reply_service",
        repo_path=EXAMPLE_ROOT / "repo_fixtures" / "support_reply_service",
    ),
    MigrationTask(
        name="case_summary_service",
        repo_path=EXAMPLE_ROOT / "repo_fixtures" / "case_summary_service",
    ),
)
```

To adapt this to your own codebase, replace the task's `repo_path` and edit its `MIGRATION.md`. The generic run prompt can stay the same because it tells the agent to follow the mounted repo's brief.

Inspect one task before the agent touches it: the migration brief, the OpenAI client wrapper, and the application call site.

```python
print(task.migration_brief_path.read_text())
```

Now inspect the two main code targets: the OpenAI client wrapper and the application call site that uses it.

```python
print((task.repo_path / "customer_support_bot" / "client.py").read_text())
```

```python
print((task.repo_path / "customer_support_bot" / "replies.py").read_text())
```

## 2. Verify the baseline before the agent edits anything

Before the agent edits a repo, run the same tests yourself. The agent will run this baseline test command inside that task's sandbox before it changes any files.

```python
baseline = subprocess.run(
    [sys.executable, "-m", "unittest", "discover", "-s", "tests", "-t", "."],
    cwd=task.repo_path,
    text=True,
    capture_output=True,
    check=False,
)
print(baseline.stdout)
print(baseline.stderr)
assert baseline.returncode == 0
```

```python
check = subprocess.run(
    [sys.executable, "-m", "compileall", "-q", "customer_support_bot", "tests"],
    cwd=task.repo_path,
    text=True,
    capture_output=True,
    check=False,
)
print(check.stdout)
print(check.stderr)
assert check.returncode == 0
```

## 3. Stage the sandbox workspace

The manifest is the sandbox boundary. It tells the sandbox client which host files to stage and where they should appear in the execution environment. Here, we copy the agent instructions and one task repo into `/workspace`.

For a real migration, stage only the target checkout, task instructions, and files required for that run. Keep credentials, customer storage, and memory in the host harness. The helper below stays small for that reason: it stages only the shared agent instructions and the repo for the current migration task.

```python
def build_manifest(task: MigrationTask | None = None) -> Manifest:
    task = task or DEFAULT_MIGRATION_TASKS[0]
    return Manifest(
        root="/workspace",
        entries={
            "migration_agent/AGENTS.md": LocalFile(
                src=EXAMPLE_ROOT / "migration_agent" / "AGENTS.md"
            ),
            "repo": LocalDir(src=task.repo_path),
        },
    )

manifest = build_manifest(task)
print(f"manifest root: {manifest.root}")
for workspace_path in manifest.entries:
    print(workspace_path)
```

## 4. Define the sandbox agent

The agent gets two sandbox-facing capabilities: `Shell()` for terminal work and `ApplyPatch()` for file edits. Everything else in the definition stays with the host harness: instructions, model settings, MCP servers, and the typed output contract.

```python
def build_agent(
    *,
    model: str,
    manifest: Manifest,
    mcp_servers: list[MCPServer] | None = None,
) -> SandboxAgent:
    return SandboxAgent(
        name="Code Migration Agent",
        model=model,
        instructions=AGENT_INSTRUCTIONS,
        developer_instructions=DEVELOPER_INSTRUCTIONS,
        default_manifest=manifest,
        capabilities=[Shell(), ApplyPatch()],
        mcp_servers=list(mcp_servers or []),
        model_settings=ModelSettings(tool_choice="required"),
        output_type=MigrationResult,
    )

agent = build_agent(model="gpt-5.4", manifest=manifest)
print(agent.name)
print([capability.type for capability in agent.capabilities])
print(agent.output_type)
```

### Optional: connect a host-side MCP server

Because the harness runs outside the sandbox, it can connect MCP servers from the trusted host process. The sandbox does not need MCP credentials or broad network access.

This runner can optionally connect the public OpenAI docs MCP from the host harness. The agent can use that docs context while shell commands and patches still run in the sandbox.

Keep this deterministic for migrations. Fetch the approved migration guide instead of asking the agent to search the docs during every run.

```python
OPTIONAL_OPENAI_DOCS_MCP_URL = "https://developers.openai.com/mcp"

print("Optional host-side MCP:")
print(f"  server: {OPTIONAL_OPENAI_DOCS_MCP_URL}")
print(f"  pinned doc: {OPENAI_RESPONSES_MIGRATION_DOC_URL}")
print("To opt in for the full run, set this before the agent cell:")
print(f'  os.environ["OPENAI_DOCS_MCP_URL"] = "{OPTIONAL_OPENAI_DOCS_MCP_URL}"')
```

## 5. Run the migration campaign

The full run is a host-side loop over migration tasks. For each task, the harness builds the manifest and agent, creates a fresh sandbox session, and passes that session into `Runner.run_streamed`. After the task finishes, the host writes the returned patch bundle under `outputs/<task_name>/` and deletes the sandbox before starting the next task.

```python
manifest = build_manifest(task)
agent = build_agent(model=model, manifest=manifest, mcp_servers=mcp_servers)
client, session = await create_sandbox(backend, manifest, docker_image=docker_image)

try:
    async with session:
        result = Runner.run_streamed(
            agent,
            [{"role": "user", "content": f"Task name: {task.name}\n\n{prompt}"}],
            max_turns=30,
            run_config=RunConfig(
                sandbox=SandboxRunConfig(session=session),
                workflow_name=f"Sandboxed code migration: {task.name} ({backend})",
                tracing_disabled=not enable_hosted_tracing,
            ),
        )
        async for event in result.stream_events():
            if event.type == "run_item_stream_event" and event.name in {"tool_called", "tool_output"}:
                append_audit_event(audit_log_path, {"event": event.name})
finally:
    await client.delete(session)
```

The snippet above is the core of `run_migration_task`; the runnable cell below calls the full helper. The run is guarded so the notebook can execute without calling the model. Change `RUN_FULL_AGENT_DEMO` to `True` when you want to run the Docker-backed migration end to end.

```python
RUN_FULL_AGENT_DEMO = False
enable_hosted_tracing = False

# Optional: uncomment to let the host harness fetch the pinned Responses migration guide.
# os.environ["OPENAI_DOCS_MCP_URL"] = "https://developers.openai.com/mcp"

if RUN_FULL_AGENT_DEMO:
    campaign = await run_migration_campaign(
        tasks=migration_tasks,
        backend=os.getenv("SANDBOX_BACKEND", "docker"),
        model=os.getenv("OPENAI_MODEL", "gpt-5.4"),
        prompt=(
            "Migrate the mounted repo from Chat Completions to the Responses API. "
            "Follow migration_agent/AGENTS.md and repo/MIGRATION.md. "
            "Run the required baseline tests, patch the app and tests, "
            "run the check command, run the final tests, produce a diff, "
            "and return the structured migration result."
        ),
        docker_image=os.getenv("SANDBOX_DOCKER_IMAGE", "python:3.14-slim"),
        output_root=EXAMPLE_ROOT / "outputs",
        enable_hosted_tracing=enable_hosted_tracing,
    )
    for summary in campaign.task_summaries:
        print(f"{summary.task_name}: {summary.patch_path}")
else:
    print("Skipped. Set RUN_FULL_AGENT_DEMO=True to run the Docker-backed campaign.")
```

## 6. Inspect returned artifacts

The host runner writes each task's typed result to disk. The sandboxes can disappear after the run; each task's report, patch, JSON result, and audit log remain in `outputs/<task_name>/`, with a campaign summary at `outputs/batch_summary.json`.

```python
artifact_names = [
    "migration_report.md",
    "migration.patch",
    "migration_result.json",
    "migration_audit.jsonl",
]

for migration_task in migration_tasks:
    print(f"\n=== {migration_task.name} ===")
    task_output_dir = EXAMPLE_ROOT / "outputs" / migration_task.name
    for artifact_name in artifact_names:
        path = task_output_dir / artifact_name
        if path.exists():
            print(f"\n--- {path.name} ---")
            print(path.read_text()[:3000])
        else:
            print(f"not generated yet: {path}")
```

### Optional: validate the generated artifacts

The host can check each returned patch, typed result, and audit log before showing a patch to a user or applying it to a real repo. This eval is deterministic: it reads the campaign outputs and fails if any task did not produce the expected contract.

```python
if (EXAMPLE_ROOT / "outputs" / "batch_summary.json").exists():
    subprocess.run([sys.executable, "evals.py"], cwd=EXAMPLE_ROOT, check=True)
else:
    print("Skipped. Run the full agent demo before running artifact evals.")
```

## 7. Optional: swap sandbox providers

This section shows three sandbox backends: Docker for local runs, E2B for a hosted sandbox, and Cloudflare for a hosted worker-backed sandbox. The pattern is the same: change the sandbox client, not the agent.

Docker:

```python
client = DockerSandboxClient(docker.from_env())
session = await client.create(
    manifest=manifest,
    options=DockerSandboxClientOptions(image="python:3.14-slim"),
)
```

E2B:

```python
client = E2BSandboxClient()
session = await client.create(
    manifest=manifest,
    options=E2BSandboxClientOptions(
        sandbox_type=E2BSandboxType.E2B,
    ),
)
```

Run E2B from the CLI:

```bash
export E2B_API_KEY="..."
python src/run_migration_agent.py --backend e2b
```

Cloudflare:

```python
client = CloudflareSandboxClient()
session = await client.create(
    manifest=manifest,
    options=CloudflareSandboxClientOptions(
        worker_url=os.environ["CLOUDFLARE_SANDBOX_WORKER_URL"],
        api_key=os.environ.get("CLOUDFLARE_SANDBOX_API_KEY"),
    ),
)
```

Run Cloudflare from the CLI:

```bash
export CLOUDFLARE_SANDBOX_WORKER_URL="https://..."
export CLOUDFLARE_SANDBOX_API_KEY="..."
python src/run_migration_agent.py --backend cloudflare
```

Run Docker from the CLI:

```bash
python src/run_migration_agent.py --backend docker
```

## Production notes

Production code should keep orchestration, execution, data access, and returned outputs behind separate trust boundaries. Treat each migration task as its own unit of review.

| Boundary | Production pattern |
| --- | --- |
| Harness | Keep orchestration, tools, credentials, policy, and audit on the host. |
| Sandbox | Stage only the task workspace. Run commands and edits there. Tear it down after the task. |
| Data access | Route customer storage and network access through the host, not directly through the sandbox. |
| Output | Validate sandbox output in the host before showing it to users or applying changes. |

## Tracing and ZDR

This example disables hosted tracing per run with `RunConfig.tracing_disabled=True`. To opt in while running this cookbook's CLI, pass `--enable-hosted-tracing`. The Agents SDK also supports the global `OPENAI_AGENTS_DISABLE_TRACING=1` environment variable when you want tracing disabled process-wide.

## Next steps

To adapt this pattern, replace `migration_tasks` with your own repos, packages, or services. Give each task one checkout and one `MIGRATION.md`. Keep the validation commands explicit, and return a patch for review instead of applying host-side changes automatically. Add deterministic evals that check the migration contract, not just whether the test suite passes.

When the job spans many packages, such as a Jest-to-Vitest migration, the host harness can use repo metadata or a manager agent to plan shards. Each shard should produce the same thing this cookbook produces: a validated patch, report, and audit trail from an isolated sandbox.
