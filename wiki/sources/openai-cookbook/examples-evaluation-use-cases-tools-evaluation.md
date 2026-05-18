---
title: "Tools Evaluation"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - evals
  - evaluation
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/tools-evaluation
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/tools-evaluation.ipynb
---

# Tools Evaluation

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/tools-evaluation
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/tools-evaluation.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/tools-evaluation.ipynb
- Source path: `examples/evaluation/use-cases/tools-evaluation.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `1fea22d97cbf32d5263d037b483bbcfd7b93a66a5f999b78c01b783b88a79754`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Tool Evaluation with OpenAI Evals This cookbook shows how to measure and improve a model’s ability to extract structured information from source code with tool evaluation. In this case, the set of symbols (functions, classes, methods, and variables) defined in Python files. Setup<a name="Setup" </a Install the latest openai Python package ≥ 1.14.0 and set yo...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.
- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Tool Evaluation with OpenAI Evals

This cookbook shows how to **measure and improve a model’s ability to extract structured information from source code** with tool evaluation. In this case, the set of *symbols* (functions, classes, methods, and variables) defined in Python files.

## Setup<a name="Setup"></a>

Install the latest **openai** Python package ≥ 1.14.0 and set your `OPENAI_API_KEY` environment variable.  If you also want to evaluate an *assistant with tools*, enable the *Assistants v2 beta* in your account.

```bash
pip install --upgrade openai
export OPENAI_API_KEY=sk‑...
```
Below we import the SDK, create a client, and define a helper that builds a small dataset from files inside the **openai** package itself.

```python
%pip install --upgrade openai pandas jinja2 rich --quiet

import os
import time
import openai
from rich import print

client = openai.OpenAI(
    api_key=os.getenv("OPENAI_API_KEY") or os.getenv("_OPENAI_API_KEY"),
)
```

### Dataset factory & grading rubric
* `get_dataset` builds a small in-memory dataset by reading several SDK files.
* `structured_output_grader` defines a detailed evaluation rubric.
* `sampled.output_tools[0].function.arguments.symbols` specifies the extracted symbols from the code file based on the tool invocation.
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
{{sample.output_tools[0].function.arguments.symbols}}
</Extracted Information>
"""
```

### Evals Creation

Here we create an eval that will be used to evaluate the quality of extracted information from code files.

```python
logs_eval = client.evals.create(
    name="Code QA Eval",
    data_source_config={
        "type": "custom",
        "item_schema": {"type": "object", "properties": {"input": {"type": "string"}}},
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
            "pass_threshold": 5.0,
        }
    ],
)

symbol_tool = {
    "name": "extract_symbols",
    "description": "Extract the symbols from the code file",
    "parameters": {
        "type": "object",
        "properties": {
            "symbols": {
                "type": "array",
                "description": "A list of symbols extracted from Python code.",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string", "description": "The name of the symbol."},
                        "symbol_type": {"type": "string", "description": "The type of the symbol, e.g., variable, function, class."},
                    },
                    "required": ["name", "symbol_type"],
                    "additionalProperties": False,
                },
            }
        },
        "required": ["symbols"],
        "additionalProperties": False,
    },
}
```

### Kick off model runs
Here we launch two runs against the same eval: one that calls the **Completions** endpoint, and one that calls the **Responses** endpoint.

```python
gpt_4one_completions_run = client.evals.runs.create(
    name="gpt-4.1",
    eval_id=logs_eval.id,
    data_source={
        "type": "completions",
        "source": {"type": "file_content", "content": [{"item": item} for item in get_dataset(limit=1)]},
        "input_messages": {
            "type": "template",
            "template": [
                {"type": "message", "role": "system", "content": {"type": "input_text", "text": "You are a helpful assistant."}},
                {"type": "message", "role": "user", "content": {"type": "input_text", "text": "Extract the symbols from the code file {{item.input}}"}},
            ],
        },
        "model": "gpt-4.1",
        "sampling_params": {
            "seed": 42,
            "temperature": 0.7,
            "max_completions_tokens": 10000,
            "top_p": 0.9,
            "tools": [{"type": "function", "function": symbol_tool}],
        },
    },
)

gpt_4one_responses_run = client.evals.runs.create(
    name="gpt-4.1-mini",
    eval_id=logs_eval.id,
    data_source={
        "type": "responses",
        "source": {"type": "file_content", "content": [{"item": item} for item in get_dataset(limit=1)]},
        "input_messages": {
            "type": "template",
            "template": [
                {"type": "message", "role": "system", "content": {"type": "input_text", "text": "You are a helpful assistant."}},
                {"type": "message", "role": "user", "content": {"type": "input_text", "text": "Extract the symbols from the code file {{item.input}}"}},
            ],
        },
        "model": "gpt-4.1-mini",
        "sampling_params": {
            "seed": 42,
            "temperature": 0.7,
            "max_completions_tokens": 10000,
            "top_p": 0.9,
            "tools": [{"type": "function", **symbol_tool}],
        },
    },
)
```

### Utility Poller

