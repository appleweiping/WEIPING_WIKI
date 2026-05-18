---
title: "Evalsapi Image Inputs"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - evals
  - evaluation
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/evaluation/use-cases/evalsapi_image_inputs
  - https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/EvalsAPI_Image_Inputs.ipynb
---

# Evalsapi Image Inputs

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/evaluation/use-cases/evalsapi_image_inputs
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/use-cases/EvalsAPI_Image_Inputs.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/evaluation/use-cases/EvalsAPI_Image_Inputs.ipynb
- Source path: `examples/evaluation/use-cases/EvalsAPI_Image_Inputs.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `83c2d1e126c1e23eef823bf43b47d42a3662fd75f166d8b479f366dcb816f998`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Evals API: Image Inputs This cookbook demonstrates how to use OpenAI's Evals framework for image-based tasks. Leveraging the Evals API, we will grade model-generated responses to an image and prompt by using sampling to generate model responses and model grading (LLM as a Judge) to score the model responses against the image, prompt, and reference answer. In...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Evals API: Image Inputs

This cookbook demonstrates how to use OpenAI's Evals framework for image-based tasks. Leveraging the Evals API, we will grade model-generated responses to an image and prompt by using **sampling** to generate model responses and **model grading** (LLM as a Judge) to score the model responses against the image, prompt, and reference answer.

In this example, we will evaluate how well our model can:
1. **Generate appropriate responses** to user prompts about images
3. **Align with reference answers** that represent high-quality responses

## Installing Dependencies + Setup

```python
# Install required packages
!pip install openai datasets pandas --quiet
```

```python
# Import libraries
from datasets import load_dataset
from openai import OpenAI
import os
import json
import time
import pandas as pd
```

## Dataset Preparation

We use the [VibeEval](https://huggingface.co/datasets/RekaAI/VibeEval) dataset that's hosted on Hugging Face. It contains a collection of user prompt, accompanying image, and reference answer data. First, we load the dataset.

```python
dataset = load_dataset("RekaAI/VibeEval")
```

We extract the relevant fields and put it in a json-like format to pass in as a data source in the Evals API. Input image data can be in the form of a web URL or a base64 encoded string. Here, we use the provided web URLs.

```python
evals_data_source = []

# select the first 3 examples in the dataset to use for this cookbook
for example in dataset["test"].select(range(3)):
    evals_data_source.append({
        "item": {
            "media_url": example["media_url"], # image web URL
            "reference": example["reference"], # reference answer
            "prompt": example["prompt"] # prompt
        }
    })
```

If you print the data source list, each item should be of a similar form to:

```python
{
  "item": {
    "media_url": "https://storage.googleapis.com/reka-annotate.appspot.com/vibe-eval/difficulty-normal_food1_7e5c2cb9c8200d70.jpg"
    "reference": "This appears to be a classic Margherita pizza, which has the following ingredients..."
    "prompt": "What ingredients do I need to make this?"
  }
}
```

## Eval Configuration

Now that we have our data source and task, we will create our evals. For the OpenAI Evals API docs, visit [API docs](https://platform.openai.com/docs/evals/overview).

```python
client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY")
)
```

Evals have two parts, the "Eval" and the "Run". In the "Eval", we define the expected structure of the data and the testing criteria (grader).

### Data Source Config

Based on the data that we have compiled, our data source config is as follows:

```python
data_source_config = {
    "type": "custom",
    "item_schema": {
        "type": "object",
        "properties": {
          "media_url": { "type": "string" },
          "reference": { "type": "string" },
          "prompt": { "type": "string" }
        },
        "required": ["media_url", "reference", "prompt"]
      },
    "include_sample_schema": True, # enables sampling
}
```

### Testing Criteria

For our testing criteria, we set up our grader config. In this example, it is a model grader that takes in an image, reference answer, and sampled model response (in the `sample` namespace), and then outputs a score between 0 and 1 based on how closely the model response matches the reference answer and its general suitability for the conversation. For more info on model graders, visit [API Grader docs](https://platform.openai.com/docs/api-reference/graders).

Getting the both the data and the grader right are key for an effective evaluation. So, you will likely want to iteratively refine the prompts for your graders.

**Note**: The image url field / templating need to be placed in an input image object to be interpreted as an image. Otherwise, the image will be interpreted as a text string.

```python
grader_config = {
	    "type": "score_model",
        "name": "Score Model Grader",
        "input":[
            {
                "role": "system",
		        "content": "You are an expert grader. Judge how well the model response suits the image and prompt as well as matches the meaniing of the reference answer. Output a score of 1 if great. If it's somewhat compatible, output a score around 0.5. Otherwise, give a score of 0."
	        },
	        {
		        "role": "user",
		        "content": [{ "type": "input_text", "text": "Prompt: {{ item.prompt }}."},
							{ "type": "input_image", "image_url": "{{ item.media_url }}", "detail": "auto" },
							{ "type": "input_text", "text": "Reference answer: {{ item.reference }}. Model response: {{ sample.output_text }}."}
				]
	        }
		],
		"pass_threshold": 0.9,
	    "range": [0, 1],
	    "model": "o4-mini" # model for grading; check that the model you use supports image inputs
	}
