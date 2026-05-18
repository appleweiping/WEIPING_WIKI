---
title: "Getting Started With Tair And Openai"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/tair/getting_started_with_tair_and_openai
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/tair/Getting_started_with_Tair_and_OpenAI.ipynb
---

# Getting Started With Tair And Openai

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/tair/getting_started_with_tair_and_openai
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/tair/Getting_started_with_Tair_and_OpenAI.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/tair/Getting_started_with_Tair_and_OpenAI.ipynb
- Source path: `examples/vector_databases/tair/Getting_started_with_Tair_and_OpenAI.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `7704bce52e9f9b16ab2d26468e7461deb7f867f1e65429498bcf749e095c2907`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Tair as a vector database for OpenAI embeddings This notebook guides you step by step on using Tair as a vector database for OpenAI embeddings. This notebook presents an end-to-end process of: 1. Using precomputed embeddings created by OpenAI API. 2. Storing the embeddings in a cloud instance of Tair. 3. Converting raw text query to an embedding with O...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Tair as a vector database for OpenAI embeddings

This notebook guides you step by step on using Tair as a vector database for OpenAI embeddings.

This notebook presents an end-to-end process of:
1. Using precomputed embeddings created by OpenAI API.
2. Storing the embeddings in a cloud instance of Tair.
3. Converting raw text query to an embedding with OpenAI API.
4. Using Tair to perform the nearest neighbour search in the created collection.

### What is Tair

[Tair](https://www.alibabacloud.com/help/en/tair/latest/what-is-tair) is a cloud native in-memory database service that is developed by Alibaba Cloud. Tair is compatible with open source Redis and provides a variety of data models and enterprise-class capabilities to support your real-time online scenarios. Tair also introduces persistent memory-optimized instances that are based on the new non-volatile memory (NVM) storage medium. These instances can reduce costs by 30%, ensure data persistence, and provide almost the same performance as in-memory databases. Tair has been widely used in areas such as government affairs, finance, manufacturing, healthcare, and pan-Internet to meet their high-speed query and computing requirements.

[Tairvector](https://www.alibabacloud.com/help/en/tair/latest/tairvector) is an in-house data structure that provides high-performance real-time storage and retrieval of vectors. TairVector provides two indexing algorithms: Hierarchical Navigable Small World (HNSW) and Flat Search. Additionally, TairVector supports multiple distance functions, such as Euclidean distance, inner product, and Jaccard distance. Compared with traditional vector retrieval services, TairVector has the following advantages:
- Stores all data in memory and supports real-time index updates to reduce latency of read and write operations.
- Uses an optimized data structure in memory to better utilize storage capacity.
- Functions as an out-of-the-box data structure in a simple and efficient architecture without complex modules or dependencies.

### Deployment options

- Using [Tair Cloud Vector Database](https://www.alibabacloud.com/help/en/tair/latest/getting-started-overview). [Click here](https://www.alibabacloud.com/product/tair) to fast deploy it.

## Prerequisites

For the purposes of this exercise we need to prepare a couple of things:

1. Tair cloud server instance.
2. The 'tair' library to interact with the tair database.
3. An [OpenAI API key](https://beta.openai.com/account/api-keys).

### Install requirements

This notebook obviously requires the `openai` and `tair` packages, but there are also some other additional libraries we will use. The following command installs them all:

```python
! pip install openai redis tair pandas wget
```

### Prepare your OpenAI API key

The OpenAI API key is used for vectorization of the documents and queries.

If you don't have an OpenAI API key, you can get one from [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys).

Once you get your key, please add it by getpass.

```python
import getpass
import openai

openai.api_key = getpass.getpass("Input your OpenAI API key:")
```

## Connect to Tair
First add it to your environment variables.

Connecting to a running instance of Tair server is easy with the official Python library.

```python
# The format of url: redis://&#91;&#91;username]:[password&#93;&#93;@localhost:6379/0
TAIR_URL = getpass.getpass("Input your tair url:")
```

```python
from tair import Tair as TairClient

# connect to tair from url and create a client

url = TAIR_URL
client = TairClient.from_url(url)
```

We can test the connection by ping:

```python
client.ping()
```

```python
import wget

embeddings_url = "https://cdn.openai.com/API/examples/data/vector_database_wikipedia_articles_embedded.zip"

# The file is ~700 MB so this will take some time
wget.download(embeddings_url)
```

The downloaded file has to then be extracted:

```python
import zipfile
import os
import re
import tempfile

