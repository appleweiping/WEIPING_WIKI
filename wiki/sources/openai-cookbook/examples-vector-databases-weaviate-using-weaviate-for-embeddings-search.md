---
title: "Using Weaviate For Embeddings Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/weaviate/using_weaviate_for_embeddings_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/weaviate/Using_Weaviate_for_embeddings_search.ipynb
---

# Using Weaviate For Embeddings Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/weaviate/using_weaviate_for_embeddings_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/weaviate/Using_Weaviate_for_embeddings_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/weaviate/Using_Weaviate_for_embeddings_search.ipynb
- Source path: `examples/vector_databases/weaviate/Using_Weaviate_for_embeddings_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `8fdce3581d63b662fd24c2120e34f71da88a4d83664bf1799194cbfe0bf7bb2a`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Weaviate for Embeddings Search This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatb...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Weaviate for Embeddings Search

This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbots, topic modelling and more.

### What is a Vector Database

A vector database is a database made to store, manage and search embedding vectors. The use of embeddings to encode unstructured data (text, audio, video and more) as vectors for consumption by machine-learning models has exploded in recent years, due to the increasing effectiveness of AI in solving use cases involving natural language, image recognition and other unstructured forms of data. Vector databases have emerged as an effective solution for enterprises to deliver and scale these use cases.

### Why use a Vector Database

Vector databases enable enterprises to take many of the embeddings use cases we've shared in this repo (question and answering, chatbot and recommendation services, for example), and make use of them in a secure, scalable environment. Many of our customers make embeddings solve their problems at small scale but performance and security hold them back from going into production - we see vector databases as a key component in solving that, and in this guide we'll walk through the basics of embedding text data, storing it in a vector database and using it for semantic search.


### Demo Flow
The demo flow is:
- **Setup**: Import packages and set any required variables
- **Load data**: Load a dataset and embed it using OpenAI embeddings
- **Weaviate**
    - *Setup*: Here we'll set up the Python client for Weaviate. For more details go [here](https://weaviate.io/developers/weaviate/current/client-libraries/python.html)
    - *Index Data*: We'll create an index with __title__ search vectors in it
    - *Search Data*: We'll run a few searches to confirm it works

Once you've run through this notebook you should have a basic understanding of how to setup and use vector databases, and can move on to more complex use cases making use of our embeddings.

## Setup

Import the required libraries and set the embedding model that we'd like to use.

```python
# We'll need to install the Weaviate client
!pip install weaviate-client

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

# Weaviate's client library for Python
import weaviate

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

## Weaviate

Another vector database option we'll explore is **Weaviate**, which offers both a managed, [SaaS](https://console.weaviate.io/) option, as well as a self-hosted [open source](https://github.com/weaviate/weaviate) option. As we've already looked at a cloud vector database, we'll try the self-hosted option here.

For this we will:
- Set up a local deployment of Weaviate
- Create indices in Weaviate
- Store our data there
- Fire some similarity search queries
- Try a real use case


### Bring your own vectors approach
In this cookbook, we provide the data with already generated vectors. This is a good approach for scenarios, where your data is already vectorized.

