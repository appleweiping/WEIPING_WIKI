---
title: "Responses Evaluation"
type: source
status: mirrored
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
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/responses-evaluation
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/responses-evaluation.ipynb
---

# Responses Evaluation

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/responses-evaluation
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/responses-evaluation.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/responses-evaluation.ipynb
- Source path: `examples/evaluation/use-cases/responses-evaluation.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `1c4cea08fad68fd80146514beb6d3bb2500f853899f1a36178b80c2656da1b3a`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Evaluating a new model on existing responses In the following eval, we are going to compare how a new model (gpt-4.1-mini) compares to our old model (gpt-4o-mini) by evaluating it on some stored responses. The benefit of this is for most developers, they won't have to spend any time putting together a whole eval -- all of their data will already be stored in...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Evaluating a new model on existing responses

In the following eval, we are going to compare how a new model (gpt-4.1-mini) compares to our old model (gpt-4o-mini) by evaluating it on some stored responses. The benefit of this is for most developers, they won't have to spend any time putting together a whole eval -- all of their data will already be stored in their [logs page](https://platform.openai.com/logs).

```python
import openai
import os


client = openai.OpenAI()
```

We want to see how gpt-4.1 compares to gpt-4o on explaining a code base. Since can only use the responses datasource if you already have user traffic, we're going to generate some example traffic using 4o, and then compare how it does to gpt-4.1.

We're going to get some example code files from the OpenAI SDK, and ask gpt-4o to explain them to us.

```python
openai_sdk_file_path = os.path.dirname(openai.__file__)

# Get some example code files from the OpenAI SDK
file_paths   = [
    os.path.join(openai_sdk_file_path, "resources", "evals", "evals.py"),
    os.path.join(openai_sdk_file_path, "resources", "responses", "responses.py"),
    os.path.join(openai_sdk_file_path, "resources", "images.py"),
    os.path.join(openai_sdk_file_path, "resources", "embeddings.py"),
    os.path.join(openai_sdk_file_path, "resources", "files.py"),
]

print(file_paths[0])
```

Now, lets generate some responses.

```python
for file_path in file_paths:
    response = client.responses.create(
        input=[
            {"role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": "What does this file do?"
                },
                {
                    "type": "input_text",
                    "text": open(file_path, "r").read(),
                },
            ]},
        ],
        model="gpt-4o-mini",
    )
    print(response.output_text)
```

Note that in order for this to work, you'll have to be doing this on an org where data logging isn't disabled (through zdr, etc). If you aren't sure if this is the case for you, go to https://platform.openai.com/logs?api=responses and see if you can see the responses you just generated.

```python
grader_system_prompt = """
You are **Code-Explanation Grader**, an expert software engineer and technical writer.
Your job is to score how well *Model A* explained the purpose and behaviour of a given source-code file.

### What you receive
1. **File contents** – the full text of the code file (or a representative excerpt).
2. **Candidate explanation** – the answer produced by Model A that tries to describe what the file does.

### What to produce
Return a single JSON object that can be parsed by `json.loads`, containing:
```json
{
  "steps": [
    { "description": "...", "result": "float" },
    { "description": "...", "result": "float" },
    { "description": "...", "result": "float" }
  ],
  "result": "float"
}
```
• Each object in `steps` documents your reasoning for one category listed under “Scoring dimensions”.
• Place your final 1 – 7 quality score (inclusive) in the top-level `result` key as a **string** (e.g. `"5.5"`).

### Scoring dimensions (evaluate in this order)

1. **Correctness & Accuracy ≈ 45 %**
   • Does the explanation match the actual code behaviour, interfaces, edge cases, and side effects?
   • Fact-check every technical claim; penalise hallucinations or missed key functionality.

2. **Completeness & Depth ≈ 25 %**
   • Are all major components, classes, functions, data flows, and external dependencies covered?
   • Depth should be appropriate to the file’s size/complexity; superficial glosses lose points.

3. **Clarity & Organization ≈ 20 %**
   • Is the explanation well-structured, logically ordered, and easy for a competent developer to follow?
   • Good use of headings, bullet lists, and concise language is rewarded.

4. **Insight & Usefulness ≈ 10 %**
   • Does the answer add valuable context (e.g., typical use cases, performance notes, risks) beyond line-by-line paraphrase?
   • Highlighting **why** design choices matter is a plus.

### Error taxonomy
• **Major error** – Any statement that materially misrepresents the file (e.g., wrong API purpose, inventing non-existent behaviour).
• **Minor error** – Small omission or wording that slightly reduces clarity but doesn’t mislead.
List all found errors in your `steps` reasoning.

### Numeric rubric
1  Catastrophically wrong; mostly hallucination or irrelevant.
2  Many major errors, few correct points.
3  Several major errors OR pervasive minor mistakes; unreliable.
4  Mostly correct but with at least one major gap or multiple minors; usable only with caution.
5  Solid, generally correct; minor issues possible but no major flaws.
6  Comprehensive, accurate, and clear; only very small nit-picks.
7  Exceptional: precise, thorough, insightful, and elegantly presented; hard to improve.

Use the full scale. Reserve 6.5 – 7 only when you are almost certain the explanation is outstanding.

Then set `"result": "4.0"` (example).

Be rigorous and unbiased.
"""
user_input_message = """**User input**

{{item.input}}

**Response to evaluate**

{{sample.output_text}}
"""
```

```python
logs_eval = client.evals.create(
    name="Code QA Eval",
    data_source_config={
        "type": "logs",
    },
    testing_criteria=[
        {
			"type": "score_model",
            "name": "General Evaluator",
            "model": "o3",
            "input": [{
                "role": "system",
                "content": grader_system_prompt,
            }, {
                "role": "user",
                "content": user_input_message,
            },
            ],
            "range": [1, 7],
            "pass_threshold": 5.5,
        }
    ]
)
```

First, lets kick off a run to evaluate how good the original responses were. To do this, we just set the filters for what responses we want to evaluate on

```python
gpt_4o_mini_run = client.evals.runs.create(
    name="gpt-4o-mini",
    eval_id=logs_eval.id,
    data_source={
        "type": "responses",
        "source": {"type": "responses", "limit": len(file_paths)}, # just grab the most recent responses
    },
)
```

Now, let's see how 4.1-mini does!

```python
gpt_41_mini_run = client.evals.runs.create(
    name="gpt-4.1-mini",
    eval_id=logs_eval.id,
    data_source={
        "type": "responses",
        "source": {"type": "responses", "limit": len(file_paths)},
        "input_messages": {
            "type": "item_reference",
            "item_reference": "item.input",
        },
        "model": "gpt-4.1-mini",
    }
)
```

Now, lets go to the dashboard to see how we did!

```python
gpt_4o_mini_run.report_url
```
