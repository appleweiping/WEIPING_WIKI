---
title: "Reasoning Function Calls"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - gpt-5
  - notebook
  - openai
  - reasoning
source_pages:
  - https://developers.openai.com/cookbook/examples/reasoning_function_calls
  - https://github.com/openai/openai-cookbook/blob/main/examples/reasoning_function_calls.ipynb
---

# Reasoning Function Calls

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/reasoning_function_calls
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/reasoning_function_calls.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/reasoning_function_calls.ipynb
- Source path: `examples/reasoning_function_calls.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `208606bf39c9f0dcab9d2593d8d1e17f1b2c0af222a12ca732a5d51926bf43ae`

## Classification

- Primary category: GPT-5 / reasoning / prompting
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Managing Function Calls With Reasoning Models OpenAI now offers function calling using reasoning models. Reasoning models are trained to follow logical chains of thought, making them better suited for complex or multi-step tasks. Reasoning models like o3 and o4-mini are LLMs trained with reinforcement learning to perform reasoning. Reasoning models think bef...

## What This Teaches

- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Managing Function Calls With Reasoning Models
OpenAI now offers function calling using [reasoning models](https://platform.openai.com/docs/guides/reasoning?api-mode=responses). Reasoning models are trained to follow logical chains of thought, making them better suited for complex or multi-step tasks.
> _Reasoning models like o3 and o4-mini are LLMs trained with reinforcement learning to perform reasoning. Reasoning models think before they answer, producing a long internal chain of thought before responding to the user. Reasoning models excel in complex problem solving, coding, scientific reasoning, and multi-step planning for agentic workflows. They're also the best models for Codex CLI, our lightweight coding agent._

For the most part, using these models via the API is very simple and comparable to using familiar 'chat' models.

However, there are some nuances to bear in mind, particularly when it comes to using features such as function calling.

All examples in this notebook use the newer [Responses API](https://community.openai.com/t/introducing-the-responses-api/1140929) which provides convenient abstractions for managing conversation state. However the principles here are relevant when using the older chat completions API.

## Making API calls to reasoning models

```python
# pip install openai
# Import libraries
import json
from openai import OpenAI
from uuid import uuid4
from typing import Callable

client = OpenAI()
MODEL_DEFAULTS = {
    "model": "o4-mini", # 200,000 token context window
    "reasoning": {"effort": "low", "summary": "auto"}, # Automatically summarise the reasoning process. Can also choose "detailed" or "none"
}
```

Let's make a simple call to a reasoning model using the Responses API.
We specify a low reasoning effort and retrieve the response with the helpful `output_text` attribute.
We can ask follow up questions and use the `previous_response_id` to let OpenAI manage the conversation history automatically

```python
response = client.responses.create(
    input="Which of the last four Olympic host cities has the highest average temperature?",
    **MODEL_DEFAULTS
)
print(response.output_text)

response = client.responses.create(
    input="what about the lowest?",
    previous_response_id=response.id,
    **MODEL_DEFAULTS
)
print(response.output_text)
```

Nice and easy!

We're asking relatively complex questions that may require the model to reason out a plan and proceed through it in steps, but this reasoning is hidden from us - we simply wait a little longer before being shown the response.

However, if we inspect the output we can see that the model has made use of a hidden set of 'reasoning' tokens that were included in the model context window, but not exposed to us as end users.
We can see these tokens and a summary of the reasoning (but not the literal tokens used) in the response.

```python
print(next(rx for rx in response.output if rx.type == 'reasoning').summary[0].text)
response.usage.to_dict()
```

It is important to know about these reasoning tokens, because it means we will consume our available context window more quickly than with traditional chat models.

## Calling custom functions
What happens if we ask the model a complex request that also requires the use of custom tools?
* Let's imagine we have more questions about Olympic Cities, but we also have an internal database that contains IDs for each city.
* It's possible that the model will need to invoke our tool partway through its reasoning process before returning a result.
* Let's make a function that produces a random UUID and ask the model to reason about these UUIDs.

```python

def get_city_uuid(city: str) -> str:
    """Just a fake tool to return a fake UUID"""
    uuid = str(uuid4())
    return f"{city} ID: {uuid}"

# The tool schema that we will pass to the model
tools = [
    {
        "type": "function",
        "name": "get_city_uuid",
        "description": "Retrieve the internal ID for a city from the internal database. Only invoke this function if the user needs to know the internal ID for a city.",
        "parameters": {
            "type": "object",
            "properties": {
                "city": {"type": "string", "description": "The name of the city to get information about"}
            },
            "required": ["city"]
        }
    }
]

# This is a general practice - we need a mapping of the tool names we tell the model about, and the functions that implement them.
tool_mapping = {
    "get_city_uuid": get_city_uuid
}

