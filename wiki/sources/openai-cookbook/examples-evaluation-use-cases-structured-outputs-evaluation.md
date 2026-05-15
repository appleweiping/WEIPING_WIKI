---
title: "Structured Outputs Evaluation"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - evals
  - evaluation
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/structured-outputs-evaluation
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/structured-outputs-evaluation.ipynb
---

# Structured Outputs Evaluation

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/structured-outputs-evaluation
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/structured-outputs-evaluation.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/structured-outputs-evaluation.ipynb
- Source path: `examples/evaluation/use-cases/structured-outputs-evaluation.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `197448d0ea18ae9603274b8fccfe3643608aa34d9fbd76f7cd41dbec9c348492`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Structured Output Evaluation Cookbook This notebook walks you through a set of focused, runnable examples how to use the OpenAI Evals framework to test, grade, and iterate on tasks that require large‑language models to produce structured outputs . Why does this matter? Production systems often depend on JSON, SQL, or domain‑specific formats. Relying on spot...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.
- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Structured Output Evaluation Cookbook

This notebook walks you through a set of focused, runnable examples how to use the OpenAI **Evals** framework to **test, grade, and iterate on tasks that require large‑language models to produce structured outputs**.

> **Why does this matter?**
> Production systems often depend on JSON, SQL, or domain‑specific formats.  Relying on spot checks or ad‑hoc prompt tweaks quickly breaks down.  Instead, you can *codify* expectations as automated evals and let your team ship with safety bricks instead of sand.


## Quick Tour

* **Section 1 – Prerequisites**: environment variables and package setup
* **Section 2 – Walk‑through: Code‑symbol extraction**: end‑to‑end demo that grades the model’s ability to extract function and class names from source code.  We keep the original logic intact and simply layer documentation around it.
* **Section 3 – Additional Recipes**: sketches of common production patterns such as sentiment extraction as additional code sample for evaluation.
* **Section 4 – Result Exploration**: lightweight helpers for pulling run output and digging into failures.


## Prerequisites

1. **Install dependencies** (minimum versions shown):

```bash
pip install --upgrade openai
```

2. **Authenticate** by exporting your key:

```bash
export OPENAI_API_KEY="sk‑..."
```

3. **Optional**: if you plan to run evals in bulk, set up an [organization‑level key](https://platform.openai.com/account/org-settings) with appropriate limits.

### Use Case 1: Code symbol extraction


The goal is to **extract all function, class, and constant symbols from python files inside the OpenAI SDK**.
For each file we ask the model to emit structured JSON like:

```json
{
  "symbols": [
    {"name": "OpenAI", "kind": "class"},
    {"name": "Evals", "kind": "module"},
    ...
  ]
}
```

A rubric model then grades **completeness** (did we capture every symbol?) and **quality** (are the kinds correct?) on a 1‑7 scale.

### Evaluating Code Quality Extraction with a Custom Dataset

Let us walk though an example to evaluate a model's ability to extract symbols from code using the OpenAI **Evals** framework with a custom in-memory dataset.

### Initialize SDK client
Creates an `openai.OpenAI` client using the `OPENAI_API_KEY` we exported above.  Nothing will run without this.

```python
%pip install --upgrade openai pandas rich --quiet



import os
import time
import openai
from rich import print
import pandas as pd

client = openai.OpenAI(
    api_key=os.getenv("OPENAI_API_KEY") or os.getenv("_OPENAI_API_KEY"),
)
```

### Dataset factory & grading rubric
* `get_dataset` builds a small in-memory dataset by reading several SDK files.
* `structured_output_grader` defines a detailed evaluation rubric.
* `client.evals.create(...)` registers the eval with the platform.

```python
def get_dataset(limit=None):
    openai_sdk_file_path = os.path.dirname(openai.__file__)

    file_paths = [
        os.path.join(openai_sdk_file_path, "resources", "evals", "evals.py"),
        os.path.join(openai_sdk_file_path, "resources", "responses", "responses.py"),
        os.path.join(openai_sdk_file_path, "resources", "images.py"),
        os.path.join(openai_sdk_file_path, "resources", "embeddings.py"),
        os.path.join(openai_sdk_file_path, "resources", "files.py"),
    ]

    items = []
    for file_path in file_paths:
        items.append({"input": open(file_path, "r").read()})
    if limit:
        return items[:limit]
    return items


