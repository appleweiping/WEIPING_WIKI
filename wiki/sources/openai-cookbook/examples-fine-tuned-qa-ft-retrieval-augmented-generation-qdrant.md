---
title: "Ft Retrieval Augmented Generation Qdrant"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - evals
  - evaluation
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/fine-tuned_qa/ft_retrieval_augmented_generation_qdrant
  - https://github.com/openai/openai-cookbook/blob/main/examples/fine-tuned_qa/ft_retrieval_augmented_generation_qdrant.ipynb
---

# Ft Retrieval Augmented Generation Qdrant

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/fine-tuned_qa/ft_retrieval_augmented_generation_qdrant
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/fine-tuned_qa/ft_retrieval_augmented_generation_qdrant.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/fine-tuned_qa/ft_retrieval_augmented_generation_qdrant.ipynb
- Source path: `examples/fine-tuned_qa/ft_retrieval_augmented_generation_qdrant.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `7bb1afe577de350778b327db5514ad40cb5cf120645e9acf1e295daec6685f64`

## Classification

- Primary category: Evaluation / eval flywheels
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Fine-Tuning OpenAI Models for Retrieval Augmented Generation (RAG) with Qdrant and Few-Shot Learning The aim of this notebook is to walk through a comprehensive example of how to fine-tune OpenAI models for Retrieval Augmented Generation (RAG). We will also be integrating Qdrant and Few-Shot Learning to boost the model's performance and reduce hallucinations...

## What This Teaches

- How to turn model behavior into measurable evaluation cases and improvement loops.
- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.
- How to prepare data or workflows for model adaptation and fine-tuning.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Fine-Tuning OpenAI Models for Retrieval Augmented Generation (RAG) with Qdrant and Few-Shot Learning

The aim of this notebook is to walk through a comprehensive example of how to fine-tune OpenAI models for Retrieval Augmented Generation (RAG).

We will also be integrating Qdrant and Few-Shot Learning to boost the model's performance and reduce hallucinations. This could serve as a practical guide for ML practitioners, data scientists, and AI Engineers interested in leveraging the power of OpenAI models for specific use-cases. 🤩

Note: This notebook uses the gpt-3.5-turbo model. Fine-tuning on the SQuAD dataset with this setup yields only minimal gains for more advanced models such as gpt-4o or gpt-4.1. As such, this notebook is primarily intended as a guide for fine-tuning workflows and retrieval-augmented generation (RAG) practices

## Why should you read this blog?

You want to learn how to
- [Fine-tune OpenAI models](https://platform.openai.com/docs/guides/fine-tuning/) for specific use-cases
- Use [Qdrant](https://qdrant.tech/documentation/) to improve the performance of your RAG model
- Use fine-tuning to improve the correctness of your RAG model and reduce hallucinations

To begin, we've selected a dataset where we've a guarantee that the retrieval is perfect. We've selected a subset of the [SQuAD](https://rajpurkar.github.io/SQuAD-explorer/) dataset, which is a collection of questions and answers about Wikipedia articles. We've also included samples where the answer is not present in the context, to demonstrate how RAG handles this case.

## Table of Contents
1. Setting up the Environment

### Section A: Zero-Shot Learning
2. Data Preparation: SQuADv2 Dataset
3. Answering using Base gpt-3.5-turbo-0613 model
4. Fine-tuning and Answering using Fine-tuned model
5. **Evaluation**: How well does the model perform?

### Section B: Few-Shot Learning

6. Using Qdrant to Improve RAG Prompt
7. Fine-Tuning OpenAI Model with Qdrant
8. Evaluation

9. **Conclusion**
    - Aggregate Results
    - Observations

## Terms, Definitions, and References

**Retrieval Augmented Generation (RAG)?**
The phrase Retrieval Augmented Generation (RAG) comes from a [recent paper](https://arxiv.org/abs/2005.11401) by Lewis et al. from Facebook AI. The idea is to use a pre-trained language model (LM) to generate text, but to use a separate retrieval system to find relevant documents to condition the LM on.

**What is Qdrant?**
Qdrant is an open-source vector search engine that allows you to search for similar vectors in a large dataset. It is built in Rust and here we'll use the Python client to interact with it. This is the Retrieval part of RAG.

**What is Few-Shot Learning?**
Few-shot learning is a type of machine learning where the model is "improved" via training or fine-tuning on a small amount of data. In this case, we'll use it to fine-tune the RAG model on a small number of examples from the SQuAD dataset. This is the Augmented part of RAG.

**What is Zero-Shot Learning?**
Zero-shot learning is a type of machine learning where the model is "improved" via training or fine-tuning without any dataset specific information.

**What is Fine-Tuning?**
Fine-tuning is a type of machine learning where the model is "improved" via training or fine-tuning on a small amount of data. In this case, we'll use it to fine-tune the RAG model on a small number of examples from the SQuAD dataset. The LLM is what makes the Generation part of RAG.

## 1. Setting Up the Environment

### Install and Import Dependencies

```python
!pip install pandas openai tqdm tenacity scikit-learn tiktoken python-dotenv seaborn --upgrade --quiet
```

```python
import json
import os
import time

