---
title: "Using Qdrant For Embeddings Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/qdrant/using_qdrant_for_embeddings_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/qdrant/Using_Qdrant_for_embeddings_search.ipynb
---

# Using Qdrant For Embeddings Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/qdrant/using_qdrant_for_embeddings_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/qdrant/Using_Qdrant_for_embeddings_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/qdrant/Using_Qdrant_for_embeddings_search.ipynb
- Source path: `examples/vector_databases/qdrant/Using_Qdrant_for_embeddings_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `2b7552a03c8768beda2953afd50d55c4fb6a180cf4485ef1ab8fd02784537b8f`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Qdrant for Embeddings Search This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbot...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Qdrant for Embeddings Search

This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbots, topic modelling and more.

### What is a Vector Database

A vector database is a database made to store, manage and search embedding vectors. The use of embeddings to encode unstructured data (text, audio, video and more) as vectors for consumption by machine-learning models has exploded in recent years, due to the increasing effectiveness of AI in solving use cases involving natural language, image recognition and other unstructured forms of data. Vector databases have emerged as an effective solution for enterprises to deliver and scale these use cases.

### Why use a Vector Database

Vector databases enable enterprises to take many of the embeddings use cases we've shared in this repo (question and answering, chatbot and recommendation services, for example), and make use of them in a secure, scalable environment. Many of our customers make embeddings solve their problems at small scale but performance and security hold them back from going into production - we see vector databases as a key component in solving that, and in this guide we'll walk through the basics of embedding text data, storing it in a vector database and using it for semantic search.


### Demo Flow
The demo flow is:
- **Setup**: Import packages and set any required variables
- **Load data**: Load a dataset and embed it using OpenAI embeddings
- **Qdrant**
    - *Setup*: Here we'll set up the Python client for Qdrant. For more details go [here](https://github.com/qdrant/qdrant_client)
    - *Index Data*: We'll create a collection with vectors for __titles__ and __content__
    - *Search Data*: We'll run a few searches to confirm it works

Once you've run through this notebook you should have a basic understanding of how to setup and use vector databases, and can move on to more complex use cases making use of our embeddings.

## Setup

Import the required libraries and set the embedding model that we'd like to use.

```python
# We'll need to install Qdrant client
!pip install qdrant-client
```

```python
import openai
import pandas as pd
from ast import literal_eval
import qdrant_client # Qdrant's client library for Python

# This can be changed to the embedding model of your choice. Make sure its the same model that is used for generating embeddings
EMBEDDING_MODEL = "text-embedding-ada-002"

# Ignore unclosed SSL socket warnings - optional in case you get these errors
import warnings

warnings.filterwarnings(action="ignore", message="unclosed", category=ResourceWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning)
```

## Load data

In this section we'll load embedded data that we've prepared previous to this session.

```python
import wget

embeddings_url = "https://cdn.openai.com/API/examples/data/vector_database_wikipedia_articles_embedded.zip"

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

## Qdrant

**[Qdrant](https://qdrant.tech/)**. is a high-performant vector search database written in Rust. It offers both on-premise and cloud version, but for the purposes of that example we're going to use the local deployment mode.

Setting everything up will require:
- Spinning up a local instance of Qdrant
- Configuring the collection and storing the data in it
- Trying out with some queries

### Setup

For the local deployment, we are going to use Docker, according to the Qdrant documentation: https://qdrant.tech/documentation/quick_start/. Qdrant requires just a single container, but an example of the docker-compose.yaml file is available at `./qdrant/docker-compose.yaml` in this repo.

You can start Qdrant instance locally by navigating to this directory and running `docker-compose up -d `

> You might need to increase the memory limit for Docker to 8GB or more. Or Qdrant might fail to execute with an error message like `7 Killed`.

```python
! docker compose up -d
```

```python
qdrant = qdrant_client.QdrantClient(host="localhost", port=6333)
```

```python
qdrant.get_collections()
```

### Index data

Qdrant stores data in __collections__ where each object is described by at least one vector and may contain an additional metadata called __payload__. Our collection will be called **Articles** and each object will be described by both **title** and **content** vectors.

We'll be using an official [qdrant-client](https://github.com/qdrant/qdrant_client) package that has all the utility methods already built-in.

```python
from qdrant_client.http import models as rest
```

```python
# Get the vector size from the first row to set up the collection
vector_size = len(article_df['content_vector'][0])

# Set up the collection with the vector configuration. You need to declare the vector size and distance metric for the collection. Distance metric enables vector database to index and search vectors efficiently.
qdrant.recreate_collection(
    collection_name='Articles',
    vectors_config={
        'title': rest.VectorParams(
            distance=rest.Distance.COSINE,
            size=vector_size,
        ),
        'content': rest.VectorParams(
            distance=rest.Distance.COSINE,
            size=vector_size,
        ),
    }
)
```

```python
vector_size = len(article_df['content_vector'][0])

qdrant.recreate_collection(
    collection_name='Articles',
    vectors_config={
        'title': rest.VectorParams(
            distance=rest.Distance.COSINE,
            size=vector_size,
        ),
        'content': rest.VectorParams(
            distance=rest.Distance.COSINE,
            size=vector_size,
        ),
    }
)
```

In addition to the vector configuration defined under `vector`, we can also define the `payload` configuration. Payload is an optional field that allows you to store additional metadata alongside the vectors. In our case, we'll store the `id`, `title`, and `url` of the articles. As we return the title of nearest articles in the search results from payload, we can also provide the user with the URL to the article (which is part of the meta-data).

```python
from qdrant_client.models import PointStruct # Import the PointStruct to store the vector and payload
from tqdm import tqdm # Library to show the progress bar

# Populate collection with vectors using tqdm to show progress
for k, v in tqdm(article_df.iterrows(), desc="Upserting articles", total=len(article_df)):
    try:
        qdrant.upsert(
            collection_name='Articles',
            points=[
                PointStruct(
                    id=k,
                    vector={'title': v['title_vector'],
                            'content': v['content_vector']},
                    payload={
                        'id': v['id'],
                        'title': v['title'],
                        'url': v['url']
                    }
                )
            ]
        )
    except Exception as e:
        print(f"Failed to upsert row {k}: {v}")
        print(f"Exception: {e}")
```

```python
# Check the collection size to make sure all the points have been stored
qdrant.count(collection_name='Articles')
```

### Search Data

Once the data is put into Qdrant we will start querying the collection for the closest vectors. We may provide an additional parameter `vector_name` to switch from title to content based search.  Ensure you use the text-embedding-ada-002 model as the original embeddings in file were created with this model.

```python
def query_qdrant(query, collection_name, vector_name='title', top_k=20):

    # Creates embedding vector from user query
    embedded_query = openai.embeddings.create(
        input=query,
        model=EMBEDDING_MODEL,
    ).data[0].embedding # We take the first embedding from the list

    query_results = qdrant.search(
        collection_name=collection_name,
        query_vector=(
            vector_name, embedded_query
        ),
        limit=top_k,
        query_filter=None
    )

    return query_results
```

```python
query_results = query_qdrant('modern art in Europe', 'Articles', 'title')
for i, article in enumerate(query_results):
    print(f'{i + 1}. {article.payload["title"]}, URL: {article.payload["url"]} (Score: {round(article.score, 3)})')
```

```python
# This time we'll query using content vector
query_results = query_qdrant('Famous battles in Scottish history', 'Articles', 'content')
for i, article in enumerate(query_results):
    print(f'{i + 1}. {article.payload["title"]}, URL: {article.payload["url"]} (Score: {round(article.score, 3)})')
```