structured_output_grader = """
You are a helpful assistant that grades the quality of extracted information from a code file.
You will be given a code file and a list of extracted information.
You should grade the quality of the extracted information.

You should grade the quality on a scale of 1 to 7.
You should apply the following criteria, and calculate your score as follows:
You should first check for completeness on a scale of 1 to 7.
Then you should apply a quality modifier.

The quality modifier is a multiplier from 0 to 1 that you multiply by the completeness score.
If there is 100% coverage for completion and it is all high quality, then you would return 7*1.
If there is 100% coverage for completion but it is all low quality, then you would return 7*0.5.
etc.
"""

structured_output_grader_user_prompt = """
<Code File>
{{item.input}}
</Code File>

<Extracted Information>
{{sample.output_json.symbols}}
</Extracted Information>
"""

logs_eval = client.evals.create(
    name="Code QA Eval",
    data_source_config={
        "type": "custom",
        "item_schema": {
            "type": "object",
            "properties": {"input": {"type": "string"}},
        },
        "include_sample_schema": True,
    },
    testing_criteria=[
        {
            "type": "score_model",
            "name": "General Evaluator",
            "model": "o3",
            "input": [
                {"role": "system", "content": structured_output_grader},
                {"role": "user", "content": structured_output_grader_user_prompt},
            ],
            "range": [1, 7],
            "pass_threshold": 5.5,
        }
    ],
)
```

### Kick off model runs
Here we launch two runs against the same eval: one that calls the **Completions** endpoint, and one that calls the **Responses** endpoint.

```python
### Kick off model runs
gpt_4one_completions_run = client.evals.runs.create(
    name="gpt-4.1",
    eval_id=logs_eval.id,
    data_source={
        "type": "completions",
        "source": {
            "type": "file_content",
            "content": [{"item": item} for item in get_dataset(limit=1)],
        },
        "input_messages": {
            "type": "template",
            "template": [
                {
                    "type": "message",
                    "role": "system",
                    "content": {"type": "input_text", "text": "You are a helpful assistant."},
                },
                {
                    "type": "message",
                    "role": "user",
                    "content": {
                        "type": "input_text",
                        "text": "Extract the symbols from the code file {{item.input}}",
                    },
                },
            ],
        },
        "model": "gpt-4.1",
        "sampling_params": {
            "seed": 42,
            "temperature": 0.7,
            "max_completions_tokens": 10000,
            "top_p": 0.9,
            "response_format": {
                "type": "json_schema",
                "json_schema": {
                    "name": "python_symbols",
                    "schema": {
                        "type": "object",
                        "properties": {
                            "symbols": {
                                "type": "array",
                                "description": "A list of symbols extracted from Python code.",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "name": {"type": "string", "description": "The name of the symbol."},
                                        "symbol_type": {
                                            "type": "string", "description": "The type of the symbol, e.g., variable, function, class.",
                                        },
                                    },
                                    "required": ["name", "symbol_type"],
                                    "additionalProperties": False,
                                },
                            }
                        },
                        "required": ["symbols"],
                        "additionalProperties": False,
                    },
                    "strict": True,
                },
            },
        },
    },
)

