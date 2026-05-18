---
title: "Fine Tuning For Function Calling"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - fine-tuning
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/fine_tuning_for_function_calling
  - https://github.com/openai/openai-cookbook/blob/main/examples/Fine_tuning_for_function_calling.ipynb
---

# Fine Tuning For Function Calling

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/fine_tuning_for_function_calling
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Fine_tuning_for_function_calling.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Fine_tuning_for_function_calling.ipynb
- Source path: `examples/Fine_tuning_for_function_calling.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `af9af7a394d483a776afe1012b851ada07afd539888d5c7df5cd9d684087998d`

## Classification

- Primary category: Fine-tuning / reinforcement fine-tuning
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Fine tuning with function-calling This notebook covers how to fine-tune to increase function calling accuracy and reliability. You can find more information on function calling here, and on fine tuning here For context, from the function calling notebook above: tools is an optional parameter in the Chat Completion API which can be used to provide function sp...

## What This Teaches

- How to prepare data or workflows for model adaptation and fine-tuning.
- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Fine tuning with function-calling

This notebook covers how to fine-tune to increase function calling accuracy and reliability. You can find more information on function calling [here](https://github.com/openai/openai-cookbook/blob/main/examples/How_to_call_functions_with_chat_models.ipynb), and on fine tuning [here](https://github.com/openai/openai-cookbook/blob/main/examples/How_to_finetune_chat_models.ipynb)

For context, from the function calling notebook above:

> `tools` is an optional parameter in the Chat Completion API which can be used to provide function specifications. The purpose of this is to enable models to generate function arguments which adhere to the provided specifications. Note that the API will not actually execute any function calls. It is up to developers to execute function calls using model outputs.

Function calling is a very powerful tool when it functions as intended. However, we have seen that as the number of functions increases, and the complexity of the task at hand increases, function calling becomes less accurate (e.g.: more hallucinated invocations, and incorrect invocations).

Before fine tuning for function calling, it's best to begin with:

- Improvements to the function definitions. Make them more clear, and more distinct from one another.
- Experiment with prompt engineering: often a more detailed prompt can help the model call the correct function.

_If_ the steps above fail to improve function calling to a satisfactory level, then you can try fine tuning for function calling.

### Overview

This notebook contains three sections

- **Assessing baseline function calling performance:** Evaluating an out-of-the-box `gpt-3.5-turbo` model on our given function (let's assume that for latency + cost reasons we cannot use `gpt-4o` for a drone copilot)
- **Generating synthetic data:** Using `gpt-4o` to create 'golden' set of prompts and function invocations to use as training data
- **Fine-tuning**: Running the fine tuning job, and evaluating the fine-tuned model

Note: _This notebook provides an example of how to create synthetic training data for fine tuning for function calling given just a list of functions. While real-world production test evals are preferable, this method produces strong results and can be used in conjunction with real-world training data._

# Getting baseline function calling performance

```python
#!pip install tenacity -q
#!pip install openai -q
#!pip install typing -q
# !pip install python-dotenv
```

```python
import numpy as np
import json
import os
from IPython.display import display
import pandas as pd
from openai import OpenAI
import itertools
import time
import base64
from tenacity import retry, wait_random_exponential, stop_after_attempt
from typing import Any, Dict, List, Generator
import ast

%load_ext dotenv
%dotenv

