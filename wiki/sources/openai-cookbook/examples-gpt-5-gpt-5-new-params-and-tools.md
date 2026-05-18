---
title: "Gpt 5 New Params And Tools"
type: source
status: mirrored
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
  - https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_new_params_and_tools
  - https://github.com/openai/openai-cookbook/blob/main/examples/gpt-5/gpt-5_new_params_and_tools.ipynb
---

# Gpt 5 New Params And Tools

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_new_params_and_tools
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/gpt-5/gpt-5_new_params_and_tools.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/gpt-5/gpt-5_new_params_and_tools.ipynb
- Source path: `examples/gpt-5/gpt-5_new_params_and_tools.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `b35b901108de55ed1a6e9d32c888a37c8c6908c51e0223fbaf9dacf20e843195`

## Classification

- Primary category: GPT-5 / reasoning / prompting
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

GPT-5 New Params and Tools We’re introducing new developer controls in the GPT-5 series that give you greater control over model responses—from shaping output length and style to enforcing strict formatting. Below is a quick overview of the latest features: Feature Overview Values / Usage ---- --------- ---------- ---------------- 1. Verbosity Parameter Lets...

## What This Teaches

- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

#  GPT-5 New Params and Tools

We’re introducing new developer controls in the GPT-5 series that give you greater control over model responses—from shaping output length and style to enforcing strict formatting. Below is a quick overview of the latest features:


| #  | Feature | Overview | Values / Usage |
|----|---------|----------|----------------|
| 1. | **Verbosity Parameter** | Lets you hint the model to be more or less expansive in its replies. Keep prompts stable and use the parameter instead of re-writing. | • **low** → terse UX, minimal prose.<br>• **medium** *(default)* → balanced detail.<br>• **high** → verbose, great for audits, teaching, or hand-offs. |
| 2. | **Freeform Function Calling** | Generate raw text payloads—anything from Python scripts to SQL queries—directly to your custom tool without JSON wrapping. Offers greater flexibility for external runtimes like:<br>• Code sandboxes (Python, C++, Java, …)<br>• SQL databases<br>• Shell environments<br>• Config generators | Use when structured JSON isn’t needed and raw text is more natural for the target tool. |
| 3. | **Context-Free Grammar (CFG)** | A set of production rules defining valid strings in a language. Each rule rewrites a non-terminal into terminals and/or other non-terminals, independent of surrounding context. Useful for constraining output to match the syntax of programming languages or custom formats in OpenAI tools. | Use as a contract to ensure the model emits only valid strings accepted by the grammar. |
| 4. | **Minimal Reasoning** | Runs GPT-5 with few or no reasoning tokens to minimize latency and speed time-to-first-token. Ideal for deterministic, lightweight tasks (extraction, formatting, short rewrites, simple classification) where explanations aren’t needed. If not specified, effort defaults to medium. | Set reasoning effort: "minimal". Avoid for multi-step planning or tool-heavy workflows. |


**Supported Models:**
- gpt-5
- gpt-5-mini
- gpt-5-nano

**Supported API Endpoints**
- Responses API
- Chat Completions API

Note: We recommend to use Responses API with GPT-5 series of model to get the most performance out of the models.

## Prerequisites

Let's begin with updating your OpenAI SDK that supports the new params and tools for GPT-5. Make sure you've set OPENAI_API_KEY as an environment variable.

```python
!pip install --quiet --upgrade openai pandas && \
echo -n "openai " && pip show openai | grep '^Version:' | cut -d' ' -f2 && \
echo -n "pandas " && pip show pandas | grep '^Version:' | cut -d' ' -f2
```

## 1. Verbosity Parameter

### 1.1 Overview
The verbosity parameter lets you hint the model to be more or less expansive in its replies.

**Values:** "low", "medium", "high"

- low → terse UX, minimal prose.
- medium (default) → balanced detail.
- high → verbose, great for audits, teaching, or hand-offs.

Keep prompts stable and use the param rather than re-writing.

```python
from openai import OpenAI
import pandas as pd
from IPython.display import display

client = OpenAI()

question = "Write a poem about a boy and his first pet dog."

