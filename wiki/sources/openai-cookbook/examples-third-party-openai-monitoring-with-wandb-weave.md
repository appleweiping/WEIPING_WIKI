---
title: "Openai Monitoring With Wandb Weave"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - integration
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/third_party/openai_monitoring_with_wandb_weave
  - https://github.com/openai/openai-cookbook/blob/main/examples/third_party/Openai_monitoring_with_wandb_weave.ipynb
---

# Openai Monitoring With Wandb Weave

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/third_party/openai_monitoring_with_wandb_weave
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/third_party/Openai_monitoring_with_wandb_weave.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/third_party/Openai_monitoring_with_wandb_weave.ipynb
- Source path: `examples/third_party/Openai_monitoring_with_wandb_weave.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `3f3f4fa95ba4bfd5c817faf4f214fdbe9e5057125541de3d9f1989badd7435ce`

## Classification

- Primary category: Third-party integrations
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

OpenAI API Monitoring with W&B Weave <img src="http://wandb.me/logo-im-png" width="400" alt="Weights & Biases" / <!--- @wandbcode{weave openai client qs} -- <a target=" blank" href="https://colab.research.google.com/github/wandb/weave/blob/master/examples/prompts/llm monitoring/openai client quickstart.ipynb" <img src="https://colab.research.google.com/asset...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: Third-party integrations.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# OpenAI API Monitoring with W&B Weave

<img src="http://wandb.me/logo-im-png" width="400" alt="Weights & Biases" />

<!--- @wandbcode{weave_openai_client_qs} -->

<a target="_blank" href="https://colab.research.google.com/github/wandb/weave/blob/master/examples/prompts/llm_monitoring/openai_client_quickstart.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

**Note:** you will need an [OpenAI API key](https://platform.openai.com/account/api-keys) to run this colab.

Use the W&B OpenAI integration to monitor OpenAI API calls and understand how your projects and teams are leveraging LLMs.
In this example, we'll generate templated Weave Boards: LLM usage monitoring dashboards which you can explore and customize from the UI.

* automatically track LLM usage and aggregate useful metrics like  cost, latency and throughput across your projects/teams
* dynamically query and derive insights from the logs of all your OpenAI API calls
* iterate visually to slice, aggregate, and explore your data; customize panels to focus on interesting patterns; share progress more easily with your team through an interactive dashboard

<img src="https://raw.githubusercontent.com/wandb/weave/master/docs/assets/full_board_view.png">

[Play with a live version of this Weave Board →](http://wandb.me/llm-monitoring-board)

#### New to Weights & Biases? [-> Sign up for an account here <-](https://wandb.ai/site)

# Step 0: Setup

Install dependencies, login to W&B so you can save and share your work, and authenticate with OpenAI.

```python
# if not already installed
!pip install -qqq weave openai tiktoken wandb
```

```python
import wandb
wandb.login()
```

```python
import weave
import os
WANDB_BASE_URL = "https://api.wandb.ai"
os.environ["WANDB_BASE_URL"] = WANDB_BASE_URL
```

```python
# authenticate with OpenAI
from getpass import getpass

if os.getenv("OPENAI_API_KEY") is None:
  os.environ["OPENAI_API_KEY"] = getpass("Paste your OpenAI key from: https://platform.openai.com/account/api-keys\n")
assert os.getenv("OPENAI_API_KEY", "").startswith("sk-"), "This doesn't look like a valid OpenAI API key"
print("OpenAI API key configured")
```

# Step 1: Configure data streaming and storage in W&B

Set WB_ENTITY to your wandb username or team name. Log in to W&B and navigate to Home Page at [wandb.ai/home](https://wandb.ai/home) to see valid options under your "Profile" and "Teams" in the left sidebar.

```python
WB_ENTITY = "" # set to your wandb username or team name
WB_PROJECT = "weave" # top-level directory for this work
STREAM_NAME = "openai_logs" # record table which stores the logs of OpenAI API calls as they stream in
```

# Step 2: Call init_monitor()

To start monitoring OpenAI API usage, call `init_monitor(<stream>)`, where `<stream>` has the form `<wandb_team_or_user>/<wandb_project>/<stream_name>`. The stream records and stores all the OpenAI API calls.

Running this cell will print out a link to view the current project in the Weave UI.

```python
from weave.monitoring import openai, init_monitor
m = init_monitor(f"{WB_ENTITY}/{WB_PROJECT}/{STREAM_NAME}")

