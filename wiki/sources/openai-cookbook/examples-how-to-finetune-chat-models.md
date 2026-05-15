---
title: "How To Finetune Chat Models"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - fine-tuning
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/how_to_finetune_chat_models
  - https://github.com/openai/openai-cookbook/blob/main/examples/How_to_finetune_chat_models.ipynb
---

# How To Finetune Chat Models

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/how_to_finetune_chat_models
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/How_to_finetune_chat_models.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/How_to_finetune_chat_models.ipynb
- Source path: `examples/How_to_finetune_chat_models.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `0b7b82d72569c89dee002801779f7d5b1ed7f377a70a51c6c8a610b1d0310288`

## Classification

- Primary category: Fine-tuning / reinforcement fine-tuning
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

How to fine-tune chat models Fine-tuning improves the model by training on many more examples than can fit in a prompt, letting you achieve better results on a wide number of tasks. This notebook provides a step-by-step guide for our new GPT-4o mini fine-tuning. We'll perform entity extraction using the $1, which provides various recipes and a list of extrac...

## What This Teaches

- How to prepare data or workflows for model adaptation and fine-tuning.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# How to fine-tune chat models

Fine-tuning improves the model by training on many more examples than can fit in a prompt, letting you achieve better results on a wide number of tasks. This notebook provides a step-by-step guide for our new GPT-4o mini fine-tuning. We'll perform entity extraction using the [RecipeNLG dataset](https://github.com/Glorf/recipenlg), which provides various recipes and a list of extracted generic ingredients for each. This is a common dataset for named entity recognition (NER) tasks.

Note: **GPT-4o mini fine-tuning is available to developers in our [Tier 4 and 5 usage tiers](https://platform.openai.com/docs/guides/rate-limits/usage-tiers).** You can start fine-tuning GPT-4o mini by visiting your fine-tuning dashboard, clicking "create", and selecting “gpt-4o-mini-2024-07-18” from the base model drop-down.

We will go through the following steps:

1. **Setup:** Loading our dataset and filtering down to one domain to fine-tune on.
2. **Data preparation:** Preparing your data for fine-tuning by creating training and validation examples, and uploading them to the `Files` endpoint.
3. **Fine-tuning:** Creating your fine-tuned model.
4. **Inference:** Using your fine-tuned model for inference on new inputs.

By the end of this you should be able to train, evaluate and deploy a fine-tuned `gpt-4o-mini-2024-07-18` model.

For more information on fine-tuning, you can refer to our [documentation guide](https://platform.openai.com/docs/guides/fine-tuning) or [API reference](https://platform.openai.com/docs/api-reference/fine-tuning).

## Setup

```python
# make sure to use the latest version of the openai python package
!pip install --upgrade --quiet openai
```

```python
import json
import openai
import os
import pandas as pd
from pprint import pprint

client = openai.OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
    organization="<org id>",
    project="<project id>",
)
```

Fine-tuning works best when focused on a particular domain. It's important to make sure your dataset is both focused enough for the model to learn, but general enough that unseen examples won't be missed. Having this in mind, we have extracted a subset from the RecipesNLG dataset to only contain documents from [cookbooks.com](https://cookbooks.com/).

```python
# Read in the dataset we'll use for this task.
# This will be the RecipesNLG dataset, which we've cleaned to only contain documents from www.cookbooks.com
recipe_df = pd.read_csv("data/cookbook_recipes_nlg_10k.csv")

recipe_df.head()
```

## Data preparation

We'll begin by preparing our data. When fine-tuning with the `ChatCompletion` format, each training example is a simple list of `messages`. For example, an entry could look like:

```
[{'role': 'system',
  'content': 'You are a helpful recipe assistant. You are to extract the generic ingredients from each of the recipes provided.'},

 {'role': 'user',
  'content': 'Title: No-Bake Nut Cookies\n\nIngredients: ["1 c. firmly packed brown sugar", "1/2 c. evaporated milk", "1/2 tsp. vanilla", "1/2 c. broken nuts (pecans)", "2 Tbsp. butter or margarine", "3 1/2 c. bite size shredded rice biscuits"]\n\nGeneric ingredients: '},

 {'role': 'assistant',
  'content': '["brown sugar", "milk", "vanilla", "nuts", "butter", "bite size shredded rice biscuits"]'}]
```

During the training process this conversation will be split, with the final entry being the `completion` that the model will produce, and the remainder of the `messages` acting as the prompt. Consider this when building your training examples - if your model will act on multi-turn conversations, then please provide representative examples so it doesn't perform poorly when the conversation starts to expand.

Please note that currently there is a 4096 token limit for each training example. Anything longer than this will be truncated at 4096 tokens.

```python
system_message = "You are a helpful recipe assistant. You are to extract the generic ingredients from each of the recipes provided."


def create_user_message(row):
    return f"Title: {row['title']}\n\nIngredients: {row['ingredients']}\n\nGeneric ingredients: "


