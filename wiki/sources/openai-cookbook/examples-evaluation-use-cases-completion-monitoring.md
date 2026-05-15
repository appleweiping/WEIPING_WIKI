---
title: "Completion Monitoring"
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
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/completion-monitoring
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/completion-monitoring.ipynb
---

# Completion Monitoring

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/completion-monitoring
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/completion-monitoring.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/completion-monitoring.ipynb
- Source path: `examples/evaluation/use-cases/completion-monitoring.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `add92128295e3c083ae1475154bc7dab08150113a643628c59c6a2c92a909370`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Evaluations Example: Push Notifications Summarizer Monitoring Evals are task-oriented and iterative, they're the best way to check how your LLM integration is doing and improve it. In the following eval, we are going to focus on the task of detecting our prompt changes for regressions . Our use-case is: 1. We have been logging chat completion requests by set...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Evaluations Example: Push Notifications Summarizer Monitoring

Evals are **task-oriented** and iterative, they're the best way to check how your LLM integration is doing and improve it.

In the following eval, we are going to focus on the task of **detecting our prompt changes for regressions**.

Our use-case is:
1. We have been logging chat completion requests by setting `store=True` in our production chat completions requests. Note that you can also enable "on by default" logging in your admin panel (https://platform.openai.com/settings/organization/data-controls/data-retention).
2. We want to see whether our prompt changes have introduced regressions.

## Evals structure

Evals have two parts, the "Eval" and the "Run". An "Eval" holds the configuration for your testing criteria and the structure of the data for your "Runs". An Eval can have many Runs, which are each evaluated using your testing criteria.

```python
from openai import AsyncOpenAI
import os
import asyncio

os.environ["OPENAI_API_KEY"] = os.environ.get("OPENAI_API_KEY", "your-api-key")
client = AsyncOpenAI()
```

## Use-case

We're testing the following integration, a push notifications summary, which takes in multiple push notifications and collapses them into a single one, this is a chat completions call.

# Generate our test data

I'm going to produce simulated production chat completions requests with two different prompt versions to test how each performs. The first is a "good" prompt, the second is a "bad" prompt. These will have different metadata which we'll use later.

```python
push_notification_data = [
        """
- New message from Sarah: "Can you call me later?"
- Your package has been delivered!
- Flash sale: 20% off electronics for the next 2 hours!
""",
        """
- Weather alert: Thunderstorm expected in your area.
- Reminder: Doctor's appointment at 3 PM.
- John liked your photo on Instagram.
""",
        """
- Breaking News: Local elections results are in.
- Your daily workout summary is ready.
- Check out your weekly screen time report.
""",
        """
- Your ride is arriving in 2 minutes.
- Grocery order has been shipped.
- Don't miss the season finale of your favorite show tonight!
""",
        """
- Event reminder: Concert starts at 7 PM.
- Your favorite team just scored!
- Flashback: Memories from 3 years ago.
""",
        """
- Low battery alert: Charge your device.
- Your friend Mike is nearby.
- New episode of "The Tech Hour" podcast is live!
""",
        """
- System update available.
- Monthly billing statement is ready.
- Your next meeting starts in 15 minutes.
""",
        """
- Alert: Unauthorized login attempt detected.
- New comment on your blog post: "Great insights!"
- Tonight's dinner recipe: Pasta Primavera.
""",
        """
- Special offer: Free coffee with any breakfast order.
- Your flight has been delayed by 30 minutes.
- New movie release: "Adventures Beyond" now streaming.
""",
        """
- Traffic alert: Accident reported on Main Street.
- Package out for delivery: Expected by 5 PM.
- New friend suggestion: Connect with Emma.
"""]
```

```python
PROMPTS = [
    (
        """
        You are a helpful assistant that summarizes push notifications.
        You are given a list of push notifications and you need to collapse them into a single one.
        Output only the final summary, nothing else.
        """,
        "v1"
    ),
    (
        """
        You are a helpful assistant that summarizes push notifications.
        You are given a list of push notifications and you need to collapse them into a single one.
        The summary should be longer than it needs to be and include more information than is necessary.
        Output only the final summary, nothing else.
        """,
        "v2"
    )
]

tasks = []
for notifications in push_notification_data:
    for (prompt, version) in PROMPTS:
        tasks.append(client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "developer", "content": prompt},
                {"role": "user", "content": notifications},
            ],
            store=True,
            metadata={"prompt_version": version, "usecase": "push_notifications_summarizer"},
        ))