client = OpenAI(api_key=os.environ.get("OPENAI_BUILD_HOUR_KEY"))
```

### Utilities

Let's define utility functions for making calls to the Chat Completions API, one to get the completion and one to get the function call.

```python
def get_chat_completion(
    messages: list[dict[str, str&#93;&#93;,
    model: str = "gpt-3.5-turbo",
    max_tokens=500,
    temperature=0.0,
    stop=None,
    tools=None,
    seed=42,
    functions=None,
    tool_choice=None,
) -> str:
    params = {
        "model": model,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "stop": stop,
        "tools": tools,
        "seed": seed,
        "tool_choice": tool_choice,
    }
    if functions:
        params["functions"] = functions

    completion = client.chat.completions.create(**params)
    return completion.choices[0].message, completion.usage


def eval(model: str, system_prompt: str, function_list, prompts_to_expected_tool_name):
    """
    Evaluate the performance of a model in selecting the correct function based on given prompts.

    Args:
        model (str): The name of the model to be evaluated.
        system_prompt (str): The system prompt to be used in the chat completion.
        function_list (list): A list of functions that the model can call.
        prompts_to_expected_tool_name (dict): A dictionary mapping prompts to their expected function names.

    Returns:
        None
    """

    prompts_to_actual = []
    latencies = []
    tokens_used = []

    for prompt, expected_function in prompts_to_expected_tool_name.items():
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ]

        start_time = time.time()
        completion, usage = get_chat_completion(
            model=model,
            messages=messages,
            seed=42,
            tools=function_list,
            temperature=0.0,
            tool_choice="required",
        )
        end_time = time.time()

        latency = (end_time - start_time) * 1000  # convert to milliseconds
        latencies.append(latency)

        prompts_to_actual.append(
            {prompt: completion.tool_calls[0].function.name})

        # Calculate tokens used
        tokens_used.append(usage.total_tokens)

    total_prompts = len(prompts_to_expected_tool_name)

    # Calculate the number of matches
    matches = sum(
        1
        for result in prompts_to_actual
        if list(result.values())[0]
        == prompts_to_expected_tool_name[list(result.keys())[0&#93;&#93;
    )
    match_percentage = (matches / total_prompts) * 100

    # Calculate average latency
    avg_latency = sum(latencies) / total_prompts
    # Calculate average tokens used
    avg_tokens_used = sum(tokens_used) / total_prompts

    # Create a DataFrame to store the results
    results_df = pd.DataFrame(columns=["Prompt", "Expected", "Match"])

    results_list = []
    for result in prompts_to_actual:
        prompt = list(result.keys())[0]
        actual_function = list(result.values())[0]
        expected_function = prompts_to_expected_tool_name[prompt]
        match = actual_function == expected_function
        results_list.append(
            {
                "Prompt": prompt,
                "Actual": actual_function,
                "Expected": expected_function,
                "Match": "Yes" if match else "No",
            }
        )
    results_df = pd.DataFrame(results_list)

    def style_rows(row):
        match = row["Match"]
        background_color = "red" if match == "No" else "white"
        return ["background-color: {}; color: black".format(background_color)] * len(
            row
        )

    styled_results_df = results_df.style.apply(style_rows, axis=1)

    # Display the DataFrame as a table
    display(styled_results_df)

    print(
        f"Number of matches: {matches} out of {total_prompts} ({match_percentage:.2f}%)"
    )
    print(f"Average latency per request: {avg_latency:.2f} ms")
    print(f"Average tokens used per request: {avg_tokens_used:.2f}")
```

### Baseline testing

Let's build an intelligent drone co-pilot. We want to be able to give the co-pilot commands, and have it either call the function
for that command, or deny that request if the command is unfeasible.
We can first define a system prompt for the copilot.

```python
DRONE_SYSTEM_PROMPT = """You are an intelligent AI that controls a drone. Given a command or request from the user,
call one of your functions to complete the request. If the request cannot be completed by your available functions, call the reject_request function.
If the request is ambiguous or unclear, reject the request."""
```

Now let's define functions for all of the actions the copilot can take.

```python
function_list = [
    {
        "type": "function",
        "function": {
            "name": "takeoff_drone",
            "description": "Initiate the drone's takeoff sequence.",
            "parameters": {
                "type": "object",
                "properties": {
                    "altitude": {
                        "type": "integer",
                        "description": "Specifies the altitude in meters to which the drone should ascend.",
                    }
                },
                "required": ["altitude"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "land_drone",
            "description": "Land the drone at its current location or a specified landing point.",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "enum": ["current", "home_base", "custom"],
                        "description": "Specifies the landing location for the drone.",
                    },
                    "coordinates": {
                        "type": "object",
                        "description": "GPS coordinates for custom landing location. Required if location is 'custom'.",
                    },
                },
                "required": ["location"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "control_drone_movement",
            "description": "Direct the drone's movement in a specific direction.",
            "parameters": {
                "type": "object",
                "properties": {
                    "direction": {
                        "type": "string",
                        "enum": ["forward", "backward", "left", "right", "up", "down"],
                        "description": "Direction in which the drone should move.",
                    },
                    "distance": {
                        "type": "integer",
                        "description": "Distance in meters the drone should travel in the specified direction.",
                    },
                },
                "required": ["direction", "distance"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_drone_speed",
            "description": "Adjust the speed of the drone.",
            "parameters": {
                "type": "object",
                "properties": {
                    "speed": {
                        "type": "integer",
                        "description": "Specifies the speed in km/h. Valid range is 0 to 100.",
                        "minimum": 0,
                    }
                },
                "required": ["speed"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "control_camera",
            "description": "Control the drone's camera to capture images or videos.",
            "parameters": {
                "type": "object",
                "properties": {
                    "mode": {
                        "type": "string",
                        "enum": ["photo", "video", "panorama"],
                        "description": "Camera mode to capture content.",
                    },
                    "duration": {
                        "type": "integer",
                        "description": "Duration in seconds for video capture. Required if mode is 'video'.",
                    },
                },
                "required": ["mode"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "control_gimbal",
            "description": "Adjust the drone's gimbal for camera stabilization and direction.",
            "parameters": {
                "type": "object",
                "properties": {
                    "tilt": {
                        "type": "integer",
                        "description": "Tilt angle for the gimbal in degrees.",
                    },
                    "pan": {
                        "type": "integer",
                        "description": "Pan angle for the gimbal in degrees.",
                    },
                },
                "required": ["tilt", "pan"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_drone_lighting",
            "description": "Control the drone's lighting for visibility and signaling.",
            "parameters": {
                "type": "object",
                "properties": {
                    "mode": {
                        "type": "string",
                        "enum": ["on", "off", "blink", "sos"],
                        "description": "Lighting mode for the drone.",
                    }
                },
                "required": ["mode"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "return_to_home",
            "description": "Command the drone to return to its home or launch location.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_battery_saver_mode",
            "description": "Toggle battery saver mode.",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": ["on", "off"],
                        "description": "Toggle battery saver mode.",
                    }
                },
                "required": ["status"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_obstacle_avoidance",
            "description": "Configure obstacle avoidance settings.",
            "parameters": {
                "type": "object",
                "properties": {
                    "mode": {
                        "type": "string",
                        "enum": ["on", "off"],
                        "description": "Toggle obstacle avoidance.",
                    }
                },
                "required": ["mode"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_follow_me_mode",
            "description": "Enable or disable 'follow me' mode.",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": ["on", "off"],
                        "description": "Toggle 'follow me' mode.",
                    }
                },
                "required": ["status"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "calibrate_sensors",
            "description": "Initiate calibration sequence for drone's sensors.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_autopilot",
            "description": "Enable or disable autopilot mode.",
            "parameters": {
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": ["on", "off"],
                        "description": "Toggle autopilot mode.",
                    }
                },
                "required": ["status"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "configure_led_display",
            "description": "Configure the drone's LED display pattern and colors.",
            "parameters": {
                "type": "object",
                "properties": {
                    "pattern": {
                        "type": "string",
                        "enum": ["solid", "blink", "pulse", "rainbow"],
                        "description": "Pattern for the LED display.",
                    },
                    "color": {
                        "type": "string",
                        "enum": ["red", "blue", "green", "yellow", "white"],
                        "description": "Color for the LED display. Not required if pattern is 'rainbow'.",
                    },
                },
                "required": ["pattern"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "set_home_location",
            "description": "Set or change the home location for the drone.",
            "parameters": {
                "type": "object",
                "properties": {
                    "coordinates": {
                        "type": "object",
                        "description": "GPS coordinates for the home location.",
                    }
                },
                "required": ["coordinates"],
            },
        },
    },
    {
        "type": "function",
        "function": {
            "name": "reject_request",
            "description": "Use this function if the request is not possible.",
            "parameters": {"type": "object", "properties": {}},
        },
    },
]
```

For starters, let's see how function calling performs with some straight forward feasible prompts, and then couple of obviously impossible requests which call the 'reject_request' function.

```python
straightforward_prompts_to_expected = {
    "Land the drone at the home base": "land_drone",
    "Take off the drone to 50 meters": "takeoff_drone",
    "Change speed to 15 kilometers per hour": "set_drone_speed",
    "Turn into an elephant!": "reject_request",
    "Move the drone forward by 10 meters": "control_drone_movement",
    "I want the LED display to blink in red": "configure_led_display",
    "Can you take a photo?": "control_camera",
    "Can you detect obstacles?": "set_obstacle_avoidance",
    "Can you dance for me?": "reject_request",
    "Can you follow me?": "set_follow_me_mode",
}
```

```python
# Evaluate the model with the given prompts
eval(
    model="gpt-3.5-turbo",
    system_prompt=DRONE_SYSTEM_PROMPT,
    function_list=function_list,
    prompts_to_expected_tool_name=straightforward_prompts_to_expected,
)
```

Nice! The model performs quite well with these requests. Now let's try some more difficult requests: requests that are _almost_ feasible and are drone-related, but that the drone cannot actually do, and the pilot should reject.

```python
challenging_prompts_to_expected = {
    "Play pre-recorded audio message": "reject_request",
    "Initiate following on social media": "reject_request",
    "Scan environment for heat signatures": "reject_request",
    "Bump into obstacles": "reject_request",
    "Change drone's paint job color": "reject_request",
    "Coordinate with nearby drones": "reject_request",
    "Change speed to negative 120 km/h": "reject_request",
    "Detect a person": "reject_request",
    "Please enable night vision": "reject_request",
    "Report on humidity levels around you": "reject_request",
}
```

```python
# Evaluate the model with the challenging prompts
eval(
    model="gpt-3.5-turbo",
    function_list=function_list,
    system_prompt=DRONE_SYSTEM_PROMPT,
    prompts_to_expected_tool_name=challenging_prompts_to_expected,
)
```

Now we run into some problems.
The model here should reject all of these requests, as they are impossible/conflicting/ambiguous given the functions, however instead the model calls functions that are somewhat related to the request, but incorrect. For example, the model sets follow_me_mode when asked to initiate following on social media.

<br>
In this simple case, more prompt engineering may resolve some of these issues, but for the purpose of this example we will demonstrate how fine tuning can be used to improve performance. Additionally, while this case is relatively straightforward, as the number of and complexity of the functions increases, fine tuning becomes more and more impactful.

Again, our goal here is to improve performance and use less tokens, so fine-tuning allows us to:

- Omit function and parameter descriptions: remove the description field from function and parameters
- Omit parameters: remove the entire properties field from the parameters object
- Omit function entirely: remove the entire function object from the functions array

# Generating synthetic data

### Helper functions

We want to generate every invocation of every function, so that we have
full coverage of all potential invocations to create synthetic data for. Then, we will use `gpt-4o` to come up with prompts that would call each invocation, and we will use that prompt - function invocation pair as training data.

Generating every invocation for a function with fixed enums is more simple, but for a function such as
`control_gimbal` we need to set the `tilt` and `pan` integer values, so to generate those synthetic invocations we will first set a placeholder, and then later use `gpt-4o` to come up with reasonable values.

```python
placeholder_int = "fill_in_int"
placeholder_string = "fill_in_string"
```

The functions below take in all the functions from the function list, and look
at all the potential invocations of those functions given each function's parameters.
The functions also account for `required` parameters, so that all the invocations
are actually feasible.

```python
def generate_permutations(
    params: Dict[str, Dict[str, Any&#93;&#93;
) -> Generator[Dict[str, Any], None, None]:
    """
    Generates all possible permutations for given parameters.

    :param params: Parameter dictionary containing required and optional fields.
    :return: A generator yielding each permutation.
    """

    # Extract the required fields from the parameters
    required_fields = params.get("required", [])

    # Generate permutations for required fields
    required_permutations = generate_required_permutations(params, required_fields)

    # Generate optional permutations based on each required permutation
    for required_perm in required_permutations:
        yield from generate_optional_permutations(params, required_perm)


def generate_required_permutations(
    params: Dict[str, Dict[str, Any&#93;&#93;, required_fields: List[str]
) -> List[Dict[str, Any&#93;&#93;:
    """
    Generates permutations for the required fields.

    :param params: Parameter dictionary.
    :param required_fields: List of required fields.
    :return: A list of permutations for required fields.
    """

    # Get all possible values for each required field
    required_values = [get_possible_values(params, field) for field in required_fields]

    # Generate permutations from possible values
    return [
        dict(zip(required_fields, values))
        for values in itertools.product(*required_values)
    ]


def generate_optional_permutations(
    params: Dict[str, Dict[str, Any&#93;&#93;, base_perm: Dict[str, Any]
) -> Generator[Dict[str, Any], None, None]:
    """
    Generates permutations for optional fields based on a base permutation.

    :param params: Parameter dictionary.
    :param base_perm: Base permutation dictionary.
    :return: A generator yielding each permutation for optional fields.
    """

    # Determine the fields that are optional by subtracting the base permutation's fields from all properties
    optional_fields = set(params["properties"]) - set(base_perm)

    # Iterate through all combinations of optional fields
    for field_subset in itertools.chain.from_iterable(
        itertools.combinations(optional_fields, r)
        for r in range(len(optional_fields) + 1)
    ):

        # Generate product of possible values for the current subset of fields
        for values in itertools.product(
            *(get_possible_values(params, field) for field in field_subset)
        ):

            # Create a new permutation by combining base permutation and current field values
            new_perm = {**base_perm, **dict(zip(field_subset, values))}

            yield new_perm


def get_possible_values(params: Dict[str, Dict[str, Any&#93;&#93;, field: str) -> List[Any]:
    """
    Retrieves possible values for a given field.

    :param params: Parameter dictionary.
    :param field: The field for which to get possible values.
    :return: A list of possible values.
    """

    # Extract field information from the parameters
    field_info = params["properties"][field]

    # Based on the field's type or presence of 'enum', determine and return the possible values
    if "enum" in field_info:
        return field_info["enum"]
    elif field_info["type"] == "integer":
        return [placeholder_int]
    elif field_info["type"] == "string":
        return [placeholder_string]
    elif field_info["type"] == "boolean":
        return [True, False]
    elif field_info["type"] == "array" and "enum" in field_info["items"]:
        enum_values = field_info["items"]["enum"]
        all_combinations = [
            list(combo)
            for i in range(1, len(enum_values) + 1)
            for combo in itertools.combinations(enum_values, i)
        ]
        return all_combinations
    return []
```

### Let's generate every invocation for every function first

Prompts:

```python
INVOCATION_FILLER_PROMPT = """
1) Input reasonable values for 'fill_in_string' and 'fill_in_int' in the invocation here: {invocation}. Reasonable values are determined by the function definition. Use the
the entire function provided here :{function} to get context over what proper fill_in_string and fill_in_int values would be.
Example:

Input: invocation: {{
    "name": "control_camera",
    "arguments": {{
      "mode":"video",
      "duration":"fill_in_int"
    }}
}},
function:{function}

Output: invocation: {{
    "name": "control_camera",
    "arguments": {{
      "mode":"video",
      "duration": 30
    }}
}}


MAKE SURE output is just a dictionary with keys 'name' and 'arguments', no other text or response.

Input: {invocation}
Output:
"""


COMMAND_GENERATION_PROMPT = """
You are to output 2 commands, questions or statements that would generate the inputted function and parameters.
Please make the commands or questions natural, as a person would ask, and the command or questions should be varied and not repetitive.
It should not always mirror the exact technical terminology used in the function and parameters, rather reflect a conversational and intuitive request.
For instance, the prompt should not be 'turn on the dome light', as that is too technical, but rather 'turn on the inside lights'.
Another example, is the prompt should not be 'turn on the HVAC', but rather 'turn on the air conditioning'. Use language a normal driver would use, even if
it is technically incorrect but colloquially used.

RULES: ALWAYS put a backwards slash before an apostrophe or single quote '. For example, do not say don't but say don\'t.
Prompts MUST be in double quotes as well.

Example

Input: {{'name': 'calibrate_sensors','arguments': {{}}'' }}
Prompt: ["The sensors are out of whack, can you reset them", "The calibration of the drone is off, fix it please!"]

Input: {{'name': 'set_autopilot','arguments': {{'status': 'off'}}}}
Prompt: ["OK, I want to take back pilot control now","Turn off the automatic pilot I'm ready control it"]

Input: {invocation}
Prompt:
"""
```

In the below snippet, we generate the invocation of each function except for the `reject_request` function.

To perform effective fine-tuning we need correctly labeled data. We could manually come up with examples and label the data,\
or we can generate synthetic data with the help of `gpt-4o` <br>

Empirically, `gpt-4o` needs a bit more help to get good realistic examples of prompts that would generate the `reject_request` function, so we'll do that next...

```python
input_objects = []
all_but_reject = [f for f in function_list if f.get("name") != "reject_request"]

for function in all_but_reject:
    func_name = function["function"]["name"]
    params = function["function"]["parameters"]
    for arguments in generate_permutations(params):
        if any(val in arguments.values() for val in ["fill_in_int", "fill_in_str"]):
            input_object = {"name": func_name, "arguments": arguments}
            messages = [
                {
                    "role": "user",
                    "content": INVOCATION_FILLER_PROMPT.format(
                        invocation=str(input_object), function=function
                    ),
                }
            ]
            input_object, usage = get_chat_completion(
                model="gpt-4o", messages=messages, max_tokens=200, temperature=0.1
            ).content
        else:
            input_object = {"name": func_name, "arguments": arguments}

        input_objects.append(input_object)
```

Now that we have all the invocations, let's use `gpt-4o` to generate prompts that would result in those invocations

```python
def remove_sequences(input_string):
    # Replace the specific sequences with an empty string
    cleaned_string = input_string.replace("```json", "")  # Remove "```json" first
    cleaned_string = cleaned_string.replace("```", "")  # Then remove "```"
    return json.loads(cleaned_string)
```

```python
def create_commands(invocation_list):
    example_list = []
    for i, invocation in enumerate(invocation_list):
        if i < 100:
            print(
                f"\033[34m{np.round(100*i/len(invocation_list),1)}% complete\033[0m")
            if type(invocation) == str or "json" in invocation:
                invocation = remove_sequences(invocation)
            print(invocation)

        # Format the prompt with the invocation string
        request_prompt = COMMAND_GENERATION_PROMPT.format(
            invocation=invocation)

        messages = [{"role": "user", "content": f"{request_prompt}"}]
        completion, usage = get_chat_completion(messages, temperature=0.8)
        command_dict = {"Input": invocation, "Prompt": completion.content}
        example_list.append(command_dict)
    return example_list
```

```python
# Only printing the first 10 rows
training_examples_unformatted = create_commands(input_objects)
```

Now let's format the training examples properly. For more documentation on the proper training data formatting for fine tuning for function calling, see here: https://platform.openai.com/docs/guides/fine-tuning/fine-tuning-examples

```python
def remove_descriptions(function_list):
    for function in function_list:
        func = function["function"]
        if "description" in func:
            del func["description"]

        params = func["parameters"]
        if "properties" in params:
            for param in params["properties"].values():
                if "description" in param:
                    del param["description"]

    return function_list


modified_function_list = remove_descriptions(function_list)
```

```python
training_examples = []

for prompt in training_examples_unformatted:
    # adjust formatting for training data specs

    # if its not a dict, convert to dict
    if type(prompt["Input"]) != dict:
        prompt["Input"] = ast.literal_eval(prompt["Input"])
    prompt["Input"]["arguments"] = json.dumps(prompt["Input"]["arguments"])
    try:
        prompt["Prompt"] = json.loads(prompt["Prompt"])
    except:
        continue
    for p in prompt["Prompt"]:
        print(p)
        print(prompt["Input"])
        tool_calls = [
            {"id": "call_id", "type": "function", "function": prompt["Input"]}
        ]
        training_examples.append(
            {
                "messages": [
                    {"role": "system", "content": DRONE_SYSTEM_PROMPT},
                    {"role": "user", "content": p},
                    {"role": "assistant", "tool_calls": tool_calls},
                ],
                "parallel_tool_calls": False,
                "tools": modified_function_list,
            }
        )
```

Now, back to the rejection function. Let's generate some prompts that are _nearly_ possible, but should result in the `reject_request` function being called. To do so, we queried `gpt-4o` asking for requests that are related to, but not quite possible with, the given list of functions.

```python
reject_list = [
    "Translate broadcast message to another language",
    "Automatically capture photos when face is detected",
    "Detect nearby drones",
    "Measure wind resistance",
    "Capture slow motion video",
    "Move the drone forward and backward by same distance at the same time.",
    "Adjust drone's altitude to ground level changes",
    "Display custom message on LED display",
    "Sync drone's time with smartphone",
    "Alert when drone travels out of designated area",
    "Calibrate sensors and land simultaneously",
    "Detect moisture levels",
    "Automatically follow GPS tagged object",
    "Toggle night vision mode",
    "Maintain current altitude when battery is low",
    "Decide best landing spot using AI",
    "Program drone's route based on wind direction",
]
```

```python
reject_training_list = []
for prompt in reject_list:
    # Adjust formatting
    tool_calls = [
        {
            "id": "call_id",
            "type": "function",
            "function": {"name": "reject_request", "arguments": "{}"},
        }
    ]
    reject_training_list.append(
        {
            "messages": [
                {"role": "system", "content": DRONE_SYSTEM_PROMPT},
                {"role": "user", "content": prompt},
                {"role": "assistant", "tool_calls": tool_calls},
            ],
            "parallel_tool_calls": False,
            "tools": modified_function_list,
        }
    )
```

Now combine all the training examples together

```python
training_list_total = training_examples + reject_training_list
```

```python
training_file = "data/drone_training.jsonl"
with open(training_file, "w") as f:
    for item in training_list_total:
        json_str = json.dumps(item)
        f.write(f"{json_str}\n")
```

# Fine tuning

Finally, we can kick off the fine-tuning job

```python
# Upload the training file
file = client.files.create(
    file=open("data/drone_training.jsonl", "rb"),
    purpose="fine-tune",
)
file_id = file.id
print(f"FileID: {file_id}")

# Create a fine-tuning job

ft = client.fine_tuning.jobs.create(
    model="gpt-3.5-turbo",
    training_file=file_id,
    suffix="drone",
)

print(f"Fine-tuning job created: {ft}")
```

In addition to creating a fine-tuning job, you can also list existing jobs, retrieve the status of a job, or cancel a job.

```python
ftjob_id = "ftjob-84PQg97hoIAKf21IPnhiNlU1"
# List 10 fine-tuning jobs
# client.fine_tuning.jobs.list(limit=10)

# Retrieve the state of a fine-tune
client.fine_tuning.jobs.retrieve(ftjob_id)

# Cancel a job
# client.fine_tuning.jobs.cancel("ftjob-abc123")

# List up to 10 events from a fine-tuning job
# client.fine_tuning.jobs.list_events(fine_tuning_job_id="ftjob-abc123", limit=10)

# Delete a fine-tuned model (must be an owner of the org the model was created in)
# client.models.delete("ft:gpt-3.5-turbo:abc:suffix:abc123")
```

After a fine-tuning job has finished, you can also see metrics around how the training process went by querying a fine-tuning job, extracting a file ID from the result_files, and then retrieving that files content. Each results CSV file has the following columns: step, train_loss, train_accuracy, valid_loss, and valid_mean_token_accuracy. While metrics can he helpful, evaluating samples from the fine-tuned model provides the most relevant sense of model quality.

```python
fine_tune_results = client.fine_tuning.jobs.retrieve(ftjob_id).result_files
result_file_id = client.files.retrieve(fine_tune_results[0]).id

# Retrieve the result file
result_file = client.files.content(file_id=result_file_id)
decoded_content = base64.b64decode(result_file.read()).decode("utf-8")
print(decoded_content)
```

# Evaluations

Great! We trained a fine-tuned model for function calling. Let's see how it does on our evaluation set for prompts that the drone assistant
should automatically reject.

```python
ft_model = "ft:gpt-3.5-turbo-0125:openai-gtm:drone:9atiPjeC"
base_model = "gpt-3.5-turbo"

print(f"\nEvaluating fine-tuned model with challenging prompts: {ft_model}")
eval(
    model=ft_model,
    function_list=modified_function_list,
    system_prompt=DRONE_SYSTEM_PROMPT,
    prompts_to_expected_tool_name=challenging_prompts_to_expected,
)

print(f"\nEvaluating base model with challenging prompts: {base_model}")
eval(
    model="gpt-3.5-turbo",
    function_list=function_list,
    system_prompt=DRONE_SYSTEM_PROMPT,
    prompts_to_expected_tool_name=challenging_prompts_to_expected,
)
```

Great! While the original model only rejected 60%, the fine tuned model rejected 100% requests and used less tokens to do so.

### Conclusion

Congratulations! You are now ready to fine tune your model for function calling. We can't wait to see what you build.