current_directory = os.getcwd()
zip_file_path = os.path.join(current_directory, "vector_database_wikipedia_articles_embedded.zip")
output_directory = os.path.join(current_directory, "../../data")

with zipfile.ZipFile(zip_file_path, "r") as zip_ref:
    zip_ref.extractall(output_directory)


# check the csv file exist
file_name = "vector_database_wikipedia_articles_embedded.csv"
data_directory = os.path.join(current_directory, "../../data")
file_path = os.path.join(data_directory, file_name)


if os.path.exists(file_path):
    print(f"The file {file_name} exists in the data directory.")
else:
    print(f"The file {file_name} does not exist in the data directory.")
```

## Create Index

Tair stores data in indexes where each object is described by one key. Each key contains a vector and multiple attribute_keys.

We will start with creating two indexes, one for **title_vector** and one for **content_vector**, and then we will fill it with our precomputed embeddings.

```python
# set index parameters
index = "openai_test"
embedding_dim = 1536
distance_type = "L2"
index_type = "HNSW"
data_type = "FLOAT32"

# Create two indexes, one for title_vector and one for content_vector, skip if already exists
index_names = [index + "_title_vector", index+"_content_vector"]
for index_name in index_names:
    index_connection = client.tvs_get_index(index_name)
    if index_connection is not None:
        print("Index already exists")
    else:
        client.tvs_create_index(name=index_name, dim=embedding_dim, distance_type=distance_type,
                                index_type=index_type, data_type=data_type)
```

## Load data

In this section we are going to load the data prepared previous to this session, so you don't have to recompute the embeddings of Wikipedia articles with your own credits.

```python
import pandas as pd
from ast import literal_eval
# Path to your local CSV file
csv_file_path = '../../data/vector_database_wikipedia_articles_embedded.csv'
article_df = pd.read_csv(csv_file_path)

# Read vectors from strings back into a list
article_df['title_vector'] = article_df.title_vector.apply(literal_eval).values
article_df['content_vector'] = article_df.content_vector.apply(literal_eval).values

# add/update data to indexes
for i in range(len(article_df)):
    # add data to index with title_vector
    client.tvs_hset(index=index_names[0], key=article_df.id[i].item(), vector=article_df.title_vector[i], is_binary=False,
                    **{"url": article_df.url[i], "title": article_df.title[i], "text": article_df.text[i]})
    # add data to index with content_vector
    client.tvs_hset(index=index_names[1], key=article_df.id[i].item(), vector=article_df.content_vector[i], is_binary=False,
                    **{"url": article_df.url[i], "title": article_df.title[i], "text": article_df.text[i]})
```

```python
# Check the data count to make sure all the points have been stored
for index_name in index_names:
    stats = client.tvs_get_index(index_name)
    count = int(stats["current_record_count"]) - int(stats["delete_record_count"])
    print(f"Count in {index_name}:{count}")
```

## Search data

Once the data is put into Tair we will start querying the collection for the closest vectors. We may provide an additional parameter `vector_name` to switch from title to content based search. Since the precomputed embeddings were created with `text-embedding-3-small` OpenAI model, we also have to use it during search.

```python
def query_tair(client, query, vector_name="title_vector", top_k=5):

    # Creates embedding vector from user query
    embedded_query = openai.Embedding.create(
        input= query,
        model="text-embedding-3-small",
    )["data"][0]['embedding']
    embedded_query = np.array(embedded_query)

    # search for the top k approximate nearest neighbors of vector in an index
    query_result = client.tvs_knnsearch(index=index+"_"+vector_name, k=top_k, vector=embedded_query)

    return query_result
```

```python
import openai
import numpy as np

query_result = query_tair(client=client, query="modern art in Europe", vector_name="title_vector")
for i in range(len(query_result)):
    title = client.tvs_hmget(index+"_"+"content_vector", query_result[i][0].decode('utf-8'), "title")
    print(f"{i + 1}. {title[0].decode('utf-8')} (Distance: {round(query_result[i][1],3)})")
```

```python
# This time we'll query using content vector
query_result = query_tair(client=client, query="Famous battles in Scottish history", vector_name="content_vector")
for i in range(len(query_result)):
    title = client.tvs_hmget(index+"_"+"content_vector", query_result[i][0].decode('utf-8'), "title")
    print(f"{i + 1}. {title[0].decode('utf-8')} (Distance: {round(query_result[i][1],3)})")
```
