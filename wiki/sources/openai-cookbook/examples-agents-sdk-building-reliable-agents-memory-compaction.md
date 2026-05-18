---
title: "Building Reliable Agents Memory Compaction"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - agent-workflows
  - agents
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/agents_sdk/building_reliable_agents_memory_compaction
  - https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/building_reliable_agents_memory_compaction.ipynb
---

# Building Reliable Agents Memory Compaction

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/agents_sdk/building_reliable_agents_memory_compaction
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/agents_sdk/building_reliable_agents_memory_compaction.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/agents_sdk/building_reliable_agents_memory_compaction.ipynb
- Source path: `examples/agents_sdk/building_reliable_agents_memory_compaction.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `9f63b4b1d50deec42fa9ddaa12c923b592f22722e381832a60cb9851a34de4d6`

## Classification

- Primary category: Agents SDK / agent workflows
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Building Reliable Agents with Memory and Compaction This Cookbook shows how to build an evidence review agent for a synthetic compliance investigation using the OpenAI Agents SDK. You will start with a simple sandbox agent, then add two reliability primitives: - Compaction lets you support long-running conversations despite finite context windows by carrying...

## What This Teaches

- How to structure agent workflows, tool use, memory, evaluation, or multi-agent coordination.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Building Reliable Agents with Memory and Compaction

This Cookbook shows how to build an evidence review agent for a synthetic compliance investigation using the OpenAI Agents SDK.

You will start with a simple sandbox agent, then add two reliability primitives:

- **Compaction** lets you support long-running conversations despite finite context windows by carrying forward the state needed for later turns while reducing context size.
- **Memory** lets future sandbox-agent runs reuse workflow lessons from prior runs without replaying every previous turn.

The reliability pattern is straightforward: compaction helps the current run continue, memory helps later runs start with useful workflow guidance, and the generated memo remains the human-reviewed source of truth for the investigation.

References:

- [OpenAI Agents SDK](https://openai.github.io/openai-agents-python/)
- [Agents SDK sessions](https://openai.github.io/openai-agents-python/sessions/)
- [Agents SDK sandboxing](https://openai.github.io/openai-agents-python/ref/sandbox/)

## Use Case: Evidence Review Agent for a Compliance Investigation

A compliance team is investigating whether a vendor exception followed internal policy. The evidence arrives as a small set of files: policy language, exception notes, audit observations, approval records, and remediation plans.

The agent's job is not to become the investigation record. Its job is to help a reviewer move through the evidence, keep track of what changed, and write a concise memo that separates supported findings from open questions.

This makes the example useful for memory and compaction because the investigation has three traits that show up in real work:

- **The record changes over time.** Later documents may narrow or supersede an earlier assumption.
- **The conversation can become long-running.** A reviewer may ask follow-up questions, request revisions, and return to the same work later.
- **The final artifact needs provenance.** The memo should cite evidence and preserve uncertainty instead of flattening the review into a confident but unsupported conclusion.

## Where This Pattern Applies

Although this notebook uses a compliance review, the same pattern applies anywhere knowledge workers review evolving context and produce a human-auditable artifact.

Good fits include:

- Customer support teams applying new policy updates to open escalations.
- Security teams reviewing incident evidence and writing incident summaries.
- Finance teams reconciling exceptions across policies, approvals, and audit notes.
- Product teams updating competitive positioning after new launches or model releases.
- Legal or procurement teams reviewing contracts, emails, and approval histories.
- M&A teams absorbing new business rules, operating procedures, and diligence notes.

In each case, compaction keeps the active review viable as context grows, memory carries reusable workflow lessons forward, and the final artifact remains the reviewed output.

## What You'll Build

The use case is a compliance evidence review. A team receives policy documents, exception notes, audit findings, approvals, and remediation plans over time. The agent helps review the evidence, preserve uncertainty, and produce a concise memo with citations.

You will build:

1. A synthetic evidence workspace with a folder structure, manifest, and output directory.
2. A simple `SandboxAgent` that can inspect files and write a memo.
3. A compaction checkpoint for long-running work.
4. SDK memory generation for reusable workflow lessons.
5. A combined run that uses sandbox tools, compaction, memory, and generated artifacts together.

You can inspect the notebook without making model calls because `RUN_AGENT` defaults to `False`. Set `RUN_AGENT = True` only when you want to execute the live sandbox workflow.

### Table of Contents

- [Use Case](#use-case-evidence-review-agent-for-a-compliance-investigation)
- [Where This Pattern Applies](#where-this-pattern-applies)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Using Agents SDK in This Notebook](#using-agents-sdk-in-this-notebook)
- [Memory vs. Compaction](#memory-vs-compaction)
- [Folder Structure and Manifest](#folder-structure-and-manifest)
- [Prepare a Small Evidence Workspace](#prepare-a-small-evidence-workspace)
- [Step 1: Start With a Simple Agent Configuration](#step-1-start-with-a-simple-agent-configuration)
- [Step 2: Add Compaction](#step-2-add-compaction)
- [Step 3: Attach Memory](#step-3-attach-memory)
- [Step 4: Run With Both Compaction and Memory](#step-4-run-with-both-compaction-and-memory)
- [Inspect Generated Artifacts](#inspect-generated-artifacts)

## Prerequisites

To run the live agent workflow, you need:

- Python 3.10 or later.
- The `openai-agents` package.
- An OpenAI API key available as `OPENAI_API_KEY`.
- A local Unix-like environment for `UnixLocalSandboxClient`. The notebook uses synthetic files created from the sandbox `Manifest`, so no external dataset is required.

The notebook is safe to inspect without credentials because `RUN_AGENT` defaults to `False`. Set `RUN_AGENT = True` only when you want to execute the model-backed sandbox run.

```python
# Install or upgrade the OpenAI Agents SDK.
%pip install --upgrade openai-agents
```

## Setup

The notebook writes all synthetic files under `examples/agents_sdk/.tmp/evidence_review_memory_compaction/`. It does not require external data.

By default, tracing is disabled because some organizations use Zero Data Retention (ZDR), where trace ingestion may be blocked. For synthetic data or non-ZDR environments, you can set `ENABLE_TRACING = True` to inspect traces while developing.

```python
from __future__ import annotations

