---
title: "Semantic Search Using Mongodb Atlas Vector Search"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/mongodb_atlas/semantic_search_using_mongodb_atlas_vector_search
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/mongodb_atlas/semantic_search_using_mongodb_atlas_vector_search.ipynb
---

# Semantic Search Using Mongodb Atlas Vector Search

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/mongodb_atlas/semantic_search_using_mongodb_atlas_vector_search
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/mongodb_atlas/semantic_search_using_mongodb_atlas_vector_search.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/mongodb_atlas/semantic_search_using_mongodb_atlas_vector_search.ipynb
- Source path: `examples/vector_databases/mongodb_atlas/semantic_search_using_mongodb_atlas_vector_search.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `433e99241f187a9397b232d5fc1f5b70c31fe50d8873992631e5c58002de2352`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

This notebook demonstrates how to build a semantic search application using OpenAI and $1 Step 1: Setup the environment There are 2 pre-requisites for this: 1. MongoDB Atlas cluster : To create a forever free MongoDB Atlas cluster, first, you need to create a MongoDB Atlas account if you don't already have one. Visit the $1 and click on “Register.” Visit the...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

This notebook demonstrates how to  build a semantic search application  using OpenAI and [MongoDB Atlas vector search](https://www.mongodb.com/products/platform/atlas-vector-search)

```python
!pip install pymongo openai
```

# Step 1: Setup the environment

There are 2 pre-requisites for this:

1.   **MongoDB Atlas cluster**: To create a forever free MongoDB Atlas cluster, first, you need to create a MongoDB Atlas account if you don't already have one. Visit the [MongoDB Atlas website](https://www.mongodb.com/atlas/database) and click on “Register.” Visit the [MongoDB Atlas](https://account.mongodb.com/account/login) dashboard and set up your cluster. In order to take advantage of the `$vectorSearch` operator in an aggregation pipeline, you need to run MongoDB Atlas 6.0.11 or higher. This tutorial can be built using a free cluster. When you’re setting up your deployment, you’ll be prompted to set up a database user and rules for your network connection. Please ensure you save your username and password somewhere safe and have the correct IP address rules in place so your cluster can connect properly. If you need more help getting started, check out our [tutorial on MongoDB Atlas](https://www.mongodb.com/basics/mongodb-atlas-tutorial).

2. **OpenAI API key**   To create your OpenAI key, you'll need to create an account. Once you have that, visit the [OpenAI platform](https://platform.openai.com/). Click on your profile icon in the top right of the screen to get the dropdown menu and select “View API keys”.

```python
import getpass

MONGODB_ATLAS_CLUSTER_URI = getpass.getpass("MongoDB Atlas Cluster URI:")
OPENAI_API_KEY = getpass.getpass("OpenAI API Key:")
```

Note: After executing the step above you will be prompted to enter the credentials.

For this tutorial, we will be using the
[MongoDB sample dataset](https://www.mongodb.com/docs/atlas/sample-data/). Load the sample dataset using the Atlas UI. We'll be using the “sample_mflix” database, which contains a “movies” collection where each document contains fields like title, plot, genres, cast, directors, etc.

```python
import openai
import pymongo

client = pymongo.MongoClient(MONGODB_ATLAS_CLUSTER_URI)
db = client.sample_mflix
collection = db.movies

openai.api_key = OPENAI_API_KEY
```

```python
ATLAS_VECTOR_SEARCH_INDEX_NAME = "default"
EMBEDDING_FIELD_NAME = "embedding_openai_nov19_23"
```

# Step 2: Setup embeddings generation function

```python
model = "text-embedding-3-small"
def generate_embedding(text: str) -> list[float]:
    return openai.embeddings.create(input = [text], model=model).data[0].embedding
```

# Step 3: Create and store embeddings

Each document in the sample dataset sample_mflix.movies corresponds to a movie; we will execute an operation to create a vector embedding for the data in the "plot" field and store it in the database. Creating vector embeddings using OpenAI embeddings endpoint is necessary for performing a similarity search based on intent.

```python
from pymongo import ReplaceOne

# Update the collection with the embeddings
requests = []

for doc in collection.find({'plot':{"$exists": True}}).limit(500):
  doc[EMBEDDING_FIELD_NAME] = generate_embedding(doc['plot'])
  requests.append(ReplaceOne({'_id': doc['_id']}, doc))

collection.bulk_write(requests)
```

After executing the above, the documents in "movies" collection will contain an additional field of "embedding", as defined by the `EMBEDDDING_FIELD_NAME` variable, apart from already existing fields like title, plot, genres, cast, directors, etc.

Note: We are restricting this to just 500 documents in the interest of time. If you want to do this over the entire dataset of 23,000+ documents in our sample_mflix database, it will take a little while. Alternatively, you can use the [sample_mflix.embedded_movies collection](https://www.mongodb.com/docs/atlas/sample-data/sample-mflix/#sample_mflix.embedded_movies) which includes a pre-populated `plot_embedding` field that contains embeddings created using OpenAI's `text-embedding-3-small` embedding model that you can use with the Atlas Search vector search feature.

# Step 4: Create a vector search index

We will create Atlas Vector Search Index on this collection which will allow us to perform the Approximate KNN search, which powers the semantic search.
We will cover 2 ways to create this index - Atlas UI and using MongoDB python driver.

(Optional) [Documentation: Create a Vector Search Index ](https://www.mongodb.com/docs/atlas/atlas-search/field-types/knn-vector/)

Now head over to [Atlas UI](cloud.mongodb.com) and create an Atlas Vector Search index using the steps descibed [here](https://www.mongodb.com/docs/atlas/atlas-vector-search/vector-search-tutorial/#create-the-atlas-vector-search-index).  The 'dimensions' field with value 1536, corresponds to openAI text-embedding-ada002.

Use the definition given below in the JSON editor on the Atlas UI.

```
{
  "mappings": {
    "dynamic": true,
    "fields": {
      "embedding": {
        "dimensions": 1536,
        "similarity": "dotProduct",
        "type": "knnVector"
      }
    }
  }
}
```

(Optional) Alternatively, we can use [pymongo driver to create these vector search indexes programatically](https://pymongo.readthedocs.io/en/stable/api/pymongo/collection.html#pymongo.collection.Collection.create_search_index)
The python command given in the cell below will create the index (this only works for the most recent version of the Python Driver for MongoDB and MongoDB server version 7.0+ Atlas cluster).

```python
collection.create_search_index(
    {"definition":
        {"mappings": {"dynamic": True, "fields": {
            EMBEDDING_FIELD_NAME : {
                "dimensions": 1536,
                "similarity": "dotProduct",
                "type": "knnVector"
                }}}},
     "name": ATLAS_VECTOR_SEARCH_INDEX_NAME
    }
)
```

# Step 5: Query your data

The results for the query here finds movies which have semantically similar plots to the text captured in the query string, rather than being based on the keyword search.

(Optional) [Documentation: Run Vector Search Queries](https://www.mongodb.com/docs/atlas/atlas-vector-search/vector-search-stage/)

```python

def query_results(query, k):
  results = collection.aggregate([
    {
        '$vectorSearch': {
            "index": ATLAS_VECTOR_SEARCH_INDEX_NAME,
            "path": EMBEDDING_FIELD_NAME,
            "queryVector": generate_embedding(query),
            "numCandidates": 50,
            "limit": 5,
        }
    }
    ])
  return results
```

```python
query="imaginary characters from outerspace at war with earthlings"
movies = query_results(query, 5)

for movie in movies:
    print(f'Movie Name: {movie["title"]},\nMovie Plot: {movie["plot"]}\n')
```
