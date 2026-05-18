---
title: "Custom Llm As A Judge"
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
  - https://developers.openai.com/cookbook/examples/custom-llm-as-a-judge
  - https://github.com/openai/openai-cookbook/blob/main/examples/Custom-LLM-as-a-Judge.ipynb
---

# Custom Llm As A Judge

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/custom-llm-as-a-judge
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Custom-LLM-as-a-Judge.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Custom-LLM-as-a-Judge.ipynb
- Source path: `examples/Custom-LLM-as-a-Judge.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `c0863d3af73581fa257a0f66e751a5e63232e4c7e213616f984b566e9b8a50bc`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Building an LLM-as-a-judge evaluation to detect hallucinations with Braintrust Let's say you're working on a customer service bot and trying to evaluate the quality of its responses. Consider a question like "What is your return policy?" If the correct answer is "You can return items within 30 days of purchase," but your bot generates "You can return items w...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Building an LLM-as-a-judge evaluation to detect hallucinations with Braintrust

Let's say you're working on a customer service bot and trying to evaluate the quality of its responses. Consider a question like "What is your return policy?" If the correct answer is "You can return items within 30 days of purchase," but your bot generates "You can return items within 30 days," how would you evaluate whether this is a good response?

A heuristic like the `Levenshtein` string distance would indicate that the response is incorrect. However, a better approach is to use an LLM-as-a-judge to assess the accuracy of the response. LLM-as-a-judge is a technique that leverages an LLM to score the quality of answers. LLMs can reason about language beyond surface-level string comparisons, enabling them to evaluate answers more accurately.

In this cookbook, we'll walk through how to build an LLM-as-a-judge scorer that can detect hallucinations using [Braintrust](https://www.braintrust.dev/), a third-party evaluation platform that is compatible with OpenAI's models.

## Installing dependencies

Let's install a few basic dependencies. We'll use the CoQA dataset (via DuckDB), [Braintrust](https://www.braintrust.dev/) for evals, and [OpenAI's models](https://platform.openai.com/docs/models). Please note that Braintrust is a third-party evaluation platform and you should review their [terms of service and privacy policy](https://www.braintrust.dev/legal/terms-of-service) before proceeding.

```python
%pip install autoevals duckdb braintrust openai --quiet
```

Next, let's initialize the OpenAI client. We'll use the `AsyncOpenAI` client so that we can parallelize our requests. The `braintrust.wrap_openai` function
wraps the OpenAI client to enable logging LLM calls to [Braintrust](https://www.braintrust.dev/). We'll use Braintrust to facilitate the evaluations below.
Before proceeding, you should sign up for a [Braintrust account](https://www.braintrust.dev/signup) and set `BRAINTRUST_API_KEY` in your environment to a valid API key.

```python
import os

import braintrust
from openai import AsyncOpenAI

braintrust.login(api_key=os.environ["BRAINTRUST_API_KEY"])
client = braintrust.wrap_openai(AsyncOpenAI(api_key=os.environ["OPENAI_API_KEY"]))
```

## Explore the dataset

We'll use the [CoQA dataset](https://stanfordnlp.github.io/coqa/) which contains a diverse set of passages, questions, and answers. Because CoQA is quite large, we'll just look at the first several passages. As with any public dataset, there's a chance that the underlying LLMs have memorized aspects of the dataset, so when developing your own scorers, it's a good idea to test them using
your own private data.

```python
import duckdb

# DuckDB has an easy wrapper for loading datasets from Hugging Face.
con = duckdb.connect(":memory:")
full_result = con.query("""
    SELECT * FROM 'hf://datasets/stanfordnlp/coqa/data/validation-00000-of-00001.parquet'
        LIMIT 40
""").fetchall()

single_result = full_result[10]

print("Passage:")
print(single_result[1])

print("\nQuestion:")
print(single_result[2][0])

print("\nAnswer:")
print(single_result[3]["input_text"][0])
```

The data contains a series of passages, each with a number of questions and answers. Let's flatten this into a list of `(passage, question, answer)` tuples.

```python
from dataclasses import dataclass


@dataclass
class QuestionAnswer:
    passage: str
    question: str
    expected_answer: str
    generated_answer: str


qa_pairs = [
    QuestionAnswer(
        passage=r[1],
        question=question,
        generated_answer=r[3]["input_text"][i],
        expected_answer=r[3]["input_text"][i],
    )
    for r in full_result
    for (i, question) in enumerate(r[2])
]