import json
import os
import textwrap
from pathlib import Path

RUN_AGENT = False
MODEL = "gpt-5.5"
COMPACTION_MODEL = "gpt-5.4-mini"
WORKFLOW_NAME = "evidence-review-memory-compaction"
FORCE_COMPACTION_CHECKPOINT = True
DISABLE_TRACING = True

if DISABLE_TRACING:
    os.environ["OPENAI_AGENTS_DISABLE_TRACING"] = "true"
else:
    os.environ.pop("OPENAI_AGENTS_DISABLE_TRACING", None)

if RUN_AGENT and not os.environ.get("OPENAI_API_KEY"):
    raise RuntimeError("Set OPENAI_API_KEY before running the live sandbox workflow.")

print({
    "run_agent": RUN_AGENT,
    "model": MODEL,
    "compaction_model": COMPACTION_MODEL,
    "force_compaction_checkpoint": FORCE_COMPACTION_CHECKPOINT,
    "tracing_disabled": DISABLE_TRACING,
})
```

## Using Agents SDK in This Notebook

A **sandbox agent** is an Agents SDK agent that runs with a controlled workspace. In this notebook, that workspace contains synthetic evidence files, a `manifest.csv`, an output folder, and SDK-generated memory files.

The sandbox gives the agent a bounded place to inspect files and write artifacts. Instead of pasting every document into the prompt, the application creates a workspace and lets the agent use capabilities such as:

- `Filesystem()` to read and write workspace files.
- `Shell()` to list files, inspect documents, and search across batches.
- `Compaction()` to support long-running reviews when the active context grows.
- `Memory()` to store reusable workflow lessons for future sandbox-agent runs.

The memo remains the human-reviewed artifact. Tools help the agent work, compaction helps it continue, memory helps future runs improve, and generated artifacts hold the reviewable output.

## Memory vs. Compaction

A useful way to separate the concepts is to ask what each one is allowed to carry forward.

| Question | Compaction | Memory |
|---|---|---|
| What does it help with? | Continuing one long-running run when context grows. | Improving future runs with reusable workflow lessons. |
| What does it summarize? | The active conversation and working state. | Patterns, preferences, and process lessons worth reusing. |
| Should it store investigation conclusions? | No. It can preserve working state, but the memo is the reviewed artifact. | No. Store workflow lessons, not case-specific facts. |
| When is it useful? | Mid-review, especially before later batches or follow-up turns. | Across repeated reviews of similar evidence workflows. |

For this notebook, the compliance memo is the source of truth for the investigation output. Memory is intentionally scoped to reviewer preferences and workflow habits, such as using the manifest first, preserving uncertainty, and keeping superseded assumptions visible.

## Folder Structure and Manifest

The agent works from a small file workspace. The folder structure is simple on purpose: evidence files are grouped by batch, generated outputs go under `outputs/`, and the manifest gives the agent a compact map of the available documents.

### The Manifest Feature

In the Agents SDK, a `Manifest` is the fresh-session workspace contract for a sandbox agent. It describes the files, directories, mounts, environment, users, groups, and related workspace configuration that should exist when a new sandbox session starts.

The local SDK implementation defines these core fields:

| Manifest field | What it controls | How to use it in this Cookbook |
|---|---|---|
| `root` | Workspace root path. Defaults to `/workspace`. | Keep the default unless a sandbox provider expects a different root. |
| `entries` | Files, directories, local files, local directories, repos, or mounts to materialize. | Put `README.md`, `manifest.csv`, input documents, and `outputs/` here. |
| `environment` | Environment variables available when the sandbox starts. | Use only for non-secret runtime configuration. Keep credentials out of prompts and committed notebooks. |
| `users` / `groups` | Sandbox-local OS accounts and groups for providers that support them. | Usually unnecessary for a Cookbook, useful for production isolation. |
| `extra_path_grants` | Additional path grants, especially useful for Unix-local workflows. | Use sparingly when a sandbox needs scoped read/write access to host paths. |
| `remote_mount_command_allowlist` | Commands allowed against remote mounts. | Keep narrow when mounting external storage or data rooms. |

Manifest entry paths should be workspace-relative. Avoid absolute paths and `..` escapes so the same agent can move between Unix-local, Docker, and hosted sandbox providers.

### Folder and Manifest Best Practices

- Put source documents, manifests, helper files, and output directories in the `Manifest` instead of pasting large content into the prompt.
- Put longer task instructions in workspace files such as `README.md`, `task.md`, or `AGENTS.md`; keep agent instructions focused on behavior and boundaries.
- Use stable document IDs and a machine-readable manifest file so generated memos can cite sources and reviewers can inspect the path back to evidence.
- Let `Memory()` manage its own memory artifacts. By default, sandbox memory uses `memories/` and `sessions/` under the workspace.
- Keep generated artifacts under `outputs/` so the application can inspect, copy, validate, or archive them after the run.
- Keep mount scopes narrow. If you mount a data room, mount only what the agent should read or write.
- Treat secrets as runtime configuration injected by your application or sandbox provider, not as prompt text or committed manifest content.
- Prefer a small synthetic `File(...)` or `Dir(...)` entry for a tutorial, then switch to `LocalDir`, `GitRepo`, or storage mounts for production-sized datasets.

```python
# This is a visual preview of the sandbox workspace structure.
# The next cell builds the actual Manifest entries manually.
WORKSPACE_TREE = """
/workspace/
  README.md
  manifest.csv
  docs/
    batch_1/
    batch_2/
    batch_3/
  outputs/
  memories/    # Generated by Memory()
  sessions/    # Generated by Memory()
""".strip()

