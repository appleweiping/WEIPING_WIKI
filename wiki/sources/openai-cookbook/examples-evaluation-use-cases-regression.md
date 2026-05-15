---
title: "Regression"
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
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/regression
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/regression.ipynb
---

# Regression

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/regression
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/regression.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/regression.ipynb
- Source path: `examples/evaluation/use-cases/regression.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `78070554aded313806cf21f445bdf765fae5f587569dcc427807def9f9410aac`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Evaluations Example: Push Notifications Summarizer Prompt Regression, Evals are task oriented and iterative, they're the best way to check how your LLM integration is doing and improve it. In the following eval, we are going to focus on the task of detecting if my prompt change is a regression . Our use-case is: 1. I have an llm integration that takes a list...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Evaluations Example: Push Notifications Summarizer Prompt Regression,

Evals are **task oriented** and iterative, they're the best way to check how your LLM integration is doing and improve it.

In the following eval, we are going to focus on the task of **detecting if my prompt change is a regression**.

Our use-case is:
1. I have an llm integration that takes a list of push notifications and summarizes them into a single condensed statement.
2. I want to detect if a prompt change regresses the behavior

## Evals structure

Evals have two parts, the "Eval" and the "Run". An "Eval" holds the configuration for your testing criteria and the structure of the data for your "Runs". An Eval can have many runs that are evaluated by your testing criteria.

```python
import openai
from openai.types.chat import ChatCompletion
import pydantic
import os

os.environ["OPENAI_API_KEY"] = os.environ.get("OPENAI_API_KEY", "your-api-key")
```

## Use-case

We're testing the following integration, a push notifications summary, which takes in multiple push notifications and collapses them into a single one, this is a chat completions call.

```python
class PushNotifications(pydantic.BaseModel):
    notifications: str

print(PushNotifications.model_json_schema())
```

```python
DEVELOPER_PROMPT = """
You are a helpful assistant that summarizes push notifications.
You are given a list of push notifications and you need to collapse them into a single one.
Output only the final summary, nothing else.
"""

def summarize_push_notification(push_notifications: str) -> ChatCompletion:
    result = openai.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "developer", "content": DEVELOPER_PROMPT},
            {"role": "user", "content": push_notifications},
        ],
    )
    return result

