---
title: "Build Iterative Repair Loops With Codex"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - codex
  - coding-agents
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/codex/build_iterative_repair_loops_with_codex
  - https://github.com/openai/openai-cookbook/blob/main/examples/codex/Build_iterative_repair_loops_with_Codex.ipynb
---

# Build Iterative Repair Loops With Codex

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/codex/build_iterative_repair_loops_with_codex
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/codex/Build_iterative_repair_loops_with_Codex.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/codex/Build_iterative_repair_loops_with_Codex.ipynb
- Source path: `examples/codex/Build_iterative_repair_loops_with_Codex.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `a3937c45f63cbc8dcc2ddfb915b2f7b8b1c7cc6f934246575b22a1778a59bd43`

## Classification

- Primary category: Codex / coding agents
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Build iterative repair loops with Codex This cookbook is about closed-loop agent workflows: agents that produce an output, validate it, and use the feedback to improve the next pass. We'll explore a documentation reliability workflow that detects, repairs, and validates stale or broken API and SDK examples. The worked example uses intentionally stale noteboo...

## What This Teaches

- How to use Codex for coding-agent workflows, repair loops, reviews, or secure engineering automation.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Build iterative repair loops with Codex

This cookbook is about closed-loop agent workflows: agents that produce an output, validate it, and use the feedback to improve the next pass.

We'll explore a documentation reliability workflow that detects, repairs, and validates stale or broken API and SDK examples. The worked example uses intentionally stale notebooks adapted from this Cookbook repository.

We'll build this agent loop with Codex. Codex reviews the current state, applies focused changes, runs validation, and repeats when the feedback shows remaining issues.

The notebook task is only the example. The pattern applies wherever agent output can be measured with trustworthy feedback.

The workflow has three phases:

- **Review:** inspect the current artifact and return structured findings without editing files.
- **Repair:** apply focused edits to a copied artifact using the findings and the latest validation feedback.
- **Validate:** run the relevant checks and report what still needs work.

Validation closes the loop. The repaired notebook has to satisfy the checks that matter, and any remaining issues become the next repair input.

<p align="center">
  <img src="../../images/codex_iterative_repair_loop.png" alt="Codex iterative repair loop for technical documentation" width="350"/>
</p>

## Setup

This notebook uses [Codex CLI](https://developers.openai.com/codex/cli) in headless mode, so the repair steps can run from Python cells instead of a chat UI. The first code cell installs the CLI; if you already have it, you can skip that cell.

Before you run the live repair loop, set `OPENAI_API_KEY` in your environment.

The notebook defaults to a fast repair model so the full example can finish in a reasonable amount of time. To experiment with a different model, set `REPAIR_MODEL` before you start. The install cell pins a known Codex CLI version for reproducibility; update that version intentionally when you want newer CLI behavior.

```python
!npm install -g @openai/codex@0.130.0
```

```python
import concurrent.futures
import json
import os
import shlex
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

CANDIDATE_EXAMPLE_DIRS = [Path("."), Path("examples/codex")]
EXAMPLE_DIR = next((base for base in CANDIDATE_EXAMPLE_DIRS if (base / "data" / "docs").exists()), None)

if EXAMPLE_DIR is None:
    raise RuntimeError(
        "This notebook needs its companion sample notebooks. "
        "Download the data folder that ships with this example and place it next to "
        "this notebook as ./data/docs, or run from a checkout where examples/codex/data/docs exists."
    )

DATA_DIR = EXAMPLE_DIR / "data" / "docs"
DEFAULT_RUNS_DIR = Path(tempfile.gettempdir()) / "codex_iterative_repair_loop_outputs"
RUNS_DIR = Path(os.getenv("CODEX_REPAIR_RUNS_DIR", str(DEFAULT_RUNS_DIR))).expanduser()
RUNS_DIR.mkdir(parents=True, exist_ok=True)
```

```python
MODEL = os.getenv("REPAIR_MODEL", "gpt-5.4-mini")
COOKBOOK_CHAT_MODEL = os.getenv("COOKBOOK_CHAT_MODEL", "gpt-5.5")
REPAIR_REASONING_EFFORT = os.getenv("REPAIR_REASONING_EFFORT", "low")