print(WORKSPACE_TREE)
```

## Prepare a Small Evidence Workspace

A `Manifest` describes the starting files in a fresh sandbox workspace. For this tutorial, the workspace includes:

- a `manifest.csv` listing documents by batch and document ID,
- three small document batches,
- an output directory for the review memo.

The only memory primitive we attach later is the SDK's `Memory()` capability. Investigation findings stay in the generated reviewer memo, where they can be cited and inspected.

```python
from agents.sandbox import Manifest
from agents.sandbox.entries import Dir, File


def workspace_file(text: str) -> File:
    return File(content=textwrap.dedent(text).strip().encode("utf-8") + b"\n")


def build_evidence_manifest() -> Manifest:
    return Manifest(
        entries={
            "README.md": workspace_file(
                """
                # Evidence Review Workspace

                Review the documents in batch order. Cite document IDs from
                `manifest.csv` when making findings. Write the final memo to
                `outputs/compliance_review_memo.md`.
                """
            ),
            "manifest.csv": workspace_file(
                """
                doc_id,batch,path,description
                ACME-B1-001,1,docs/batch_1/payment_policy.txt,Baseline payment policy
                ACME-B1-002,1,docs/batch_1/vendor_exception.txt,Vendor exception note
                ACME-B2-001,2,docs/batch_2/audit_followup.txt,Audit follow-up request
                ACME-B2-002,2,docs/batch_2/approval_thread.txt,Approval clarification
                ACME-B3-001,3,docs/batch_3/remediation_plan.txt,Remediation plan
                """
            ),
            "docs/batch_1/payment_policy.txt": workspace_file(
                """
                doc_id: ACME-B1-001
                ACME requires two approvals for payments over $50,000. Exceptions must
                be logged with Finance Ops and reviewed within five business days.
                """
            ),
            "docs/batch_1/vendor_exception.txt": workspace_file(
                """
                doc_id: ACME-B1-002
                A vendor onboarding exception was approved verbally for Northwind
                Logistics because the renewal was time-sensitive. The note does not show
                a Finance Ops log entry.
                """
            ),
            "docs/batch_2/audit_followup.txt": workspace_file(
                """
                doc_id: ACME-B2-001
                Internal Audit asked Finance Ops to confirm whether Northwind Logistics
                received post-approval review. The request says missing exception logs
                should be treated as a control gap until resolved.
                """
            ),
            "docs/batch_2/approval_thread.txt": workspace_file(
                """
                doc_id: ACME-B2-002
                The approval thread says Legal approved the vendor exception, but Finance
                Ops approval was still pending when the payment was released.
                """
            ),
            "docs/batch_3/remediation_plan.txt": workspace_file(
                """
                doc_id: ACME-B3-001
                The remediation plan requires Finance Ops to reconcile all verbal vendor
                exceptions from Q4 and add retrospective control attestations.
                """
            ),
            "outputs": Dir(),
        }
    )