data = []

for verbosity in ["low", "medium", "high"]:
    response = client.responses.create(
        model="gpt-5-mini",
        input=question,
        text={"verbosity": verbosity}
    )

    # Extract text
    output_text = ""
    for item in response.output:
        if hasattr(item, "content"):
            for content in item.content:
                if hasattr(content, "text"):
                    output_text += content.text

    usage = response.usage
    data.append({
        "Verbosity": verbosity,
        "Sample Output": output_text,
        "Output Tokens": usage.output_tokens
    })

# Create DataFrame
df = pd.DataFrame(data)

# Display nicely with centered headers
pd.set_option('display.max_colwidth', None)
styled_df = df.style.set_table_styles(
    [
        {'selector': 'th', 'props': [('text-align', 'center')]},  # Center column headers
        {'selector': 'td', 'props': [('text-align', 'left')]}     # Left-align table cells
    ]
)

display(styled_df)
```

The output tokens scale roughly linearly with verbosity: low (560) → medium (849) → high (1288).

### 2.3 Using Verbosity for Coding Use Cases

The verbosity parameter also influences the length and complexity of generated code, as well as the depth of accompanying explanations. Here's an example, wherein we use various verboisty levels for a task to generate a Python program that sorts an array of 1000000 random numbers.

```python
from openai import OpenAI

client = OpenAI()

prompt = "Output a Python program that sorts an array of 1000000 random numbers"

def ask_with_verbosity(verbosity: str, question: str):
    response = client.responses.create(
        model="gpt-5-mini",
        input=question,
        text={
            "verbosity": verbosity
        }
    )

    # Extract assistant's text output
    output_text = ""
    for item in response.output:
        if hasattr(item, "content"):
            for content in item.content:
                if hasattr(content, "text"):
                    output_text += content.text

    # Token usage details
    usage = response.usage

    print("--------------------------------")
    print(f"Verbosity: {verbosity}")
    print("Output:")
    print(output_text)
    print("Tokens => input: {} | output: {}".format(
        usage.input_tokens, usage.output_tokens
    ))


# Example usage:
ask_with_verbosity("low", prompt)
```

Notice that the code output is a plain script. Now, lets run with 'medium'

```python
ask_with_verbosity("medium", prompt)
```

Medium verboisty, generated richer code with additioanl explanations. Let's do the same with high.

```python
ask_with_verbosity("high", prompt)
```

High verbosity yielded additional details and explanations.

### 1.3 Takeaways

The new verbosity parameter reliably scales both the length and depth of the model’s output while preserving correctness and reasoning quality - **without changing the underlying prompt**.
In this example:

- **Low verbosity** produces a minimal, functional script with no extra comments or structure.
- **Medium verbosity** adds explanatory comments, function structure, and reproducibility controls.
- **High verbosity** yields a comprehensive, production-ready script with argument parsing, multiple sorting methods, timing/verification, usage notes, and best-practice tips.

## 2. Free‑Form Function Calling

### 2.1 Overview
GPT‑5 can now send raw text payloads - anything from Python scripts to SQL queries - to your custom tool without wrapping the data in JSON using the new tool `"type": "custom"`. This differs from classic structured function calls, giving you greater flexibility when interacting with external runtimes such as:

- code_exec with sandboxes (Python, C++, Java, …)
- SQL databases
- Shell environments
- Configuration generators

**Note that custom tool type does NOT support parallel tool calling.**

### 2.2 Quick Start Example - Compute the Area of a Circle

The code below produces a simple python code to calculate area of a circle, and instruct the model to use the freeform tool call to output the result.

```python
from openai import OpenAI

client = OpenAI()

response = client.responses.create(
    model="gpt-5-mini",
    input="Please use the code_exec tool to calculate the area of a circle with radius equal to the number of 'r's in strawberry",
    text={"format": {"type": "text"}},
    tools=[
        {
            "type": "custom",
            "name": "code_exec",
            "description": "Executes arbitrary python code",
        }
    ]
)
print(response.output)
```

The model emits a `tool call` containing raw Python. You execute that code server‑side, capture the printed result, and send it back in a follow‑up responses.create call.

### 2.3 Mini‑Benchmark – Sorting an Array in Three Languages
To illustrate the use of free form tool calling, we will ask GPT‑5 to:
- Generate Python, C++, and Java code that sorts a fixed array 10 times.
- Print only the time (in ms) taken for each iteration in the code.
- Call all three functions, and then stop

```python
from openai import OpenAI
from typing import List, Optional

