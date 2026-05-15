---
title: "How To Handle Rate Limits"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/how_to_handle_rate_limits
  - https://github.com/openai/openai-cookbook/blob/main/examples/How_to_handle_rate_limits.ipynb
---

# How To Handle Rate Limits

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/how_to_handle_rate_limits
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/How_to_handle_rate_limits.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/How_to_handle_rate_limits.ipynb
- Source path: `examples/How_to_handle_rate_limits.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `b2e71549c45ee12a555905723447e145d6e43d66a1dbc259edaef97f000d3db8`

## Classification

- Primary category: General OpenAI API patterns
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

How to handle rate limits When you call the OpenAI API repeatedly, you may encounter error messages that say 429: 'Too Many Requests' or RateLimitError . These error messages come from exceeding the API's rate limits. This guide shares tips for avoiding and handling rate limit errors. To see an example script for throttling parallel requests to avoid rate li...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: General OpenAI API patterns.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# How to handle rate limits

When you call the OpenAI API repeatedly, you may encounter error messages that say `429: 'Too Many Requests'` or `RateLimitError`. These error messages come from exceeding the API's rate limits.

This guide shares tips for avoiding and handling rate limit errors.

To see an example script for throttling parallel requests to avoid rate limit errors, see [api_request_parallel_processor.py](https://github.com/openai/openai-cookbook/blob/main/examples/api_request_parallel_processor.py).

## Why rate limits exist

Rate limits are a common practice for APIs, and they're put in place for a few different reasons.

- First, they help protect against abuse or misuse of the API. For example, a malicious actor could flood the API with requests in an attempt to overload it or cause disruptions in service. By setting rate limits, OpenAI can prevent this kind of activity.
- Second, rate limits help ensure that everyone has fair access to the API. If one person or organization makes an excessive number of requests, it could bog down the API for everyone else. By throttling the number of requests that a single user can make, OpenAI ensures that everyone has an opportunity to use the API without experiencing slowdowns.
- Lastly, rate limits can help OpenAI manage the aggregate load on its infrastructure. If requests to the API increase dramatically, it could tax the servers and cause performance issues. By setting rate limits, OpenAI can help maintain a smooth and consistent experience for all users.

Although hitting rate limits can be frustrating, rate limits exist to protect the reliable operation of the API for its users.

## Default rate limits

Your rate limit and spending limit (quota) are automatically adjusted based on a number of factors. As your usage of the OpenAI API goes up and you successfully pay the bill, we automatically increase your usage tier. You can find specific information regarding rate limits using the resources below.

### Other rate limit resources

Read more about OpenAI's rate limits in these other resources:

- [Guide: Rate limits](https://platform.openai.com/docs/guides/rate-limits?context=tier-free)
- [Help Center: Is API usage subject to any rate limits?](https://help.openai.com/en/articles/5955598-is-api-usage-subject-to-any-rate-limits)
- [Help Center: How can I solve 429: 'Too Many Requests' errors?](https://help.openai.com/en/articles/5955604-how-can-i-solve-429-too-many-requests-errors)

### Requesting a rate limit increase

To learn more about increasing your organization's usage tier and rate limit, visit your [Limits settings page](https://platform.openai.com/account/limits).

```python
import openai
import os

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))
```

## Example rate limit error

A rate limit error will occur when API requests are sent too quickly. If using the OpenAI Python library, they will look something like:

```
RateLimitError: Rate limit reached for default-codex in organization org-{id} on requests per min. Limit: 20.000000 / min. Current: 24.000000 / min. Contact support@openai.com if you continue to have issues or if you’d like to request an increase.
```

Below is example code for triggering a rate limit error.

```python
# request a bunch of completions in a loop
for _ in range(100):
    client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": "Hello"}],
        max_tokens=10,
    )
```

## How to mitigate rate limit errors

### Retrying with exponential backoff

One easy way to mitigate rate limit errors is to automatically retry requests with a random exponential backoff. Retrying with exponential backoff means performing a short sleep when a rate limit error is hit, then retrying the unsuccessful request. If the request is still unsuccessful, the sleep length is increased and the process is repeated. This continues until the request is successful or until a maximum number of retries is reached.

This approach has many benefits:

- Automatic retries means you can recover from rate limit errors without crashes or missing data
- Exponential backoff means that your first retries can be tried quickly, while still benefiting from longer delays if your first few retries fail
- Adding random jitter to the delay helps retries from all hitting at the same time

Note that unsuccessful requests contribute to your per-minute limit, so continuously resending a request won’t work.

Below are a few example solutions.

#### Example #1: Using the Tenacity library

[Tenacity](https://tenacity.readthedocs.io/en/latest/) is an Apache 2.0 licensed general-purpose retrying library, written in Python, to simplify the task of adding retry behavior to just about anything.

To add exponential backoff to your requests, you can use the `tenacity.retry` [decorator](https://peps.python.org/pep-0318/). The following example uses the `tenacity.wait_random_exponential` function to add random exponential backoff to a request.

Note that the Tenacity library is a third-party tool, and OpenAI makes no guarantees about its reliability or security.

```python
from tenacity import (
    retry,
    stop_after_attempt,
    wait_random_exponential,
)  # for exponential backoff