# Let's add this to our defaults so we don't have to pass it every time
MODEL_DEFAULTS["tools"] = tools

response = client.responses.create(
    input="What's the internal ID for the lowest-temperature city?",
    previous_response_id=response.id,
    **MODEL_DEFAULTS)
print(response.output_text)
```

We didn't get an `output_text` this time. Let's look at the response output

```python
response.output
```

Along with the reasoning step, the model has successfully identified the need for a tool call and passed back instructions to send to our function call.

Let's invoke the function and send the results to the model so it can continue reasoning.
Function responses are a special kind of message, so we need to structure our next message as a special kind of input:
```json
{
    "type": "function_call_output",
    "call_id": function_call.call_id,
    "output": tool_output
}
```

```python
# Extract the function call(s) from the response
new_conversation_items = []
function_calls = [rx for rx in response.output if rx.type == 'function_call']
for function_call in function_calls:
    target_tool = tool_mapping.get(function_call.name)
    if not target_tool:
        raise ValueError(f"No tool found for function call: {function_call.name}")
    arguments = json.loads(function_call.arguments) # Load the arguments as a dictionary
    tool_output = target_tool(**arguments) # Invoke the tool with the arguments
    new_conversation_items.append({
        "type": "function_call_output",
        "call_id": function_call.call_id, # We map the response back to the original function call
        "output": tool_output
    })
```

```python
response = client.responses.create(
    input=new_conversation_items,
    previous_response_id=response.id,
    **MODEL_DEFAULTS
)
print(response.output_text)
```

This works great here - as we know that a single function call is all that is required for the model to respond - but we also need to account for situations where multiple tool calls might need to be executed for the reasoning to complete.

Let's add a second call to run a web search.

OpenAI's web search tool is not available out of the box with reasoning models (as of May 2025 - this may soon change) but it's not too hard to create a custom web search function using 4o mini or another web search enabled model.

```python
def web_search(query: str) -> str:
    """Search the web for information and return back a summary of the results"""
    result = client.responses.create(
        model="gpt-4o-mini",
        input=f"Search the web for '{query}' and reply with only the result.",
        tools=[{"type": "web_search_preview"}],
    )
    return result.output_text

tools.append({
        "type": "function",
        "name": "web_search",
        "description": "Search the web for information and return back a summary of the results",
        "parameters": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "The query to search the web for."}
            },
            "required": ["query"]
        }
    })
tool_mapping["web_search"] = web_search
```

## Executing multiple functions in series

Some OpenAI models support the parameter `parallel_tool_calls` which allows the model to return an array of functions which we can then execute in parallel. However, reasoning models may produce a sequence of function calls that must be made in series, particularly as some steps may depend on the results of previous ones.
As such, we ought to define a general pattern which we can use to handle arbitrarily complex reasoning workflows:
* At each step in the conversation, initialise a loop
* If the response contains function calls, we must assume the reasoning is ongoing and we should feed the function results (and any intermediate reasoning) back into the model for further inference
* If there are no function calls and we instead receive a Reponse.output with a type of 'message', we can safely assume the agent has finished reasoning and we can break out of the loop

```python
# Let's wrap our logic above into a function which we can use to invoke tool calls.
def invoke_functions_from_response(response,
                                   tool_mapping: dict[str, Callable] = tool_mapping
                                   ) -> list[dict]:
    """Extract all function calls from the response, look up the corresponding tool function(s) and execute them.
    (This would be a good place to handle asynchroneous tool calls, or ones that take a while to execute.)
    This returns a list of messages to be added to the conversation history.
    """
    intermediate_messages = []
    for response_item in response.output:
        if response_item.type == 'function_call':
            target_tool = tool_mapping.get(response_item.name)
            if target_tool:
                try:
                    arguments = json.loads(response_item.arguments)
                    print(f"Invoking tool: {response_item.name}({arguments})")
                    tool_output = target_tool(**arguments)
                except Exception as e:
                    msg = f"Error executing function call: {response_item.name}: {e}"
                    tool_output = msg
                    print(msg)
            else:
                msg = f"ERROR - No tool registered for function call: {response_item.name}"
                tool_output = msg
                print(msg)
            intermediate_messages.append({
                "type": "function_call_output",
                "call_id": response_item.call_id,
                "output": tool_output
            })
        elif response_item.type == 'reasoning':
            print(f'Reasoning step: {response_item.summary}')
    return intermediate_messages
```

Now let's demonstrate the loop concept we discussed before.

```python
initial_question = (
    "What are the internal IDs for the cities that have hosted the Olympics in the last 20 years, "
    "and which of those cities have recent news stories (in 2025) about the Olympics? "
    "Use your internal tools to look up the IDs and the web search tool to find the news stories."
)