MODEL_NAME = "gpt-5"

# Tools that will be passed to every model invocation. They are defined once so
# that the configuration lives in a single place.
TOOLS = [
    {
        "type": "custom",
        "name": "code_exec_python",
        "description": "Executes python code",
    },
    {
        "type": "custom",
        "name": "code_exec_cpp",
        "description": "Executes c++ code",
    },
    {
        "type": "custom",
        "name": "code_exec_java",
        "description": "Executes java code",
    },
]

client = OpenAI()

def create_response(
    input_messages: List[dict],
    previous_response_id: Optional[str] = None,
):
    """Wrapper around ``client.responses.create``.

    Parameters
    ----------
    input_messages: List[dict]
        The running conversation history to feed to the model.
    previous_response_id: str | None
        Pass the ``response.id`` from the *previous* call so the model can keep
        the thread of the conversation.  Omit on the very first request.
    """
    kwargs = {
        "model": MODEL_NAME,
        "input": input_messages,
        "text": {"format": {"type": "text"}},
        "tools": TOOLS,
    }
    if previous_response_id:
        kwargs["previous_response_id"] = previous_response_id

    return client.responses.create(**kwargs)

# Recursive
def run_conversation(
    input_messages: List[dict],
    previous_response_id: Optional[str] = None,
):

    response = create_response(input_messages, previous_response_id)

    # ``response.output`` is expected to be a list where element 0 is the model
    # message.  Element 1 (if present) denotes a tool call.  When the model is
    # done with tool calls, that element is omitted.
    tool_call = response.output[1] if len(response.output) > 1 else None

    if tool_call and tool_call.type == "custom_tool_call":
        print("--- tool name ---")
        print(tool_call.name)
        print("--- tool call argument (generated code) ---")
        print(tool_call.input)

        # Add a synthetic *tool result* so the model can continue the thread.

        input_messages.append(
            {
                "type": "function_call_output",
                "call_id": tool_call.call_id,
                "output": "done", # <-- replace with the result of the tool call
            }
        )

        # Recurse with updated conversation and track the response id so the
        # model is aware of the prior turn.
        return run_conversation(input_messages, previous_response_id=response.id)
    else:
        # Base-case: no further tool call - return.
        return


prompt = """
Write code to sort the array of numbers in three languages: C++, Python and Java (10 times each)using code_exec functions.

ALWAYS CALL THESE THREE FUNCTIONS EXACTLY ONCE: code_exec_python, code_exec_cpp and code_exec_java tools to sort the array in each language. Stop once you've called these three functions in each language once.

Print only the time it takes to sort the array in milliseconds.

[448, 986, 255, 884, 632, 623, 246, 439, 936, 925, 644, 159, 777, 986, 706, 723, 534, 862, 195, 686, 846, 880, 970, 276, 613, 736, 329, 622, 870, 284, 945, 708, 267, 327, 678, 807, 687, 890, 907, 645, 364, 333, 385, 262, 730, 603, 945, 358, 923, 930, 761, 504, 870, 561, 517, 928, 994, 949, 233, 137, 670, 555, 149, 870, 997, 809, 180, 498, 914, 508, 411, 378, 394, 368, 766, 486, 757, 319, 338, 159, 585, 934, 654, 194, 542, 188, 934, 163, 889, 736, 792, 737, 667, 772, 198, 971, 459, 402, 989, 949]
"""

# Initial developer message.
messages = [
    {
        "role": "developer",
        "content": prompt,
    }
]