gpt_4one_responses_run = client.evals.runs.create(
    name="gpt-4.1-mini",
    eval_id=logs_eval.id,
    data_source={
        "type": "responses",
        "source": {
            "type": "file_content",
            "content": [{"item": item} for item in get_dataset(limit=1)],
        },
        "input_messages": {
            "type": "template",
            "template": [
                {
                    "type": "message",
                    "role": "system",
                    "content": {"type": "input_text", "text": "You are a helpful assistant."},
                },
                {
                    "type": "message",
                    "role": "user",
                    "content": {
                        "type": "input_text",
                        "text": "Extract the symbols from the code file {{item.input}}",
                    },
                },
            ],
        },
        "model": "gpt-4.1-mini",
        "sampling_params": {
            "seed": 42,
            "temperature": 0.7,
            "max_completions_tokens": 10000,
            "top_p": 0.9,
            "text": {
                "format": {
                    "type": "json_schema",
                    "name": "python_symbols",
                    "schema": {
                        "type": "object",
                        "properties": {
                            "symbols": {
                                "type": "array",
                                "description": "A list of symbols extracted from Python code.",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "name": {"type": "string", "description": "The name of the symbol."},
                                        "symbol_type": {
                                            "type": "string",
                                            "description": "The type of the symbol, e.g., variable, function, class.",
                                        },
                                    },
                                    "required": ["name", "symbol_type"],
                                    "additionalProperties": False,
                                },
                            }
                        },
                        "required": ["symbols"],
                        "additionalProperties": False,
                    },
                    "strict": True,
                },
            },
        },
    },
)
```

### Utility poller
Next, we will use a simple loop that waits for all runs to finish, then saves each run’s JSON to disk so you can inspect it later or attach it to CI artifacts.

```python
### Utility poller
def poll_runs(eval_id, run_ids):
    while True:
        runs = [client.evals.runs.retrieve(rid, eval_id=eval_id) for rid in run_ids]
        for run in runs:
            print(run.id, run.status, run.result_counts)
        if all(run.status in {"completed", "failed"} for run in runs):
            # dump results to file
            for run in runs:
                with open(f"{run.id}.json", "w") as f:
                    f.write(
                        client.evals.runs.output_items.list(
                            run_id=run.id, eval_id=eval_id
                        ).model_dump_json(indent=4)
                    )
            break
        time.sleep(5)

poll_runs(logs_eval.id, [gpt_4one_completions_run.id, gpt_4one_responses_run.id])
```

### Load outputs for quick inspection
We will fetch the output items for both runs so we can print or post‑process them.

```python
completions_output = client.evals.runs.output_items.list(
    run_id=gpt_4one_completions_run.id, eval_id=logs_eval.id
)

responses_output = client.evals.runs.output_items.list(
    run_id=gpt_4one_responses_run.id, eval_id=logs_eval.id
)
```

### Human-readable dump
Let us print a side-by-side view of completions vs responses.

```python
from IPython.display import display, HTML

# Collect outputs for both runs
completions_outputs = [item.sample.output[0].content for item in completions_output]
responses_outputs = [item.sample.output[0].content for item in responses_output]

# Create DataFrame for side-by-side display (truncated to 250 chars for readability)
df = pd.DataFrame({
    "Completions Output": [c[:250].replace('\n', ' ') + ('...' if len(c) > 250 else '') for c in completions_outputs],
    "Responses Output": [r[:250].replace('\n', ' ') + ('...' if len(r) > 250 else '') for r in responses_outputs]
})

# Custom color scheme
custom_styles = [
    {'selector': 'th', 'props': [('font-size', '1.1em'), ('background-color', '#323C50'), ('color', '#FFFFFF'), ('border-bottom', '2px solid #1CA7EC')]},
    {'selector': 'td', 'props': [('font-size', '1em'), ('max-width', '650px'), ('background-color', '#F6F8FA'), ('color', '#222'), ('border-bottom', '1px solid #DDD')]},
    {'selector': 'tr:hover td', 'props': [('background-color', '#D1ECF1'), ('color', '#18647E')]},
    {'selector': 'tbody tr:nth-child(even) td', 'props': [('background-color', '#E8F1FB')]},
    {'selector': 'tbody tr:nth-child(odd) td', 'props': [('background-color', '#F6F8FA')]},
    {'selector': 'table', 'props': [('border-collapse', 'collapse'), ('border-radius', '6px'), ('overflow', 'hidden')]},
]

styled = (
    df.style
    .set_properties(**{'white-space': 'pre-wrap', 'word-break': 'break-word', 'padding': '8px'})
    .set_table_styles(custom_styles)
    .hide(axis="index")
)

