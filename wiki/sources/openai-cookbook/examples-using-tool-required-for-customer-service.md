---
title: "Using Tool Required For Customer Service"
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
  - https://developers.openai.com/cookbook/examples/using_tool_required_for_customer_service
  - https://github.com/openai/openai-cookbook/blob/main/examples/Using_tool_required_for_customer_service.ipynb
---

# Using Tool Required For Customer Service

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/using_tool_required_for_customer_service
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Using_tool_required_for_customer_service.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Using_tool_required_for_customer_service.ipynb
- Source path: `examples/Using_tool_required_for_customer_service.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `196893a63ca70b3d26db24b70c70f684f98de78782db55b53449e8631e6eac54`

## Classification

- Primary category: Structured outputs / function calling
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Tool Required for Customer Service The ChatCompletion endpoint now includes the ability to specify whether a tool must be called every time, by adding tool choice='required' as a parameter. This adds an element of determinism to how you build your wrapping application, as you can count on a tool being provided with every call. We'll demonstrate here ho...

## What This Teaches

- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Tool Required for Customer Service

The `ChatCompletion` endpoint now includes the ability to specify whether a tool **must** be called every time, by adding `tool_choice='required'` as a parameter.

This adds an element of determinism to how you build your wrapping application, as you can count on a tool being provided with every call. We'll demonstrate here how this can be useful for a contained flow like customer service, where having the ability to define specific exit points gives more control.

The notebook concludes with a multi-turn evaluation, where we spin up a customer GPT to imitate our customer and test the LLM customer service agent we've set up.

```python
import json
from openai import OpenAI
import os

client = OpenAI()
GPT_MODEL = 'gpt-4-turbo'
```

## Config definition

We will define `tools` and `instructions` which our LLM customer service agent will use. It will source the right instructions for the problem the customer is facing, and use those to answer the customer's query.

As this is a demo example, we'll ask the model to make up values where it doesn't have external systems to source info.

```python
# The tools our customer service LLM will use to communicate
tools = [
{
  "type": "function",
  "function": {
    "name": "speak_to_user",
    "description": "Use this to speak to the user to give them information and to ask for anything required for their case.",
    "parameters": {
      "type": "object",
      "properties": {
        "message": {
          "type": "string",
          "description": "Text of message to send to user. Can cover multiple topics."
        }
      },
      "required": ["message"]
    }
  }
},
{
  "type": "function",
  "function": {
    "name": "get_instructions",
    "description": "Used to get instructions to deal with the user's problem.",
    "parameters": {
      "type": "object",
      "properties": {
        "problem": {
          "type": "string",
          "enum": ["fraud","refund","information"],
          "description": """The type of problem the customer has. Can be one of:
          - fraud: Required to report and resolve fraud.
          - refund: Required to submit a refund request.
          - information: Used for any other informational queries."""
        }
      },
      "required": [
        "problem"
      ]
    }
  }
}
]

# Example instructions that the customer service assistant can consult for relevant customer problems
INSTRUCTIONS = [ {"type": "fraud",
                  "instructions": """• Ask the customer to describe the fraudulent activity, including the the date and items involved in the suspected fraud.
• Offer the customer a refund.
• Report the fraud to the security team for further investigation.
• Thank the customer for contacting support and invite them to reach out with any future queries."""},
                {"type": "refund",
                 "instructions": """• Confirm the customer's purchase details and verify the transaction in the system.
• Check the company's refund policy to ensure the request meets the criteria.
• Ask the customer to provide a reason for the refund.
• Submit the refund request to the accounting department.
• Inform the customer of the expected time frame for the refund processing.
• Thank the customer for contacting support and invite them to reach out with any future queries."""},
                {"type": "information",
                 "instructions": """• Greet the customer and ask how you can assist them today.
• Listen carefully to the customer's query and clarify if necessary.
• Provide accurate and clear information based on the customer's questions.
• Offer to assist with any additional questions or provide further details if needed.
• Ensure the customer is satisfied with the information provided.
• Thank the customer for contacting support and invite them to reach out with any future queries.""" }]
```

```python
assistant_system_prompt = """You are a customer service assistant. Your role is to answer user questions politely and competently.
You should follow these instructions to solve the case:
- Understand their problem and get the relevant instructions.
- Follow the instructions to solve the customer's problem. Get their confirmation before performing a permanent operation like a refund or similar.
- Help them with any other problems or close the case.

Only call a tool once in a single message.
If you need to fetch a piece of information from a system or document that you don't have access to, give a clear, confident answer with some dummy values."""