import pandas as pd
from openai import OpenAI
import tiktoken
import seaborn as sns
from tenacity import retry, wait_exponential
from tqdm import tqdm
from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt
import numpy as np
from sklearn.metrics import confusion_matrix

import warnings
warnings.filterwarnings('ignore')

tqdm.pandas()

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))
```

### Set your keys
Get your OpenAI keys [here](https://platform.openai.com/account/api-keys) and Qdrant keys after making a free cluster [here](https://cloud.qdrant.io/login).

```python
os.environ["QDRANT_URL"] = "https://xxx.cloud.qdrant.io:6333"
os.environ["QDRANT_API_KEY"] = "xxx"
```

## Section A

## 2. Data Preparation: SQuADv2 Data Subsets

For the purpose of demonstration, we'll make small slices from the train and validation splits of the [SQuADv2](https://rajpurkar.github.io/SQuAD-explorer/) dataset. This dataset has questions and contexts where the answer is not present in the context, to help us evaluate how LLM handles this case.

We'll read the data from the JSON files and create a dataframe with the following columns: `question`, `context`, `answer`, `is_impossible`.

### Download the Data

```python
# !mkdir -p local_cache
# !wget https://rajpurkar.github.io/SQuAD-explorer/dataset/train-v2.0.json -O local_cache/train.json
# !wget https://rajpurkar.github.io/SQuAD-explorer/dataset/dev-v2.0.json -O local_cache/dev.json
```

### Read JSON to DataFrame

```python
def json_to_dataframe_with_titles(json_data):
    qas = []
    context = []
    is_impossible = []
    answers = []
    titles = []

    for article in json_data['data']:
        title = article['title']
        for paragraph in article['paragraphs']:
            for qa in paragraph['qas']:
                qas.append(qa['question'].strip())
                context.append(paragraph['context'])
                is_impossible.append(qa['is_impossible'])

                ans_list = []
                for ans in qa['answers']:
                    ans_list.append(ans['text'])
                answers.append(ans_list)
                titles.append(title)

    df = pd.DataFrame({'title': titles, 'question': qas, 'context': context, 'is_impossible': is_impossible, 'answers': answers})
    return df

