---
title: "Leveraging Model Distillation To Fine Tune A Model"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - notebook
  - openai
  - rag
  - retrieval
source_pages:
  - https://developers.openai.com/cookbook/examples/leveraging_model_distillation_to_fine-tune_a_model
  - https://github.com/openai/openai-cookbook/blob/main/examples/Leveraging_model_distillation_to_fine-tune_a_model.ipynb
---

# Leveraging Model Distillation To Fine Tune A Model

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/leveraging_model_distillation_to_fine-tune_a_model
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Leveraging_model_distillation_to_fine-tune_a_model.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Leveraging_model_distillation_to_fine-tune_a_model.ipynb
- Source path: `examples/Leveraging_model_distillation_to_fine-tune_a_model.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `730e0add7dbceb4d5ee8cf241847eb05251bfa80c6da85f9e05bedc7b4cb81ba`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Leveraging model distillation to fine-tune a model OpenAI recently released Distillation which allows to leverage the outputs of a (large) model to fine-tune another (smaller) model. This can significantly reduce the price and the latency for specific tasks as you move to a smaller model. In this cookbook we'll look at a dataset, distill the output of gpt-4o...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.
- How to prepare data or workflows for model adaptation and fine-tuning.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Leveraging model distillation to fine-tune a model

OpenAI recently released **Distillation** which allows to leverage the outputs of a (large) model to fine-tune another (smaller) model. This can significantly reduce the price and the latency for specific tasks as you move to a smaller model. In this cookbook we'll look at a dataset, distill the output of gpt-4o to gpt-4o-mini and show how we can get significantly better results than on a generic, non-distilled, 4o-mini.

We'll also leverage **Structured Outputs** for a classification problem using a list of enum. We'll see how fine-tuned model can benefit from structured output and how it will impact the performance. We'll show that **Structured Ouputs** work with all of those models, including the distilled one.

We'll first analyze the dataset, get the output of both 4o and 4o mini, highlighting the difference in performance of both models, then proceed to the distillation and analyze the performance of this distilled model.

## Prerequisites

Let's install and load dependencies.
Make sure your OpenAI API key is defined in your environment as "OPENAI_API_KEY" and it'll be loaded by the client directly.

```python
! pip install openai tiktoken numpy pandas tqdm --quiet
```

```python
import openai
import json
import tiktoken
from tqdm import tqdm
from openai import OpenAI
import numpy as np
import concurrent.futures
import pandas as pd

client = OpenAI()
```

## Loading and understanding the dataset

For this cookbook, we'll load the data from the following Kaggle challenge: [https://www.kaggle.com/datasets/zynicide/wine-reviews](https://www.kaggle.com/datasets/zynicide/wine-reviews).

This dataset has a large number of rows and you're free to run this cookbook on the whole data, but as a biaised french wine-lover, I'll narrow down the dataset to only French wine to focus on less rows and grape varieties.

We're looking at a classification problem where we'd like to guess the grape variety based on all other criterias available, including description, subregion and province that we'll include in the prompt. It gives a lot of information to the model, you're free to also remove some information that can help significantly the model such as the region in which it was produced to see if it does a good job at finding the grape.

Let's filter the grape varieties that have less than 5 occurences in reviews.

Let's proceed with a subset of 500 random rows from this dataset.

```python
df = pd.read_csv('data/winemag/winemag-data-130k-v2.csv')
df_france = df[df['country'] == 'France']

# Let's also filter out wines that have less than 5 references with their grape variety – even though we'd like to find those
# they're outliers that we don't want to optimize for that would make our enum list be too long
# and they could also add noise for the rest of the dataset on which we'd like to guess, eventually reducing our accuracy.

varieties_less_than_five_list = df_france['variety'].value_counts()[df_france['variety'].value_counts() < 5].index.tolist()
df_france = df_france[~df_france['variety'].isin(varieties_less_than_five_list)]

df_france_subset = df_france.sample(n=500)
df_france_subset.head()
```

Let's retrieve all grape varieties to include them in the prompt and in our structured outputs enum list.

```python
varieties = np.array(df_france['variety'].unique()).astype('str')
varieties
```

## Generating the prompt

Let's build out a function to generate our prompt and try it for the first wine of our list.

```python
def generate_prompt(row, varieties):
    # Format the varieties list as a comma-separated string
    variety_list = ', '.join(varieties)

    prompt = f"""
    Based on this wine review, guess the grape variety:
    This wine is produced by {row['winery']} in the {row['province']} region of {row['country']}.
    It was grown in {row['region_1']}. It is described as: "{row['description']}".
    The wine has been reviewed by {row['taster_name']} and received {row['points']} points.
    The price is {row['price']}.

    Here is a list of possible grape varieties to choose from: {variety_list}.

    What is the likely grape variety? Answer only with the grape variety name or blend from the list.
    """
    return prompt

