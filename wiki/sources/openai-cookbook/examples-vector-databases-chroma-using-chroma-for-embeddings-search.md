---
title: "Using Chroma For Embeddings Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/chroma/using_chroma_for_embeddings_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/chroma/Using_Chroma_for_embeddings_search.ipynb
---

# Using Chroma For Embeddings Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/chroma/using_chroma_for_embeddings_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/chroma/Using_Chroma_for_embeddings_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/chroma/Using_Chroma_for_embeddings_search.ipynb
- Source path: `examples/vector_databases/chroma/Using_Chroma_for_embeddings_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `2be42b8e0d0a3733c8e9aa9399e8c3665b41f342af50f356857d85bb0febe595`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Chroma for Embeddings Search This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbot...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Chroma for Embeddings Search

This notebook takes you through a simple flow to download some data, embed it, and then index and search it using a selection of vector databases. This is a common requirement for customers who want to store and search our embeddings with their own data in a secure environment to support production use cases such as chatbots, topic modelling and more.

### What is a Vector Database

A vector database is a database made to store, manage and search embedding vectors. The use of embeddings to encode unstructured data (text, audio, video and more) as vectors for consumption by machine-learning models has exploded in recent years, due to the increasing effectiveness of AI in solving use cases involving natural language, image recognition and other unstructured forms of data. Vector databases have emerged as an effective solution for enterprises to deliver and scale these use cases.

### Why use a Vector Database

Vector databases enable enterprises to take many of the embeddings use cases we've shared in this repo (question and answering, chatbot and recommendation services, for example), and make use of them in a secure, scalable environment. Many of our customers make embeddings solve their problems at small scale but performance and security hold them back from going into production - we see vector databases as a key component in solving that, and in this guide we'll walk through the basics of embedding text data, storing it in a vector database and using it for semantic search.


### Demo Flow
The demo flow is:
- **Setup**: Import packages and set any required variables
- **Load data**: Load a dataset and embed it using OpenAI embeddings
- **Chroma**:
    - *Setup*: Here we'll set up the Python client for Chroma. For more details go [here](https://docs.trychroma.com/usage-guide)
    - *Index Data*: We'll create collections with vectors for __titles__ and __content__
    - *Search Data*: We'll run a few searches to confirm it works

Once you've run through this notebook you should have a basic understanding of how to setup and use vector databases, and can move on to more complex use cases making use of our embeddings.

## Setup

Import the required libraries and set the embedding model that we'd like to use.

```python
# Make sure the OpenAI library is installed
%pip install openai

# We'll need to install the Chroma client
%pip install chromadb

# Install wget to pull zip file
%pip install wget

# Install numpy for data manipulation
%pip install numpy
```

```python
import openai
import pandas as pd
import os
import wget
from ast import literal_eval

# Chroma's client library for Python
import chromadb

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

# Chroma

We'll index these embedded documents in a vector database and search them. The first option we'll look at is **Chroma**, an easy to use open-source self-hosted in-memory vector database, designed for working with embeddings together with LLMs.

In this section, we will:
- Instantiate the Chroma client
- Create collections for each class of embedding
- Query each collection

### Instantiate the Chroma client

Create the Chroma client. By default, Chroma is ephemeral and runs in memory.
However, you can easily set up a persistent configuration which writes to disk.

```python
chroma_client = chromadb.EphemeralClient() # Equivalent to chromadb.Client(), ephemeral.
# Uncomment for persistent client
# chroma_client = chromadb.PersistentClient()
```

### Create collections

Chroma collections allow you to store and filter with arbitrary metadata, making it easy to query subsets of the embedded data.

Chroma is already integrated with OpenAI's embedding functions. The best way to use them is on construction of a collection, as follows.
Alternatively, you can 'bring your own embeddings'. More information can be found [here](https://docs.trychroma.com/embeddings)

```python
from chromadb.utils.embedding_functions import OpenAIEmbeddingFunction

# Test that your OpenAI API key is correctly set as an environment variable
# Note. if you run this notebook locally, you will need to reload your terminal and the notebook for the env variables to be live.

# Note. alternatively you can set a temporary env variable like this:
# os.environ["OPENAI_API_KEY"] = 'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

if os.getenv("OPENAI_API_KEY") is not None:
    openai.api_key = os.getenv("OPENAI_API_KEY")
    print ("OPENAI_API_KEY is ready")
else:
    print ("OPENAI_API_KEY environment variable not found")


embedding_function = OpenAIEmbeddingFunction(api_key=os.environ.get('OPENAI_API_KEY'), model_name=EMBEDDING_MODEL)

wikipedia_content_collection = chroma_client.create_collection(name='wikipedia_content', embedding_function=embedding_function)
wikipedia_title_collection = chroma_client.create_collection(name='wikipedia_titles', embedding_function=embedding_function)
```

### Populate the collections

Chroma collections allow you to populate, and filter on, whatever metadata you like. Chroma can also store the text alongside the vectors, and return everything in a single `query` call, when this is more convenient.

For this use-case, we'll just store the embeddings and IDs, and use these to index the original dataframe.

```python
# Add the content vectors
wikipedia_content_collection.add(
    ids=article_df.vector_id.tolist(),
    embeddings=article_df.content_vector.tolist(),
)

# Add the title vectors
wikipedia_title_collection.add(
    ids=article_df.vector_id.tolist(),
    embeddings=article_df.title_vector.tolist(),
)
```

### Search the collections

Chroma handles embedding queries for you if an embedding function is set, like in this example.

```python
def query_collection(collection, query, max_results, dataframe):
    results = collection.query(query_texts=query, n_results=max_results, include=['distances'])
    df = pd.DataFrame({
                'id':results['ids'][0],
                'score':results['distances'][0],
                'title': dataframe[dataframe.vector_id.isin(results['ids'][0])]['title'],
                'content': dataframe[dataframe.vector_id.isin(results['ids'][0])]['text'],
                })

    return df
```

```python
title_query_result = query_collection(
    collection=wikipedia_title_collection,
    query="modern art in Europe",
    max_results=10,
    dataframe=article_df
)
title_query_result.head()
```

```python
content_query_result = query_collection(
    collection=wikipedia_content_collection,
    query="Famous battles in Scottish history",
    max_results=10,
    dataframe=article_df
)
content_query_result.head()
```

Now that you've got a basic embeddings search running, you can [hop over to the Chroma docs](https://docs.trychroma.com/usage-guide#using-where-filters) to learn more about how to add filters to your query, update/delete data in your collections, and deploy Chroma.
