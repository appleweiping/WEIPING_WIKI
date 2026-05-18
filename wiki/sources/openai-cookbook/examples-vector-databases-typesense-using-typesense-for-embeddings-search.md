---
title: "Using Typesense For Embeddings Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/typesense/using_typesense_for_embeddings_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/typesense/Using_Typesense_for_embeddings_search.ipynb
---

# Using Typesense For Embeddings Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/typesense/using_typesense_for_embeddings_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/typesense/Using_Typesense_for_embeddings_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/typesense/Using_Typesense_for_embeddings_search.ipynb
- Source path: `examples/vector_databases/typesense/Using_Typesense_for_embeddings_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `b3a5adf7cc6bcd76c1d6f66f179f2e669537dc74a2b688766b337c90d9b65933`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Typesense for Embeddings Search This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chat...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Typesense for Embeddings Search

This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbots, topic modelling and more.

### What is a Vector Database

A vector database is a database made to store, manage and search embedding vectors. The use of embeddings to encode unstructured data (text, audio, video and more) as vectors for consumption by machine-learning models has exploded in recent years, due to the increasing effectiveness of AI in solving use cases involving natural language, image recognition and other unstructured forms of data. Vector databases have emerged as an effective solution for enterprises to deliver and scale these use cases.

### Why use a Vector Database

Vector databases enable enterprises to take many of the embeddings use cases we've shared in this repo (question and answering, chatbot and recommendation services, for example), and make use of them in a secure, scalable environment. Many of our customers make embeddings solve their problems at small scale but performance and security hold them back from going into production - we see vector databases as a key component in solving that, and in this guide we'll walk through the basics of embedding text data, storing it in a vector database and using it for semantic search.


### Demo Flow
The demo flow is:
- **Setup**: Import packages and set any required variables
- **Load data**: Load a dataset and embed it using OpenAI embeddings
- **Typesense**
    - *Setup*: Set up the Typesense Python client. For more details go [here](https://typesense.org/docs/0.24.0/api/)
    - *Index Data*: We'll create a collection and index it for both __titles__ and __content__.
    - *Search Data*: Run a few example queries with various goals in mind.

Once you've run through this notebook you should have a basic understanding of how to setup and use vector databases, and can move on to more complex use cases making use of our embeddings.

## Setup

Import the required libraries and set the embedding model that we'd like to use.

```python
# We'll need to install the Typesense client
!pip install typesense

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

# Typesense's client library for Python
import typesense

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

## Typesense

The next vector store we'll look at is [Typesense](https://typesense.org/), which is an open source, in-memory search engine, that you can either self-host or run on [Typesense Cloud](https://cloud.typesense.org).

Typesense focuses on performance by storing the entire index in RAM (with a backup on disk) and also focuses on providing an out-of-the-box developer experience by simplifying available options and setting good defaults. It also lets you combine attribute-based filtering together with vector queries.

For this example, we will set up a local docker-based Typesense server, index our vectors in Typesense and then do some nearest-neighbor search queries. If you use Typesense Cloud, you can skip the docker setup part and just obtain the hostname and API keys from your cluster dashboard.

### Setup

To run Typesense locally, you'll need [Docker](https://www.docker.com/). Following the instructions contained in the Typesense documentation [here](https://typesense.org/docs/guide/install-typesense.html#docker-compose), we created an example docker-compose.yml file in this repo saved at [./typesense/docker-compose.yml](./typesense/docker-compose.yml).

After starting Docker, you can start Typesense locally by navigating to the `examples/vector_databases/typesense/` directory and running `docker-compose up -d`.

The default API key is set to `xyz` in the Docker compose file, and the default Typesense port to `8108`.

```python
import typesense

typesense_client = \
    typesense.Client({
        "nodes": [{
            "host": "localhost",  # For Typesense Cloud use xxx.a1.typesense.net
            "port": "8108",       # For Typesense Cloud use 443
            "protocol": "http"    # For Typesense Cloud use https
          }],
          "api_key": "xyz",
          "connection_timeout_seconds": 60
        })
```

### Index data

To index vectors in Typesense, we'll first create a Collection (which is a collection of Documents) and turn on vector indexing for a particular field. You can even store multiple vector fields in a single document.

```python
# Delete existing collections if they already exist
try:
    typesense_client.collections['wikipedia_articles'].delete()
except Exception as e:
    pass

# Create a new collection

schema = {
    "name": "wikipedia_articles",
    "fields": [
        {
            "name": "content_vector",
            "type": "float[]",
            "num_dim": len(article_df['content_vector'][0])
        },
        {
            "name": "title_vector",
            "type": "float[]",
            "num_dim": len(article_df['title_vector'][0])
        }
    ]
}

create_response = typesense_client.collections.create(schema)
print(create_response)

print("Created new collection wikipedia-articles")
```

```python
# Upsert the vector data into the collection we just created
#
# Note: This can take a few minutes, especially if your on an M1 and running docker in an emulated mode

print("Indexing vectors in Typesense...")

document_counter = 0
documents_batch = []

for k,v in article_df.iterrows():
    # Create a document with the vector data

    # Notice how you can add any fields that you haven't added to the schema to the document.
    # These will be stored on disk and returned when the document is a hit.
    # This is useful to store attributes required for display purposes.

    document = {
        "title_vector": v["title_vector"],
        "content_vector": v["content_vector"],
        "title": v["title"],
        "content": v["text"],
    }
    documents_batch.append(document)
    document_counter = document_counter + 1

    # Upsert a batch of 100 documents
    if document_counter % 100 == 0 or document_counter == len(article_df):
        response = typesense_client.collections['wikipedia_articles'].documents.import_(documents_batch)
        # print(response)

        documents_batch = []
        print(f"Processed {document_counter} / {len(article_df)} ")

print(f"Imported ({len(article_df)}) articles.")
```

```python
# Check the number of documents imported

collection = typesense_client.collections['wikipedia_articles'].retrieve()
print(f'Collection has {collection["num_documents"]} documents')
```

### Search Data

Now that we've imported the vectors into Typesense, we can do a nearest neighbor search on the `title_vector` or `content_vector` field.

```python
def query_typesense(query, field='title', top_k=20):

    # Creates embedding vector from user query
    openai.api_key = os.getenv("OPENAI_API_KEY", "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    embedded_query = openai.Embedding.create(
        input=query,
        model=EMBEDDING_MODEL,
    )['data'][0]['embedding']

    typesense_results = typesense_client.multi_search.perform({
        "searches": [{
            "q": "*",
            "collection": "wikipedia_articles",
            "vector_query": f"{field}_vector:([{','.join(str(v) for v in embedded_query)}], k:{top_k})"
        }]
    }, {})

    return typesense_results
```

```python
query_results = query_typesense('modern art in Europe', 'title')

for i, hit in enumerate(query_results['results'][0]['hits']):
    document = hit["document"]
    vector_distance = hit["vector_distance"]
    print(f'{i + 1}. {document["title"]} (Distance: {vector_distance})')
```

```python
query_results = query_typesense('Famous battles in Scottish history', 'content')

for i, hit in enumerate(query_results['results'][0]['hits']):
    document = hit["document"]
    vector_distance = hit["vector_distance"]
    print(f'{i + 1}. {document["title"]} (Distance: {vector_distance})')
```

Thanks for following along, you're now equipped to set up your own vector databases and use embeddings to do all kinds of cool things - enjoy! For more complex use cases please continue to work through other cookbook examples in this repo.
