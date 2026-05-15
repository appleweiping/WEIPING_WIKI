---
title: "Deeplake Langchain Qa"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - notebook
  - openai
  - rag
  - retrieval
source_pages:
  - https://developers.openai.com/cookbook/examples/vector_databases/deeplake/deeplake_langchain_qa
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/deeplake/deeplake_langchain_qa.ipynb
---

# Deeplake Langchain Qa

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/deeplake/deeplake_langchain_qa
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/deeplake/deeplake_langchain_qa.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/deeplake/deeplake_langchain_qa.ipynb
- Source path: `examples/vector_databases/deeplake/deeplake_langchain_qa.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `8883ef32f6bf2103842f8fdfe891a7138cb04e51eec4bf228e5f47f84e08338e`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Question Answering with LangChain, Deep Lake, & OpenAI This notebook shows how to implement a question answering system with LangChain, $1 as a vector store and OpenAI embeddings. We will take the following steps to achieve this: 1. Load a Deep Lake text dataset 2. Initialize a $1 3. Add text to the vector store 4. Run queries on the database 5. Done! You ca...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Question Answering with LangChain, Deep Lake, & OpenAI

This notebook shows how to implement a question answering system with LangChain, [Deep Lake](https://activeloop.ai/) as a vector store and OpenAI embeddings. We will take the following steps to achieve this:

1. Load a Deep Lake text dataset
2. Initialize a [Deep Lake vector store with LangChain](https://docs.activeloop.ai/tutorials/vector-store/deep-lake-vector-store-in-langchain)
3. Add text to the vector store
4. Run queries on the database
5. Done!

You can also follow other tutorials such as question answering over any type of data (PDFs, json, csv, text): [chatting with any data](https://www.activeloop.ai/resources/data-chad-an-ai-app-with-lang-chain-deep-lake-to-chat-with-any-data/) stored in Deep Lake, [code understanding](https://www.activeloop.ai/resources/lang-chain-gpt-4-for-code-understanding-twitter-algorithm/), or [question answering over PDFs](https://www.activeloop.ai/resources/ultimate-guide-to-lang-chain-deep-lake-build-chat-gpt-to-answer-questions-on-your-financial-data/), or [recommending songs](https://www.activeloop.ai/resources/3-ways-to-build-a-recommendation-engine-for-songs-with-lang-chain/).

## Install requirements
Let's install the following packages.

```python
!pip install deeplake langchain openai tiktoken
```

## Authentication
Provide your OpenAI API key here:

```python
import getpass
import os

os.environ['OPENAI_API_KEY'] = getpass.getpass()
```

## Load a Deep Lake text dataset
We will use a 20000 sample subset of the [cohere-wikipedia-22](https://app.activeloop.ai/davitbun/cohere-wikipedia-22) dataset for this example.

```python
import deeplake

ds = deeplake.load("hub://activeloop/cohere-wikipedia-22-sample")
ds.summary()
```

Let's take a look at a few samples:

```python
ds[:3].text.data()["value"]
```

## LangChain's Deep Lake vector store
Let's define a `dataset_path`, this is where your Deep Lake vector store will house the text embeddings.

```python
dataset_path = 'wikipedia-embeddings-deeplake'
```

We will setup OpenAI's `text-embedding-3-small` as our embedding function and initialize a Deep Lake vector store at `dataset_path`...

```python
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import DeepLake

embedding = OpenAIEmbeddings(model="text-embedding-3-small")
db = DeepLake(dataset_path, embedding=embedding, overwrite=True)
```

... and populate it with samples, one batch at a time, using the `add_texts` method.

```python
from tqdm.auto import tqdm

batch_size = 100

nsamples = 10  # for testing. Replace with len(ds) to append everything
for i in tqdm(range(0, nsamples, batch_size)):
    # find end of batch
    i_end = min(nsamples, i + batch_size)

    batch = ds[i:i_end]
    id_batch = batch.ids.data()["value"]
    text_batch = batch.text.data()["value"]
    meta_batch = batch.metadata.data()["value"]

    db.add_texts(text_batch, metadatas=meta_batch, ids=id_batch)
```

## Run user queries on the database
The underlying Deep Lake dataset object is accessible through `db.vectorstore.dataset`, and the data structure can be summarized using `db.vectorstore.summary()`, which shows 4 tensors with 10 samples:

```python
db.vectorstore.summary()
```

We will now setup QA on our vector store with GPT-3.5-Turbo as our LLM.

```python
from langchain.chains import RetrievalQA
from langchain.chat_models import ChatOpenAI

# Re-load the vector store in case it's no longer initialized
# db = DeepLake(dataset_path = dataset_path, embedding_function=embedding)

qa = RetrievalQA.from_chain_type(llm=ChatOpenAI(model='gpt-3.5-turbo'), chain_type="stuff", retriever=db.as_retriever())
```

Let's try running a prompt and check the output. Internally, this API performs an embedding search to find the most relevant data to feed into the LLM context.

```python
query = 'Why does the military not say 24:00?'
qa.run(query)
```

Et voila!