run_conversation(messages)
```

The model output three code blocks in Python, C++ and Java for the same algorithm. The output of the function call was chained back into the model as input to allow model to keep going until all the functions have been called exactly once.

### 2.4 Takeaways

Freeform tool calling in GPT-5 lets you send raw text payloads—such as Python scripts, SQL queries, or config files—directly to custom tools without JSON wrapping. This provides greater flexibility for interacting with external runtimes and allows the model to generate code or text in the exact format your tool expects. It’s ideal when structured JSON is unnecessary and natural text output improves usability.

## 3. Context‑Free Grammar (CFG)

### 3.1 Overview
A context‑free grammar is a collection of production rules that define which strings belong to a language. Each rule rewrites a non‑terminal symbol into a sequence of terminals (literal tokens) and/or other non‑terminals, independent of surrounding context—hence context‑free. CFGs can capture the syntax of most programming languages and, in OpenAI custom tools, serve as contracts that force the model to emit only strings that the grammar accepts.

### 3.2 Grammar Fundamentals

**Supported Grammar Syntax**
- Lark - https://lark-parser.readthedocs.io/en/stable/
- Regex - https://docs.rs/regex/latest/regex/#syntax

We use LLGuidance under the hood to constrain model sampling: https://github.com/guidance-ai/llguidance.

**Unsupported Lark Features**
- Lookaround in regexes (`(?=...)`, `(?!...)`, etc.)
- Lazy modifier (`*?`, `+?`, `??`) in regexes.
- Terminal priorities, templates, %declares, %import (except %import common).


**Terminals vs Rules & Greedy Lexing**

| Concept          | Take-away                                                                    |
|------------------|------------------------------------------------------------------------------|
| Terminals (UPPER)| Matched first by the lexer – longest match wins.                             |
| Rules (lower)    | Combine terminals; cannot influence how text is tokenised.                   |
| Greedy lexer     | Never try to “shape” free text across multiple terminals – you’ll lose control. |

**Correct vs Incorrect Pattern Design**

✅ **One bounded terminal handles free‑text between anchors**
```
start: SENTENCE
SENTENCE: /[A-Za-z, ]*(the hero|a dragon)[A-Za-z, ]*(fought|saved)[A-Za-z, ]*(a treasure|the kingdom)[A-Za-z, ]*\./
```
❌ **Don’t split free‑text across multiple terminals/rules**
```
start: sentence
sentence: /[A-Za-z, ]+/ subject /[A-Za-z, ]+/ verb /[A-Za-z, ]+/ object /[A-Za-z, ]+/
```

### 3.3 Example - SQL Dialect — MS SQL vs PostgreSQL

The following code example is now the canonical reference for building multi‑dialect SQL tools with CFGs. It demonstrates:

- Two isolated grammar definitions (`mssql_grammar_definition`, `postgres_grammar_definition`) encoding TOP vs LIMIT semantics.
- How to prompt, invoke, and inspect tool calls in a single script.
- A side‑by‑side inspection of the assistant’s responses.

Define the LARK grammars for different SQL dialects

```python
import textwrap

# ----------------- grammars for MS SQL dialect -----------------
mssql_grammar = textwrap.dedent(r"""
            // ---------- Punctuation & operators ----------
            SP: " "
            COMMA: ","
            GT: ">"
            EQ: "="
            SEMI: ";"

            // ---------- Start ----------
            start: "SELECT" SP "TOP" SP NUMBER SP select_list SP "FROM" SP table SP "WHERE" SP amount_filter SP "AND" SP date_filter SP "ORDER" SP "BY" SP sort_cols SEMI

            // ---------- Projections ----------
            select_list: column (COMMA SP column)*
            column: IDENTIFIER

            // ---------- Tables ----------
            table: IDENTIFIER

            // ---------- Filters ----------
            amount_filter: "total_amount" SP GT SP NUMBER
            date_filter: "order_date" SP GT SP DATE

            // ---------- Sorting ----------
            sort_cols: "order_date" SP "DESC"

            // ---------- Terminals ----------
            IDENTIFIER: /[A-Za-z_][A-Za-z0-9_]*/
            NUMBER: /[0-9]+/
            DATE: /'[0-9]{4}-[0-9]{2}-[0-9]{2}'/
    """)