def submit_user_message(user_query,conversation_messages=[]):
    """Message handling function which loops through tool calls until it reaches one that requires a response.
    Once it receives respond=True it returns the conversation_messages to the user."""

    # Initiate a respond object. This will be set to True by our functions when a response is required
    respond = False

    user_message = {"role":"user","content": user_query}
    conversation_messages.append(user_message)

    print(f"User: {user_query}")

    while respond is False:

        # Build a transient messages object to add the conversation messages to
        messages = [
            {
                "role": "system",
                "content": assistant_system_prompt
            }
        ]

        # Add the conversation messages to our messages call to the API
        [messages.append(x) for x in conversation_messages]

        # Make the ChatCompletion call with tool_choice='required' so we can guarantee tools will be used
        response = client.chat.completions.create(model=GPT_MODEL
                                                  ,messages=messages
                                                  ,temperature=0
                                                  ,tools=tools
                                                  ,tool_choice='required'
                                                 )

        conversation_messages.append(response.choices[0].message)

        # Execute the function and get an updated conversation_messages object back
        # If it doesn't require a response, it will ask the assistant again.
        # If not the results are returned to the user.
        respond, conversation_messages = execute_function(response.choices[0].message,conversation_messages)

    return conversation_messages

def execute_function(function_calls,messages):
    """Wrapper function to execute the tool calls"""

    for function_call in function_calls.tool_calls:

        function_id = function_call.id
        function_name = function_call.function.name
        print(f"Calling function {function_name}")
        function_arguments = json.loads(function_call.function.arguments)

        if function_name == 'get_instructions':

            respond = False

            instruction_name = function_arguments['problem']
            instructions = INSTRUCTIONS['type' == instruction_name]

            messages.append(
                                {
                                    "tool_call_id": function_id,
                                    "role": "tool",
                                    "name": function_name,
                                    "content": instructions['instructions'],
                                }
                            )

        elif function_name != 'get_instructions':

            respond = True

            messages.append(
                                {
                                    "tool_call_id": function_id,
                                    "role": "tool",
                                    "name": function_name,
                                    "content": function_arguments['message'],
                                }
                            )

            print(f"Assistant: {function_arguments['message']}")

    return (respond, messages)
```

## Example

To test this we will run an example for a customer who has experienced fraud, and see how the model handles it.

Play the role of the user and provide plausible next steps to keep the conversation going.

```python
messages = submit_user_message("Hi, I have had an item stolen that was supposed to be delivered to me yesterday.")
```

```python
messages = submit_user_message("For sure, it was a shirt, it was supposed to be delivered yesterday but it never arrived.",messages)
```

```python
messages = submit_user_message("Yes I would like to proceed with the refund.",messages)
```

```python
messages = submit_user_message("Thanks very much.",messages)
```

## Evaluation

Now we'll do a simple evaluation where a GPT will pretend to be our customer. The two will go back and forth until a resolution is reached.

We'll reuse the functions above, adding an `execute_conversation` function where the customer GPT will continue answering.

```python
customer_system_prompt = """You are a user calling in to customer service.
You will talk to the agent until you have a resolution to your query.
Your query is {query}.
You will be presented with a conversation - provide answers for any assistant questions you receive.
Here is the conversation - you are the "user" and you are speaking with the "assistant":
{chat_history}

If you don't know the details, respond with dummy values.
Once your query is resolved, respond with "DONE" """

# Initiate a bank of questions run through
questions = ['I want to get a refund for the suit I ordered last Friday.',
            'Can you tell me what your policy is for returning damaged goods?',
            'Please tell me what your complaint policy is']
```

```python
def execute_conversation(objective):

    conversation_messages = []

    done = False

    user_query = objective

    while done is False:

        conversation_messages = submit_user_message(user_query,conversation_messages)

        messages_string = ''
        for x in conversation_messages:
            if isinstance(x,dict):
                if x['role'] == 'user':
                    messages_string += 'User: ' + x['content'] + '\n'
                elif x['role'] == 'tool':
                    if x['name'] == 'speak_to_user':
                        messages_string += 'Assistant: ' + x['content'] + '\n'
            else:
                continue

        messages = [
            {
            "role": "system",
            "content": customer_system_prompt.format(query=objective,chat_history=messages_string)
            },
            {
            "role": "user",
            "content": "Continue the chat to solve your query. Remember, you are in the user in this exchange. Do not provide User: or Assistant: in your response"
            }
        ]

        user_response = client.chat.completions.create(model=GPT_MODEL,messages=messages,temperature=0.5)

        conversation_messages.append({
            "role": "user",
            "content": user_response.choices[0].message.content
            })

        if 'DONE' in user_response.choices[0].message.content:
            done = True
            print("Achieved objective, closing conversation\n\n")

        else:
            user_query = user_response.choices[0].message.content
```

```python
for x in questions:

    execute_conversation(x)
```

## Conclusion

You can now control your LLM's behaviour explicitly by making tool use mandatory, as well as spin up GPT testers to challenge your LLM and to act as automated test cases.

We hope this has given you an appreciation for a great use case for tool use, and look forward to seeing what you build!
