---
title: "Using Myscale For Embeddings Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/myscale/using_myscale_for_embeddings_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/myscale/Using_MyScale_for_embeddings_search.ipynb
---

# Using Myscale For Embeddings Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/myscale/using_myscale_for_embeddings_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/myscale/Using_MyScale_for_embeddings_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/myscale/Using_MyScale_for_embeddings_search.ipynb
- Source path: `examples/vector_databases/myscale/Using_MyScale_for_embeddings_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `1b320c624bf0c167a7053fbdedd3c559d97cfe75239bff136a4fe4ef9f9f2e1b`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using MyScale for Embeddings Search This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbo...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using MyScale for Embeddings Search

This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbots, topic modelling and more.

### What is a Vector Database

A vector database is a database made to store, manage and search embedding vectors. The use of embeddings to encode unstructured data (text, audio, video and more) as vectors for consumption by machine-learning models has exploded in recent years, due to the increasing effectiveness of AI in solving use cases involving natural language, image recognition and other unstructured forms of data. Vector databases have emerged as an effective solution for enterprises to deliver and scale these use cases.

### Why use a Vector Database

Vector databases enable enterprises to take many of the embeddings use cases we've shared in this repo (question and answering, chatbot and recommendation services, for example), and make use of them in a secure, scalable environment. Many of our customers make embeddings solve their problems at small scale but performance and security hold them back from going into production - we see vector databases as a key component in solving that, and in this guide we'll walk through the basics of embedding text data, storing it in a vector database and using it for semantic search.


### Demo Flow
The demo flow is:
- **Setup**: Import packages and set any required variables
- **Load data**: Load a dataset and embed it using OpenAI embeddings
- **MyScale**
    - *Setup*: Set up the MyScale Python client. For more details go [here](https://docs.myscale.com/en/python-client/)
    - *Index Data*: We'll create a table and index it for __content__.
    - *Search Data*: Run a few example queries with various goals in mind.

Once you've run through this notebook you should have a basic understanding of how to setup and use vector databases, and can move on to more complex use cases making use of our embeddings.

## Setup

Import the required libraries and set the embedding model that we'd like to use.

```python
# We'll need to install the MyScale client
!pip install clickhouse-connect

#Install wget to pull zip file
!pip install wget
```

```python
import openai

from typing import List, Iterator
import pandas as pd
import numpy as np
import os
import wget
from ast import literal_eval

# MyScale's client library for Python
import clickhouse_connect

# I've set this to our new embeddings model, this can be changed to the embedding model of your choice
EMBEDDING_MODEL = "text-embedding-3-small"

# Ignore unclosed SSL socket warnings - optional in case you get these errors
import warnings

warnings.filterwarnings(action="ignore", message="unclosed", category=ResourceWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning)
```

## Load data

In this section we'll load embedded data that we've prepared previous to this session.

```python
embeddings_url = 'https://cdn.openai.com/API/examples/data/vector_database_wikipedia_articles_embedded.zip'

# The file is ~700 MB so this will take some time
wget.download(embeddings_url)
```

```python
import zipfile
with zipfile.ZipFile("vector_database_wikipedia_articles_embedded.zip","r") as zip_ref:
    zip_ref.extractall("../data")
```

```python
article_df = pd.read_csv('../data/vector_database_wikipedia_articles_embedded.csv')
```

```python
article_df.head()
```

```python
# Read vectors from strings back into a list
article_df['title_vector'] = article_df.title_vector.apply(literal_eval)
article_df['content_vector'] = article_df.content_vector.apply(literal_eval)

# Set vector_id to be a string
article_df['vector_id'] = article_df['vector_id'].apply(str)
```

```python
article_df.info(show_counts=True)
```

## MyScale
The next vector database we'll consider is [MyScale](https://myscale.com).

[MyScale](https://myscale.com) is a database built on Clickhouse that combines vector search and SQL analytics to offer a high-performance, streamlined, and fully managed experience. It's designed to facilitate joint queries and analyses on both structured and vector data, with comprehensive SQL support for all data processing.

Deploy and execute vector search with SQL on your cluster within two minutes by using [MyScale Console](https://console.myscale.com).

### Connect to MyScale

Follow the [connections details](https://docs.myscale.com/en/cluster-management/) section to retrieve the cluster host, username, and password information from the MyScale console, and use it to create a connection to your cluster as shown below:

```python
# initialize client
client = clickhouse_connect.get_client(host='YOUR_CLUSTER_HOST', port=8443, username='YOUR_USERNAME', password='YOUR_CLUSTER_PASSWORD')
```

### Index data

We will create an SQL table called `articles` in MyScale to store the embeddings data. The table will include a vector index with a cosine distance metric and a constraint for the length of the embeddings. Use the following code to create and insert data into the articles table:

```python
# create articles table with vector index
embedding_len=len(article_df['content_vector'][0]) # 1536

client.command(f"""
CREATE TABLE IF NOT EXISTS default.articles
(
    id UInt64,
    url String,
    title String,
    text String,
    content_vector Array(Float32),
    CONSTRAINT cons_vector_len CHECK length(content_vector) = {embedding_len},
    VECTOR INDEX article_content_index content_vector TYPE HNSWFLAT('metric_type=Cosine')
)
ENGINE = MergeTree ORDER BY id
""")

# insert data into the table in batches
from tqdm.auto import tqdm

batch_size = 100
total_records = len(article_df)

# we only need subset of columns
article_df = article_df&#91;&#91;'id', 'url', 'title', 'text', 'content_vector'&#93;&#93;

# upload data in batches
data = article_df.to_records(index=False).tolist()
column_names = article_df.columns.tolist()

for i in tqdm(range(0, total_records, batch_size)):
    i_end = min(i + batch_size, total_records)
    client.insert("default.articles", data[i:i_end], column_names=column_names)
```

We need to check the build status of the vector index before proceeding with the search, as it is automatically built in the background.

```python
# check count of inserted data
print(f"articles count: {client.command('SELECT count(*) FROM default.articles')}")

# check the status of the vector index, make sure vector index is ready with 'Built' status
get_index_status="SELECT status FROM system.vector_indices WHERE name='article_content_index'"
print(f"index build status: {client.command(get_index_status)}")
```

### Search data

Once indexed in MyScale, we can perform vector search to find similar content. First, we will use the OpenAI API to generate embeddings for our query. Then, we will perform the vector search using MyScale.

```python
query = "Famous battles in Scottish history"

# creates embedding vector from user query
embed = openai.Embedding.create(
    input=query,
    model="text-embedding-3-small",
)["data"][0]["embedding"]

# query the database to find the top K similar content to the given query
top_k = 10
results = client.query(f"""
SELECT id, url, title, distance(content_vector, {embed}) as dist
FROM default.articles
ORDER BY dist
LIMIT {top_k}
""")

# display results
for i, r in enumerate(results.named_results()):
    print(i+1, r['title'])
```