# Example usage with a specific row
prompt = generate_prompt(df_france.iloc[0], varieties)
prompt
```

To get a understanding of the cost before running the queries, you can leverage tiktoken to understand the number of tokens we'll send and the cost associated to run this. This will only give you an estimate for to run the completions, not the fine-tuning process (used later in this cookbook when running the distillation), which depends on other factors such as the number of epochs, training set etc.

```python
# Load encoding for the GPT-4 model
enc = tiktoken.encoding_for_model("gpt-4o")

# Initialize a variable to store the total number of tokens
total_tokens = 0

for index, row in df_france_subset.iterrows():
    prompt = generate_prompt(row, varieties)

    # Tokenize the input text and count tokens
    tokens = enc.encode(prompt)
    token_count = len(tokens)

    # Add the token count to the total
    total_tokens += token_count

print(f"Total number of tokens in the dataset: {total_tokens}")
print(f"Total number of prompts: {len(df_france_subset)}")
```

```python
# outputing cost in $ as of 2024/10/16

gpt4o_token_price = 2.50 / 1_000_000  # $2.50 per 1M tokens
gpt4o_mini_token_price = 0.150 / 1_000_000  # $0.15 per 1M tokens

total_gpt4o_cost = gpt4o_token_price*total_tokens
total_gpt4o_mini_cost = gpt4o_mini_token_price*total_tokens

print(total_gpt4o_cost)
print(total_gpt4o_mini_cost)
```

## Preparing functions to Store Completions

As we're looking at a limited list of response (enumerate list of grape varieties), let's leverage structured outputs so we make sure the model will answer from this list. This also allows us to compare the model's answer directly with the grape variety and have a deterministic answer (compared to a model that could answer "I think the grape is Pinot Noir" instead of just "Pinot noir"), on top of improving the performance to avoid grape varieties not in our dataset.

If you want to know more on Structured Outputs you can read this [cookbook](https://cookbook.openai.com/examples/structured_outputs_intro) and this [documentation guide](https://platform.openai.com/docs/guides/structured-outputs/introduction).

```python
response_format = {
    "type": "json_schema",
    "json_schema": {
        "name": "grape-variety",
        "schema": {
            "type": "object",
            "properties": {
                "variety": {
                    "type": "string",
                    "enum": varieties.tolist()
                }
            },
            "additionalProperties": False,
            "required": ["variety"],
        },
        "strict": True
    }
}
```

To distill a model, you need to store all completions from a model, allowing you to give it as a reference to the smaller model to fine-tune it. We're therefore adding a `store=True` parameter to our `client.chat.completions.create` method so we can store those completions from gpt-4o.

We're going to store all completions (even 4o-mini and our future fine-tuned model) so we are able to run [Evals](https://platform.openai.com/docs/guides/evals) from OpenAI platform directly.

When storing those completions, it's useful to store them with a metadata tag, that will allow filtering from the OpenAI platform to run distillation & evals on the specific set of completions you'd like to run those.

```python
# Initialize the progress index
metadata_value = "wine-distillation" # that's a funny metadata tag :-)