manifest = build_evidence_manifest()
print(f"Workspace entries: {len(manifest.entries)}")
```

## Step 1: Start With a Simple Agent Configuration

First, build the agent without memory or compaction. The goal is to make the baseline behavior clear before adding primitives.

One subtle point: `SandboxAgent` defaults can include built-in capabilities. To keep this baseline explicit, pass the exact capability list you want. Here we include only the workspace tools the agent needs to inspect files and write an artifact: `Filesystem()` and `Shell()`. We intentionally do **not** attach `Compaction()` or `Memory()` yet.

- `Filesystem()` gives the sandbox agent file-oriented workspace access so it can read staged evidence and write the memo artifact. In the [Sandbox Agents guide](https://developers.openai.com/api/docs/guides/agents/sandboxes#give-the-agent-capabilities), capabilities are described as the way to attach sandbox-native behavior and tools to a `SandboxAgent`
- `Shell()` lets the agent inspect the workspace with terminal commands such as listing files, opening evidence documents, and searching for terms across batches. The Sandbox Agents guide notes that `Shell()` is one of the default capabilities, and the [Shell tool guide](https://developers.openai.com/api/docs/guides/tools-shell) explains that shell gives models a terminal environment for hosted or local execution.
- For this baseline, these two capabilities are enough: `Filesystem()` handles workspace reads and writes, while `Shell()` handles deterministic inspection and search. Memory and compaction are added only after the baseline harness is clear.

```python
from agents.sandbox import SandboxAgent
from agents.sandbox.capabilities import Filesystem, Shell

BASELINE_INSTRUCTIONS = """
You are an evidence review agent for a compliance investigation.

Review documents in batch order. Keep these boundaries clear:
- Cite document IDs from `manifest.csv` for each finding.
- If evidence is incomplete, record an open question instead of guessing.
- Write a concise reviewer memo to `outputs/compliance_review_memo.md`.
- Use the generated memo as the reviewer-facing investigation artifact.
""".strip()


