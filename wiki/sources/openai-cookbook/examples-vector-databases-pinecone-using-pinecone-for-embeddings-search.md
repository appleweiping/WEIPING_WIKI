---
title: "Using Pinecone For Embeddings Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/pinecone/using_pinecone_for_embeddings_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/pinecone/Using_Pinecone_for_embeddings_search.ipynb
---

# Using Pinecone For Embeddings Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/pinecone/using_pinecone_for_embeddings_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/pinecone/Using_Pinecone_for_embeddings_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/pinecone/Using_Pinecone_for_embeddings_search.ipynb
- Source path: `examples/vector_databases/pinecone/Using_Pinecone_for_embeddings_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `4c34ecadf7866246d514903e0232e204215ff1e3ad37a1219c7bf30093097e44`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Pinecone for Embeddings Search This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatb...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Pinecone for Embeddings Search

This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbots, topic modelling and more.

### What is a Vector Database

A vector database is a database made to store, manage and search embedding vectors. The use of embeddings to encode unstructured data (text, audio, video and more) as vectors for consumption by machine-learning models has exploded in recent years, due to the increasing effectiveness of AI in solving use cases involving natural language, image recognition and other unstructured forms of data. Vector databases have emerged as an effective solution for enterprises to deliver and scale these use cases.

### Why use a Vector Database

Vector databases enable enterprises to take many of the embeddings use cases we've shared in this repo (question and answering, chatbot and recommendation services, for example), and make use of them in a secure, scalable environment. Many of our customers make embeddings solve their problems at small scale but performance and security hold them back from going into production - we see vector databases as a key component in solving that, and in this guide we'll walk through the basics of embedding text data, storing it in a vector database and using it for semantic search.


### Demo Flow
The demo flow is:
- **Setup**: Import packages and set any required variables
- **Load data**: Load a dataset and embed it using OpenAI embeddings
- **Pinecone**
    - *Setup*: Here we'll set up the Python client for Pinecone. For more details go [here](https://docs.pinecone.io/docs/quickstart)
    - *Index Data*: We'll create an index with namespaces for __titles__ and __content__
    - *Search Data*: We'll test out both namespaces with search queries to confirm it works

Once you've run through this notebook you should have a basic understanding of how to setup and use vector databases, and can move on to more complex use cases making use of our embeddings.

## Setup

Import the required libraries and set the embedding model that we'd like to use.

```python
# We'll need to install the Pinecone client
!pip install pinecone-client

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

# Pinecone's client library for Python
import pinecone

# I've set this to our new embeddings model, this can be changed to the embedding model of your choice
EMBEDDING_MODEL = "text-embedding-3-small"

# Ignore unclosed SSL socket warnings - optional in case you get these errors
import warnings

warnings.filterwarnings(action="ignore", message="unclosed", category=ResourceWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning)
```

## Load data

In this section we'll load embedded data that we've prepared [in this article](../../Embedding_Wikipedia_articles_for_search.ipynb).

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

## Pinecone

The next option we'll look at is **Pinecone**, a managed vector database which offers a cloud-native option.

Before you proceed with this step you'll need to navigate to [Pinecone](pinecone.io), sign up and then save your API key as an environment variable titled ```PINECONE_API_KEY```.

For section we will:
- Create an index with multiple namespaces for article titles and content
- Store our data in the index with separate searchable "namespaces" for article **titles** and **content**
- Fire some similarity search queries to verify our setup is working

```python
api_key = os.getenv("PINECONE_API_KEY")
pinecone.init(api_key=api_key)
```

### Create Index

First we will need to create an index, which we'll call `wikipedia-articles`. Once we have an index, we can create multiple namespaces, which can make a single index searchable for various use cases. For more details, consult [Pinecone documentation](https://docs.pinecone.io/docs/namespaces#:~:text=Pinecone%20allows%20you%20to%20partition,different%20subsets%20of%20your%20index.).

If you want to batch insert to your index in parallel to increase insertion speed then there is a great guide in the Pinecone documentation on [batch inserts in parallel](https://docs.pinecone.io/docs/insert-data#sending-upserts-in-parallel).

```python
# Models a simple batch generator that make chunks out of an input DataFrame
class BatchGenerator:


    def __init__(self, batch_size: int = 10) -> None:
        self.batch_size = batch_size

    # Makes chunks out of an input DataFrame
    def to_batches(self, df: pd.DataFrame) -> Iterator[pd.DataFrame]:
        splits = self.splits_num(df.shape[0])
        if splits <= 1:
            yield df
        else:
            for chunk in np.array_split(df, splits):
                yield chunk

    # Determines how many chunks DataFrame contains
    def splits_num(self, elements: int) -> int:
        return round(elements / self.batch_size)

    __call__ = to_batches

df_batcher = BatchGenerator(300)
```

```python
# Pick a name for the new index
index_name = 'wikipedia-articles'

# Check whether the index with the same name already exists - if so, delete it
if index_name in pinecone.list_indexes():
    pinecone.delete_index(index_name)

# Creates new index
pinecone.create_index(name=index_name, dimension=len(article_df['content_vector'][0]))
index = pinecone.Index(index_name=index_name)

# Confirm our index was created
pinecone.list_indexes()
```

```python
# Upsert content vectors in content namespace - this can take a few minutes
print("Uploading vectors to content namespace..")
for batch_df in df_batcher(article_df):
    index.upsert(vectors=zip(batch_df.vector_id, batch_df.content_vector), namespace='content')
```

```python
# Upsert title vectors in title namespace - this can also take a few minutes
print("Uploading vectors to title namespace..")
for batch_df in df_batcher(article_df):
    index.upsert(vectors=zip(batch_df.vector_id, batch_df.title_vector), namespace='title')
```

```python
# Check index size for each namespace to confirm all of our docs have loaded
index.describe_index_stats()
```

### Search data

Now we'll enter some dummy searches and check we get decent results back

```python
# First we'll create dictionaries mapping vector IDs to their outputs so we can retrieve the text for our search results
titles_mapped = dict(zip(article_df.vector_id,article_df.title))
content_mapped = dict(zip(article_df.vector_id,article_df.text))
```

```python
def query_article(query, namespace, top_k=5):
    '''Queries an article using its title in the specified
     namespace and prints results.'''

    # Create vector embeddings based on the title column
    embedded_query = openai.Embedding.create(
                                            input=query,
                                            model=EMBEDDING_MODEL,
                                            )["data"][0]['embedding']

    # Query namespace passed as parameter using title vector
    query_result = index.query(embedded_query,
                                      namespace=namespace,
                                      top_k=top_k)

    # Print query results
    print(f'\nMost similar results to {query} in "{namespace}" namespace:\n')
    if not query_result.matches:
        print('no query result')

    matches = query_result.matches
    ids = [res.id for res in matches]
    scores = [res.score for res in matches]
    df = pd.DataFrame({'id':ids,
                       'score':scores,
                       'title': [titles_mapped[_id] for _id in ids],
                       'content': [content_mapped[_id] for _id in ids],
                       })

    counter = 0
    for k,v in df.iterrows():
        counter += 1
        print(f'{v.title} (score = {v.score})')

    print('\n')

    return df
```

```python
query_output = query_article('modern art in Europe','title')
```

```python
content_query_output = query_article("Famous battles in Scottish history",'content')
```
