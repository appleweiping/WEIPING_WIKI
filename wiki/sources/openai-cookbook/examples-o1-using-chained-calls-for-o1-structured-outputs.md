---
title: "Using Chained Calls For O1 Structured Outputs"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - function-calling
  - notebook
  - openai
  - structured-outputs
source_pages:
  - https://developers.openai.com/cookbook/examples/o1/using_chained_calls_for_o1_structured_outputs
  - https://github.com/openai/openai-cookbook/blob/main/examples/o1/Using_chained_calls_for_o1_structured_outputs.ipynb
---

# Using Chained Calls For O1 Structured Outputs

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/o1/using_chained_calls_for_o1_structured_outputs
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/o1/Using_chained_calls_for_o1_structured_outputs.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/o1/Using_chained_calls_for_o1_structured_outputs.ipynb
- Source path: `examples/o1/Using_chained_calls_for_o1_structured_outputs.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `d0a1faa1e3794d8620693c1cb38c38feaf310ee970420a4438b83cf06d1e69c4`

## Classification

- Primary category: Structured outputs / function calling
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using chained calls for reasoning structured outputs The initially released versions (September 2024) of $1 reasoning models have advanced capabilities but do not have $1 support. This means that requests with o1 don't have reliable type-safety and rely on the prompt itself to return a useful JSON. In this guide, we'll explore two methods to prompt o1 models...

## What This Teaches

- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using chained calls for reasoning structured outputs

The initially released versions (September 2024) of [o1](https://openai.com/index/introducing-openai-o1-preview/) reasoning models have advanced capabilities but do not have [structured outputs](https://platform.openai.com/docs/guides/structured-outputs/examples) support.

This means that requests with o1 don't have reliable type-safety and rely on the prompt itself to return a useful JSON.

In this guide, we'll explore two methods to prompt o1 models, specifically `o1-preview`, to return a valid JSON format when using the OpenAI API.

# Prompting

The simplest way to return a JSON response using `o1-preview` is to explicitly prompt it.

Let's run through an example of:
- Fetching a wikipedia page of companies
- Determining which could benefit the most from AI capabilities
- Returning them in a JSON format, which could then be ingested by other systems

```python
import requests
from openai import OpenAI

client = OpenAI()

def fetch_html(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.text
    else:
        return None

url = "https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue"
html_content = fetch_html(url)

json_format = """
{
    companies: [
        {
            \"company_name\": \"OpenAI\",
            \"page_link\": \"https://en.wikipedia.org/wiki/OpenAI\",
            \"reason\": \"OpenAI would benefit because they are an AI company...\"
        }
    ]
}
"""

o1_response = client.chat.completions.create(
    model="o1-preview",
    messages=[
        {
            "role": "user",
            "content": f"""
You are a business analyst designed to understand how AI technology could be used across large corporations.

- Read the following html and return which companies would benefit from using AI technology: {html_content}.
- Rank these propects by opportunity by comparing them and show me the top 3. Return only as a JSON with the following format: {json_format}"
"""
        }
    ]
)

print(o1_response.choices[0].message.content)
```

Note that the response is already quite good - it returns the JSON with the appropriate responses. However, it runs into the same pitfalls as existing use-cases of prompt-only JSON inference:
- You must manually process this JSON into your type-safe structure
- Model refusals are not [explicitly returned from the API as a separate structure](https://platform.openai.com/docs/guides/structured-outputs/refusals)

# Structured Outputs

Let's now do this with [structured outputs](https://platform.openai.com/docs/guides/structured-outputs). To enable this functionality, we’ll link the `o1-preview` response with a follow-up request to `gpt-4o-mini`, which can effectively process the data returned from the initial o1-preview response.

```python
from pydantic import BaseModel
from devtools import pprint

class CompanyData(BaseModel):
    company_name: str
    page_link: str
    reason: str

class CompaniesData(BaseModel):
    companies: list[CompanyData]

o1_response = client.chat.completions.create(
    model="o1-preview",
    messages=[
        {
            "role": "user",
            "content": f"""
You are a business analyst designed to understand how AI technology could be used across large corporations.

- Read the following html and return which companies would benefit from using AI technology: {html_content}.
- Rank these propects by opportunity by comparing them and show me the top 3. Return each with {CompanyData.__fields__.keys()}
"""
        }
    ]
)

o1_response_content = o1_response.choices[0].message.content

response = client.beta.chat.completions.parse(
    model="gpt-4o-mini",
    messages=[
        {
            "role": "user",
            "content": f"""
Given the following data, format it with the given response format: {o1_response_content}
"""
        }
    ],
    response_format=CompaniesData,
)

pprint(response.choices[0].message.parsed)
```

# Conclusion

Structured outputs allow your code to have reliable type-safety and simpler prompting. In addition, it allows you to re-use your object schemas for easier integration into your existing workflows.

The o1 class of models currently doesn't have structured outputs support, but we can re-use existing structured outputs functionality from `gpt-4o-mini` by chaining two requests together. This flow currently requires two calls, but the second `gpt-4o-mini` call cost should be minimal compared to the `o1-preview`/`o1-mini` calls.