def build_baseline_agent() -> SandboxAgent:
    return SandboxAgent(
        name="Evidence Review Agent",
        model=MODEL,
        instructions=BASELINE_INSTRUCTIONS,
        default_manifest=build_evidence_manifest(),
        capabilities=[
            Filesystem(),
            Shell(),
        ],
    )


baseline_agent = build_baseline_agent()
print([type(capability).__name__ for capability in baseline_agent.capabilities])
```

```python
from agents import Runner
from agents.run import RunConfig
from agents.sandbox import SandboxRunConfig
from agents.sandbox.sandboxes.unix_local import UnixLocalSandboxClient

BASELINE_TASK = """
Review Batch 1 only, then draft `outputs/compliance_review_memo.md` for a
compliance reviewer. Include cited findings and open questions.
""".strip()


async def _read_text_file(session, path: str) -> str | None:
    try:
        handle = await session.read(Path(path))
    except Exception as exc:
        if "NotFound" not in type(exc).__name__:
            raise
        return None
    try:
        return handle.read().decode("utf-8", errors="replace")
    finally:
        handle.close()


async def _list_workspace_files(session) -> str:
    result = await session.exec(
        "find outputs memories sessions -maxdepth 4 -type f 2>/dev/null | sort || true",
        timeout=30,
    )
    return result.stdout.decode("utf-8", errors="replace").strip()


async def _read_memory_artifacts(session) -> dict[str, str]:
    memory_artifacts = {}
    for path in ["memories/MEMORY.md", "memories/memory_summary.md"]:
        text = await _read_text_file(session, path)
        if text:
            memory_artifacts[path] = text
    return memory_artifacts


async def run_in_unix_sandbox(agent: SandboxAgent, task: str, *, sdk_session=None) -> dict[str, object]:
    client = UnixLocalSandboxClient()
    session = await client.create(manifest=agent.default_manifest)
    try:
        await session.start()
        result = await Runner.run(
            agent,
            task,
            max_turns=12,
            run_config=RunConfig(
                sandbox=SandboxRunConfig(session=session),
                workflow_name=WORKFLOW_NAME,
                tracing_disabled=DISABLE_TRACING,
            ),
            session=sdk_session,
        )

        compaction_checkpoint = None
        if sdk_session is not None and FORCE_COMPACTION_CHECKPOINT:
            compaction_checkpoint = await force_compaction_checkpoint(sdk_session)

        # Memory generation runs as a sandbox pre-stop hook. Flush it before reading artifacts
        # so `memories/MEMORY.md` and `memories/memory_summary.md` are available here.
        await session.run_pre_stop_hooks()

        memo = await _read_text_file(session, "outputs/compliance_review_memo.md")
        files = await _list_workspace_files(session)
        memory_artifacts = await _read_memory_artifacts(session)

        return {
            "result": result,
            "final_output": str(result.final_output),
            "memo": memo,
            "workspace_files": files,
            "memory_artifacts": memory_artifacts,
            "compaction_checkpoint": compaction_checkpoint,
        }
    finally:
        await session.aclose()


if RUN_AGENT:
    baseline_run = await run_in_unix_sandbox(baseline_agent, BASELINE_TASK)
    print(baseline_run["final_output"])
    print("\n----- END AGENT OUTPUT -----")
else:
    print("RUN_AGENT is False. Baseline agent is configured but not executed.")
```

## Step 2: Add Compaction

Compaction is for long-running work. As a conversation grows, compaction reduces context size while preserving the state needed for later turns. There are three useful ways to think about it:

1. **Automatic compaction with `Compaction()`**: attach the capability and let the SDK compact when context pressure requires it.
2. **Threshold-based compaction with `StaticCompactionPolicy`**: set an explicit threshold for environments where you want more predictable context-size behavior.
3. **Forced checkpoint compaction with `OpenAIResponsesCompactionSession.run_compaction({"force": True})`**: compact at an application-defined phase boundary, such as after a major review phase and before the next evidence batch.

This notebook uses a forced checkpoint because the synthetic dataset is intentionally small. In production, automatic compaction is often the simplest starting point, and threshold-based compaction is useful when you want a tighter operational policy.

> **Best practices**
>
> - Compact at meaningful workflow boundaries, not after every turn.
> - Preserve enough working state for the next phase to make sense.
> - Keep cited facts in generated artifacts, not only in compacted conversation state.

```python
from agents.sandbox.capabilities import Compaction, StaticCompactionPolicy