def get_diverse_sample(df, sample_size=100, random_state=42):
    """
    Get a diverse sample of the dataframe by sampling from each title
    """
    sample_df = df.groupby(['title', 'is_impossible']).apply(lambda x: x.sample(min(len(x), max(1, sample_size // 50)), random_state=random_state)).reset_index(drop=True)

    if len(sample_df) < sample_size:
        remaining_sample_size = sample_size - len(sample_df)
        remaining_df = df.drop(sample_df.index).sample(remaining_sample_size, random_state=random_state)
        sample_df = pd.concat([sample_df, remaining_df]).sample(frac=1, random_state=random_state).reset_index(drop=True)

    return sample_df.sample(min(sample_size, len(sample_df)), random_state=random_state).reset_index(drop=True)

train_df = json_to_dataframe_with_titles(json.load(open('local_cache/train.json')))
val_df = json_to_dataframe_with_titles(json.load(open('local_cache/dev.json')))

df = get_diverse_sample(val_df, sample_size=100, random_state=42)
```

## 3. Answering using Base gpt-3.5-turbo-0613 model

### 3.1 Zero Shot Prompt

Let's start by using the base gpt-3.5-turbo-0613 model to answer the questions. This prompt is a simple concatenation of the question and context, with a separator token in between: `\n\n`. We've a simple instruction part of the prompt:

> Answer the following Question based on the Context only. Only answer from the Context. If you don't know the answer, say 'I don't know'.

Other prompts are possible, but this is a good starting point. We'll use this prompt to answer the questions in the validation set.

```python
# Function to get prompt messages
def get_prompt(row):
    return [
        {"role": "system", "content": "You are a helpful assistant."},
        {
            "role": "user",
            "content": f"""Answer the following Question based on the Context only. Only answer from the Context. If you don't know the answer, say 'I don't know'.
    Question: {row.question}\n\n
    Context: {row.context}\n\n
    Answer:\n""",
        },
    ]
```

### 3.2 Answering using Zero Shot Prompt

Next, you'll need some re-usable functions which make an OpenAI API Call and return the answer. You'll use the `ChatCompletion.create` endpoint of the API, which takes a prompt and returns the completed text.

```python
# Function with tenacity for retries
@retry(wait=wait_exponential(multiplier=1, min=2, max=6))
def api_call(messages, model):
    return client.chat.completions.create(
        model=model,
        messages=messages,
        stop=["\n\n"],
        max_tokens=100,
        temperature=0.0,
    )


# Main function to answer question
def answer_question(row, prompt_func=get_prompt, model="gpt-3.5-turbo"):
    messages = prompt_func(row)
    response = api_call(messages, model)
    return response.choices[0].message.content
```

⏰ **Time to run: ~3 min**, 🛜 Needs Internet Connection

```python
# Use progress_apply with tqdm for progress bar
df["generated_answer"] = df.progress_apply(answer_question, axis=1)
df.to_json("local_cache/100_val.json", orient="records", lines=True)
df = pd.read_json("local_cache/100_val.json", orient="records", lines=True)
```

```python
df
```

## 4. Fine-tuning and Answering using Fine-tuned model

For the complete fine-tuning process, please refer to the [OpenAI Fine-Tuning Docs](https://platform.openai.com/docs/guides/fine-tuning/use-a-fine-tuned-model).

### 4.1 Prepare the Fine-Tuning Data

We need to prepare the data for fine-tuning. We'll use a few samples from train split of same dataset as before, but we'll add the answer to the context. This will help the model learn to retrieve the answer from the context.

Our instruction prompt is the same as before, and so is the system prompt.

```python
def dataframe_to_jsonl(df):
    def create_jsonl_entry(row):
        answer = row["answers"][0] if row["answers"] else "I don't know"
        messages = [
            {"role": "system", "content": "You are a helpful assistant."},
            {
                "role": "user",
                "content": f"""Answer the following Question based on the Context only. Only answer from the Context. If you don't know the answer, say 'I don't know'.
            Question: {row.question}\n\n
            Context: {row.context}\n\n
            Answer:\n""",
            },
            {"role": "assistant", "content": answer},
        ]
        return json.dumps({"messages": messages})

    jsonl_output = df.apply(create_jsonl_entry, axis=1)
    return "\n".join(jsonl_output)

train_sample = get_diverse_sample(train_df, sample_size=100, random_state=42)

with open("local_cache/100_train.jsonl", "w") as f:
    f.write(dataframe_to_jsonl(train_sample))
```

**Tip: 💡 Verify the Fine-Tuning Data**

You can see this [cookbook](https://github.com/openai/openai-cookbook/blob/main/examples/Chat_finetuning_data_prep.ipynb) for more details on how to prepare the data for fine-tuning.

### 4.2 Fine-Tune OpenAI Model

If you're new to OpenAI Model Fine-Tuning, please refer to the [How to finetune Chat models](https://github.com/openai/openai-cookbook/blob/448a0595b84ced3bebc9a1568b625e748f9c1d60/examples/How_to_finetune_chat_models.ipynb) notebook. You can also refer to the [OpenAI Fine-Tuning Docs](platform.openai.com/docs/guides/fine-tuning/use-a-fine-tuned-model) for more details.

```python
class OpenAIFineTuner:
    """
    Class to fine tune OpenAI models
    """
    def __init__(self, training_file_path, model_name, suffix):
        self.training_file_path = training_file_path
        self.model_name = model_name
        self.suffix = suffix
        self.file_object = None
        self.fine_tuning_job = None
        self.model_id = None

    def create_openai_file(self):
        self.file_object = client.files.create(
            file=open(self.training_file_path, "rb"),
            purpose="fine-tune",
        )

    def wait_for_file_processing(self, sleep_time=20):
        while self.file_object.status != 'processed':
            time.sleep(sleep_time)
            self.file_object.refresh()
            print("File Status: ", self.file_object.status)

    def create_fine_tuning_job(self):
        self.fine_tuning_job = client.fine_tuning.jobs.create(
            training_file=self.file_object.id,
            model=self.model_name,
            suffix=self.suffix,
        )

    def wait_for_fine_tuning(self, sleep_time=45):
        while True:
            # Retrieve the latest fine-tuning job status
            self.fine_tuning_job = client.fine_tuning.jobs.retrieve(self.fine_tuning_job.id)
            print("Job Status:", self.fine_tuning_job.status)
            if self.fine_tuning_job.status in {'succeeded', 'failed', 'cancelled'}:
                break
            time.sleep(sleep_time)

    def retrieve_fine_tuned_model(self):
        self.model_id = client.fine_tuning.jobs.retrieve(self.fine_tuning_job.id).fine_tuned_model
        return self.model_id

    def fine_tune_model(self):
        self.create_openai_file()
        self.wait_for_file_processing()
        self.create_fine_tuning_job()
        self.wait_for_fine_tuning()
        return self.retrieve_fine_tuned_model()

fine_tuner = OpenAIFineTuner(
        training_file_path="local_cache/100_train.jsonl",
        model_name="gpt-3.5-turbo",
        suffix="100trn20230907"
    )
```

⏰ **Time to run: ~10-20 minutes**, 🛜 Needs Internet Connection

```python
model_id = fine_tuner.fine_tune_model()
model_id
```

#### 4.2.1 Try out the Fine-Tuned Model

Let's try out the fine-tuned model on the same validation set as before. You'll use the same prompt as before, but you will use the fine-tuned model instead of the base model. Before you do that, you can make a simple call to get a sense of how the fine-tuned model is doing.

```python
completion = client.chat.completions.create(
    model=model_id,
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello!"},
        {"role": "assistant", "content": "Hi, how can I help you today?"},
        {
            "role": "user",
            "content": "Can you answer the following question based on the given context? If not, say, I don't know:\n\nQuestion: What is the capital of France?\n\nContext: The capital of Mars is Gaia. Answer:",
        },
    ],
)

print(completion.choices[0].message)
```

### 4.3 Answer Using the Fine-Tuned Model

This is the same as before, but you'll use the fine-tuned model instead of the base model.

⏰ **Time to run: ~5 min**, 🛜 Needs Internet Connection

```python
df["ft_generated_answer"] = df.progress_apply(answer_question, model=model_id, axis=1)
```

## 5. Evaluation: How well does the model perform?

To evaluate the model's performance, compare the predicted answer to the actual answers -- if any of the actual answers are present in the predicted answer, then it's a match. We've also created error categories to help you understand where the model is struggling.

When we know that a correct answer exists in the context, we can measure the model's performance, there are 3 possible outcomes:

1. ✅ **Answered Correctly**: The model responded the correct answer. It may have also included other answers that were not in the context.
2. ❎ **Skipped**: The model responded with "I don't know" (IDK) while the answer was present in the context. It's better than giving the wrong answer. It's better for the model say "I don't know" than giving the wrong answer. In our design, we know that a true answer exists and hence we're able to measure it -- this is not always the case. *This is a model error*. We exclude this from the overall error rate.
3. ❌ **Wrong**: The model responded with an incorrect answer. **This is a model ERROR.**

When we know that a correct answer does not exist in the context, we can measure the model's performance, there are 2 possible outcomes:

4. ❌ **Hallucination**: The model responded with an answer, when "I don't know" was expected. **This is a model ERROR.**
5. ✅ **I don't know**: The model responded with "I don't know" (IDK) and the answer was not present in the context. **This is a model WIN.**

```python
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

class Evaluator:
    def __init__(self, df):
        self.df = df
        self.y_pred = pd.Series()  # Initialize as empty Series
        self.labels_answer_expected = ["✅ Answered Correctly", "❎ Skipped", "❌ Wrong Answer"]
        self.labels_idk_expected = ["❌ Hallucination", "✅ I don't know"]

    def _evaluate_answer_expected(self, row, answers_column):
        generated_answer = row[answers_column].lower()
        actual_answers = [ans.lower() for ans in row["answers"&#93;&#93;
        return (
            "✅ Answered Correctly" if any(ans in generated_answer for ans in actual_answers)
            else "❎ Skipped" if generated_answer == "i don't know"
            else "❌ Wrong Answer"
        )

    def _evaluate_idk_expected(self, row, answers_column):
        generated_answer = row[answers_column].lower()
        return (
            "❌ Hallucination" if generated_answer != "i don't know"
            else "✅ I don't know"
        )

    def _evaluate_single_row(self, row, answers_column):
        is_impossible = row["is_impossible"]
        return (
            self._evaluate_answer_expected(row, answers_column) if not is_impossible
            else self._evaluate_idk_expected(row, answers_column)
        )

    def evaluate_model(self, answers_column="generated_answer"):
        self.y_pred = pd.Series(self.df.apply(self._evaluate_single_row, answers_column=answers_column, axis=1))
        freq_series = self.y_pred.value_counts()

        # Counting rows for each scenario
        total_answer_expected = len(self.df[self.df['is_impossible'] == False])
        total_idk_expected = len(self.df[self.df['is_impossible'] == True])

        freq_answer_expected = (freq_series / total_answer_expected * 100).round(2).reindex(self.labels_answer_expected, fill_value=0)
        freq_idk_expected = (freq_series / total_idk_expected * 100).round(2).reindex(self.labels_idk_expected, fill_value=0)
        return freq_answer_expected.to_dict(), freq_idk_expected.to_dict()

    def print_eval(self):
        answer_columns=["generated_answer", "ft_generated_answer"]
        baseline_correctness, baseline_idk = self.evaluate_model()
        ft_correctness, ft_idk = self.evaluate_model(self.df, answer_columns[1])
        print("When the model should answer correctly:")
        eval_df = pd.merge(
            baseline_correctness.rename("Baseline"),
            ft_correctness.rename("Fine-Tuned"),
            left_index=True,
            right_index=True,
        )
        print(eval_df)
        print("\n\n\nWhen the model should say 'I don't know':")
        eval_df = pd.merge(
            baseline_idk.rename("Baseline"),
            ft_idk.rename("Fine-Tuned"),
            left_index=True,
            right_index=True,
        )
        print(eval_df)

    def plot_model_comparison(self, answer_columns=["generated_answer", "ft_generated_answer"], scenario="answer_expected", nice_names=["Baseline", "Fine-Tuned"]):

        results = []
        for col in answer_columns:
            answer_expected, idk_expected = self.evaluate_model(col)
            if scenario == "answer_expected":
                results.append(answer_expected)
            elif scenario == "idk_expected":
                results.append(idk_expected)
            else:
                raise ValueError("Invalid scenario")


        results_df = pd.DataFrame(results, index=nice_names)
        if scenario == "answer_expected":
            results_df = results_df.reindex(self.labels_answer_expected, axis=1)
        elif scenario == "idk_expected":
            results_df = results_df.reindex(self.labels_idk_expected, axis=1)

        melted_df = results_df.reset_index().melt(id_vars='index', var_name='Status', value_name='Frequency')
        sns.set_theme(style="whitegrid", palette="icefire")
        g = sns.catplot(data=melted_df, x='Frequency', y='index', hue='Status', kind='bar', height=5, aspect=2)

        # Annotating each bar
        for p in g.ax.patches:
            g.ax.annotate(f"{p.get_width():.0f}%", (p.get_width()+5, p.get_y() + p.get_height() / 2),
                        textcoords="offset points",
                        xytext=(0, 0),
                        ha='center', va='center')
        plt.ylabel("Model")
        plt.xlabel("Percentage")
        plt.xlim(0, 100)
        plt.tight_layout()
        plt.title(scenario.replace("_", " ").title())
        plt.show()


# Compare the results by merging into one dataframe
evaluator = Evaluator(df)
# evaluator.evaluate_model(answers_column="ft_generated_answer")
# evaluator.plot_model_comparison(["generated_answer", "ft_generated_answer"], scenario="answer_expected", nice_names=["Baseline", "Fine-Tuned"])
```

```python
# Optionally, save the results to a JSON file
df.to_json("local_cache/100_val_ft.json", orient="records", lines=True)
df = pd.read_json("local_cache/100_val_ft.json", orient="records", lines=True)
```

```python
evaluator.plot_model_comparison(["generated_answer", "ft_generated_answer"], scenario="answer_expected", nice_names=["Baseline", "Fine-Tuned"])
```

Notice that the fine-tuned model skips questions more often -- and makes fewer mistakes. This is because the fine-tuned model is more conservative and skips questions when it's not sure.

```python
evaluator.plot_model_comparison(["generated_answer", "ft_generated_answer"], scenario="idk_expected", nice_names=["Baseline", "Fine-Tuned"])
```

Notice that the fine-tuned model has learnt to say "I don't know" a lot better than the prompt. Or, the model has gotten good at skipping questions.

### Observations

1. The fine-tuned model is better at saying "I don't know"
2. Hallucinations drop from 100% to 15% with fine-tuning
3. Wrong answers drop from 17% to 6% with fine-tuning

**Correct answers also drop from 83% to 60% with fine-tuning** - this is because the fine-tuned model is **more conservative** and says "I don't know" more often. This is a good thing because it's better to say "I don't know" than to give a wrong answer.

That said, we want to improve the correctness of the model, even if that increases the hallucinations. We're looking for a model that is both correct and conservative, striking a balance between the two. We'll use Qdrant and Few-Shot Learning to achieve this.

**💪 You're 2/3rds of the way there! Keep reading!**

# Section B: Few Shot Learning

We'll select a few examples from the dataset, including cases where the answer is not present in the context. We'll then use these examples to create a prompt that we can use to fine-tune the model. We'll then measure the performance of the fine-tuned model.

**What is next?**

6. Fine-Tuning OpenAI Model with Qdrant
    6.1 Embed the Fine-Tuning Data
    6.2 Embedding the Questions
7. Using Qdrant to Improve RAG Prompt
8. Evaluation


## 6. Fine-Tuning OpenAI Model with Qdrant

So far, we've been using the OpenAI model to answer questions without using examples of the answer. The previous step made it work better on in-context examples, while this one helps it generalize to unseen data, and attempt to learn when to say "I don't know" and when to give an answer.

This is where few-shot learning comes in!

Few-shot learning is a type of transfer learning that allows us to answer questions where the answer is not present in the context. We can do this by providing a few examples of the answer we're looking for, and the model will learn to answer questions where the answer is not present in the context.

### 5.1 Embed the Training Data

Embeddings are a way to represent sentences as an array of floats. We'll use the embeddings to find the most similar questions to the ones we're looking for.

```python
import os
from qdrant_client import QdrantClient
from qdrant_client.http import models
from qdrant_client.http.models import PointStruct
from qdrant_client.http.models import Distance, VectorParams
```

Now that we've the Qdrant imports in place,

```python
qdrant_client = QdrantClient(
    url=os.getenv("QDRANT_URL"), api_key=os.getenv("QDRANT_API_KEY"), timeout=6000, prefer_grpc=True
)

collection_name = "squadv2-cookbook"

# # Create the collection, run this only once
# qdrant_client.recreate_collection(
#     collection_name=collection_name,
#     vectors_config=VectorParams(size=384, distance=Distance.COSINE),
# )
```

```python
from fastembed.embedding import DefaultEmbedding
from typing import List
import numpy as np
import pandas as pd
from tqdm.notebook import tqdm

tqdm.pandas()

embedding_model = DefaultEmbedding()
```

### 5.2 Embedding the Questions

Next, you'll embed the entire training set questions. You'll use the question to question similarity to find the most similar questions to the question we're looking for. This is a workflow which is used in RAG to leverage the OpenAI model ability of incontext learning with more examples. This is what we call Few Shot Learning here.

**❗️⏰ Important Note: This step can take up to 3 hours to complete. Please be patient. If you see Out of Memory errors or Kernel Crashes, please reduce the batch size to 32, restart the kernel and run the notebook again. This code needs to be run only ONCE.**

## Function Breakdown for `generate_points_from_dataframe`

1. **Initialization**: `batch_size = 512` and `total_batches` set the stage for how many questions will be processed in one go. This is to prevent memory issues. If your machine can handle more, feel free to increase the batch size. If your kernel crashes, reduce the batch size to 32 and try again.
2. **Progress Bar**: `tqdm` gives you a nice progress bar so you don't fall asleep.
3. **Batch Loop**: The for-loop iterates through batches. `start_idx` and `end_idx` define the slice of the DataFrame to process.
4. **Generate Embeddings**: `batch_embeddings = embedding_model.embed(batch, batch_size=batch_size)` - This is where the magic happens. Your questions get turned into embeddings.
5. **PointStruct Generation**: Using `.progress_apply`, it turns each row into a `PointStruct` object. This includes an ID, the embedding vector, and other metadata.

Returns the list of `PointStruct` objects, which can be used to create a collection in Qdrant.

```python
def generate_points_from_dataframe(df: pd.DataFrame) -> List[PointStruct]:
    batch_size = 512
    questions = df["question"].tolist()
    total_batches = len(questions) // batch_size + 1

    pbar = tqdm(total=len(questions), desc="Generating embeddings")

    # Generate embeddings in batches to improve performance
    embeddings = []
    for i in range(total_batches):
        start_idx = i * batch_size
        end_idx = min((i + 1) * batch_size, len(questions))
        batch = questions[start_idx:end_idx]

        batch_embeddings = embedding_model.embed(batch, batch_size=batch_size)
        embeddings.extend(batch_embeddings)
        pbar.update(len(batch))

    pbar.close()

    # Convert embeddings to list of lists
    embeddings_list = [embedding.tolist() for embedding in embeddings]

    # Create a temporary DataFrame to hold the embeddings and existing DataFrame columns
    temp_df = df.copy()
    temp_df["embeddings"] = embeddings_list
    temp_df["id"] = temp_df.index

    # Generate PointStruct objects using DataFrame apply method
    points = temp_df.progress_apply(
        lambda row: PointStruct(
            id=row["id"],
            vector=row["embeddings"],
            payload={
                "question": row["question"],
                "title": row["title"],
                "context": row["context"],
                "is_impossible": row["is_impossible"],
                "answers": row["answers"],
            },
        ),
        axis=1,
    ).tolist()

    return points

points = generate_points_from_dataframe(train_df)
```

#### Upload the Embeddings to Qdrant

Note that configuring Qdrant is outside the scope of this notebook. Please refer to the [Qdrant](https://qdrant.tech) for more information. We used a timeout of 600 seconds for the upload, and grpc compression to speed up the upload.

```python
operation_info = qdrant_client.upsert(
    collection_name=collection_name, wait=True, points=points
)
print(operation_info)
```

## 6. Using Qdrant to Improve RAG Prompt

Now that we've uploaded the embeddings to Qdrant, we can use Qdrant to find the most similar questions to the question we're looking for. We'll use the top 5 most similar questions to create a prompt that we can use to fine-tune the model. We'll then measure the performance of the fine-tuned model on the same validation set, but with few shot prompting!

Our main function `get_few_shot_prompt` serves as the workhorse for generating prompts for few-shot learning. It does this by retrieving similar questions from Qdrant - a vector search engine, using an embeddings model. Here is the high-level workflow:

1. Retrieve similar questions from Qdrant where the **answer is present** in the context
2. Retrieve similar questions from Qdrant where the **answer is IMPOSSIBLE** i.e. the expected answer is "I don't know" to find in the context
3. Create a prompt using the retrieved questions
4. Fine-tune the model using the prompt
5. Evaluate the fine-tuned model on the validation set with the same prompting technique

```python
def get_few_shot_prompt(row):

    query, row_context = row["question"], row["context"]

    embeddings = list(embedding_model.embed([query]))
    query_embedding = embeddings[0].tolist()

    num_of_qa_to_retrieve = 5

    # Query Qdrant for similar questions that have an answer
    q1 = qdrant_client.search(
        collection_name=collection_name,
        query_vector=query_embedding,
        with_payload=True,
        limit=num_of_qa_to_retrieve,
        query_filter=models.Filter(
            must=[
                models.FieldCondition(
                    key="is_impossible",
                    match=models.MatchValue(
                        value=False,
                    ),
                ),
            ],
        )
    )

    # Query Qdrant for similar questions that are IMPOSSIBLE to answer
    q2 = qdrant_client.search(
        collection_name=collection_name,
        query_vector=query_embedding,
        query_filter=models.Filter(
            must=[
                models.FieldCondition(
                    key="is_impossible",
                    match=models.MatchValue(
                        value=True,
                    ),
                ),
            ]
        ),
        with_payload=True,
        limit=num_of_qa_to_retrieve,
    )


    instruction = """Answer the following Question based on the Context only. Only answer from the Context. If you don't know the answer, say 'I don't know'.\n\n"""
    # If there is a next best question, add it to the prompt

    def q_to_prompt(q):
        question, context = q.payload["question"], q.payload["context"]
        answer = q.payload["answers"][0] if len(q.payload["answers"]) > 0 else "I don't know"
        return [
            {
                "role": "user",
                "content": f"""Question: {question}\n\nContext: {context}\n\nAnswer:"""
            },
            {"role": "assistant", "content": answer},
        ]

    rag_prompt = []

    if len(q1) >= 1:
        rag_prompt += q_to_prompt(q1[1])
    if len(q2) >= 1:
        rag_prompt += q_to_prompt(q2[1])
    if len(q1) >= 1:
        rag_prompt += q_to_prompt(q1[2])



    rag_prompt += [
        {
            "role": "user",
            "content": f"""Question: {query}\n\nContext: {row_context}\n\nAnswer:"""
        },
    ]

    rag_prompt = [{"role": "system", "content": instruction}] + rag_prompt
    return rag_prompt
```

```python
# ⏰ Time: 2 min
train_sample["few_shot_prompt"] = train_sample.progress_apply(get_few_shot_prompt, axis=1)
```

## 7. Fine-Tuning OpenAI Model with Qdrant

### 7.1 Upload the Fine-Tuning Data to OpenAI

```python
# Prepare the OpenAI File format i.e. JSONL from train_sample
def dataframe_to_jsonl(df):
    def create_jsonl_entry(row):
        messages = row["few_shot_prompt"]
        return json.dumps({"messages": messages})

    jsonl_output = df.progress_apply(create_jsonl_entry, axis=1)
    return "\n".join(jsonl_output)

with open("local_cache/100_train_few_shot.jsonl", "w") as f:
    f.write(dataframe_to_jsonl(train_sample))
```

### 7.2 Fine-Tune the Model

⏰ **Time to run: ~15-30 minutes**

```python
fine_tuner = OpenAIFineTuner(
        training_file_path="local_cache/100_train_few_shot.jsonl",
        model_name="gpt-3.5-turbo",
        suffix="trnfewshot20230907"
    )

model_id = fine_tuner.fine_tune_model()
model_id
```

```python
# Let's try this out
completion = client.chat.completions.create(
    model=model_id,
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {
            "role": "user",
            "content": "Can you answer the following question based on the given context? If not, say, I don't know:\n\nQuestion: What is the capital of France?\n\nContext: The capital of Mars is Gaia. Answer:",
        },
        {
            "role": "assistant",
            "content": "I don't know",
        },
        {
            "role": "user",
            "content": "Question: Where did Maharana Pratap die?\n\nContext: Rana Pratap's defiance of the mighty Mughal empire, almost alone and unaided by the other Rajput states, constitute a glorious saga of Rajput valour and the spirit of self sacrifice for cherished principles. Rana Pratap's methods of guerrilla warfare was later elaborated further by Malik Ambar, the Deccani general, and by Emperor Shivaji.\nAnswer:",
        },
        {
            "role": "assistant",
            "content": "I don't know",
        },
        {
            "role": "user",
            "content": "Question: Who did Rana Pratap fight against?\n\nContext: In stark contrast to other Rajput rulers who accommodated and formed alliances with the various Muslim dynasties in the subcontinent, by the time Pratap ascended to the throne, Mewar was going through a long standing conflict with the Mughals which started with the defeat of his grandfather Rana Sanga in the Battle of Khanwa in 1527 and continued with the defeat of his father Udai Singh II in Siege of Chittorgarh in 1568. Pratap Singh, gained distinction for his refusal to form any political alliance with the Mughal Empire and his resistance to Muslim domination. The conflicts between Pratap Singh and Akbar led to the Battle of Haldighati. Answer:",
        },
        {
            "role": "assistant",
            "content": "Akbar",
        },
        {
            "role": "user",
            "content": "Question: Which state is Chittorgarh in?\n\nContext: Chittorgarh, located in the southern part of the state of Rajasthan, 233 km (144.8 mi) from Ajmer, midway between Delhi and Mumbai on the National Highway 8 (India) in the road network of Golden Quadrilateral. Chittorgarh is situated where National Highways No. 76 & 79 intersect. Answer:",
        },
    ],
)
print("Correct Answer: Rajasthan\nModel Answer:")
print(completion.choices[0].message)
```

⏰ **Time to run: 5-15 min**

```python
df["ft_generated_answer_few_shot"] = df.progress_apply(answer_question, model=model_id, prompt_func=get_few_shot_prompt, axis=1)
df.to_json("local_cache/100_val_ft_few_shot.json", orient="records", lines=True)
```

## 8. Evaluation

But how well does the model perform? Let's compare the results from the 3 different models we've looked at so far:

```python
evaluator = Evaluator(df)
evaluator.plot_model_comparison(["generated_answer", "ft_generated_answer", "ft_generated_answer_few_shot"], scenario="answer_expected", nice_names=["Baseline", "Fine-Tuned", "Fine-Tuned with Few-Shot"])
```

This is quite amazing -- we're able to get the best of both worlds! We're able to get the model to be both correct and conservative:

1. The model is correct 83% of the time -- this is the same as the base model
2. The model gives the wrong answer only 8% of the time -- down from 17% with the base model

Next, let's look at the hallucinations. We want to reduce the hallucinations, but not at the cost of correctness. We want to strike a balance between the two. We've struck a good balance here:

1. The model hallucinates 53% of the time -- down from 100% with the base model
2. The model says "I don't know" 47% of the time -- up from NEVER with the base model

```python
evaluator.plot_model_comparison(["generated_answer", "ft_generated_answer", "ft_generated_answer_few_shot"], scenario="idk_expected", nice_names=["Baseline", "Fine-Tuned", "Fine-Tuned with Few-Shot"])
```

Few Shot Fine-Tuning with Qdrant is a great way to control and steer the performance of your RAG system. Here, we made the model less conservative compared to zero shot and more confident by using Qdrant to find similar questions.

You can also use Qdrant to make the model more conservative. We did this by giving examples of questions where the answer is not present in the context.
This is biasing the model to say "I don't know" more often.

Similarly, one can also use Qdrant to make the model more confident by giving examples of questions where the answer is present in the context. This biases the model to give an answer more often. The trade-off is that the model will also hallucinate more often.

You can make this trade off by adjusting the training data: distribution of questions and examples, as well as the kind and number of examples you retrieve from Qdrant.

## 9. Conclusion

In this notebook, we've demonstrated how to fine-tune OpenAI models for specific use-cases. We've also demonstrated how to use Qdrant and Few-Shot Learning to improve the performance of the model.

### Aggregate Results

So far, we've looked at the results for each scenario separately, i.e. each scenario summed to 100. Let's look at the results as an aggregate to get a broader sense of how the model is performing:

| Category | Base | Fine-Tuned | Fine-Tuned with Qdrant |
| --- | --- | --- | --- |
| Correct | 44% | 32% | 44% |
| Skipped | 0% | 18% | 5% |
| Wrong | 9% | 3% | 4% |
| Hallucination | 47% | 7% | 25% |
| I don't know | 0% | 40% | 22% |

### Observations

#### Compared to base model
1. The few shot fine-tuned with Qdrant model is as good as the base model at answering questions where the answer is present in the context.
2. The few shot fine-tuned with Qdrant model is better at saying "I don't know" when the answer is not present in the context.
3. The few shot fine-tuned with Qdrant model is better at reducing hallucinations.


#### Compared to fine-tuned model
1. The few shot fine-tuned with Qdrant model gets more correct answers than the fine-tuned model: **83% of the questions are answered correctly vs 60%** for the fine-tuned model
2. The few shot fine-tuned with Qdrant model is better at deciding when to say "I don't know" when the answer is not present in the context. **34% skip rate for the plain fine-tuning mode, vs 9% for the few shot fine-tuned with Qdrant model**


Now, you should be able to:

1. Notice the trade-offs between number of correct answers and hallucinations -- and how training dataset choice influences that!
2. Fine-tune OpenAI models for specific use-cases and use Qdrant to improve the performance of your RAG model
3. Get started on how to evaluate the performance of your RAG model