### Automated vectorization with OpenAI module
For scenarios, where your data is not vectorized yet, you can delegate the vectorization task with OpenAI to Weaviate.
Weaviate offers a built-in module [text2vec-openai](https://weaviate.io/developers/weaviate/modules/retriever-vectorizer-modules/text2vec-openai), which takes care of the vectorization for you at:
* import
* for any CRUD operations
* for semantic search

Check out the [Getting Started with Weaviate and OpenAI module cookbook](./weaviate/getting-started-with-weaviate-and-openai.ipynb) to learn step by step how to import and vectorize data in one step.

### Setup

To run Weaviate locally, you'll need [Docker](https://www.docker.com/). Following the instructions contained in the Weaviate documentation [here](https://weaviate.io/developers/weaviate/installation/docker-compose), we created an example docker-compose.yml file in this repo saved at [./weaviate/docker-compose.yml](./weaviate/docker-compose.yml).

After starting Docker, you can start Weaviate locally by navigating to the `examples/vector_databases/weaviate/` directory and running `docker-compose up -d`.

#### SaaS
Alternatively you can use [Weaviate Cloud Service](https://console.weaviate.io/) (WCS) to create a free Weaviate cluster.
1. create a free account and/or login to [WCS](https://console.weaviate.io/)
2. create a `Weaviate Cluster` with the following settings:
    * Sandbox: `Sandbox Free`
    * Weaviate Version: Use default (latest)
    * OIDC Authentication: `Disabled`
3. your instance should be ready in a minute or two
4. make a note of the `Cluster Id`. The link will take you to the full path of your cluster (you will need it later to connect to it). It should be something like: `https://your-project-name-suffix.weaviate.network`

```python
# Option #1 - Self-hosted - Weaviate Open Source
client = weaviate.Client(
    url="http://localhost:8080",
    additional_headers={
        "X-OpenAI-Api-Key": os.getenv("OPENAI_API_KEY")
    }
)
```

```python
# Option #2 - SaaS - (Weaviate Cloud Service)
client = weaviate.Client(
    url="https://your-wcs-instance-name.weaviate.network",
    additional_headers={
        "X-OpenAI-Api-Key": os.getenv("OPENAI_API_KEY")
    }
)
```

```python
client.is_ready()
```

### Index data

In Weaviate you create __schemas__ to capture each of the entities you will be searching.

In this case we'll create a schema called **Article** with the **title** vector from above included for us to search by.

The next few steps closely follow the documentation Weaviate provides [here](https://weaviate.io/developers/weaviate/quickstart).

```python
# Clear up the schema, so that we can recreate it
client.schema.delete_all()
client.schema.get()

# Define the Schema object to use `text-embedding-3-small` on `title` and `content`, but skip it for `url`
article_schema = {
    "class": "Article",
    "description": "A collection of articles",
    "vectorizer": "text2vec-openai",
    "moduleConfig": {
        "text2vec-openai": {
          "model": "ada",
          "modelVersion": "002",
          "type": "text"
        }
    },
    "properties": [{
        "name": "title",
        "description": "Title of the article",
        "dataType": ["string"]
    },
    {
        "name": "content",
        "description": "Contents of the article",
        "dataType": ["text"],
        "moduleConfig": { "text2vec-openai": { "skip": True } }
    }]
}

# add the Article schema
client.schema.create_class(article_schema)

# get the schema to make sure it worked
client.schema.get()
```

```python
### Step 1 - configure Weaviate Batch, which optimizes CRUD operations in bulk
# - starting batch size of 100
# - dynamically increase/decrease based on performance
# - add timeout retries if something goes wrong

client.batch.configure(
    batch_size=100,
    dynamic=True,
    timeout_retries=3,
)
```

```python
### Step 2 - import data

print("Uploading data with vectors to Article schema..")

counter=0

with client.batch as batch:
    for k,v in article_df.iterrows():

        # print update message every 100 objects
        if (counter %100 == 0):
            print(f"Import {counter} / {len(article_df)} ")

        properties = {
            "title": v["title"],
            "content": v["text"]
        }

        vector = v["title_vector"]

        batch.add_data_object(properties, "Article", None, vector)
        counter = counter+1

print(f"Importing ({len(article_df)}) Articles complete")
```

```python
# Test that all data has loaded – get object count
result = (
    client.query.aggregate("Article")
    .with_fields("meta { count }")
    .do()
)
print("Object count: ", result["data"]["Aggregate"]["Article"])
```

```python
# Test one article has worked by checking one object
test_article = (
    client.query
    .get("Article", ["title", "content", "_additional {id}"])
    .with_limit(1)
    .do()
)["data"]["Get"]["Article"][0]

print(test_article["_additional"]["id"])
print(test_article["title"])
print(test_article["content"])
```

### Search data

As above, we'll fire some queries at our new Index and get back results based on the closeness to our existing vectors

```python
def query_weaviate(query, collection_name, top_k=20):

    # Creates embedding vector from user query
    embedded_query = openai.Embedding.create(
        input=query,
        model=EMBEDDING_MODEL,
    )["data"][0]['embedding']

    near_vector = {"vector": embedded_query}

    # Queries input schema with vectorised user query
    query_result = (
        client.query
        .get(collection_name, ["title", "content", "_additional {certainty distance}"])
        .with_near_vector(near_vector)
        .with_limit(top_k)
        .do()
    )

    return query_result
```

```python
query_result = query_weaviate("modern art in Europe", "Article")
counter = 0
for article in query_result["data"]["Get"]["Article"]:
    counter += 1
    print(f"{counter}. { article['title']} (Certainty: {round(article['_additional']['certainty'],3) }) (Distance: {round(article['_additional']['distance'],3) })")
```

```python
query_result = query_weaviate("Famous battles in Scottish history", "Article")
counter = 0
for article in query_result["data"]["Get"]["Article"]:
    counter += 1
    print(f"{counter}. {article['title']} (Score: {round(article['_additional']['certainty'],3) })")
```

### Let Weaviate handle vector embeddings

Weaviate has a [built-in module for OpenAI](https://weaviate.io/developers/weaviate/modules/retriever-vectorizer-modules/text2vec-openai), which takes care of the steps required to generate a vector embedding for your queries and any CRUD operations.

This allows you to run a vector query with the `with_near_text` filter, which uses your `OPEN_API_KEY`.

```python
def near_text_weaviate(query, collection_name):

    nearText = {
        "concepts": [query],
        "distance": 0.7,
    }

    properties = [
        "title", "content",
        "_additional {certainty distance}"
    ]

    query_result = (
        client.query
        .get(collection_name, properties)
        .with_near_text(nearText)
        .with_limit(20)
        .do()
    )["data"]["Get"][collection_name]

    print (f"Objects returned: {len(query_result)}")

    return query_result
```

```python
query_result = near_text_weaviate("modern art in Europe","Article")
counter = 0
for article in query_result:
    counter += 1
    print(f"{counter}. { article['title']} (Certainty: {round(article['_additional']['certainty'],3) }) (Distance: {round(article['_additional']['distance'],3) })")
```

```python
query_result = near_text_weaviate("Famous battles in Scottish history","Article")
counter = 0
for article in query_result:
    counter += 1
    print(f"{counter}. { article['title']} (Certainty: {round(article['_additional']['certainty'],3) }) (Distance: {round(article['_additional']['distance'],3) })")
```
