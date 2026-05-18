---
title: "Function Calling With An Openapi Spec"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - function-calling
  - notebook
  - openai
  - structured-outputs
source_pages:
  - https://developers.openai.com/cookbook/examples/function_calling_with_an_openapi_spec
  - https://github.com/openai/openai-cookbook/blob/main/examples/Function_calling_with_an_OpenAPI_spec.ipynb
---

# Function Calling With An Openapi Spec

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/function_calling_with_an_openapi_spec
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Function_calling_with_an_OpenAPI_spec.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Function_calling_with_an_OpenAPI_spec.ipynb
- Source path: `examples/Function_calling_with_an_OpenAPI_spec.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `0e4f7ac94ed7218ba9ab5f7d99e15207b2c22dfe59796ef227470bef37c8c4dd`

## Classification

- Primary category: Structured outputs / function calling
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Function-calling with an OpenAPI specification Much of the internet is powered by RESTful APIs. Giving GPT the ability to call them opens up a world of possibilities. This notebook demonstrates how GPTs can be used to intelligently call APIs. It leverages OpenAPI specifications and chained function calls. The OpenAPI Specification (OAS) is a universally acce...

## What This Teaches

- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Function-calling with an OpenAPI specification

Much of the internet is powered by RESTful APIs. Giving GPT the ability to call them opens up a world of possibilities. This notebook demonstrates how GPTs can be used to intelligently call APIs. It leverages OpenAPI specifications and chained function calls.

The [OpenAPI Specification (OAS)](https://swagger.io/specification/) is a universally accepted standard for describing the details of RESTful APIs in a format that machines can read and interpret. It enables both humans and computers to understand the capabilities of a service, and it can be leveraged to show GPT how to call APIs.

This notebook is divided into two main sections:

1. How to convert a sample OpenAPI specification into a list of function definitions for the chat completions API.
2. How to use the chat completions API to intelligently invoke these functions based on user instructions.

We recommend familiariazing yourself with [function-calling](./How_to_call_functions_with_chat_models.ipynb) before proceding.

```python
!pip install -q jsonref # for resolving $ref's in the OpenAPI spec
!pip install -q openai
```

```python
import os
import json
import jsonref
from openai import OpenAI
import requests
from pprint import pp

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))
```

## How to convert an OpenAPI specification into function definitions

The example OpenAPI spec we use here was created using `gpt-4`. We will transform this sample spec into a set of function definitions that can be supplied to the chat completion API. The model, based on the provided user instructions, generates a JSON object containing the necessary arguments to call these functions.

Before we proceed, let's inspect this generated spec. OpenAPI specs include details about the API's endpoints, the operations they support, the parameters they accept, the requests they can handle, and the responses they return. The spec is defined in JSON format.

The endpoints in the spec include operations for:

- Listing all events
- Creating a new event
- Retrieving an event by ID
- Deleting an event by ID
- Updating an event name by ID

Each operation in the spec has an `operationId`, which we will use as the function name when we parse the spec into function specifications. The spec also includes schemas that define the data types and structures of the parameters for each operation.

You can see the schema here:

```python
with open('./data/example_events_openapi.json', 'r') as f:
    openapi_spec = jsonref.loads(f.read()) # it's important to load with jsonref, as explained below