@retry(wait=wait_random_exponential(min=1, max=60), stop=stop_after_attempt(6))
def completion_with_backoff(**kwargs):
    return client.chat.completions.create(**kwargs)


completion_with_backoff(model="gpt-4o-mini", messages=[{"role": "user", "content": "Once upon a time,"}])
```

#### Example #2: Using the backoff library

Another library that provides function decorators for backoff and retry is [backoff](https://pypi.org/project/backoff/).

Like Tenacity, the backoff library is a third-party tool, and OpenAI makes no guarantees about its reliability or security.

```python
import backoff  # for exponential backoff

@backoff.on_exception(backoff.expo, openai.RateLimitError, max_time=60, max_tries=6)
def completions_with_backoff(**kwargs):
    return client.chat.completions.create(**kwargs)


completions_with_backoff(model="gpt-4o-mini", messages=[{"role": "user", "content": "Once upon a time,"}])
```

#### Example 3: Manual backoff implementation

If you don't want to use third-party libraries, you can implement your own backoff logic.

```python
# imports
import random
import time

# define a retry decorator
def retry_with_exponential_backoff(
    func,
    initial_delay: float = 1,
    exponential_base: float = 2,
    jitter: bool = True,
    max_retries: int = 10,
    errors: tuple = (openai.RateLimitError,),
):
    """Retry a function with exponential backoff."""

    def wrapper(*args, **kwargs):
        # Initialize variables
        num_retries = 0
        delay = initial_delay

        # Loop until a successful response or max_retries is hit or an exception is raised
        while True:
            try:
                return func(*args, **kwargs)

            # Retry on specified errors
            except errors as e:
                # Increment retries
                num_retries += 1

                # Check if max retries has been reached
                if num_retries > max_retries:
                    raise Exception(
                        f"Maximum number of retries ({max_retries}) exceeded."
                    )

                # Increment the delay
                delay *= exponential_base * (1 + jitter * random.random())

                # Sleep for the delay
                time.sleep(delay)

            # Raise exceptions for any errors not specified
            except Exception as e:
                raise e

    return wrapper


@retry_with_exponential_backoff
def completions_with_backoff(**kwargs):
    return client.chat.completions.create(**kwargs)


completions_with_backoff(model="gpt-4o-mini", messages=[{"role": "user", "content": "Once upon a time,"}])
```

### Backing off to another model

If you encounter rate limit errors on your primary model, one option is to switch to a secondary model. This approach helps keep your application responsive when your primary model is throttled or unavailable.

However, fallback models can differ significantly in accuracy, latency, and cost. As a result, this strategy might not work for every use case; particularly those requiring highly consistent results. Additionally, keep in mind that some models share rate limits, which may reduce the effectiveness of simply switching models. You can see the models that share limits in your [organizations limit page](https://platform.openai.com/settings/organization/limits).

Before deploying this approach to production, thoroughly test how it affects output quality, user experience, and operational budgets. Validate your fallback solution with relevant evaluations to ensure it meets your requirements and maintains acceptable performance under real-world conditions.

```python
def completions_with_fallback(fallback_model, **kwargs):
    try:
        return client.chat.completions.create(**kwargs)
    except openai.RateLimitError:
        kwargs['model'] = fallback_model
        return client.chat.completions.create(**kwargs)


completions_with_fallback(fallback_model="gpt-4o", model="gpt-4o-mini", messages=[{"role": "user", "content": "Once upon a time,"}])
```

### Reducing `max_tokens` to match expected completions

Rate limit usage is calculated based on the greater of:
1. `max_tokens` - the maximum number of tokens allowed in a response.
2. Estimated tokens in your input – derived from your prompt’s character count.

If you set `max_tokens` too high, your usage can be overestimated, even if the actual response is much shorter. To avoid hitting rate limits prematurely, configure `max_tokens` so it closely matches the size of the response you expect. This ensures more accurate usage calculations and helps prevent unintended throttling.

```python
def completions_with_max_tokens(**kwargs):
    return client.chat.completions.create(**kwargs)