display(HTML("""
<h4 style="color: #1CA7EC; font-weight: 600; letter-spacing: 1px; text-shadow: 0 1px 2px rgba(0,0,0,0.08), 0 0px 0px #fff;">
Completions vs Responses Output
</h4>
"""))
display(styled)
```

### Visualize the Results

Below are visualizations that represent the evaluation data and code outputs for structured QA evaluation. These images provide insights into the data distribution and the evaluation workflow.

---

**Evaluation Data Overview**

![Evaluation Data Part 1](../../../images/eval_qa_data_1.png)

![Evaluation Data Part 2](../../../images/eval_qa_data_2.png)

---

**Evaluation Code Workflow**

![Evaluation Code Structure](../../../images/eval_qa_code.png)

---

By reviewing these visualizations, you can better understand the structure of the evaluation dataset and the steps involved in evaluating structured outputs for QA tasks.

### Use Case 2: Multi-lingual Sentiment Extraction
In a similar way, let us evaluate a multi-lingual sentiment extraction model with structured outputs.

```python
# Sample in-memory dataset for sentiment extraction
sentiment_dataset = [
    {
        "text": "I love this product!",
        "channel": "twitter",
        "language": "en"
    },
    {
        "text": "This is the worst experience I've ever had.",
        "channel": "support_ticket",
        "language": "en"
    },
    {
        "text": "It's okay – not great but not bad either.",
        "channel": "app_review",
        "language": "en"
    },
    {
        "text": "No estoy seguro de lo que pienso sobre este producto.",
        "channel": "facebook",
        "language": "es"
    },
    {
        "text": "总体来说，我对这款产品很满意。",
        "channel": "wechat",
        "language": "zh"
    },
]
```

```python
# Define output schema
sentiment_output_schema = {
    "type": "object",
    "properties": {
        "sentiment": {
            "type": "string",
            "description": "overall label: positive / negative / neutral"
        },
        "confidence": {
            "type": "number",
            "description": "confidence score 0-1"
        },
        "emotions": {
            "type": "array",
            "description": "list of dominant emotions (e.g. joy, anger)",
            "items": {"type": "string"}
        }
    },
    "required": ["sentiment", "confidence", "emotions"],
    "additionalProperties": False
}

# Grader prompts
sentiment_grader_system = """You are a strict grader for sentiment extraction.
Given the text and the model's JSON output, score correctness on a 1-5 scale."""

sentiment_grader_user = """Text: {{item.text}}
Model output:
{{sample.output_json}}
"""
```

```python
# Register an eval for the richer sentiment task
sentiment_eval = client.evals.create(
    name="sentiment_extraction_eval",
    data_source_config={
        "type": "custom",
        "item_schema": {          # matches the new dataset fields
            "type": "object",
            "properties": {
                "text": {"type": "string"},
                "channel": {"type": "string"},
                "language": {"type": "string"},
            },
            "required": ["text"],
        },
        "include_sample_schema": True,
    },
    testing_criteria=[
        {
            "type": "score_model",
            "name": "Sentiment Grader",
            "model": "o3",
            "input": [
                {"role": "system", "content": sentiment_grader_system},
                {"role": "user",   "content": sentiment_grader_user},
            ],
            "range": [1, 5],
            "pass_threshold": 3.5,
        }
    ],
)
```

```python
# Run the sentiment eval
sentiment_run = client.evals.runs.create(
    name="gpt-4.1-sentiment",
    eval_id=sentiment_eval.id,
    data_source={
        "type": "responses",
        "source": {
            "type": "file_content",
            "content": [{"item": item} for item in sentiment_dataset],
        },
        "input_messages": {
            "type": "template",
            "template": [
                {
                    "type": "message",
                    "role": "system",
                    "content": {"type": "input_text", "text": "You are a helpful assistant."},
                },
                {
                    "type": "message",
                    "role": "user",
                    "content": {
                        "type": "input_text",
                        "text": "{{item.text}}",
                    },
                },
            ],
        },
        "model": "gpt-4.1",
        "sampling_params": {
            "seed": 42,
            "temperature": 0.7,
            "max_completions_tokens": 100,
            "top_p": 0.9,
            "text": {
                "format": {
                    "type": "json_schema",
                    "name": "sentiment_output",
                    "schema": sentiment_output_schema,
                    "strict": True,
                },
            },
        },
    },
)
```

### Visualize evals data
![image](../../../images/evals_sentiment.png)

### Summary and Next Steps

In this notebook, we have demonstrated how to use the OpenAI Evaluation API to evaluate a model's performance on a structured output task.

**Next steps:**
- We encourage you to try out the API with your own models and datasets.
- You can also explore the API documentation for more details on how to use the API.

For more information, see the [OpenAI Evals documentation](https://platform.openai.com/docs/guides/evals).