# ----------------- grammars for PostgreSQL dialect -----------------
postgres_grammar = textwrap.dedent(r"""
            // ---------- Punctuation & operators ----------
            SP: " "
            COMMA: ","
            GT: ">"
            EQ: "="
            SEMI: ";"

            // ---------- Start ----------
            start: "SELECT" SP select_list SP "FROM" SP table SP "WHERE" SP amount_filter SP "AND" SP date_filter SP "ORDER" SP "BY" SP sort_cols SP "LIMIT" SP NUMBER SEMI

            // ---------- Projections ----------
            select_list: column (COMMA SP column)*
            column: IDENTIFIER

            // ---------- Tables ----------
            table: IDENTIFIER

            // ---------- Filters ----------
            amount_filter: "total_amount" SP GT SP NUMBER
            date_filter: "order_date" SP GT SP DATE

            // ---------- Sorting ----------
            sort_cols: "order_date" SP "DESC"

            // ---------- Terminals ----------
            IDENTIFIER: /[A-Za-z_][A-Za-z0-9_]*/
            NUMBER: /[0-9]+/
            DATE: /'[0-9]{4}-[0-9]{2}-[0-9]{2}'/
    """)
```

### 3.4 Generate specific SQL dialect
Let's define the prompt, and call the function to produce MS SQL dialect

```python
from openai import OpenAI
client = OpenAI()

sql_prompt_mssql = (
    "Call the mssql_grammar to generate a query for Microsoft SQL Server that retrieve the "
    "five most recent orders per customer, showing customer_id, order_id, order_date, and total_amount, "
    "where total_amount > 500 and order_date is after '2025-01-01'. "
)

response_mssql = client.responses.create(
    model="gpt-5",
    input=sql_prompt_mssql,
    text={"format": {"type": "text"}},
    tools=[
        {
            "type": "custom",
            "name": "mssql_grammar",
            "description": "Executes read-only Microsoft SQL Server queries limited to SELECT statements with TOP and basic WHERE/ORDER BY. YOU MUST REASON HEAVILY ABOUT THE QUERY AND MAKE SURE IT OBEYS THE GRAMMAR.",
            "format": {
                "type": "grammar",
                "syntax": "lark",
                "definition": mssql_grammar
            }
        },
    ],
    parallel_tool_calls=False
)

print("--- MS SQL Query ---")
print(response_mssql.output[1].input)
```

The output SQL accurately uses "SELECT TOP" construct.

```python
sql_prompt_pg = (
    "Call the postgres_grammar to generate a query for PostgreSQL that retrieve the "
    "five most recent orders per customer, showing customer_id, order_id, order_date, and total_amount, "
    "where total_amount > 500 and order_date is after '2025-01-01'. "
)

response_pg = client.responses.create(
    model="gpt-5",
    input=sql_prompt_pg,
    text={"format": {"type": "text"}},
    tools=[
        {
            "type": "custom",
            "name": "postgres_grammar",
            "description": "Executes read-only PostgreSQL queries limited to SELECT statements with LIMIT and basic WHERE/ORDER BY. YOU MUST REASON HEAVILY ABOUT THE QUERY AND MAKE SURE IT OBEYS THE GRAMMAR.",
            "format": {
                "type": "grammar",
                "syntax": "lark",
                "definition": postgres_grammar
            }
        },
    ],
    parallel_tool_calls=False,
)

print("--- PG SQL Query ---")
print(response_pg.output[1].input)
```

Output highlights the same logical query - different physical syntax. Supply distinct grammars so the model can only produce valid statements for the chosen dialect.

| Dialect       | Generated Query                                              | Key Difference                          |
|---------------|--------------------------------------------------------------|------------------------------------------|
| MS SQL Server | SELECT TOP 5 customer_id, … ORDER BY order_date DESC;         | Uses `TOP N` clause before column list.  |
| PostgreSQL    | SELECT customer_id, … ORDER BY order_date DESC LIMIT 5;       | Uses `LIMIT N` after `ORDER BY`.         |

### 3.5 Example - Regex CFG Syntax

The following code example demonstrates using the Regex CFG syntax to constrain the freeform tool call to a certain timestamp pattern.

```python
from openai import OpenAI
client = OpenAI()

