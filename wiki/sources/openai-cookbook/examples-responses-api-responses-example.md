---
title: "Responses Example"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - notebook
  - openai
  - responses-api
  - tools
source_pages:
  - https://developers.openai.com/cookbook/examples/responses_api/responses_example
  - https://github.com/openai/openai-cookbook/blob/main/examples/responses_api/responses_example.ipynb
---

# Responses Example

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/responses_api/responses_example
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/responses_api/responses_example.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/responses_api/responses_example.ipynb
- Source path: `examples/responses_api/responses_example.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `1d51b23a76f24c3606597ba99f9670eb72881cb8dfc63b7dd5e0a0a3abb867a1`

## Classification

- Primary category: Responses API / tool orchestration
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

What is the Responses API? The Responses API is a new way to interact with OpenAI models, designed to be simpler and more flexible than previous APIs. It makes it easy to build advanced AI applications that use multiple tools, handle multi-turn conversations, and work with different types of data (not just text). Unlike older APIs—such as Chat Completions, w...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: Responses API / tool orchestration.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

## What is the Responses API?

The Responses API is a new way to interact with OpenAI models, designed to be simpler and more flexible than previous APIs. It makes it easy to build advanced AI applications that use multiple tools, handle multi-turn conversations, and work with different types of data (not just text).

Unlike older APIs—such as Chat Completions, which were built mainly for text, or the Assistants API, which can require a lot of setup—the Responses API is built from the ground up for:

- Seamless multi-turn interactions (carry on a conversation across several steps in a single API call)
- Easy access to powerful hosted tools (like file search, web search, and code interpreter)
- Fine-grained control over the context you send to the model

As AI models become more capable of complex, long-running reasoning, developers need an API that is both asynchronous and stateful. The Responses API is designed to meet these needs.

In this guide, you'll see some of the new features the Responses API offers, along with practical examples to help you get started.

## Basics
By design, on the surface, the Responses API is very similar to the Completions API.

```python
from openai import OpenAI
import os
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
```

```python
response = client.responses.create(
    model="gpt-4o-mini",
    input="tell me a joke",
)
```

```python
print(response.output[0].content[0].text)
```

One key feature of the Response API is that it is stateful. This means that you do not have to manage the state of the conversation by yourself, the API will handle it for you. For example, you can retrieve the response at any time and it will include the full conversation history.

```python
fetched_response = client.responses.retrieve(
response_id=response.id)

print(fetched_response.output[0].content[0].text)
```

You can continue the conversation by referring to the previous response.

```python
response_two = client.responses.create(
    model="gpt-4o-mini",
    input="tell me another",
    previous_response_id=response.id
)
```

```python
print(response_two.output[0].content[0].text)
```

You can of course manage the context yourself. But one benefit of OpenAI maintaining the context for you is that you can fork the response at any point and continue the conversation from that point.

```python
response_two_forked = client.responses.create(
    model="gpt-4o-mini",
    input="I didn't like that joke, tell me another and tell me the difference between the two jokes",
    previous_response_id=response.id # Forking and continuing from the first response
)

output_text = response_two_forked.output[0].content[0].text
print(output_text)
```

## Hosted Tools

Another benefit of the Responses API is that it adds support for hosted tools like `file_search` and `web_search`. Instead of manually calling the tools, simply pass in the tools and the API will decide which tool to use and use it.

Here is an example of using the `web_search` tool to incorporate web search results into the response.

```python
response = client.responses.create(
    model="gpt-4o",  # or another supported model
    input="What's the latest news about AI?",
    tools=[
        {
            "type": "web_search"
        }
    ]
)
```

```python
import json
print(json.dumps(response.output, default=lambda o: o.__dict__, indent=2))
```

## Multimodal, Tool-augmented conversation

The Responses API natively supports text, images, and audio modalities.
Tying everything together, we can build a fully multimodal, tool-augmented interaction with one API call through the responses API.

```python
import base64

from IPython.display import Image, display

# Display the image from the provided URL
url = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Cat_August_2010-4.jpg/2880px-Cat_August_2010-4.jpg"
display(Image(url=url, width=400))

response_multimodal = client.responses.create(
    model="gpt-4o",
    input=[
        {
            "role": "user",
            "content": [
                {"type": "input_text", "text":
                 "Come up with keywords related to the image, and search on the web using the search tool for any news related to the keywords"
                 ", summarize the findings and cite the sources."},
                {"type": "input_image", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Cat_August_2010-4.jpg/2880px-Cat_August_2010-4.jpg"}
            ]
        }
    ],
    tools=[
        {"type": "web_search"}
    ]
)
```

```python
import json
print(json.dumps(response_multimodal.__dict__, default=lambda o: o.__dict__, indent=4))
```

In the above example, we were able to use the `web_search` tool to search the web for news related to the image in one API call instead of multiple round trips that would be required if we were using the Chat Completions API.

With the responses API
🔥 a single API call can handle:

✅ Analyze a given image using a multimodal input.

✅ Perform web search via the `web_search` hosted tool

✅ Summarize the results.

In contrast, With Chat Completions API would require multiple steps, each requiring a round trip to the API:

1️⃣ Upload image and get analysis → 1 request

2️⃣ Extract info, call external web search → manual step + tool execution

3️⃣ Re-submit tool results for summarization → another request

See the following diagram for a side by side visualized comparison!

![Responses vs Completions](../../images/comparisons.png)


We are very excited for you to try out the Responses API and see how it can simplify your code and make it easier to build complex, multimodal, tool-augmented interactions!