print(len(qa_pairs))
```

### Adding hallucinations

Because Braintrust's scorer is designed to test hallucinations, we can use the QA pairs to generate known hallucinations. We'll create hallucinated answers by asking an
LLM to confidently generate an answer to each question without using the passage.

```python
import asyncio
import random

random.seed(42)


async def hallucinate_answer(qa):
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": """\
You are a helpful hallucinating assistant, who makes up fake answers to questions.

Answer the following question in 1 sentence. If you know the answer, then make up some fake
superfluous details that are not in the passage you have memorized.

Make sure to always answer it confidently, even if you don't know the answer. Do not use words
like "perhaps", "likely", "maybe", etc. or punctuation like "...".Do not admit that you cannot
or do not know the answer.""",
            },
            {"role": "user", "content": qa.question},
        ],
        temperature=1,
        max_tokens=100,
    )
    return response.choices[0].message.content


hallucinated_answers = await asyncio.gather(
    *[hallucinate_answer(qa) for qa in qa_pairs]
)


hallucinations = [
    QuestionAnswer(
        passage=qa.passage,
        question=qa.question,
        expected_answer=qa.expected_answer,
        generated_answer=hallucination,
    )
    for (qa, hallucination) in zip(qa_pairs, hallucinated_answers)
    # Exclude simple yes/no answers.
    if "yes" not in hallucination.lower() and "no" not in hallucination.lower()
]

print("Passage:")
print(hallucinations[0].passage)
print("\nQuestion:")
print(hallucinations[0].question)
print("\nExpected Answer:")
print(hallucinations[0].expected_answer)
print("\nGenerated Answer:")
print(hallucinations[0].generated_answer)

print("\n\nNumber of hallucinations:", len(hallucinations))
```

## Creating the evaluators

We'll consider a few popular approaches for creating an LLM-as-a-judge. For each approach, we'll create a scorer and then "meta-evaluate" it to see how it performs.
Since we know that the hallucinated answers are incorrect, we'll assess the quality of an evaluator by testing how often it scores the hallucinated answers as `0`.

### LLM-as-a-judge #1: Numeric rater

A common initial intuition when creating an LLM-as-a-judge is asking the LLM to rate the answer on a scale of 1 to 5. The benefit of this approach is that
it's easy to convert the LLM's output into a numeric score.

We'll use a modified version of the [Factuality](https://github.com/braintrustdata/autoevals/blob/main/templates/factuality.yaml) template, but ask the LLM to
rate the answer on a scale of 1 to 10.

```python
import json

PROMPT = """\
You are comparing a submitted answer to an expert answer on a given question. Here is the data:
[BEGIN DATA]
************
[Question]: {input}
************
[Expert]: {expected}
************
[Submission]: {output}
************
[END DATA]

