---
title: "Qa With Langchain Tair And Openai"
type: source
status: imported
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
  - https://developers.openai.com/cookbook/examples/vector_databases/tair/qa_with_langchain_tair_and_openai
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/tair/QA_with_Langchain_Tair_and_OpenAI.ipynb
---

# Qa With Langchain Tair And Openai

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/tair/qa_with_langchain_tair_and_openai
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/tair/QA_with_Langchain_Tair_and_OpenAI.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/tair/QA_with_Langchain_Tair_and_OpenAI.ipynb
- Source path: `examples/vector_databases/tair/QA_with_Langchain_Tair_and_OpenAI.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `129cabcf7cb5663465b34283e33e4d38f0785b9b4ec2ce26480487db97a20826`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Question Answering with Langchain, Tair and OpenAI This notebook presents how to implement a Question Answering system with Langchain, Tair as a knowledge based and OpenAI embeddings. If you are not familiar with Tair, it’s better to check out the Getting started with Tair and OpenAI.ipynb notebook. This notebook presents an end-to-end process of: - Calculat...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Question Answering with Langchain, Tair and OpenAI
This notebook presents how to implement a Question Answering system with Langchain, Tair as a knowledge based and OpenAI embeddings. If you are not familiar with Tair, it’s better to check out the [Getting_started_with_Tair_and_OpenAI.ipynb](Getting_started_with_Tair_and_OpenAI.ipynb) notebook.

This notebook presents an end-to-end process of:
- Calculating the embeddings with OpenAI API.
- Storing the embeddings in an Tair instance to build a knowledge base.
- Converting raw text query to an embedding with OpenAI API.
- Using Tair to perform the nearest neighbour search in the created collection to find some context.
- Asking LLM to find the answer in a given context.

All the steps will be simplified to calling some corresponding Langchain methods.

## Prerequisites
For the purposes of this exercise we need to prepare a couple of things:
[Tair cloud instance](https://www.alibabacloud.com/help/en/tair/latest/what-is-tair).
[Langchain](https://github.com/hwchase17/langchain) as a framework.
An OpenAI API key.

### Install requirements
This notebook requires the following Python packages: `openai`, `tiktoken`, `langchain` and `tair`.
- `openai` provides convenient access to the OpenAI API.
- `tiktoken` is a fast BPE tokeniser for use with OpenAI's models.
- `langchain` helps us to build applications with LLM more easily.
- `tair` library is used to interact with the tair vector database.

```python
! pip install openai tiktoken langchain tair
```

### Prepare your OpenAI API key
The OpenAI API key is used for vectorization of the documents and queries.

If you don't have an OpenAI API key, you can get one from [https://platform.openai.com/account/api-keys ).

Once you get your key, please add it by getpass.

```python
import getpass

openai_api_key = getpass.getpass("Input your OpenAI API key:")
```

### Prepare your Tair URL
To build the Tair connection, you need to have `TAIR_URL`.

```python
# The format of url: redis://&#91;&#91;username]:[password&#93;&#93;@localhost:6379/0
TAIR_URL = getpass.getpass("Input your tair url:")
```

## Load data
In this section we are going to load the data containing some natural questions and answers to them. All the data will be used to create a Langchain application with Tair being the knowledge base.

```python
import wget

# All the examples come from https://ai.google.com/research/NaturalQuestions
# This is a sample of the training set that we download and extract for some
# further processing.
wget.download("https://storage.googleapis.com/dataset-natural-questions/questions.json")
wget.download("https://storage.googleapis.com/dataset-natural-questions/answers.json")
```

```python
import json

with open("questions.json", "r") as fp:
    questions = json.load(fp)

with open("answers.json", "r") as fp:
    answers = json.load(fp)
```

```python
print(questions[0])
```

```python
print(answers[0])
```

## Chain definition

Langchain is already integrated with Tair and performs all the indexing for given list of documents. In our case we are going to store the set of answers we have.

```python
from langchain.vectorstores import Tair
from langchain.embeddings import OpenAIEmbeddings
from langchain import VectorDBQA, OpenAI

embeddings = OpenAIEmbeddings(openai_api_key=openai_api_key)
doc_store = Tair.from_texts(
    texts=answers, embedding=embeddings, tair_url=TAIR_URL,
)
```

At this stage all the possible answers are already stored in Tair, so we can define the whole QA chain.

```python
llm = OpenAI(openai_api_key=openai_api_key)
qa = VectorDBQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    vectorstore=doc_store,
    return_source_documents=False,
)
```

## Search data

Once the data is put into Tair we can start asking some questions. A question will be automatically vectorized by OpenAI model, and the created vector will be used to find some possibly matching answers in Tair. Once retrieved, the most similar answers will be incorporated into the prompt sent to OpenAI Large Language Model.

```python
import random

random.seed(52)
selected_questions = random.choices(questions, k=5)
```

```python
import time
for question in selected_questions:
    print(">", question)
    print(qa.run(question), end="\n\n")
    # wait 20seconds because of the rate limit
    time.sleep(20)
```

### Custom prompt templates

The `stuff` chain type in Langchain uses a specific prompt with question and context documents incorporated. This is what the default prompt looks like:

```text
Use the following pieces of context to answer the question at the end. If you don't know the answer, just say that you don't know, don't try to make up an answer.
{context}
Question: {question}
Helpful Answer:
```

We can, however, provide our prompt template and change the behaviour of the OpenAI LLM, while still using the `stuff` chain type. It is important to keep `{context}` and `{question}` as placeholders.

#### Experimenting with custom prompts

We can try using a different prompt template, so the model:
1. Responds with a single-sentence answer if it knows it.
2. Suggests a random song title if it doesn't know the answer to our question.

```python
from langchain.prompts import PromptTemplate
custom_prompt = """
Use the following pieces of context to answer the question at the end. Please provide
a short single-sentence summary answer only. If you don't know the answer or if it's
not present in given context, don't try to make up an answer, but suggest me a random
unrelated song title I could listen to.
Context: {context}
Question: {question}
Helpful Answer:
"""

custom_prompt_template = PromptTemplate(
    template=custom_prompt, input_variables=["context", "question"]
)
```

```python
custom_qa = VectorDBQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    vectorstore=doc_store,
    return_source_documents=False,
    chain_type_kwargs={"prompt": custom_prompt_template},
)
```

```python
random.seed(41)
for question in random.choices(questions, k=5):
    print(">", question)
    print(custom_qa.run(question), end="\n\n")
    # wait 20seconds because of the rate limit
    time.sleep(20)
```