display(openapi_spec)
```

Now that we have a good understanding of the OpenAPI spec, we can proceed to parse it into function specifications.

We can write a simple `openapi_to_functions` function to generate a list of definitions, where each function is represented as a dictionary containing the following keys:

- `name`: This corresponds to the operation identifier of the API endpoint as defined in the OpenAPI specification.
- `description`: This is a brief description or summary of the function, providing an overview of what the function does.
- `parameters`: This is a schema that defines the expected input parameters for the function. It provides information about the type of each parameter, whether it is required or optional, and other related details.

For each of the endpoints defined in the schema, we need to do the following:

1. **Resolve JSON references**: In an OpenAPI specification, it's common to use JSON references (also known as $ref) to avoid duplication. These references point to definitions that are used in multiple places. For example, if multiple API endpoints return the same object structure, that structure can be defined once and then referenced wherever it's needed. We need to resolve and replace these references with the content they point to.

2. **Extract a name for the functions:** We will simply use the operationId as the function name. Alternatively, we could use the endpoint path and operation as the function name.

3. **Extract a description and parameters:** We will iterate through the `description`, `summary`, `requestBody` and `parameters` fields to populate the function's description and parameters.

Here's the implementation:

```python
def openapi_to_functions(openapi_spec):
    functions = []

    for path, methods in openapi_spec["paths"].items():
        for method, spec_with_ref in methods.items():
            # 1. Resolve JSON references.
            spec = jsonref.replace_refs(spec_with_ref)

            # 2. Extract a name for the functions.
            function_name = spec.get("operationId")

            # 3. Extract a description and parameters.
            desc = spec.get("description") or spec.get("summary", "")

            schema = {"type": "object", "properties": {}}

            req_body = (
                spec.get("requestBody", {})
                .get("content", {})
                .get("application/json", {})
                .get("schema")
            )
            if req_body:
                schema["properties"]["requestBody"] = req_body

            params = spec.get("parameters", [])
            if params:
                param_properties = {
                    param["name"]: param["schema"]
                    for param in params
                    if "schema" in param
                }
                schema["properties"]["parameters"] = {
                    "type": "object",
                    "properties": param_properties,
                }

            functions.append(
                {"type": "function", "function": {"name": function_name, "description": desc, "parameters": schema}}
            )

    return functions


functions = openapi_to_functions(openapi_spec)

for function in functions:
    pp(function)
    print()
```

## How to call these functions with GPT

Now that we have these function definitions, we can leverage GPT to call them intelligently based on user inputs.

It's important to note that the chat completions API does not execute the function; instead, it generates the JSON that you can use to call the function in your own code.

For more information on function-calling, refer to our dedicated [function-calling guide](./How_to_call_functions_with_chat_models.ipynb).

```python
SYSTEM_MESSAGE = """
You are a helpful assistant.
Respond to the following prompt by using function_call and then summarize actions.
Ask for clarification if a user request is ambiguous.
"""

# Maximum number of function calls allowed to prevent infinite or lengthy loops
MAX_CALLS = 5


def get_openai_response(functions, messages):
    return client.chat.completions.create(
        model="gpt-3.5-turbo-16k",
        tools=functions,
        tool_choice="auto",  # "auto" means the model can pick between generating a message or calling a function.
        temperature=0,
        messages=messages,
    )


def process_user_instruction(functions, instruction):
    num_calls = 0
    messages = [
        {"content": SYSTEM_MESSAGE, "role": "system"},
        {"content": instruction, "role": "user"},
    ]

    while num_calls < MAX_CALLS:
        response = get_openai_response(functions, messages)
        message = response.choices[0].message
        print(message)
        try:
            print(f"\n>> Function call #: {num_calls + 1}\n")
            pp(message.tool_calls)
            messages.append(message)

            # For the sake of this example, we'll simply add a message to simulate success.
            # Normally, you'd want to call the function here, and append the results to messages.
            messages.append(
                {
                    "role": "tool",
                    "content": "success",
                    "tool_call_id": message.tool_calls[0].id,
                }
            )

            num_calls += 1
        except:
            print("\n>> Message:\n")
            print(message.content)
            break

    if num_calls >= MAX_CALLS:
        print(f"Reached max chained function calls: {MAX_CALLS}")


USER_INSTRUCTION = """
Instruction: Get all the events.
Then create a new event named AGI Party.
Then delete event with id 2456.
"""

process_user_instruction(functions, USER_INSTRUCTION)
```

### Conclusion

We have demonstrated how to convert OpenAPI specs into function specifications that can be given to GPT for it to intelligently call them, and shown how these can be chained together to perform complex operations.

Possible extensions of this system could include handling more complex user instructions that require conditional logic or looping, integrating with real APIs to perform actual operations, and improving error handling and validation to ensure the instructions are feasible and the function calls are successful.