# We fetch a response and then kick off a loop to handle the response
response = client.responses.create(
    input=initial_question,
    **MODEL_DEFAULTS,
)
while True:
    function_responses = invoke_functions_from_response(response)
    if len(function_responses) == 0: # We're done reasoning
        print(response.output_text)
        break
    else:
        print("More reasoning required, continuing...")
        response = client.responses.create(
            input=function_responses,
            previous_response_id=response.id,
            **MODEL_DEFAULTS
        )
```

## Manual conversation orchestration
So far so good! It's really cool to watch the model pause execution to run a function before continuing.
In practice the example above is quite trivial, and production use cases may be much more complex:
* Our context window may grow too large and we may wish to prune older and less relevant messages, or summarize the conversation so far
* We may wish to allow users to navigate back and forth through the conversation and re-generate answers
* We may wish to store messages in our own database for audit purposes rather than relying on OpenAI's storage and orchestration
* etc.

In these situations we may wish to take full control of the conversation. Rather than using `previous_message_id` we can instead treat the API as 'stateless' and make and maintain an array of conversation items that we send to the model as input each time.

This poses some Reasoning model specific nuances to consider.
* In particular, it is essential that we preserve any reasoning and function call responses in our conversation history.
* This is how the model keeps track of what chain-of-thought steps it has run through. The API will error if these are not included.

Let's run through the example above again, orchestrating the messages ourselves and tracking token usage.

---
*Note that the code below is structured for readibility - in practice you may wish to consider a more sophisticated workflow to handle edge cases*

```python
# Let's initialise our conversation with the first user message
total_tokens_used = 0
user_messages = [
    (
        "Of those cities that have hosted the summer Olympic games in the last 20 years - "
        "do any of them have IDs beginning with a number and a temperate climate? "
        "Use your available tools to look up the IDs for each city and make sure to search the web to find out about the climate."
    ),
    "Great thanks! We've just updated the IDs - could you please check again?"
    ]

conversation = []
for message in user_messages:
    conversation_item = {
        "role": "user",
        "type": "message",
        "content": message
    }
    print(f"{'*' * 79}\nUser message: {message}\n{'*' * 79}")
    conversation.append(conversation_item)
    while True: # Response loop
        response = client.responses.create(
            input=conversation,
            **MODEL_DEFAULTS
        )
        total_tokens_used += response.usage.total_tokens
        reasoning = [rx.to_dict() for rx in response.output if rx.type == 'reasoning']
        function_calls = [rx.to_dict() for rx in response.output if rx.type == 'function_call']
        messages = [rx.to_dict() for rx in response.output if rx.type == 'message']
        if len(reasoning) > 0:
            print("More reasoning required, continuing...")
            # Ensure we capture any reasoning steps
            conversation.extend(reasoning)
            print('\n'.join(s['text'] for r in reasoning for s in r['summary']))
        if len(function_calls) > 0:
            function_outputs = invoke_functions_from_response(response)
            # Preserve order of function calls and outputs in case of multiple function calls (currently not supported by reasoning models, but worth considering)
            interleaved = [val for pair in zip(function_calls, function_outputs) for val in pair]
            conversation.extend(interleaved)
        if len(messages) > 0:
            print(response.output_text)
            conversation.extend(messages)
        if len(function_calls) == 0:  # No more functions = We're done reasoning and we're ready for the next user message
            break
print(f"Total tokens used: {total_tokens_used} ({total_tokens_used / 200_000:.2%} of o4-mini's context window)")
```

## Summary
In this cookbook, we identified how to combine function calling with OpenAI's reasoning models to demonstrate multi-step tasks that are dependent on external data sources., including searching the web.

Importantly, we covered reasoning-model specific nuances in the function calling process, specifically that:
* The model may choose to make multiple function calls or reasoning steps in series, and some steps may depend on the results of previous ones
* We cannot know how many of these steps there will be, so we must process responses with a loop
* The responses API makes orchestration easy using the `previous_response_id` parameter, but where manual control is needed, it's important to maintain the correct order of conversation item to preserve the 'chain-of-thought'

---

The examples used here are rather simple, but you can imagine how this technique could be extended to more real-world use cases, such as:

* Looking up a customer's transaction history and recent correspondence to determine if they are eligible for a promotional offer
* Calling recent transaction logs, geolocation data, and device metadata to assess the likelihood of a transaction being fraudulent
* Reviewing internal HR databases to fetch an employee’s benefits usage, tenure, and recent policy changes to answer personalized HR questions
* Reading internal dashboards, competitor news feeds, and market analyses to compile a daily executive briefing tailored to their focus areas