completions_with_max_tokens(model="gpt-4o-mini", messages=[{"role": "user", "content": "Once upon a time,"}], max_tokens=100)
```

## How to maximize throughput of batch processing given rate limits

If you're processing real-time requests from users, backoff and retry is a great strategy to minimize latency while avoiding rate limit errors.

However, if you're processing large volumes of batch data, where throughput matters more than latency, there are a few other things you can do in addition to backoff and retry.

### Proactively adding delay between requests

If you are constantly hitting the rate limit, then backing off, then hitting the rate limit again, then backing off again, it's possible that a good fraction of your request budget will be 'wasted' on requests that need to be retried. This limits your processing throughput, given a fixed rate limit.

Here, one potential solution is to calculate your rate limit and add a delay equal to its reciprocal (e.g., if your rate limit 20 requests per minute, add a delay of 3–6 seconds to each request). This can help you operate near the rate limit ceiling without hitting it and incurring wasted requests.

#### Example of adding delay to a request

```python
import time

# Define a function that adds a delay to a Completion API call
def delayed_completion(delay_in_seconds: float = 1, **kwargs):
    """Delay a completion by a specified amount of time."""

    # Sleep for the delay
    time.sleep(delay_in_seconds)

    # Call the Completion API and return the result
    return client.chat.completions.create(**kwargs)


# Calculate the delay based on your rate limit
rate_limit_per_minute = 20
delay = 60.0 / rate_limit_per_minute

delayed_completion(
    delay_in_seconds=delay,
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Once upon a time,"}]
)
```

### Batching requests

The OpenAI API enforces separate limits for requests per minute/day (RPM/RPD) and tokens per minute (TPM). If you’re hitting RPM limits but still have available TPM capacity, consider batching multiple tasks into each request.

By bundling several prompts together, you reduce the total number of requests sent per minute, which helps avoid hitting the RPM cap. This approach may also lead to higher overall throughput if you manage your TPM usage carefully. However, keep the following points in mind:
- Each model has a maximum number of tokens it can process in one request. If your batched prompt exceeds this limit, the request will fail or be truncated.
- Batching can introduce extra waiting time if tasks are delayed until they’re grouped into a single request. This might affect user experience for time-sensitive applications.
- When sending multiple prompts, the response object may not return in the same order or format as the prompts that were submitted. You should try to match each response back to its corresponding prompt by post-processing the output.

#### Example without batching

```python
num_stories = 10
content = "Once upon a time,"

# serial example, with one story completion per request
for _ in range(num_stories):
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": content}],
        max_tokens=20,
    )

    print(content + response.choices[0].message.content)
```

#### Example batching multiple prompts in a single request with Structured Outputs

OpenAI's [Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs) feature offers a robust way to batch multiple prompts in a single request.

Here, rather than parsing raw text or hoping the model follows informal formatting, you specify a strict schema. This ensures your application can reliably parse the results by examining the defined structure. This eliminates the need for extensive validation or complicated parsing logic, as Structured Outputs guarantees consistent, type-safe data.

```python
from pydantic import BaseModel

# Define the Pydantic model for the structured output
class StoryResponse(BaseModel):
    stories: list[str]
    story_count: int

num_stories = 10
content = "Once upon a time,"

prompt_lines = [f"Story #{i+1}: {content}" for i in range(num_stories)]
prompt_text = "\n".join(prompt_lines)

messages = [
    {
        "role": "developer",
        "content": "You are a helpful assistant. Please respond to each prompt as a separate short story."
    },
    {
        "role": "user",
        "content": prompt_text
    }
]

# batched example, with all story completions in one request and using structured outputs
response = client.beta.chat.completions.parse(
    model="gpt-4o-mini",
    messages=messages,
    response_format=StoryResponse,
)

print(response.choices[0].message.content)
```

## Example parallel processing script

We've written an example script for parallel processing large quantities of API requests: [api_request_parallel_processor.py](https://github.com/openai/openai-cookbook/blob/main/examples/api_request_parallel_processor.py).

The script combines some handy features:
- Streams requests from file, to avoid running out of memory for giant jobs
- Makes requests concurrently, to maximize throughput
- Throttles both request and token usage, to stay under rate limits
- Retries failed requests, to avoid missing data
- Logs errors, to diagnose problems with requests

Feel free to use it as is or modify it to suit your needs.