def prepare_example_conversation(row):
    return {
        "messages": [
            {"role": "system", "content": system_message},
            {"role": "user", "content": create_user_message(row)},
            {"role": "assistant", "content": row["NER"]},
        ]
    }


pprint(prepare_example_conversation(recipe_df.iloc[0]))
```

Let's now do this for a subset of the dataset to use as our training data. You can begin with even 30-50 well-pruned examples. You should see performance continue to scale linearly as you increase the size of the training set, but your jobs will also take longer.

```python
# use the first 100 rows of the dataset for training
training_df = recipe_df.loc[0:100]

# apply the prepare_example_conversation function to each row of the training_df
training_data = training_df.apply(prepare_example_conversation, axis=1).tolist()

for example in training_data[:5]:
    print(example)
```

In addition to training data, we can also **optionally** provide validation data, which will be used to make sure that the model does not overfit your training set.

```python
validation_df = recipe_df.loc[101:200]
validation_data = validation_df.apply(
    prepare_example_conversation, axis=1).tolist()
```

We then need to save our data as `.jsonl` files, with each line being one training example conversation.

```python
def write_jsonl(data_list: list, filename: str) -> None:
    with open(filename, "w") as out:
        for ddict in data_list:
            jout = json.dumps(ddict) + "\n"
            out.write(jout)
```

```python
training_file_name = "tmp_recipe_finetune_training.jsonl"
write_jsonl(training_data, training_file_name)

validation_file_name = "tmp_recipe_finetune_validation.jsonl"
write_jsonl(validation_data, validation_file_name)
```

This is what the first 5 lines of our training `.jsonl` file look like:

```python
# print the first 5 lines of the training file
!head -n 5 tmp_recipe_finetune_training.jsonl
```

### Upload files

You can now upload the files to our `Files` endpoint to be used by the fine-tuned model.

```python
def upload_file(file_name: str, purpose: str) -> str:
    with open(file_name, "rb") as file_fd:
        response = client.files.create(file=file_fd, purpose=purpose)
    return response.id


training_file_id = upload_file(training_file_name, "fine-tune")
validation_file_id = upload_file(validation_file_name, "fine-tune")

print("Training file ID:", training_file_id)
print("Validation file ID:", validation_file_id)
```

## Fine-tuning

Now we can create our fine-tuning job with the generated files and an optional suffix to identify the model. The response will contain an `id` which you can use to retrieve updates on the job.

Note: The files have to first be processed by our system, so you might get a `File not ready` error. In that case, simply retry a few minutes later.

```python
MODEL = "gpt-4o-mini-2024-07-18"

response = client.fine_tuning.jobs.create(
    training_file=training_file_id,
    validation_file=validation_file_id,
    model=MODEL,
    suffix="recipe-ner",
)

job_id = response.id

print("Job ID:", response.id)
print("Status:", response.status)
```

#### Check job status

You can make a `GET` request to the `https://api.openai.com/v1/alpha/fine-tunes` endpoint to list your alpha fine-tune jobs. In this instance you'll want to check that the ID you got from the previous step ends up as `status: succeeded`.

Once it is completed, you can use the `result_files` to sample the results from the validation set (if you uploaded one), and use the ID from the `fine_tuned_model` parameter to invoke your trained model.

```python
response = client.fine_tuning.jobs.retrieve(job_id)

print("Job ID:", response.id)
print("Status:", response.status)
print("Trained Tokens:", response.trained_tokens)
```

We can track the progress of the fine-tune with the events endpoint. You can rerun the cell below a few times until the fine-tune is ready.

```python
response = client.fine_tuning.jobs.list_events(job_id)

events = response.data
events.reverse()

for event in events:
    print(event.message)
```

Now that it's done, we can get a fine-tuned model ID from the job:

```python
response = client.fine_tuning.jobs.retrieve(job_id)
fine_tuned_model_id = response.fine_tuned_model

if fine_tuned_model_id is None:
    raise RuntimeError(
        "Fine-tuned model ID not found. Your job has likely not been completed yet."
    )

print("Fine-tuned model ID:", fine_tuned_model_id)
```

## Inference

The last step is to use your fine-tuned model for inference. Similar to the classic `FineTuning`, you simply call `ChatCompletions` with your new fine-tuned model name filling the `model` parameter.

```python
test_df = recipe_df.loc[201:300]
test_row = test_df.iloc[0]
test_messages = []
test_messages.append({"role": "system", "content": system_message})
user_message = create_user_message(test_row)
test_messages.append({"role": "user", "content": user_message})

pprint(test_messages)
```

```python
response = client.chat.completions.create(
    model=fine_tuned_model_id, messages=test_messages, temperature=0, max_tokens=500
)
print(response.choices[0].message.content)
```

## Conclusion

Congratulations, you are now ready to fine-tune your own models using the `ChatCompletion` format! We look forward to seeing what you build