await asyncio.gather(*tasks)
```

You can view the completions you just created at https://platform.openai.com/logs.

**Make sure that the chat completions show up, as they are necessary for the next step.**

```python
completions = await client.chat.completions.list()
assert completions.data, "No completions found. You may need to enable logs in your admin panel."
completions.data[0]
```

# Setting up your eval

An Eval holds the configuration that is shared across multiple *Runs*, it has two components:
1. Data source configuration `data_source_config` - the schema (columns) that your future *Runs* conform to.
    - The `data_source_config` uses JSON Schema to define what variables are available in the Eval.
2. Testing Criteria `testing_criteria` - How you'll determine if your integration is working for each *row* of your data source.

For this use-case, we're using stored-completions, so we'll set up that data_source_config

**Important**
You are likely to have many different stored completions use-cases, metadata is the best way to keep track of this for evals to keep them focused and task oriented.

```python
# We want our input data to be available in our variables, so we set the item_schema to
# PushNotifications.model_json_schema()
data_source_config = {
    "type": "stored_completions",
    "metadata": {
        "usecase": "push_notifications_summarizer"
    }
}
```

This data_source_config defines what variables are available throughout the eval.

The stored completions config provides two variables for you to use throughout your eval:
1. {{item.input}} - the messages sent to the completions call
2. {{sample.output_text}} - the text response from the assistant

**Now, we'll use those variables to set up our test criteria.**

```python
GRADER_DEVELOPER_PROMPT = """
Label the following push notification summary as either correct or incorrect.
The push notification and the summary will be provided below.
A good push notificiation summary is concise and snappy.
If it is good, then label it as correct, if not, then incorrect.
"""
GRADER_TEMPLATE_PROMPT = """
Push notifications: {{item.input}}
Summary: {{sample.output_text}}
"""
push_notification_grader = {
    "name": "Push Notification Summary Grader",
    "type": "label_model",
    "model": "o3-mini",
    "input": [
        {
            "role": "developer",
            "content": GRADER_DEVELOPER_PROMPT,
        },
        {
            "role": "user",
            "content": GRADER_TEMPLATE_PROMPT,
        },
    ],
    "passing_labels": ["correct"],
    "labels": ["correct", "incorrect"],
}
```

The `push_notification_grader` is a model grader (llm-as-a-judge), which looks at the input `{{item.input}}` and the generated summary `{{sample.output_text}}` and labels it as "correct" or "incorrect".

Note: under the hood, this uses structured outputs so that labels are always valid.

**Now we'll create our eval!, and start adding data to it**

```python
eval_create_result = await client.evals.create(
    name="Push Notification Completion Monitoring",
    metadata={"description": "This eval monitors completions"},
    data_source_config=data_source_config,
    testing_criteria=[push_notification_grader],
)

eval_id = eval_create_result.id
```

# Creating runs

Now that we have our eval set-up with our test_criteria, we can start adding runs.
I want to compare the performance between my two **prompt versions**

To do this, we just define our source as "stored_completions" with a metadata filter for each of our prompt versions.

```python
# Grade prompt_version=v1
eval_run_result = await client.evals.runs.create(
    eval_id=eval_id,
    name="v1-run",
    data_source={
        "type": "completions",
        "source": {
            "type": "stored_completions",
            "metadata": {
                "prompt_version": "v1",
            }
        }
    }
)
print(eval_run_result.report_url)
```

```python
# Grade prompt_version=v2
eval_run_result_v2 = await client.evals.runs.create(
    eval_id=eval_id,
    name="v2-run",
    data_source={
        "type": "completions",
        "source": {
            "type": "stored_completions",
            "metadata": {
                "prompt_version": "v2",
            }
        }
    }
)
print(eval_run_result_v2.report_url)
```

Just for to be thorough, let's see how this prompt would do with 4o, instead of 4o-mini, with both prompt versions as the starting point.

All we have to do is reference the input messages ({{item.input}}) and set the model to 4o. Since we don't already have any stored completions for 4o, this eval run will generate new completions.

```python
tasks = []
for prompt_version in ["v1", "v2"]:
    tasks.append(client.evals.runs.create(
        eval_id=eval_id,
        name=f"post-fix-new-model-run-{prompt_version}",
        data_source={
            "type": "completions",
            "input_messages": {
                "type": "item_reference",
                "item_reference": "item.input",
            },
            "model": "gpt-4o",
            "source": {
                "type": "stored_completions",
                "metadata": {
                    "prompt_version": prompt_version,
                }
            }
        },
    ))
result = await asyncio.gather(*tasks)
for run in result:
    print(run.report_url)
```

If you view that report, you'll see that we can see that prompt_version=v2 has a regression!

## Congratulations, you just discovered a bug, you could revert it, or make another prompt change, etc.!