Compare the factual content of the submitted answer with the expert answer. Ignore any differences in style, grammar, or punctuation.
Rate the submission on a scale of 1 to 10.
"""


@braintrust.traced
async def numeric_rater(input, output, expected):
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": PROMPT.format(input=input, output=output, expected=expected),
            }
        ],
        temperature=0,
        tools=[
            {
                "type": "function",
                "function": {
                    "name": "rate",
                    "description": "Rate the submission on a scale of 1 to 10.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "rating": {"type": "integer", "minimum": 1, "maximum": 10},
                        },
                        "required": ["rating"],
                    },
                },
            }
        ],
        tool_choice={"type": "function", "function": {"name": "rate"}},
    )
    arguments = json.loads(response.choices[0].message.tool_calls[0].function.arguments)
    return (arguments["rating"] - 1) / 9


print(qa_pairs[10].question, "On a correct answer:", qa_pairs[10].generated_answer)
print(
    await numeric_rater(
        qa_pairs[10].question,
        qa_pairs[10].generated_answer,
        qa_pairs[10].expected_answer,
    )
)

print(
    hallucinations[10].question,
    "On a hallucinated answer:",
    hallucinations[10].generated_answer,
)
print(
    await numeric_rater(
        hallucinations[10].question,
        hallucinations[10].generated_answer,
        hallucinations[10].expected_answer,
    )
)
```

This looks promising! Now that we have sanity checked it on a single example, let's run a proper evaluation and see how it performs on a wider set of data. An evaluation consists of three components:

- **Data**: In this case, the `input` is the question, hallucinated answer, and ground truth answer. The scorer will convert this into a score between 0 and 1. The expected score is 0, since it's a hallucination.
- **Task**: The task is simply calling the numeric rater for each input.
- **Scores**: We'll assess the quality of the generated score by comparing it with the ground truth score. Since we know both numbers are between 0 and 1, we can use the normalized difference as the score.

```python
from dataclasses import asdict

from braintrust import Eval


def data():
    for pair in hallucinations:
        yield dict(
            input=dict(asdict(pair)), expected=0, metadata=dict(hallucination=True)
        )


async def task(input):
    return await numeric_rater(
        input=input["question"],
        output=input["generated_answer"],
        expected=input["expected_answer"],
    )


def normalized_diff(output, expected):
    return 1 - abs(output - expected)


await Eval(
    "LLM-as-a-judge",
    data=data,
    task=task,
    scores=[normalized_diff],
    experiment_name="Numeric rater",
    max_concurrency=10,
)
```

It looks like the numeric rater scored almost 94% in total. That's not bad, but if 6% of your evals are incorrectly judged, that could make it very hard to trust them. Let's dig into the Braintrust
UI to get some insight into what's going on.

![Partial credit](../images/Custom-LLM-as-a-Judge-Partial-Credit.gif)

It looks like a number of the incorrect answers were scored with numbers between 1 and 10. However, we do not currently have any insight into why the model gave these scores. Let's see if we can
fix that next.

### LLM-as-a-judge #2: Adding reasoning

Let's tweak the prompt to get the LLM to also reason about its rating. This method is called [Chain of Thought Reasoning](https://en.wikipedia.org/wiki/Chain_of_thought_reasoning). In addition
to potentially improving the score, it will give us some insight into why the model gave these scores.

```python
@braintrust.traced
async def numeric_rater(input, output, expected):
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": PROMPT.format(input=input, output=output, expected=expected),
            }
        ],
        temperature=0,
        tools=[
            {
                "type": "function",
                "function": {
                    "name": "rate",
                    "description": "Rate the submission on a scale of 1 to 10.",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "reasons": {
                                "description": "Write out in a step by step manner your reasoning to be sure that your conclusion is correct. Avoid simply stating the correct answer at the outset.",
                                "title": "Reasoning",
                                "type": "string",
                            },
                            "rating": {"type": "integer", "minimum": 1, "maximum": 10},
                        },
                        "required": ["rating"],
                    },
                },
            }
        ],
        tool_choice={"type": "function", "function": {"name": "rate"}},
    )
    arguments = json.loads(response.choices[0].message.tool_calls[0].function.arguments)
    return (arguments["rating"] - 1) / 9


print(qa_pairs[10].question, "On a correct answer:", qa_pairs[10].generated_answer)
print(
    await numeric_rater(
        qa_pairs[10].question,
        qa_pairs[10].generated_answer,
        qa_pairs[10].expected_answer,
    )
)

print(
    hallucinations[10].question,
    "On a hallucinated answer:",
    hallucinations[10].generated_answer,
)
print(
    await numeric_rater(
        hallucinations[10].question,
        hallucinations[10].generated_answer,
        hallucinations[10].expected_answer,
    )
)
```

```python
await Eval(
    "LLM-as-a-judge",
    data=data,
    task=task,
    scores=[normalized_diff],
    experiment_name="Numeric rater with reasoning",
    max_concurrency=10,
)
```

It doesn't look like adding reasoning helped the score (in fact, it's 3% percent worse). However, if we look at one of the failures, we'll get some insight into
what the model was thinking. Here is an example of a hallucinated answer:

![Output](../images/Custom-LLM-as-a-Judge-Output.png)

And the score along with its reasoning:

![Reasoning](../images/Custom-LLM-as-a-Judge-Reasoning.png)

It looks like the model is applying its own judgement to compute partial credit. This is a common problem with numeric rating—both for models and for humans—and can often be solved
by using better prompting.

### LLM-as-a-judge #3: Classifying instead of rating

Next, we'll spell out specific criteria and ask the model to classify the answer according to those criteria. This method allows us to more precisely guide the model
towards the hallucinations we're testing for. Intuitively, giving the model specific criteria to rate will result in a more accurate score.

```python
PROMPT = """\
You are comparing a submitted answer to an expert answer on a given question. Here is the data:
[BEGIN DATA]
************
[Question]: {input}
************
[Expert]: {expected}
************
[Submission]: {output}
************
[END DATA]

Compare the factual content of the submitted answer with the expert answer. Ignore any differences in style, grammar, or punctuation.
The submitted answer may either be a subset or superset of the expert answer, or it may conflict with it. Determine which case applies. Answer the question by selecting one of the following options:
(A) The submitted answer is a subset of the expert answer and is fully consistent with it.
(B) The submitted answer is a superset of the expert answer and is fully consistent with it.
(C) The submitted answer contains all the same details as the expert answer.
(D) There is a disagreement between the submitted answer and the expert answer.
(E) The answers differ, but these differences don't matter from the perspective of factuality.

