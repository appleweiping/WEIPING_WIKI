---
title: "Bulk Experimentation"
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
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/bulk-experimentation
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/bulk-experimentation.ipynb
---

# Bulk Experimentation

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/bulk-experimentation
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/bulk-experimentation.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/bulk-experimentation.ipynb
- Source path: `examples/evaluation/use-cases/bulk-experimentation.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `cb487bf76c2ce3d764d466a89f86969404c36b0e40538eca334f7cfc6529bf10`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Evaluations Example: Push Notifications Bulk Experimentation Evals are task oriented and iterative, they're the best way to check how your LLM integration is doing and improve it. In the following eval, we are going to focus on the task of testing many variants of models and prompts . Our use-case is: 1. I want to get the best possible performance out of my...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Evaluations Example: Push Notifications Bulk Experimentation

Evals are **task oriented** and iterative, they're the best way to check how your LLM integration is doing and improve it.

In the following eval, we are going to focus on the task of **testing many variants of models and prompts**.

Our use-case is:
1. I want to get the best possible performance out of my push notifications summarizer

## Evals structure

Evals have two parts, the "Eval" and the "Run". An "Eval" holds the configuration for your testing criteria and the structure of the data for your "Runs". An Eval `has_many` runs, that are evaluated by your testing criteria.

```python
import pydantic
import openai
from openai.types.chat import ChatCompletion
import os

os.environ["OPENAI_API_KEY"] = os.environ.get("OPENAI_API_KEY", "your-api-key")
```

## Use-case

We're testing the following integration, a push notifications summarizer, which takes in multiple push notifications and collapses them into a single message.

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
Categorize the following push notification summary into the following categories:
1. concise-and-snappy
2. drops-important-information
3. verbose
4. unclear
5. obscures-meaning
6. other

You'll be given the original list of push notifications and the summary like this:

<push_notifications>
...notificationlist...
</push_notifications>
<summary>
...summary...
</summary>

You should only pick one of the categories above, pick the one which most closely matches and why.
"""
GRADER_TEMPLATE_PROMPT = """
<push_notifications>{{item.notifications}}</push_notifications>
<summary>{{sample.output_text}}</summary>
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
    "passing_labels": ["concise-and-snappy"],
    "labels": [
        "concise-and-snappy",
        "drops-important-information",
        "verbose",
        "unclear",
        "obscures-meaning",
        "other",
    ],
}
```

The `push_notification_grader` is a model grader (llm-as-a-judge) which looks at the input `{{item.notifications}}` and the generated summary `{{sample.output_text}}` and labels it as "correct" or "incorrect"
We then instruct via the "passing_labels" what constitutes a passing answer.

Note: under the hood, this uses structured outputs so that labels are always valid.

**Now we'll create our eval, and start adding data to it!**

```python
eval_create_result = openai.evals.create(
    name="Push Notification Bulk Experimentation Eval",
    metadata={
        "description": "This eval tests many prompts and models to find the best performing combination.",
    },
    data_source_config=data_source_config,
    testing_criteria=[push_notification_grader],
)
eval_id = eval_create_result.id
```

# Creating runs

Now that we have our eval set-up with our testing_criteria, we can start to add a bunch of runs!
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

Now we're going to set up a bunch of prompts to test.

We want to test a basic prompt, with a couple of variations:
1. In one variation, we'll just have the basic prompt
2. In the next one, we'll include some positive examples of what we want the summaries to look like
3. In the final one, we'll include both positive and negative examples.

We'll also include a list of models to use.

```python
PROMPT_PREFIX = """
You are a helpful assistant that takes in an array of push notifications and returns a collapsed summary of them.
The push notification will be provided as follows:
<push_notifications>
...notificationlist...
</push_notifications>

You should return just the summary and nothing else.
"""

PROMPT_VARIATION_BASIC = f"""
{PROMPT_PREFIX}

You should return a summary that is concise and snappy.
"""

PROMPT_VARIATION_WITH_EXAMPLES = f"""
{PROMPT_VARIATION_BASIC}

Here is an example of a good summary:
<push_notifications>
- Traffic alert: Accident reported on Main Street.- Package out for delivery: Expected by 5 PM.- New friend suggestion: Connect with Emma.
</push_notifications>
<summary>
Traffic alert, package expected by 5pm, suggestion for new friend (Emily).
</summary>
"""

PROMPT_VARIATION_WITH_NEGATIVE_EXAMPLES = f"""
{PROMPT_VARIATION_WITH_EXAMPLES}

Here is an example of a bad summary:
<push_notifications>
- Traffic alert: Accident reported on Main Street.- Package out for delivery: Expected by 5 PM.- New friend suggestion: Connect with Emma.
</push_notifications>
<summary>
Traffic alert reported on main street. You have a package that will arrive by 5pm, Emily is a new friend suggested for you.
</summary>
"""

prompts = [
    ("basic", PROMPT_VARIATION_BASIC),
    ("with_examples", PROMPT_VARIATION_WITH_EXAMPLES),
    ("with_negative_examples", PROMPT_VARIATION_WITH_NEGATIVE_EXAMPLES),
]

models = ["gpt-4o", "gpt-4o-mini", "o3-mini"]
```

**Now we can just loop through all prompts and all models to test a bunch of configurations at once!**

We'll use the 'completion' run data source with template variables for our push notification list.

OpenAI will handle making the completions calls for you and populating "sample.output_text"

```python
for prompt_name, prompt in prompts:
    for model in models:
        run_data_source = {
            "type": "completions",
            "input_messages": {
                "type": "template",
                "template": [
                    {
                        "role": "developer",
                        "content": prompt,
                    },
                    {
                        "role": "user",
                        "content": "<push_notifications>{{item.notifications}}</push_notifications>",
                    },
                ],
            },
            "model": model,
            "source": {
                "type": "file_content",
                "content": [
                    {
                        "item": PushNotifications(notifications=notification).model_dump()
                    }
                    for notification in push_notification_data
                ],
            },
        }

        run_create_result = openai.evals.runs.create(
            eval_id=eval_id,
            name=f"bulk_{prompt_name}_{model}",
            data_source=run_data_source,
        )
        print(f"Report URL {model}, {prompt_name}:", run_create_result.report_url)
```



## Congratulations, you just tested 9 different prompt and model variations across your dataset!