timestamp_grammar_definition = r"^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]) (?:[01]\d|2[0-3]):[0-5]\d$"

timestamp_prompt = (
        "Call the timestamp_grammar to save a timestamp for August 7th 2025 at 10AM."
)

response_mssql = client.responses.create(
    model="gpt-5",
    input=timestamp_prompt,
    text={"format": {"type": "text"}},
    tools=[
        {
            "type": "custom",
            "name": "timestamp_grammar",
            "description": "Saves a timestamp in date + time in 24-hr format.",
            "format": {
                "type": "grammar",
                "syntax": "regex",
                "definition": timestamp_grammar_definition
            }
        },
    ],
    parallel_tool_calls=False
)

print("--- Timestamp ---")
print(response_mssql.output[1].input)
```

### 3.5 Best Practices

Lark grammars can be tricky to perfect. While simple grammars perform most reliably, complex grammars often require iteration on the grammar definition itself, the prompt, and the tool description to ensure that the model does not go out of distribution.

- Keep terminals bounded – use `/[^.\n]{0,10}*\./` rather than `/.*\./`. Limit matches both by content (negated character class) and by length (`{M,N}` quantifier).
- Prefer explicit char‑classes over `.` wildcards.
- Thread whitespace explicitly, e.g. using `SP = " "`, instead of a global `%ignore`.
- Describe your tool: tell the model exactly what the CFG accepts and instruct it to reason heavily about compliance.

**Troubleshooting**
- API rejects the grammar because it is too complex ➜ Simplify rules and terminals, remove `%ignore.*`.
- Unexpected tokens ➜ Confirm terminals aren’t overlapping; check greedy lexer.
- When the model drifts "out‑of‑distribution" (shows up as the model producing excessively long or repetitive outputs, it is syntactically valid but is semantically wrong):
    - Tighten the grammar.
    - Iterate on the prompt (add few-shot examples) and tool description (explain the grammar and instruct the model to reason to conform to it).
    - Experiment with a higher reasoning effort (e.g, bump from medium to high).

**Resources:**
- Lark Docs – https://lark-parser.readthedocs.io/en/stable/
- Lark IDE – https://www.lark-parser.org/ide/
- LLGuidance Syntax – https://github.com/guidance-ai/llguidance/blob/main/docs/syntax.md
- Regex (Rust crate) – https://docs.rs/regex/latest/regex/#syntax

### 3.6 Takeaways

Context-Free Grammar (CFG) support in GPT-5 lets you strictly constrain model output to match predefined syntax, ensuring only valid strings are generated. This is especially useful for enforcing programming language rules or custom formats, reducing post-processing and errors. By providing a precise grammar and clear tool description, you can make the model reliably stay within your target output structure.

## 4. Minimal Reasoning

### 4.1 Overview

GPT-5 now support for a new minimal reasoning effort. When using minimal reasoning effort, the model will output very few or no reasoning tokens. This is designed for use cases where developers want a very fast time-to-first-user-visible token. Note: If no reasoning effort is supplied, the default value is medium.

```python
from openai import OpenAI

client = OpenAI()

prompt = "Classify sentiment of the review as positive|neutral|negative. Return one word only."


response = client.responses.create(
    model="gpt-5",
    input= [{ 'role': 'developer', 'content': prompt },
            { 'role': 'user', 'content': 'The food that the restaurant was great! I recommend it to everyone.' }],
    reasoning = {
        "effort": "minimal"
    },
)

# Extract model's text output
output_text = ""
for item in response.output:
    if hasattr(item, "content"):
        for content in item.content:
            if hasattr(content, "text"):
                output_text += content.text

# Token usage details
usage = response.usage

print("--------------------------------")
print("Output:")
print(output_text)
```

### 4.2 Takeaways

Minimal reasoning runs GPT-5 with few or no reasoning tokens to minimize latency and speed up time-to-first-token. Use it for deterministic, lightweight tasks (extraction, formatting, short rewrites, simple classification) where explanations aren’t needed. If you don’t specify effort, it defaults to medium—set minimal explicitly when you want speed over deliberation.