We create a utility poller that will be used to poll for the results of the eval runs.

```python
def poll_runs(eval_id, run_ids):
    # poll both runs at the same time, until they are complete or failed
    while True:
        runs = [client.evals.runs.retrieve(run_id, eval_id=eval_id) for run_id in run_ids]
        for run in runs:
            print(run.id, run.status, run.result_counts)
        if all(run.status in ("completed", "failed") for run in runs):
            break
        time.sleep(5)


poll_runs(logs_eval.id, [gpt_4one_completions_run.id, gpt_4one_responses_run.id])
```

```python

### Get Output
completions_output = client.evals.runs.output_items.list(
    run_id=gpt_4one_completions_run.id, eval_id=logs_eval.id
)

responses_output = client.evals.runs.output_items.list(
    run_id=gpt_4one_responses_run.id, eval_id=logs_eval.id
)
```

### Inspecting results<a name="Inspecting-results"></a>

For both completions and responses, we print the *symbols* dictionary that the model returned. You can diff this against the reference answer or compute precision / recall.

```python
import json
import pandas as pd
from IPython.display import display, HTML

def extract_symbols(output_list):
    symbols_list = []
    for item in output_list:
        try:
            args = item.sample.output[0].tool_calls[0]["function"]["arguments"]
            symbols = json.loads(args)["symbols"]
            symbols_list.append(symbols)
        except Exception as e:
            symbols_list.append([{"error": str(e)}])
    return symbols_list

completions_symbols = extract_symbols(completions_output)
responses_symbols = extract_symbols(responses_output)

def symbols_to_html_table(symbols):
    if symbols and isinstance(symbols, list):
        df = pd.DataFrame(symbols)
        return (
            df.style
            .set_properties(**{
                'white-space': 'pre-wrap',
                'word-break': 'break-word',
                'padding': '2px 6px',
                'border': '1px solid #C3E7FA',
                'font-size': '0.92em',
                'background-color': '#FDFEFF'
            })
            .set_table_styles([{
                'selector': 'th',
                'props': [
                    ('font-size', '0.95em'),
                    ('background-color', '#1CA7EC'),
                    ('color', '#fff'),
                    ('border-bottom', '1px solid #18647E'),
                    ('padding', '2px 6px')
                ]
            }])
            .hide(axis='index')
            .to_html()
        )
    return f"<div style='padding:4px 0;color:#D9534F;font-style:italic;font-size:0.9em'>{str(symbols)}</div>"

table_rows = []
max_len = max(len(completions_symbols), len(responses_symbols))
for i in range(max_len):
    c_html = symbols_to_html_table(completions_symbols[i]) if i < len(completions_symbols) else ""
    r_html = symbols_to_html_table(responses_symbols[i]) if i < len(responses_symbols) else ""
    table_rows.append(f"""
      <tr style="height:1.2em;">
          <td style="vertical-align:top; background:#F6F8FA; border-right:1px solid #E3E3E3; padding:2px 4px;">{c_html}</td>
          <td style="vertical-align:top; background:#F6F8FA; padding:2px 4px;">{r_html}</td>
      </tr>
    """)

table_html = f"""
<div style="margin-bottom:0.5em;margin-top:0.2em;">
  <h4 style="color:#1CA7EC;font-weight:600;letter-spacing:0.5px;
     text-shadow:0 1px 2px rgba(0,0,0,0.06), 0 0px 0px #fff;font-size:1.05em;margin:0 0 0.35em 0;">
    Completions vs Responses Output Symbols
  </h4>
  <table style="border-collapse:separate;border-spacing:0 0.2em;width:100%;border-radius:5px;overflow:hidden;box-shadow:0 1px 7px #BEE7FA22;">
    <thead>
      <tr style="height:1.4em;">
              <th style="width:50%;background:#323C50;color:#fff;font-size:1em;padding:6px 10px;border-bottom:2px solid #1CA7EC;text-align:center;">Completions Output</th>
      <th style="width:50%;background:#323C50;color:#fff;font-size:1em;padding:6px 10px;border-bottom:2px solid #1CA7EC;text-align:center;">Responses Output</th>
      </tr>
    </thead>
    <tbody>
      {''.join(table_rows)}
    </tbody>
  </table>
</div>
"""

display(HTML(table_html))
```

### Visualize Evals Dashboard

You can navigate to the Evals Dashboard in order to visualize the data.


![evals_tool_dashboard](../../../images/evals_tool_dashboard.png)


You can also take a look at the explanation of the failed results in the Evals Dashboard after the run is complete as shown in the image below.

![evals_tool_failed](../../../images/eval_tools_fail.png)

This notebook demonstrated how to use OpenAI Evals to assess and improve a model’s ability to extract structured information from Python code using tool calls.


OpenAI Evals provides a robust, reproducible framework for evaluating LLMs on structured extraction tasks. By combining clear tool schemas, rigorous grading rubrics, and well-structured datasets, you can measure and improve overall performance.

*For more details, see the [OpenAI Evals documentation](https://platform.openai.com/docs/guides/evals).*