def build_compaction_agent(*, demo_threshold: int | None = None) -> SandboxAgent:
    if demo_threshold is None:
        compaction = Compaction()
    else:
        compaction = Compaction(policy=StaticCompactionPolicy(threshold=demo_threshold))

    return SandboxAgent(
        name="Evidence Review Agent with Compaction",
        model=MODEL,
        instructions=(
            BASELINE_INSTRUCTIONS
            + "\n\nWhen context is compacted, preserve the current batch, cited facts, open "
            "questions, artifact paths, and unresolved reviewer concerns."
        ),
        default_manifest=build_evidence_manifest(),
        capabilities=[
            Filesystem(),
            Shell(),
            compaction,
        ],
    )


compaction_agent = build_compaction_agent()
threshold_compaction_agent = build_compaction_agent(demo_threshold=8_000)
print({
    "automatic": [type(capability).__name__ for capability in compaction_agent.capabilities],
    "threshold_policy": [type(capability).__name__ for capability in threshold_compaction_agent.capabilities],
})
```

### How Compaction Gets Triggered

With the `Compaction()` capability, server-side compaction is eligible to run when the active context grows large enough. That is the current default behavior: attach the capability and let the SDK manage context pressure.

For small tutorials, automatic compaction can be hard to see because the run may never get close to the model context limit. A lower `StaticCompactionPolicy` can help, but it still depends on the rendered context crossing the threshold.

For a small evidence set, a forced checkpoint is the clearest operational pattern. The `OpenAIResponsesCompactionSession` wrapper stores session history and lets the application call `run_compaction({"force": True})` at a phase boundary. That makes compaction visible without inflating the evidence set.

```python
from agents.memory import OpenAIResponsesCompactionSession, SQLiteSession


def build_compaction_session() -> OpenAIResponsesCompactionSession:
    underlying = SQLiteSession("evidence_review_session.sqlite")
    return OpenAIResponsesCompactionSession(
        session_id="evidence-review-demo",
        underlying_session=underlying,
        model=COMPACTION_MODEL,
        compaction_mode="input",
    )


async def force_compaction_checkpoint(session: OpenAIResponsesCompactionSession) -> dict[str, int]:
    items_before = await session.get_items()
    await session.run_compaction({"force": True, "compaction_mode": "input"})
    items_after = await session.get_items()
    return {"items_before": len(items_before), "items_after": len(items_after)}


print("Compaction session helper defined. The final run uses it to show an explicit phase checkpoint.")
```

## Step 3: Attach Memory

Memory is for reuse across runs. In this example, memory should capture **workflow lessons**, not investigation facts.

Good memory candidates include:

- Use the manifest first when reviewing a file-based evidence workspace.
- Preserve uncertainty in the memo instead of guessing.
- Keep earlier assumptions visible when later evidence narrows them.

Bad memory candidates include:

- "Northwind Logistics violated policy."
- "ACME's Finance Ops process is deficient."
- Any case-specific conclusion that belongs in the memo.

> **Best practices**
>
> - Use memory for stable process lessons and user preferences.
> - Keep case-specific facts in reviewed artifacts such as the memo.
> - Inspect generated memory before relying on it in future runs.

```python
from agents.sandbox import MemoryGenerateConfig
from agents.sandbox.capabilities import Memory

MEMORY_GENERATION_PROMPT = """
Store reusable workflow lessons only.
Do not store ACME-specific compliance findings, document facts, evidence citations,
or memo conclusions. Those belong in outputs/compliance_review_memo.md.
Memory should help future evidence-review workflows behave better; it should not
become a second investigation record.
""".strip()


def workflow_memory() -> Memory:
    return Memory(
        generate=MemoryGenerateConfig(
            extra_prompt=MEMORY_GENERATION_PROMPT,
        )
    )