```

Now, we create the eval object.

```python
eval_object = client.evals.create(
        name="Image Grading",
        data_source_config=data_source_config,
        testing_criteria=[grader_config],
    )
```

## Eval Run

To create the run, we pass in the eval object id, the data source (i.e., the data we compiled earlier), and the chat message input we will use for sampling to generate the model response. Note that EvalsAPI also supports stored completions and responses containing images as a data source. See the [Additional Info: Logs Data Source](#additional-info-logs-data-source) section for more info.

Here's the sampling message input we'll use for this example.

```python
sampling_messages = [{
    "role": "user",
    "type": "message",
    "content": {
        "type": "input_text",
        "text": "{{ item.prompt }}"
      }
  },
  {
    "role": "user",
    "type": "message",
    "content": {
        "type": "input_image",
        "image_url": "{{ item.media_url }}",
        "detail": "auto"
    }
  }]
```

We now kickoff an eval run.

```python
eval_run = client.evals.runs.create(
        name="Image Input Eval Run",
        eval_id=eval_object.id,
        data_source={
            "type": "responses", # sample using responses API
            "source": {
                "type": "file_content",
                "content": evals_data_source
            },
            "model": "gpt-4o-mini", # model used to generate the response; check that the model you use supports image inputs
            "input_messages": {
                "type": "template",
                "template": sampling_messages}
        }
    )
```

## Poll and Display the Results

When the run finishes, we can take a look at the result. You can also check in your org's OpenAI evals dashboard to see the progress and results.

```python
while True:
    run = client.evals.runs.retrieve(run_id=eval_run.id, eval_id=eval_object.id)
    if run.status == "completed" or run.status == "failed": # check if the run is finished
        output_items = list(client.evals.runs.output_items.list(
            run_id=run.id, eval_id=eval_object.id
        ))
        df = pd.DataFrame({
                "prompt": [item.datasource_item["prompt"] for item in output_items],
                "reference": [item.datasource_item["reference"] for item in output_items],
                "model_response": [item.sample.output[0].content for item in output_items],
                "score": [item.results[0].score for item in output_items],
                "passed": [item.results[0].passed for item in output_items],
                "grading_results": [item.results[0].sample["output"][0]["content"] for item in output_items]
            })
        display(df)
        break
    time.sleep(5)
```

### Viewing Individual Output Items

To see a full output item, we can do the following. The structure of an output item is specified in the API docs [here](https://platform.openai.com/docs/api-reference/evals/run-output-item-object).

```python
first_item = output_items[0]

print(json.dumps(dict(first_item), indent=2, default=str))
```

## Additional Info: Logs Data Source

As mentioned earlier, EvalsAPI supports logs (i.e., stored completions or responses) containing images as a data source. To use this functionality, change your eval configurations as follows:

Eval Creation
  - set `data_source_config = { "type": "logs" }`
  - revise templating in `grader_config` to use `{{item.input}}` and/or `{{sample.output_text}}`, denoting the input and output of the log

Eval Run Creation
  - specify the filters in the `data_source` field that will be used to obtain the corresponding logs for the eval run (see the [docs](https://platform.openai.com/docs/api-reference/evals/createRun) for more information)

## Conclusion

In this cookbook, we covered a workflow for evaluating an image-based task using the OpenAI Evals API's. By using the image input functionality for both sampling and model grading, we were able to streamline our evals process for the task.

We're excited to see you extend this to your own image-based use cases, whether it's OCR accuracy, image generation grading, and more!