example_push_notifications_list = PushNotifications(notifications="""
- Alert: Unauthorized login attempt detected.
- New comment on your blog post: "Great insights!"
- Tonight's dinner recipe: Pasta Primavera.
""")
result = summarize_push_notification(example_push_notifications_list.notifications)
print(result.choices[0].message.content)
```

# Setting up your eval

An Eval holds the configuration that is shared across multiple *Runs*, it has two components:
1. Data source configuration `data_source_config` - the schema (columns) that your future *Runs* conform to.
    - The `data_source_config` uses JSON Schema to define what variables are available in the Eval.
2. Testing Criteria `testing_criteria` - How you'll determine if your integration is working for each *row* of your data source.

For this use-case, we want to test if the push notification summary completion is good, so we'll set-up our eval with this in mind.

```python
# We want our input data to be available in our variables, so we set the item_schema to
# PushNotifications.model_json_schema()
data_source_config = {
    "type": "custom",
    "item_schema": PushNotifications.model_json_schema(),
    # We're going to be uploading completions from the API, so we tell the Eval to expect this
    "include_sample_schema": True,
}
```

This data_source_config defines what variables are available throughout the eval.

This item schema:
```json
{
  "properties": {
    "notifications": {
      "title": "Notifications",
      "type": "string"
    }
  },
  "required": ["notifications"],
  "title": "PushNotifications",
  "type": "object"
}
```
Means that we'll have the variable `{{item.notifications}}` available in our eval.

`"include_sample_schema": True`
Mean's that we'll have the variable `{{sample.output_text}}` available in our eval.

**Now, we'll use those variables to set up our test criteria.**

```python
GRADER_DEVELOPER_PROMPT = """
Label the following push notification summary as either correct or incorrect.
The push notification and the summary will be provided below.
A good push notificiation summary is concise and snappy.
If it is good, then label it as correct, if not, then incorrect.
"""
GRADER_TEMPLATE_PROMPT = """
Push notifications: {{item.notifications}}
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

The `push_notification_grader` is a model grader (llm-as-a-judge), which looks at the input `{{item.notifications}}` and the generated summary `{{sample.output_text}}` and labels it as "correct" or "incorrect".
We then instruct via. the "passing_labels", what constitutes a passing answer.

Note: under the hood, this uses structured outputs so that labels are always valid.

**Now we'll create our eval!, and start adding data to it**

```python
eval_create_result = openai.evals.create(
    name="Push Notification Summary Workflow",
    metadata={
        "description": "This eval checks if the push notification summary is correct.",
    },
    data_source_config=data_source_config,
    testing_criteria=[push_notification_grader],
)

eval_id = eval_create_result.id
```

# Creating runs

Now that we have our eval set-up with our test_criteria, we can start to add a bunch of runs!
We'll start with some push notification data.

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

Our first run will be our default grader from the completions function above `summarize_push_notification`
We'll loop through our dataset, make completions calls, and then submit them as a run to be graded.

```python
run_data = []
for push_notifications in push_notification_data:
    result = summarize_push_notification(push_notifications)
    run_data.append({
        "item": PushNotifications(notifications=push_notifications).model_dump(),
        "sample": result.model_dump()
    })

eval_run_result = openai.evals.runs.create(
    eval_id=eval_id,
    name="baseline-run",
    data_source={
        "type": "jsonl",
        "source": {
            "type": "file_content",
            "content": run_data,
        }
    },
)
print(eval_run_result)
# Check out the results in the UI
print(eval_run_result.report_url)
```

Now let's simulate a regression, here's our original prompt, let's simulate a developer breaking the prompt.

```python
DEVELOPER_PROMPT = """
You are a helpful assistant that summarizes push notifications.
You are given a list of push notifications and you need to collapse them into a single one.
Output only the final summary, nothing else.
"""
```

```python
DEVELOPER_PROMPT = """
You are a helpful assistant that summarizes push notifications.
You are given a list of push notifications and you need to collapse them into a single one.
You should make the summary longer than it needs to be and include more information than is necessary.
"""

def summarize_push_notification_bad(push_notifications: str) -> ChatCompletion:
    result = openai.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "developer", "content": DEVELOPER_PROMPT},
            {"role": "user", "content": push_notifications},
        ],
    )
    return result
```

```python
run_data = []
for push_notifications in push_notification_data:
    result = summarize_push_notification_bad(push_notifications)
    run_data.append({
        "item": PushNotifications(notifications=push_notifications).model_dump(),
        "sample": result.model_dump()
    })

eval_run_result = openai.evals.runs.create(
    eval_id=eval_id,
    name="regression-run",
    data_source={
        "type": "jsonl",
        "source": {
            "type": "file_content",
            "content": run_data,
        }
    },
)
print(eval_run_result.report_url)
```

If you view that report, you'll see that it has a score that's much lower than the baseline-run.

## Congratulations, you just prevented a bug from shipping to users

Quick note:
Evals doesn't yet support the `responses` api natively, however, you can transform it to the `completions` format with the following code.

```python
def summarize_push_notification_responses(push_notifications: str):
    result = openai.responses.create(
                model="gpt-4o",
                input=[
                    {"role": "developer", "content": DEVELOPER_PROMPT},
                    {"role": "user", "content": push_notifications},
                ],
            )
    return result
def transform_response_to_completion(response):
    completion = {
        "model": response.model,
        "choices": [{
        "index": 0,
        "message": {
            "role": "assistant",
            "content": response.output_text
        },
        "finish_reason": "stop",
    }]
    }
    return completion

run_data = []
for push_notifications in push_notification_data:
    response = summarize_push_notification_responses(push_notifications)
    completion = transform_response_to_completion(response)
    run_data.append({
        "item": PushNotifications(notifications=push_notifications).model_dump(),
        "sample": completion
    })

report_response = openai.evals.runs.create(
    eval_id=eval_id,
    name="responses-run",
    data_source={
        "type": "jsonl",
        "source": {
            "type": "file_content",
            "content": run_data,
        }
    },
)
print(report_response.report_url)
```