# Function to call the API and process the result for a single model (blocking call in this case)
def call_model(model, prompt):
    response = client.chat.completions.create(
        model=model,
        store=True,
        metadata={
            "distillation": metadata_value,
        },
        messages=[
            {
                "role": "system",
                "content": "You're a sommelier expert and you know everything about wine. You answer precisely with the name of the variety/blend."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
         response_format=response_format
    )
    return json.loads(response.choices[0].message.content.strip())['variety']
```

## Parallel processing

As we'll run this on a large number of rows, let's make sure we run those completions in parallel and use concurrent futures for this. We'll iterate on our dataframe and output progress every 20 rows. We'll store the completion from the model we run the completion for in the same dataframe using the column name `{model}-variety`.

```python
def process_example(index, row, model, df, progress_bar):
    global progress_index

    try:
        # Generate the prompt using the row
        prompt = generate_prompt(row, varieties)

        df.at[index, model + "-variety"] = call_model(model, prompt)

        # Update the progress bar
        progress_bar.update(1)

        progress_index += 1
    except Exception as e:
        print(f"Error processing model {model}: {str(e)}")

def process_dataframe(df, model):
    global progress_index
    progress_index = 1  # Reset progress index

    # Create a tqdm progress bar
    with tqdm(total=len(df), desc="Processing rows") as progress_bar:
        # Process each example concurrently using ThreadPoolExecutor
        with concurrent.futures.ThreadPoolExecutor() as executor:
            futures = {executor.submit(process_example, index, row, model, df, progress_bar): index for index, row in df.iterrows()}

            for future in concurrent.futures.as_completed(futures):
                try:
                    future.result()  # Wait for each example to be processed
                except Exception as e:
                    print(f"Error processing example: {str(e)}")

    return df
```

Let's try out our call model function before processing the whole dataframe and check the output.

```python
answer = call_model('gpt-4o', generate_prompt(df_france_subset.iloc[0], varieties))
answer
```

Great! We confirmed we can get a grape variety as an output, let's now process the dataset with both `gpt-4o` and `gpt-4o-mini` and compare the results.

```python
df_france_subset = process_dataframe(df_france_subset, "gpt-4o")
```

```python
df_france_subset = process_dataframe(df_france_subset, "gpt-4o-mini")
```

## Comparing gpt-4o and gpt-4o-mini

Now that we've got all chat completions for those two models ; let's compare them against the expected grape variety and assess their accuracy at finding it. We'll do this directly in python here as we've got a simple string check to run, but if your task involves more complex evals you can leverage OpenAI Evals or our open-source eval framework.

```python
models = ['gpt-4o', 'gpt-4o-mini']

def get_accuracy(model, df):
    return np.mean(df['variety'] == df[model + '-variety'])

for model in models:
    print(f"{model} accuracy: {get_accuracy(model, df_france_subset) * 100:.2f}%")
```

We can see that gpt-4o is better a finding grape variety than 4o-mini (12.80% higher or almost 20% relatively to 4o-mini!). Now I'm wondering if we're making gpt-4o drink wine during training!

## Distilling gpt-4o outputs to gpt-4o-mini

Let's assume we'd like to run this prediction often, we want completions to be faster and cheaper, but keep that level of accuracy. That'd be great to be able to distill 4o accuracy to 4o-mini, wouldn't it? Let's do it!

We'll now go to OpenAI Stored completions page: [https://platform.openai.com/chat-completions](https://platform.openai.com/chat-completions).

Let's select the model gpt-4o (make sure to do this, you don't want to distill the outputs of 4o-mini that we ran). Let's also select the metadata `distillation: wine-distillation` to get only stored completions ran from this cookbook.

![Filtering out completions](../images/filtering-out-completions.png)

Once you've selected completions, you can click on "Distill" on the top right corner to fine-tune a model based on those completions. Once we've done that, a file to run the fine-tuning process will automatically be created. Let's then select `gpt-4o-mini` as the base model, keep the default parameters (but you're free to change them or iterate with it to improve performance).

![Distilling modal](../images/distilling.png)

Once the fine-tuning job is starting, you can retrieve the fine tuning job ID from the fine-tuning page, we'll use it to monitor status of the fine-tuned job as well as retrieving the fine-tuned model id once done.

![Fine tuning job](../images/fine-tuning-job.png)

```python
# copy paste your fine-tune job ID below
finetune_job = client.fine_tuning.jobs.retrieve("ftjob-pRyNWzUItmHpxmJ1TX7FOaWe")

if finetune_job.status == 'succeeded':
    fine_tuned_model = finetune_job.fine_tuned_model
    print('finetuned model: ' + fine_tuned_model)
else:
    print('finetuned job status: ' + finetune_job.status)
```

## Running completions for the distilled model

Now that we've got our model fine-tuned, we can use this model to run completions and compare accuracy with both gpt4o and gpt4o-mini.
Let's grab a different subset of french wines (as we restricted the outputs to french grape varieties, without outliers, we'll need to focus our validation dataset to this too). Let's run this on 300 entries for each models.

```python
validation_dataset = df_france.sample(n=300)

models.append(fine_tuned_model)

for model in models:
    another_subset = process_dataframe(validation_dataset, model)
```

Let's compare accuracy of models

```python
for model in models:
    print(f"{model} accuracy: {get_accuracy(model, another_subset) * 100:.2f}%")
```

That's almost a **22% relative improvement over the non-distilled gpt-4o-mini! 🎉**

Our fine-tuned model performs way better than gpt-4o-mini, while having the same base model. We'll be able to use this model to run inferences at a lower cost and lower latency for future grape variety prediction.