def build_memory_agent() -> SandboxAgent:
    return SandboxAgent(
        name="Evidence Review Agent with Memory",
        model=MODEL,
        instructions=BASELINE_INSTRUCTIONS,
        default_manifest=build_evidence_manifest(),
        capabilities=[
            Filesystem(),
            Shell(),
            workflow_memory(),
        ],
    )


memory_agent = build_memory_agent()
print([type(capability).__name__ for capability in memory_agent.capabilities])
```

## Step 4: Run With Both Compaction and Memory

Now combine the pieces:

- `Filesystem()` and `Shell()` let the agent navigate the evidence workspace.
- `Compaction()` keeps the active review viable as context grows.
- `Memory()` captures reusable workflow lessons after the run.
- The final memo remains the investigation artifact.

The task below asks the agent to review the synthetic evidence, write a memo, then read the memo back to verify it preserved the required structure and uncertainty.

```python
FINAL_REVIEW_TASK = """
Review all three document batches in order.

For each batch:
1. Read the manifest and relevant documents.
2. Preserve cited findings and uncertainty in your working notes and final memo.
3. Preserve any superseded or narrowed assumption instead of silently deleting it.

After Batch 3, write `outputs/compliance_review_memo.md` with:
- executive summary,
- cited findings table,
- open questions,
- recommended next steps for the reviewer.

Reviewer preference for future runs: keep the memo concise, preserve uncertainty
instead of guessing, and separate reusable workflow lessons from document-specific
compliance findings.
""".strip()


def build_reliable_evidence_agent() -> SandboxAgent:
    return SandboxAgent(
        name="Reliable Evidence Review Agent",
        model=MODEL,
        instructions=(
            BASELINE_INSTRUCTIONS
            + "\n\nUse compaction as working context. Use SDK memory for reusable "
            "workflow lessons across runs. Do not treat memory as the system of record "
            "for ACME-specific findings; those belong in the cited memo artifact."
        ),
        default_manifest=build_evidence_manifest(),
        capabilities=[
            Filesystem(),
            Shell(),
            Compaction(),
            workflow_memory(),
        ],
    )


reliable_agent = build_reliable_evidence_agent()
print([type(capability).__name__ for capability in reliable_agent.capabilities])
```

```python
EXAMPLE_OUTPUT = """
# Compliance Review Memo

## Executive Summary

The current record supports a control-gap finding for the Northwind Logistics
vendor exception, not a final conclusion that policy was intentionally violated.
The strongest evidence is that ACME required two approvals and Finance Ops
logging for payment exceptions, while the Northwind exception appears to have
been released before Finance Ops approval was complete.

Later evidence narrows the initial concern. The record no longer points only to
an undocumented verbal exception; it now points to a specific process weakness:
Legal approval may have been obtained, but Finance Ops review and exception-log
reconciliation remained incomplete at the time of release.

## Cited Findings

| Finding | Support | Status |
|---|---|---|
| Payments over $50,000 required two approvals, and exceptions had to be logged with Finance Ops. | ACME-B1-001 | Supported |
| The Northwind Logistics exception was approved verbally, but the initial note does not show a Finance Ops log entry. | ACME-B1-002 | Supported |
| Internal Audit treated missing exception logs as a control gap until resolved. | ACME-B2-001 | Supported |
| The approval thread indicates Legal approved the exception, but Finance Ops approval was still pending when payment was released. | ACME-B2-002 | Supported |
| The remediation plan requires Finance Ops to reconcile verbal vendor exceptions from Q4 and add retrospective control attestations. | ACME-B3-001 | Supported |

## Open Questions

- Was Finance Ops approval completed after the payment release, and if so, when?
- How many other Q4 verbal vendor exceptions lack retrospective attestations?
- Did any compensating control apply to the Northwind payment before remediation began?

## Recommended Next Steps

1. Reconcile Northwind Logistics against the Finance Ops exception log and payment-release timestamp.
2. Pull the full Q4 population of verbal vendor exceptions into the same review workflow.
3. Classify the issue as a control gap unless later evidence shows timely Finance Ops approval or an approved compensating control.
""".strip()

