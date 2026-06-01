---
title: "Getting Started With Hologres And Openai"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/hologres/getting_started_with_hologres_and_openai
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/hologres/Getting_started_with_Hologres_and_OpenAI.ipynb
---

# Getting Started With Hologres And Openai

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/hologres/getting_started_with_hologres_and_openai
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/hologres/Getting_started_with_Hologres_and_OpenAI.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/hologres/Getting_started_with_Hologres_and_OpenAI.ipynb
- Source path: `examples/vector_databases/hologres/Getting_started_with_Hologres_and_OpenAI.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `9e213723c17cfdb0426c4b1dd515f400cdf0303704b7d12b163df3700f7646ba`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using Hologres as a vector database for OpenAI embeddings This notebook guides you step by step on using Hologres as a vector database for OpenAI embeddings. This notebook presents an end-to-end process of: 1. Using precomputed embeddings created by OpenAI API. 2. Storing the embeddings in a cloud instance of Hologres. 3. Converting raw text query to an embe...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using Hologres as a vector database for OpenAI embeddings

This notebook guides you step by step on using Hologres as a vector database for OpenAI embeddings.

This notebook presents an end-to-end process of:
1. Using precomputed embeddings created by OpenAI API.
2. Storing the embeddings in a cloud instance of Hologres.
3. Converting raw text query to an embedding with OpenAI API.
4. Using Hologres to perform the nearest neighbour search in the created collection.
5. Provide large language models with the search results as context in prompt engineering

### What is Hologres

[Hologres](https://www.alibabacloud.com/help/en/hologres/latest/what-is-hologres) is a unified real-time data warehousing service developed by Alibaba Cloud. You can use Hologres to write, update, process, and analyze large amounts of data in real time. Hologres supports standard SQL syntax, is compatible with PostgreSQL, and supports most PostgreSQL functions. Hologres supports online analytical processing (OLAP) and ad hoc analysis for up to petabytes of data, and provides high-concurrency and low-latency online data services. Hologres supports fine-grained isolation of multiple workloads and enterprise-level security capabilities. Hologres is deeply integrated with MaxCompute, Realtime Compute for Apache Flink, and DataWorks, and provides full-stack online and offline data warehousing solutions for enterprises.

Hologres provides vector database functionality by adopting [Proxima](https://www.alibabacloud.com/help/en/hologres/latest/vector-processing).

Proxima is a high-performance software library developed by Alibaba DAMO Academy. It allows you to search for the nearest neighbors of vectors. Proxima provides higher stability and performance than similar open source software such as Facebook AI Similarity Search (Faiss). Proxima provides basic modules that have leading performance and effects in the industry and allows you to search for similar images, videos, or human faces. Hologres is deeply integrated with Proxima to provide a high-performance vector search service.

### Deployment options

- [Click here](https://www.alibabacloud.com/product/hologres) to fast deploy [Hologres data warehouse](https://www.alibabacloud.com/help/en/hologres/latest/getting-started).

## Prerequisites

For the purposes of this exercise we need to prepare a couple of things:

1. Hologres cloud server instance.
2. The 'psycopg2-binary' library to interact with the vector database. Any other postgresql client library is ok.
3. An [OpenAI API key](https://beta.openai.com/account/api-keys).

We might validate if the server was launched successfully by running a simple curl command:

### Install requirements

This notebook obviously requires the `openai` and `psycopg2-binary` packages, but there are also some other additional libraries we will use. The following command installs them all:

```python
! pip install openai psycopg2-binary pandas wget
```

### Prepare your OpenAI API key

The OpenAI API key is used for vectorization of the documents and queries.

If you don't have an OpenAI API key, you can get one from [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys).

Once you get your key, please add it to your environment variables as `OPENAI_API_KEY`.

```python
# Test that your OpenAI API key is correctly set as an environment variable
# Note. if you run this notebook locally, you will need to reload your terminal and the notebook for the env variables to be live.
import os

# Note. alternatively you can set a temporary env variable like this:
# os.environ["OPENAI_API_KEY"] = "sk-REDACTED"

if os.getenv("OPENAI_API_KEY") is not None:
    print("OPENAI_API_KEY is ready")
else:
    print("OPENAI_API_KEY environment variable not found")
```

## Connect to Hologres
First add it to your environment variables. or you can just change the "psycopg2.connect" parameters below

Connecting to a running instance of Hologres server is easy with the official Python library:

```python
import os
import psycopg2

# Note. alternatively you can set a temporary env variable like this:
# os.environ["PGHOST"] = "your_host"
# os.environ["PGPORT"] "5432"),
# os.environ["PGDATABASE"] "postgres"),
# os.environ["PGUSER"] "user"),
# os.environ["PGPASSWORD"] "password"),

connection = psycopg2.connect(
    host=os.environ.get("PGHOST", "localhost"),
    port=os.environ.get("PGPORT", "5432"),
    database=os.environ.get("PGDATABASE", "postgres"),
    user=os.environ.get("PGUSER", "user"),
    password=os.environ.get("PGPASSWORD", "password")
)
connection.set_session(autocommit=True)

# Create a new cursor object
cursor = connection.cursor()
```

We can test the connection by running any available method:

```python

# Execute a simple query to test the connection
cursor.execute("SELECT 1;")
result = cursor.fetchone()

# Check the query result
if result == (1,):
    print("Connection successful!")
