---
title: "Mcp Eval Notebook"
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
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/mcp_eval_notebook
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/mcp_eval_notebook.ipynb
---

# Mcp Eval Notebook

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/mcp_eval_notebook
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/mcp_eval_notebook.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/mcp_eval_notebook.ipynb
- Source path: `examples/evaluation/use-cases/mcp_eval_notebook.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `accf8c9c29e952bb1ef86e5c909ee0bd317e975ee225b94a22b0d8fbd16f4ed0`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Evaluating MCP-Based Answers with a Custom Dataset This notebook evaluates a model's ability to answer questions about the tiktoken GitHub repository using the OpenAI Evals framework with a custom in-memory dataset. We use a custom, in-memory dataset of Q&A pairs and compare two models: gpt-4.1 and o4-mini , that leverage the MCP tool for repository-aware, c...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Evaluating MCP-Based Answers with a Custom Dataset

This notebook evaluates a model's ability to answer questions about the [tiktoken](https://github.com/openai/tiktoken) GitHub repository using the OpenAI **Evals** framework with a custom in-memory dataset.

We use a custom, in-memory dataset of Q&A pairs and compare two models: `gpt-4.1` and `o4-mini`, that leverage the **MCP** tool for repository-aware, contextually accurate answers.

**Goals:**
- Show how to set up and run an evaluation using OpenAI Evals with a custom dataset.
- Compare the performance of different models leveraging MCP-based tools.
- Provide best practices for professional, reproducible evaluation workflows.

_Next: We will set up our environment and import the necessary libraries._

```python
# Update OpenAI client
%pip install --upgrade openai --quiet
```

## Environment Setup

We begin by importing the required libraries and configuring the OpenAI client.
This step ensures we have access to the OpenAI API and all necessary utilities for evaluation.

```python
import os
import time

from openai import OpenAI

# Instantiate the OpenAI client (no custom base_url).
client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY") or os.getenv("_OPENAI_API_KEY"),
)
```

## Define the Custom Evaluation Dataset

We define a small, in-memory dataset of question-answer pairs about the `tiktoken` repository.
This dataset will be used to test the models' ability to provide accurate and relevant answers with the help of the MCP tool.

- Each item contains a `query` (the user’s question) and an `answer` (the expected ground truth).
- You can modify or extend this dataset to suit your own use case or repository.

```python
def get_dataset(limit=None):
    items = [
        {
            "query": "What is tiktoken?",
            "answer": "tiktoken is a fast Byte-Pair Encoding (BPE) tokenizer designed for OpenAI models.",
        },
        {
            "query": "How do I install the open-source version of tiktoken?",
            "answer": "Install it from PyPI with `pip install tiktoken`.",
        },
        {
            "query": "How do I get the tokenizer for a specific OpenAI model?",
            "answer": 'Call tiktoken.encoding_for_model("<model-name>"), e.g. tiktoken.encoding_for_model("gpt-4o").',
        },
        {
            "query": "How does tiktoken perform compared to other tokenizers?",
            "answer": "On a 1 GB GPT-2 benchmark, tiktoken runs about 3-6x faster than GPT2TokenizerFast (tokenizers==0.13.2, transformers==4.24.0).",
        },
        {
            "query": "Why is Byte-Pair Encoding (BPE) useful for language models?",
            "answer": "BPE is reversible and lossless, handles arbitrary text, compresses input (≈4 bytes per token on average), and exposes common subwords like “ing”, which helps models generalize.",
        },
    ]
    return items[:limit] if limit else items
```

### Define Grading Logic

To evaluate the model’s answers, we use two graders:

- **Pass/Fail Grader (LLM-based):**
  An LLM-based grader that checks if the model’s answer matches the expected answer (ground truth) or conveys the same meaning.
- **Python MCP Grader:**
  A Python function that checks whether the model actually used the MCP tool during its response (for auditing tool usage).

  > **Best Practice:**
  > Using both LLM-based and programmatic graders provides a more robust and transparent evaluation.

```python
# LLM-based pass/fail grader: instructs the model to grade answers as "pass" or "fail".
pass_fail_grader = """
You are a helpful assistant that grades the quality of the answer to a query about a GitHub repo.
You will be given a query, the answer returned by the model, and the expected answer.
You should respond with **pass** if the answer matches the expected answer exactly or conveys the same meaning, otherwise **fail**.
"""