# specifying a single model for simplicity
OPENAI_MODEL = 'gpt-3.5-turbo'

# prefill with some sample logs
r = openai.ChatCompletion.create(model=OPENAI_MODEL, messages=[{"role": "user", "content": "hello world!"}])
r = openai.ChatCompletion.create(model=OPENAI_MODEL, messages=[{"role": "user", "content": "what is 2+2?"}])
```

# Step 3: Preview monitoring dashboard

Click on the link above to preview the data stream, then click "OpenAI Monitor Board" in the right sidebar to create a Weave Board for this data stream.

<img src="https://raw.githubusercontent.com/wandb/weave/master/docs/assets/short_board_attempt.gif" width=75%>

# Step 4: Explore & understand your LLM usage

To save your work, rename the board by clicking on the autogenerated name at the top of the page. To share your board, click \"Publish\" in the top right.

<img src="https://raw.githubusercontent.com/wandb/weave/master/docs/assets/publish_board_short.gif" width=75%>

To visualize your work in real-time as you iterate, you can:
* keep the Board open in a separate tab and refresh to view the latest data
* rename the Board for easier reference at any point and \"Publish\" that version to share a link with others
* find previously saved Boards by navigating to the relevant W&B entity and W&B project name from weave.wandb.ai
* or open a new instance of a Board template to start fresh with all the data accumulated so far


Next we'll illustrate a few ways you could track OpenAI API calls. There are many more possibilities depending on your use case, and we can't wait to see what you create from these starter templates.

# Examples

## Example 0: Log a prompt and its completion

Monitor a ChatCompletion request and print the corresponding response, extracting only the text of the completion.

```python
response = openai.ChatCompletion.create(model=OPENAI_MODEL, messages=[
        {"role": "user", "content": f"What is the meaning of life, the universe, and everything?"},
    ])
print(response['choices'][0]['message']['content'])
```

## Example 1: Track relevant parameters as attributes

Factor out parameters of interest and track them as attributes on the logged record.
Here we track the "system prompt" separately from the "prompt template" and the "equation" parameter. This time we'll print the full structured response from the ChatCompletion call.

```python
system_prompt = "you always write in bullet points"
prompt_template = 'solve the following equation step by step: {equation}'
params = {'equation': '4 * (3 - 1)'}
openai.ChatCompletion.create(model=OPENAI_MODEL,
                             messages=[
                                    {"role": "system", "content": system_prompt},
                                    {"role": "user", "content": prompt_template.format(**params)},
                                ],
                             # you can add additional attributes to the logged record
                             # see the monitor_api notebook for more examples
                             monitor_attributes={
                                 'system_prompt': system_prompt,
                                 'prompt_template': prompt_template,
                                 'params': params
                             })
```

## Example 2: Log an ongoing stream of messages

Monitor a stream of messages and log the result as a single record. Note: tokens are not counted in this format.

```python
from weave.monitoring.openai import message_from_stream
r = openai.ChatCompletion.create(model=OPENAI_MODEL, messages=[
        {"role": "system", "content": "You are a robot and only speak in robot, like beep bloop bop."},
        {"role": "user", "content": "Tell me a 50-word story."},
    ], stream=True)
for s in message_from_stream(r):
    print(s, end='')
```

## Example 3: Structure prompt engineering experiments

Here we compare a few toy options for the system prompt, user question, and intended audience. Try your own experiments and see if any interesting insights emerge as you explore in the Board and group by different parameters.

```python
def explain_math(system_prompt, prompt_template, params):
    openai.ChatCompletion.create(model=OPENAI_MODEL,
                             messages=[
                                    {"role": "system", "content": system_prompt},
                                    {"role": "user", "content": prompt_template.format(**params)},
                                ],
                             # you can add additional attributes to the logged record
                             # see the monitor_api notebook for more examples
                             monitor_attributes={
                                 'system_prompt': system_prompt,
                                 'prompt_template': prompt_template,
                                 'params': params
                             })
```

```python
# feel free to substitute your own prompts :)
system_prompts = ["you're extremely flowery and poetic", "you're very direct and precise", "balance brevity with insight"]
prompt_template = 'explain the solution of the following to a {audience}: {equation}'
equations = ['x^2 + 4x + 9 = 0', '15 * (2 - 6) / 4']
audience = ["new student", "math genius"]

for system_prompt in system_prompts:
    for equation in equations:
        for person in audience:
            params = {"equation" : equation, "audience" : person}
            explain_math(system_prompt, prompt_template, params)
```