if not os.environ.get("OPENAI_API_KEY"):
    raise ValueError("Set the OPENAI_API_KEY environment variable before running the live Codex repair loop.")

CODEX_CLI = shutil.which("codex")
if CODEX_CLI is None:
    raise RuntimeError("Run the install cell before continuing; Codex CLI is not on PATH.")
```

## Load the sample artifacts

The cells below load the three companion notebooks and summarize the metadata that drives the repair loop.

The samples are small on purpose. They run quickly, but they still exercise the architecture: review finds substantive issues, repair makes focused edits, and validation produces feedback for the next pass.

If you download this notebook by itself, also download the companion `data/docs/` folder and place it next to the notebook before running the cells below. The code expects those sample notebooks to be available locally.

In this example, validation executes each repaired notebook end to end. In another domain, validation might be a unit test, policy check, schema validator, simulation, or human approval step. The important part is that failures become structured feedback instead of a dead end.

```python
NOTEBOOKS = [
    DATA_DIR / "qdrant_embeddings_search_pre_repair.ipynb",
    DATA_DIR / "getting_started_evals_pre_repair.ipynb",
    DATA_DIR / "knowledge_retrieval_pre_repair.ipynb",
]


def read_notebook(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def case_metadata(path: Path) -> dict[str, Any]:
    return read_notebook(path).get("metadata", {}).get("codex_case_study", {})


cases = []
for notebook_path in NOTEBOOKS:
    notebook = read_notebook(notebook_path)
    metadata = notebook.get("metadata", {}).get("codex_case_study", {})
    repair_story = metadata.get("repair_story", {})
    cases.append(
        {
            "notebook": notebook_path.name,
            "cells": len(notebook["cells"]),
            "code_cells": sum(cell["cell_type"] == "code" for cell in notebook["cells"]),
            "source": metadata.get("source_path"),
            "target_iteration": repair_story.get("target_iteration"),
            "repair_depth": repair_story.get("repair_depth", ""),
        }
    )

cases
```

## Define business rules and issue taxonomy

Before asking Codex to review or repair an artifact, give it a small shared contract. That keeps the loop focused on the issues that matter, instead of asking the model to infer every product and style rule from scratch.

The rules below define what "good" means for these example notebooks: current API patterns, clear setup, runnable local samples, and preservation of the original teaching goal. In another workflow, this contract would describe that domain's source of truth.

```python
business_rules = {
    "preferred_chat_model": COOKBOOK_CHAT_MODEL,
    "preferred_embedding_model": "text-embedding-3-large",
    "modernize": [
        "client.chat.completions.create -> client.responses.create",
        "legacy function-calling schemas -> current tools schema",
        "qdrant.search -> qdrant.query_points",
        "oaieval CLI examples -> current Evals API workflow",
    ],
    "reader_experience": [
        "Make fresh-environment setup explicit.",
        "Keep the included examples runnable with local data and the standard library.",
        "Keep sample repairs self-contained unless the notebook explicitly teaches external setup.",
        "Remove manual result-file placeholders.",
        "State runtime prerequisites and side effects before readers run cells.",
        "Preserve the original teaching goal while modernizing the implementation.",
    ],
}

business_rules
```

## Define structured outputs

Each phase returns structured data so the next phase has something concrete to use.

Review returns findings. Repair returns a change summary and the path to the updated artifact. Validation returns the remaining delta for the next pass. With structured handoffs, the loop is easier to debug, rerun, and adapt to other artifact types.

```python
def object_schema(properties: dict[str, Any], required: list[str] | None = None) -> dict[str, Any]:
    return {
        "type": "object",
        "properties": properties,
        "required": required or list(properties),
        "additionalProperties": False,
    }


def string_array() -> dict[str, Any]:
    return {"type": "array", "items": {"type": "string"}}


finding_schema = object_schema(
    {
        "artifact": {"type": "string"},
        "issue_type": {"type": "string"},
        "severity": {"type": "string"},
        "description": {"type": "string"},
        "suggested_fix_direction": {"type": "string"},
    }
)

review_schema = object_schema(
    {"findings": {"type": "array", "items": finding_schema}}
)

fix_schema = object_schema(
    {
        "artifact": {"type": "string"},
        "iteration": {"type": "integer"},
        "changes_made": string_array(),
        "unresolved_items": string_array(),
        "updated_artifact_path": {"type": "string"},
    }
)

validation_case_schema = object_schema(
    {
        "name": {"type": "string"},
        "passed": {"type": "boolean"},
        "severity": {"type": "string"},
        "evidence": {"type": "string"},
        "feedback": {"type": "string"},
    }
)

validation_schema = object_schema(
    {
        "overall_passed": {"type": "boolean"},
        "cases": {"type": "array", "items": validation_case_schema},
        "remaining_delta": string_array(),
    }
)
```

## Review phase

The review phase reads the artifact and returns structured findings. It does not run validation and it does not edit files. That separation keeps the first step focused: identify likely problems before changing anything.

We send the review prompt to `codex exec` with a JSON schema. The schema keeps the result machine-readable, so later cells can pass findings directly into the repair prompt instead of scraping prose from a previous answer.

```python
def notebook_text(path: Path, max_chars: int = 7000) -> str:
    chunks = []
    for index, cell in enumerate(read_notebook(path)["cells"]):
        source = "".join(cell.get("source", []))
        chunks.append(f"cell {index} ({cell['cell_type']})\n{source}")
    text = "\n\n".join(chunks)
    if len(text) <= max_chars:
        return text
    return text[:max_chars] + "\n\n[truncated for prompt size]"


def run_command(command: str, *, stdin: str | None = None, cwd: Path | None = None, timeout: int | None = None):
    cwd = Path.cwd() if cwd is None else cwd
    return subprocess.run(
        shlex.split(command),
        input=stdin,
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )


def run_codex_json(prompt: str, schema: dict[str, Any], run_dir: Path) -> dict[str, Any]:
    run_dir.mkdir(parents=True, exist_ok=True)
    prompt_file = run_dir / "prompt.txt"
    schema_file = run_dir / "schema.json"
    answer_file = run_dir / "answer.json"

    prompt_file.write_text(prompt, encoding="utf-8")
    schema_file.write_text(json.dumps(schema, indent=2), encoding="utf-8")

    command = f"""
    {CODEX_CLI} exec
      --model {MODEL}
      --sandbox workspace-write
      --ask-for-approval never
      --config model_reasoning_effort={REPAIR_REASONING_EFFORT}
      --output-schema {schema_file}
      --output-last-message {answer_file}
      -
    """
    result = run_command(command, stdin=prompt)
    (run_dir / "stdout.txt").write_text(result.stdout, encoding="utf-8")
    (run_dir / "stderr.txt").write_text(result.stderr, encoding="utf-8")

    if result.returncode != 0:
        raise RuntimeError(f"Codex exited with {result.returncode}. See {run_dir / 'stderr.txt'}.")

    return json.loads(answer_file.read_text(encoding="utf-8"))


def review_notebook(path: Path, run_dir: Path) -> list[dict[str, Any&#93;&#93;:
    prompt = "\n".join(
        [
            "You are reviewing a public OpenAI Cookbook notebook before publication.",
            f"Artifact: {path.name}",
            "Find issues that would make the notebook stale, hard to run, or confusing for a developer reader.",
            "Do not execute the notebook or edit files.",
            "Use concise issue_type labels such as stale_model, deprecated_api, setup_gap, runtime_risk, or clarity_issue.",
            f"Business rules: {json.dumps(business_rules)}",
            "Base findings only on the notebook content below.",
            "Keep the findings focused; three strong findings are better than a long list.",
            "",
            notebook_text(path),
        ]
    )
    return run_codex_json(prompt, review_schema, run_dir)["findings"]
```

```python
def run_initial_review(path: Path) -> tuple[str, list[dict[str, Any&#93;&#93;]:
    return path.name, review_notebook(path, RUNS_DIR / "initial_review" / path.stem)


with concurrent.futures.ThreadPoolExecutor(max_workers=min(3, len(NOTEBOOKS))) as executor:
    initial_reviews = dict(executor.map(run_initial_review, NOTEBOOKS))

initial_reviews
```

## Repair phase

The repair phase gets the current artifact, review findings, business rules, and any validation feedback from the previous pass. The prompt gets more specific as the loop learns.

Codex edits a copy inside the iteration directory and returns a short summary of what changed. The loop does not assume the edit worked; validation decides that in the next step.

```python
def repair_prompt(path: Path, updated_path: Path, findings: list[dict[str, Any&#93;&#93;, remaining_delta: list[str], iteration: int) -> str:
    repair_story = case_metadata(path).get("repair_story", {})
    return "\n".join(
        [
            "You are repairing a copy of a public OpenAI Cookbook notebook.",
            f"Source notebook: {path}",
            f"Editable copy: {updated_path}",
            f"Iteration: {iteration}",
            "Make the smallest useful edits that address the review findings and validation delta.",
            "Preserve the notebook's teaching flow and original purpose.",
            "Keep sample repairs self-contained unless the notebook explicitly teaches external setup.",
            "For staged examples, focus on the most important remaining issue for this pass instead of rewriting everything at once.",
            "Edit only the editable copy. Do not claim the notebook passes validation.",
            f"Repair depth: {json.dumps(repair_story, indent=2)}",
            f"Business rules: {json.dumps(business_rules, indent=2)}",
            f"Review findings: {json.dumps(findings, indent=2)}",
            f"Remaining validation delta: {json.dumps(remaining_delta, indent=2)}",
        ]
    )


def repair_notebook(path: Path, iteration: int, findings: list[dict[str, Any&#93;&#93;, remaining_delta: list[str], case_dir: Path) -> dict[str, Any]:
    updated_path = case_dir / "updated.ipynb"
    updated_path.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, updated_path)

    prompt = repair_prompt(path, updated_path, findings, remaining_delta, iteration)
    return run_codex_json(prompt, fix_schema, case_dir / "repair")
```

## Validation phase

Validation works like a small eval. We define the behavior we want, run the relevant check, and ask a judge to score the result against that rubric.

For the documentation example, execution comes first. Many notebook problems only appear at runtime: a missing import, a stale file path, a cell that depends on an old API response, or setup guidance that was clear to the author but not to a fresh reader.

If validation fails, the failure becomes evidence for the next repair pass. This keeps the next repair grounded in observed behavior, not just what looked right in the diff.

```python
VALIDATION_CASES = [
    {
        "name": "api_modernization",
        "question": "Does the notebook avoid stale OpenAI API patterns, legacy function-calling syntax, and outdated model names?",
    },
    {
        "name": "setup_reproducibility",
        "question": "Could a reader run the notebook from a fresh environment without hidden manual steps?",
    },
    {
        "name": "artifact_integrity",
        "question": "Did the update preserve the notebook's teaching flow and avoid deleting substantive cells?",
    },
]


def short_output(value: Any, limit: int = 1200) -> str:
    if value is None:
        return ""
    if isinstance(value, bytes):
        value = value.decode("utf-8", errors="replace")
    return str(value)[-limit:]


def execute_notebook(path: Path) -> dict[str, Any]:
    code_cells = sum(cell["cell_type"] == "code" for cell in read_notebook(path)["cells"])
    command = f"jupyter nbconvert --to notebook --execute --inplace {path.name}"

    try:
        result = run_command(
            command,
            cwd=path.parent,
            timeout=int(os.getenv("SAMPLE_NOTEBOOK_TIMEOUT_SECONDS", "300")),
        )
    except FileNotFoundError:
        return {
            "status": "failed",
            "executed_code_cells": 0,
            "error": "Jupyter or nbconvert is not installed or is not available on PATH.",
            "summary": "Install Jupyter with nbconvert before running the validation loop.",
        }
    except subprocess.TimeoutExpired as exc:
        return {
            "status": "failed",
            "executed_code_cells": 0,
            "error": f"Notebook execution timed out after {exc.timeout} seconds.",
            "summary": short_output(exc.stderr or exc.stdout),
        }

    output = result.stderr or result.stdout
    return {
        "status": "passed" if result.returncode == 0 else "failed",
        "executed_code_cells": code_cells if result.returncode == 0 else 0,
        "error": "" if result.returncode == 0 else f"Notebook execution exited with code {result.returncode}.",
        "summary": short_output(output),
    }

def validation_prompt(updated_path: Path, before_path: Path, execution: dict[str, Any], iteration: int) -> str:
    repair_story = case_metadata(before_path).get("repair_story", {})
    return "\n".join(
        [
            "You are judging a repaired OpenAI Cookbook notebook.",
            f"Iteration: {iteration}",
            "Score each validation case independently and give concise feedback for the next repair pass.",
            "Set overall_passed to false when execution failed or any case has a material issue.",
            "When execution failed, include the failure in remaining_delta so the next repair pass can address it.",
            "Use the business rules as the source of truth for current model names and API targets.",
            "Do not mark the preferred embedding model or preferred chat model as stale.",
            "For local examples, do not require extra services or package installs when the notebook says it is intentionally self-contained.",
            f"Repair depth: {json.dumps(repair_story, indent=2)}",
            f"Business rules: {json.dumps(business_rules, indent=2)}",
            f"Validation cases: {json.dumps(VALIDATION_CASES, indent=2)}",
            f"Execution evidence: {json.dumps(execution, indent=2)}",
            f"Original cell count: {len(read_notebook(before_path)['cells'])}",
            f"Updated cell count: {len(read_notebook(updated_path)['cells'])}",
            "",
            notebook_text(updated_path),
        ]
    )


def staged_delta(before_path: Path, iteration: int) -> list[str]:
    repair_story = case_metadata(before_path).get("repair_story", {})
    target = int(repair_story.get("target_iteration") or 1)
    if iteration >= target:
        return []
    depth = repair_story.get("repair_depth", "This case is intentionally staged across multiple repair passes.")
    return [f"Continue to iteration {iteration + 1}: {depth}"]


def evaluate_notebook(updated_path: Path, before_path: Path, run_dir: Path, iteration: int) -> dict[str, Any]:
    execution = execute_notebook(updated_path)
    judged = run_codex_json(validation_prompt(updated_path, before_path, execution, iteration), validation_schema, run_dir)
    failed_cases = [case for case in judged["cases"] if not case["passed"&#93;&#93;
    execution_delta = []
    if execution["status"] != "passed":
        execution_delta.append(f"Execution failed: {execution.get('error') or execution.get('summary')}")

    stage_delta = staged_delta(before_path, iteration)
    return {
        "passed": judged["overall_passed"] and execution["status"] == "passed" and not stage_delta,
        "execution_status": execution["status"],
        "executed_code_cells": execution["executed_code_cells"],
        "execution_summary": execution["summary"],
        "findings": failed_cases,
        "remaining_delta": execution_delta + stage_delta + judged["remaining_delta"],
    }
```

## Save per-iteration outputs

Each iteration writes a `record.json` file and, for this example, a repaired notebook under `CODEX_REPAIR_RUNS_DIR/iteration_N/<sample_name>/`. If you do not set `CODEX_REPAIR_RUNS_DIR`, the notebook writes to your system temp directory so a normal repo checkout stays clean.

Those files are the audit trail. You can see what the review found, what Codex changed, whether execution passed, and what feedback carried into the next iteration.

A `record.json` file is the receipt for one loop attempt. It keeps the handoff between phases in one place:

```json
{
  "review": [{"issue_type": "deprecated_api", "severity": "high"}],
  "repair": {
    "changes_made": ["Updated the notebook to use the current API pattern."],
    "updated_artifact_path": "/tmp/codex_iterative_repair_loop_outputs/iteration_1/sample/updated.ipynb"
  },
  "validation": {
    "passed": false,
    "remaining_delta": ["One setup instruction is still unclear."]
  }
}
```

That compact record is what lets a maintainer review the loop without reconstructing the whole run from notebook diffs and terminal logs.

```python
def save_json(payload: Any, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def iteration_dir(number: int) -> Path:
    path = RUNS_DIR / f"iteration_{number}"
    path.mkdir(parents=True, exist_ok=True)
    return path
```

## Run iteration 1

Each notebook case is independent, so we process the cases concurrently. This keeps the demo fast while preserving the same review, repair, and validation flow for every sample.

Iteration 1 reuses the initial review findings from the earlier review cell. After this pass, inspect the returned booleans: passing cases can stop, and failing cases carry their validation feedback into the next pass.

```python
current_notebooks = {path.name: path for path in NOTEBOOKS}
history: dict[int, dict[str, Any&#93;&#93; = {}


def review_findings_for(original: Path, current_path: Path, case_dir: Path, previous_results: dict[str, Any] | None) -> list[dict[str, Any&#93;&#93;:
    if previous_results is None:
        return initial_reviews[original.name]
    return review_notebook(current_path, case_dir / "review")


def run_case(number: int, original: Path, run_dir: Path, previous_results: dict[str, Any] | None) -> tuple[str, dict[str, Any], Path]:
    name = original.name
    case_dir = run_dir / original.stem
    current_path = current_notebooks[name]

    findings = review_findings_for(original, current_path, case_dir, previous_results)
    delta = [] if previous_results is None else previous_results[name]["validation"]["remaining_delta"]
    repair = repair_notebook(current_path, number, findings, delta, case_dir)
    updated_path = Path(repair["updated_artifact_path"])
    validation = evaluate_notebook(updated_path, current_path, case_dir / "evaluation", number)

    record = {"review": findings, "repair": repair, "validation": validation}
    save_json(record, case_dir / "record.json")
    return name, record, updated_path


def run_iteration(number: int, previous_results: dict[str, Any] | None = None) -> dict[str, Any]:
    results = {}
    updates = {}
    run_dir = iteration_dir(number)

    with concurrent.futures.ThreadPoolExecutor(max_workers=min(3, len(NOTEBOOKS))) as executor:
        futures = [executor.submit(run_case, number, original, run_dir, previous_results) for original in NOTEBOOKS]
        for future in concurrent.futures.as_completed(futures):
            name, record, updated_path = future.result()
            results[name] = record
            updates[name] = updated_path

    current_notebooks.update(updates)
    history[number] = results
    return results


iteration_1 = run_iteration(1)
{name: result["validation"]["passed"] for name, result in iteration_1.items()}
```

## Run iteration 2

Iteration 2 is where the loop starts to pay off. Codex is no longer working only from the original review; it also sees what happened during validation.

That changes the task. Instead of asking for a broad rewrite, we ask for the next useful repair based on evidence from the last run: what executed, what passed, and what still needs attention.

For the included staged fixtures, this pass is designed to clear the medium-depth Evals case while the deeper Knowledge Retrieval case continues with a smaller, more specific delta.

```python
iteration_2 = run_iteration(2, iteration_1)
{name: result["validation"]["passed"] for name, result in iteration_2.items()}
```

## Run iteration 3

Iteration 3 focuses on the deepest documentation case.

The Knowledge Retrieval fixture has to modernize the API shape, stay runnable with local data, and preserve the retrieval teaching flow. Those requirements can pull against each other: a repair that makes the notebook modern might accidentally make it less runnable, while a repair that keeps it local might remove too much of the original lesson.

The third pass gives Codex the latest notebook plus the final validation delta. This is the part of the demo that shows why iteration matters: the agent responds to the specific issue that remained, rather than trying to anticipate everything up front.

```python
iteration_3 = run_iteration(3, iteration_2)
{name: result["validation"]["passed"] for name, result in iteration_3.items()}
```

## Summarize improvement

Now we can look at the whole run instead of opening every intermediate artifact by hand. The summary below shows the signal that matters most: which artifacts passed, how many validation findings remained, and whether any delta carried forward.

For the included fixtures, the intended shape is simple: one notebook clears in iteration 1, another clears in iteration 2, and the deepest one clears in iteration 3. In a real maintenance workflow, this table tells you whether the loop is converging or needs a clearer constraint or human review.

This summary is also useful for human review. A maintainer can start with the pass/fail pattern, open records for anything that still has a delta, and inspect only the repaired artifacts that are ready for review.

```python
summary = []
for iteration, results in history.items():
    for artifact, record in results.items():
        validation = record["validation"]
        summary.append(
            {
                "iteration": iteration,
                "artifact": artifact,
                "passed": validation["passed"],
                "findings": len(validation["findings"]),
                "remaining_delta": len(validation["remaining_delta"]),
            }
        )

summary
```

```python
for row in summary:
    print(
        f"iteration={row['iteration']} artifact={row['artifact']} "
        f"passed={row['passed']} findings={row['findings']} delta={row['remaining_delta']}"
    )
```

## What the summary tells us

The important signal is not that Codex made edits. The important signal is that the remaining validation delta gets smaller as the loop runs.

| Pass | Signal to look for | Why it matters |
| --- | --- | --- |
| Iteration 1 | The simplest fixture passes; deeper fixtures keep a small delta. | The loop can make an initial repair while carrying forward the cases that still need evidence. |
| Iteration 2 | The medium-depth fixture clears after seeing validation feedback. | Runtime and judge feedback become useful repair instructions. |
| Iteration 3 | The deepest fixture clears or leaves a focused final delta. | The loop converges, or it produces a clear handoff for a human reviewer. |

The `record.json` files are where this becomes auditable. A useful record answers four questions: what did the review find, what did Codex change, did the notebook execute, and what remains? That is the difference between an impressive-looking edit and a repair workflow a maintainer can trust.

## Generalize to a continuous loop

The fixed three-pass run above is useful for teaching the pattern. A production loop should decide when to stop on its own.

A good loop usually stops for one of four reasons: validation passes, the loop reaches a maximum number of attempts, the remaining delta stops changing, or the next decision needs human review. Those stop conditions are just as important as the repair prompt.

The other production detail is the audit trail. Keep the review findings, repaired artifact, validation result, validation judgment, and remaining delta for every pass. That record lets a maintainer understand why the loop continued, why it stopped, and which artifact is ready for review.

```python
def repair_until_done(max_iterations: int = 3) -> dict[int, dict[str, Any&#93;&#93;:
    current_notebooks.update({path.name: path for path in NOTEBOOKS})
    previous = None
    loop_history = {}

    for number in range(1, max_iterations + 1):
        previous = run_iteration(number, previous)
        loop_history[number] = previous
        if all(record["validation"]["passed"] for record in previous.values()):
            break

    return loop_history
```

## Where else this applies

The notebook walkthrough is just one way to teach the architecture. The same pattern helps whenever an agent changes a file or process that needs more than subjective review before it is accepted.

A few high-value examples:

- **Protocol optimization:** Draft an update for expert review, then validate it against dosing rules, timing constraints, or required safety checks.
- **Regulatory remediation:** Draft updates to regulated content, then check that required language, citations, approvals, and jurisdiction-specific terms remain intact.
- **Support knowledge refresh:** Update an article, test it against current product behavior or known resolutions, and carry mismatches into the next pass.
- **Code modernization:** Replace deprecated APIs, run tests or static checks, and use remaining failures to guide the next repair.

The common thread is that the change matters, and each pass needs evidence. Whether the target is a notebook, a policy, a protocol, a support article, a pipeline, or a codebase, the loop gives the agent a way to improve it with evidence a maintainer can review.

## Conclusion

Iterative repair loops make agentic maintenance easier to review and operate because they separate judgment from proof.

Review finds candidate issues. Repair makes focused edits. Validation executes the artifact and produces the next delta. When those phases exchange structured outputs, the workflow becomes easier to inspect, repeat, and adapt.

The main idea is simple: instead of relying on a single pass, give the workflow a way to learn from the artifact, make a bounded repair, and react to real validation feedback. That small change makes agentic maintenance much more practical.