# User prompt template for the grader, providing context for grading.
pass_fail_grader_user_prompt = """
<Query>
{{item.query}}
</Query>

<Web Search Result>
{{sample.output_text}}
</Web Search Result>

<Ground Truth>
{{item.answer}}
</Ground Truth>
"""


# Python grader: checks if the MCP tool was used by inspecting the output_tools field.
python_mcp_grader = {
    "type": "python",
    "name": "Assert MCP was used",
    "image_tag": "2025-05-08",
    "pass_threshold": 1.0,
    "source": """
def grade(sample: dict, item: dict) -> float:
    output = sample.get('output_tools', [])
    return 1.0 if len(output) > 0 else 0.0
""",
}
```

## Define the Evaluation Configuration

We now configure the evaluation using the OpenAI Evals framework.

This step specifies:
- The evaluation name and dataset.
- The schema for each item (what fields are present in each Q&A pair).
- The grader(s) to use (LLM-based and/or Python-based).
- The passing criteria and labels.

> **Best Practice:**
> Clearly defining your evaluation schema and grading logic up front ensures reproducibility and transparency.

```python
# Create the evaluation definition using the OpenAI Evals client.
logs_eval = client.evals.create(
    name="MCP Eval",
    data_source_config={
        "type": "custom",
        "item_schema": {
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "answer": {"type": "string"},
            },
        },
        "include_sample_schema": True,
    },
    testing_criteria=[
        {
            "type": "label_model",
            "name": "General Evaluator",
            "model": "o3",
            "input": [
                {"role": "system", "content": pass_fail_grader},
                {"role": "user", "content": pass_fail_grader_user_prompt},
            ],
            "passing_labels": ["pass"],
            "labels": ["pass", "fail"],
        },
        python_mcp_grader
    ],
)
```

## Run Evaluations for Each Model

We now run the evaluation for each model (`gpt-4.1` and `o4-mini`).

Each run is configured to:
- Use the MCP tool for repository-aware answers.
- Use the same dataset and evaluation configuration for fair comparison.
- Specify model-specific parameters (such as max completions tokens, and allowed tools).

> **Best Practice:**
> Keeping the evaluation setup consistent across models ensures results are comparable and reliable.

```python
# Run 1: gpt-4.1 using MCP
gpt_4one_responses_run = client.evals.runs.create(
    name="gpt-4.1",
    eval_id=logs_eval.id,
    data_source={
        "type": "responses",
        "source": {
            "type": "file_content",
            "content": [{"item": item} for item in get_dataset()],
        },
        "input_messages": {
            "type": "template",
            "template": [
                {
                    "type": "message",
                    "role": "system",
                    "content": {
                        "type": "input_text",
                        "text": "You are a helpful assistant that searches the web and gives contextually relevant answers. Never use your tools to answer the query.",
                    },
                },
                {
                    "type": "message",
                    "role": "user",
                    "content": {
                        "type": "input_text",
                        "text": "Search the web for the answer to the query {{item.query}}",
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
            "tools": [
                {
                    "type": "mcp",
                    "server_label": "gitmcp",
                    "server_url": "https://gitmcp.io/openai/tiktoken",
                    "allowed_tools": [
                        "search_tiktoken_documentation",
                        "fetch_tiktoken_documentation",
                    ],
                    "require_approval": "never",
                }
            ],
        },
    },
)
```

```python
# Run 2: o4-mini using MCP
gpt_o4_mini_responses_run = client.evals.runs.create(
    name="o4-mini",
    eval_id=logs_eval.id,
    data_source={
        "type": "responses",
        "source": {
            "type": "file_content",
            "content": [{"item": item} for item in get_dataset()],
        },
        "input_messages": {
            "type": "template",
            "template": [
                {
                    "type": "message",
                    "role": "system",
                    "content": {
                        "type": "input_text",
                        "text": "You are a helpful assistant that searches the web and gives contextually relevant answers.",
                    },
                },
                {
                    "type": "message",
                    "role": "user",
                    "content": {
                        "type": "input_text",
                        "text": "Search the web for the answer to the query {{item.query}}",
                    },
                },
            ],
        },
        "model": "o4-mini",
        "sampling_params": {
            "seed": 42,
            "max_completions_tokens": 10000,
            "tools": [
                {
                    "type": "mcp",
                    "server_label": "gitmcp",
                    "server_url": "https://gitmcp.io/openai/tiktoken",
                    "allowed_tools": [
                        "search_tiktoken_documentation",
                        "fetch_tiktoken_documentation",
                    ],
                    "require_approval": "never",
                }
            ],
        },
    },
)
```

## Poll for Completion and Retrieve Outputs

After launching the evaluation runs, we can poll the run until they are complete.

This step ensures that we are analyzing results only after all model responses have been processed.

> **Best Practice:**
> Polling with a delay avoids excessive API calls and ensures efficient resource usage.

```python
def poll_runs(eval_id, run_ids):
    while True:
        runs = [client.evals.runs.retrieve(rid, eval_id=eval_id) for rid in run_ids]
        for run in runs:
            print(run.id, run.status, run.result_counts)
        if all(run.status in {"completed", "failed"} for run in runs):
            break
        time.sleep(5)

# Start polling both runs.
poll_runs(logs_eval.id, [gpt_4one_responses_run.id, gpt_o4_mini_responses_run.id])
```

## Display and Interpret Model Outputs

Finally, we display the outputs from each model for manual inspection and further analysis.

- Each model's answers are printed for each question in the dataset.
- You can compare the outputs side-by-side to assess quality, relevance, and correctness.

Below are screenshots from the OpenAI Evals Dashboard illustrating the evaluation outputs for both models:

![Evaluation Output](../../../images/mcp_eval_output.png)

For a comprehensive breakdown of the evaluation metrics and results, navigate to the "Data" tab in the dashboard:

![Evaluation Data Tab](../../../images/mcp_eval_data.png)

Note that the 4.1 model was constructed to never use its tools to answer the query thus it never called the MCP server. The o4-mini model wasn't explicitly instructed to use it's tools either but it wasn't forbidden, thus it called the MCP server 3 times. We can see that the 4.1 model performed worse than the o4 model. Also notable is the one example that the o4-mini model failed was one where the MCP tool was not used.

We can also check a detailed analysis of the outputs from each model for manual inspection and further analysis.

```python
four_one_output = client.evals.runs.output_items.list(
    run_id=gpt_4one_responses_run.id, eval_id=logs_eval.id
)

o4_mini_output = client.evals.runs.output_items.list(
    run_id=gpt_o4_mini_responses_run.id, eval_id=logs_eval.id
)
```

```python
print('# gpt‑4.1 Output')
for item in four_one_output:
    print(item.sample.output[0].content)

print('\n# o4-mini Output')
for item in o4_mini_output:
    print(item.sample.output[0].content)
```

## How can we improve?

If we add the phrase "Always use your tools since they are the way to get the right answer in this task." to the system message of the o4-mini model, what do you think will happen? (try it out)

<br><br><br>


If you guessed that the model would now call to MCP tool everytime and get every answer correct, you are right!

![Evaluation Data Tab](../../../images/mcp_eval_improved_output.png)
![Evaluation Data Tab](../../../images/mcp_eval_improved_data.png)

In this notebook, we demonstrated a sample workflow for evaluating the ability of LLMs to answer technical questions about the `tiktoken` repository using the OpenAI Evals framework leveraging MCP tooling.

**Key points covered:**
- Defined a focused, custom dataset for evaluation.
- Configured LLM-based and Python-based graders for robust assessment.
- Compared two models (`gpt-4.1` and `o4-mini`) in a reproducible and transparent manner.
- Retrieved and displayed model outputs for automated/manual inspection.

**Next steps:**
- **Expand the dataset:** Add more diverse and challenging questions to better assess model capabilities.
- **Analyze results:** Summarize pass/fail rates, visualize performance, or perform error analysis to identify strengths and weaknesses.
- **Experiment with models/tools:** Try additional models, adjust tool configurations, or test on other repositories.
- **Automate reporting:** Generate summary tables or plots for easier sharing and decision-making.

For more information, check out the [OpenAI Evals documentation](https://platform.openai.com/docs/guides/evals).