if not RUN_AGENT:
    print("RUN_AGENT is False, so this cell shows an example memo shape rather than running the model.\n")
    print(EXAMPLE_OUTPUT)
```

## Inspect Generated Artifacts

The final agent response is useful, but the reliability pattern becomes clearer when you inspect the files the sandbox run produced. This section makes the normally hidden state visible:

- the reviewer-facing memo in `outputs/compliance_review_memo.md`,
- generated SDK memory files such as `memories/MEMORY.md` and `memories/memory_summary.md`,
- the workspace files produced by the run, including the session log.

The generated memory artifact is not the compliance memo and should not be treated as investigation truth. It is reusable workflow memory. The `Task Group` heading is the memory system's own grouping label, and the memory generator is steered with `MemoryGenerateConfig.extra_prompt` so it stores workflow lessons rather than ACME-specific findings.

If `RUN_AGENT = False`, this section displays the expected output shape instead of live sandbox artifacts.

```python
try:
    from IPython.display import Markdown, display
except ImportError:
    Markdown = None
    display = None

memo_text = final_run.get("memo") if "final_run" in globals() else None
workspace_files = final_run.get("workspace_files") if "final_run" in globals() else None
memory_artifacts = final_run.get("memory_artifacts", {}) if "final_run" in globals() else {}
compaction_checkpoint = final_run.get("compaction_checkpoint") if "final_run" in globals() else None

print("Generated workspace files:")
print(workspace_files or "No generated workspace files were captured.")

print("\nMemory and compaction configuration:")
print({
    "final_agent_capabilities": [type(capability).__name__ for capability in reliable_agent.capabilities],
    "sandbox_compaction": "Compaction() is attached to the final agent for automatic context management",
    "sandbox_memory": "Memory(generate=MemoryGenerateConfig(...)) is attached to the final agent",
    "memory_write_policy": "Store reusable workflow lessons, not ACME-specific compliance findings",
    "forced_checkpoint": "OpenAIResponsesCompactionSession.run_compaction({force: True}) after the final review",
    "compaction_model_for_checkpoint": COMPACTION_MODEL,
    "checkpoint_result": compaction_checkpoint,
})

if memory_artifacts:
    for path, text in memory_artifacts.items():
        heading = f"### Generated SDK memory artifact: `{path}`\n\n"
        explanation = (
            "This block is generated by the SDK `Memory()` primitive. It is reusable "
            "workflow memory, not the compliance memo and not the investigation system "
            "of record.\n\n"
            "```text\n----- BEGIN GENERATED SDK MEMORY ARTIFACT -----\n"
        )
        closing = "\n----- END GENERATED SDK MEMORY ARTIFACT -----\n```"
        if display is not None and Markdown is not None:
            display(Markdown(heading + explanation + text + closing))
        else:
            print(f"\nGenerated SDK memory artifact: {path}\n")
            print("----- BEGIN GENERATED SDK MEMORY ARTIFACT -----")
            print(text)
            print("----- END GENERATED SDK MEMORY ARTIFACT -----")
else:
    print("\nNo generated memory artifacts were captured. Set RUN_AGENT = True and rerun the final workflow.")

if memo_text:
    if display is not None and Markdown is not None:
        display(Markdown("## Generated memo: `outputs/compliance_review_memo.md`\n\n" + memo_text))
    else:
        print("\nGenerated memo:\n")
        print(memo_text)
else:
    print("\nNo memo was captured. Set RUN_AGENT = True and rerun the final workflow.")
```

**Common Pitfall**

Do not treat `Memory()` as an unreviewed fact database.

Memory should help the next run remember how to work. It should not become a shadow compliance record. If a conclusion matters, write it into a reviewed artifact with citations.

## Conclusion

You now have the building blocks for a reliable long-running agent workflow:

- A sandbox workspace for controlled file access.
- A manifest that helps the agent route across documents.
- Compaction for finite context windows.
- Memory for reusable workflow lessons.
- A generated memo as the reviewed investigation artifact.

The main design choice is separation of responsibility: context helps the agent work, memory helps future agents work better, and reviewed artifacts hold the facts that people will rely on.