Answer the question by calling `select_choice` with your reasoning in a step-by-step matter to be
sure that your conclusion is correct. Avoid simply stating the correct answer at the outset. Select a
single choice by setting the `choice` parameter to a single choice from A, B, C, D, or E.
"""

# Since we're testing for hallucinations, penalize (B) as much as (D).
CHOICE_SCORES = {
    "A": 0.5,
    "B": 0,
    "C": 1,
    "D": 0,
    "E": 1,
}


@braintrust.traced
async def classifier(input, output, expected):
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": PROMPT.format(input=input, output=output, expected=expected),
            }
        ],
        temperature=0,
        tools=[
            {
                "type": "function",
                "function": {
                    "name": "rate",
                    "description": "Call this function to select a choice.",
                    "parameters": {
                        "properties": {
                            "reasons": {
                                "description": "Write out in a step by step manner your reasoning to be sure that your conclusion is correct. Avoid simply stating the correct answer at the outset.",
                                "type": "string",
                            },
                            "choice": {
                                "description": "The choice",
                                "type": "string",
                                "enum": ["A", "B", "C", "D", "E"],
                            },
                        },
                        "required": ["reasons", "choice"],
                        "type": "object",
                    },
                },
            }
        ],
        tool_choice={"type": "function", "function": {"name": "rate"}},
    )
    arguments = json.loads(response.choices[0].message.tool_calls[0].function.arguments)
    choice = arguments["choice"]
    return CHOICE_SCORES[choice] if choice in CHOICE_SCORES else None


print(qa_pairs[10].question, "On a correct answer:", qa_pairs[10].generated_answer)
print(
    await classifier(
        qa_pairs[10].question,
        qa_pairs[10].generated_answer,
        qa_pairs[10].expected_answer,
    )
)

print(
    hallucinations[10].question,
    "On a hallucinated answer:",
    hallucinations[10].generated_answer,
)
print(
    await classifier(
        hallucinations[10].question,
        hallucinations[10].generated_answer,
        hallucinations[10].expected_answer,
    )
)
```

```python
async def task(input):
    return await classifier(
        input=input["question"],
        output=input["generated_answer"],
        expected=input["expected_answer"],
    )


await Eval(
    "LLM-as-a-judge",
    data=data,
    task=task,
    scores=[normalized_diff],
    experiment_name="Classifier",
    max_concurrency=10,
)
```

The classifier scored 98% which is a significant improvement!

### Codifying this pattern

The classifier above can simply be rewritten as:

```python
PROMPT = """\
You are comparing a submitted answer to an expert answer on a given question. Here is the data:
[BEGIN DATA]
************
[Question]: {{input}}
************
[Expert]: {{expected}}
************
[Submission]: {{output}}
************
[END DATA]

Compare the factual content of the submitted answer with the expert answer. Ignore any differences in style, grammar, or punctuation.
The submitted answer may either be a subset or superset of the expert answer, or it may conflict with it. Determine which case applies. Answer the question by selecting one of the following options:
(A) The submitted answer is a subset of the expert answer and is fully consistent with it.
(B) The submitted answer is a superset of the expert answer and is fully consistent with it.
(C) The submitted answer contains all the same details as the expert answer.
(D) There is a disagreement between the submitted answer and the expert answer.
(E) The answers differ, but these differences don't matter from the perspective of factuality.

Answer the question by calling `select_choice` with your reasoning in a step-by-step matter to be
sure that your conclusion is correct. Avoid simply stating the correct answer at the outset. Select a
single choice by setting the `choice` parameter to a single choice from A, B, C, D, or E.
"""

Classifier = autoevals.LLMClassifier(
    name="Hallucination detector",
    prompt_template=PROMPT,
    choice_scores={"A": 0.5, "B": 0, "C": 1, "D": 0, "E": 1},
    use_cot=True,
)
```

## Next steps

As a next step, you could dig into the individual improvements and regressions to assess them and consider future improvements to the prompt. You could also test it on your own data, and double check that the results hold for your use case.
You could also measure a model like o1, try fine-tuning a smaller model and see if the results are reproducible, or use few-shot prompting to align the model with more subjective criteria.
In all cases, you should strive to evaluate your results, so you can rigorously assess the impact of each change.