else:
    print("Connection failed.")
```

```python
import wget

embeddings_url = "https://cdn.openai.com/API/examples/data/vector_database_wikipedia_articles_embedded.zip"

# The file is ~700 MB so this will take some time
wget.download(embeddings_url)
```

The downloaded file has to be then extracted:

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

## Load data

In this section we are going to load the data prepared previous to this session, so you don't have to recompute the embeddings of Wikipedia articles with your own credits.

```python
!unzip -n vector_database_wikipedia_articles_embedded.zip
!ls -lh vector_database_wikipedia_articles_embedded.csv
```

Take a look at the data.

```python
import pandas, json
data = pandas.read_csv('../../data/vector_database_wikipedia_articles_embedded.csv')
data
```

```python
title_vector_length = len(json.loads(data['title_vector'].iloc[0]))
content_vector_length = len(json.loads(data['content_vector'].iloc[0]))

print(title_vector_length, content_vector_length)
```

### Create table and proxima vector index

Hologres stores data in __tables__ where each object is described by at least one vector. Our table will be called **articles** and each object will be described by both **title** and **content** vectors.

We will start with creating a table and create proxima indexes on both **title** and **content**, and then we will fill it with our precomputed embeddings.

```python
cursor.execute('CREATE EXTENSION IF NOT EXISTS proxima;')
create_proxima_table_sql = '''
BEGIN;
DROP TABLE IF EXISTS articles;
CREATE TABLE articles (
    id INT PRIMARY KEY NOT NULL,
    url TEXT,
    title TEXT,
    content TEXT,
    title_vector float4[] check(
        array_ndims(title_vector) = 1 and
        array_length(title_vector, 1) = 1536
    ), -- define the vectors
    content_vector float4[] check(
        array_ndims(content_vector) = 1 and
        array_length(content_vector, 1) = 1536
    ),
    vector_id INT
);

-- Create indexes for the vector fields.
call set_table_property(
    'articles',
    'proxima_vectors',
    '{
        "title_vector":{"algorithm":"Graph","distance_method":"Euclidean","builder_params":{"min_flush_proxima_row_count" : 10}},
        "content_vector":{"algorithm":"Graph","distance_method":"Euclidean","builder_params":{"min_flush_proxima_row_count" : 10}}
    }'
);

COMMIT;
'''

# Execute the SQL statements (will autocommit)
cursor.execute(create_proxima_table_sql)
```

### Upload data

Now let's upload the data to the Hologres cloud instance using [COPY statement](https://www.alibabacloud.com/help/en/hologres/latest/use-the-copy-statement-to-import-or-export-data). This might take 5-10 minutes according to the network bandwidth.

```python
import io

# Path to the unzipped CSV file
csv_file_path = '../../data/vector_database_wikipedia_articles_embedded.csv'

# In SQL, arrays are surrounded by {}, rather than []
def process_file(file_path):
    with open(file_path, 'r') as file:
        for line in file:
            # Replace '[' with '{' and ']' with '}'
            modified_line = line.replace('[', '{').replace(']', '}')
            yield modified_line

# Create a StringIO object to store the modified lines
modified_lines = io.StringIO(''.join(list(process_file(csv_file_path))))

# Create the COPY command for the copy_expert method
copy_command = '''
COPY public.articles (id, url, title, content, title_vector, content_vector, vector_id)
FROM STDIN WITH (FORMAT CSV, HEADER true, DELIMITER ',');
'''

# Execute the COPY command using the copy_expert method
cursor.copy_expert(copy_command, modified_lines)
```

The proxima index will be built in the background. We can do searching during this period but the query will be slow without the vector index. Use this command to wait for finish building the index.

```python
cursor.execute('vacuum articles;')
```

```python
# Check the collection size to make sure all the points have been stored
count_sql = "select count(*) from articles;"
cursor.execute(count_sql)
result = cursor.fetchone()
print(f"Count:{result[0]}")
```

## Search data

Once the data is uploaded we will start querying the collection for the closest vectors. We may provide an additional parameter `vector_name` to switch from title to content based search. Since the precomputed embeddings were created with `text-embedding-3-small` OpenAI model we also have to use it during search.

```python
import openai
def query_knn(query, table_name, vector_name="title_vector", top_k=20):

    # Creates embedding vector from user query
    embedded_query = openai.Embedding.create(
        input=query,
        model="text-embedding-3-small",
    )["data"][0]["embedding"]

    # Convert the embedded_query to PostgreSQL compatible format
    embedded_query_pg = "{" + ",".join(map(str, embedded_query)) + "}"

    # Create SQL query
    query_sql = f"""
    SELECT id, url, title, pm_approx_euclidean_distance({vector_name},'{embedded_query_pg}'::float4[]) AS distance
    FROM {table_name}
    ORDER BY distance
    LIMIT {top_k};
    """
    # Execute the query
    cursor.execute(query_sql)
    results = cursor.fetchall()

    return results
```

```python
query_results = query_knn("modern art in Europe", "Articles")
for i, result in enumerate(query_results):
    print(f"{i + 1}. {result[2]} (Score: {round(1 - result[3], 3)})")
```

```python
# This time we'll query using content vector
query_results = query_knn("Famous battles in Scottish history", "Articles", "content_vector")
for i, result in enumerate(query_results):
    print(f"{i + 1}. {result[2]} (Score: {round(1 - result[3], 3)})")
```
