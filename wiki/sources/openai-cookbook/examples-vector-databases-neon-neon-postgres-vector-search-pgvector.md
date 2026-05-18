---
title: "Neon Postgres Vector Search Pgvector"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/neon/neon-postgres-vector-search-pgvector
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/neon/neon-postgres-vector-search-pgvector.ipynb
---

# Neon Postgres Vector Search Pgvector

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/neon/neon-postgres-vector-search-pgvector
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/neon/neon-postgres-vector-search-pgvector.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/neon/neon-postgres-vector-search-pgvector.ipynb
- Source path: `examples/vector_databases/neon/neon-postgres-vector-search-pgvector.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `642b30dbcbcb2d8206bd01a2140061bbc9041e23ca835d199a4f7496abceaecc`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Vector similarity search using Neon Postgres This notebook guides you through using Neon Serverless Postgres as a vector database for OpenAI embeddings. It demonstrates how to: 1. Use embeddings created by OpenAI API. 2. Store embeddings in a Neon Serverless Postgres database. 3. Convert a raw text query to an embedding with OpenAI API. 4. Use Neon with the...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Vector similarity search using Neon Postgres

This notebook guides you through using [Neon Serverless Postgres](https://neon.tech/) as a vector database for OpenAI embeddings. It demonstrates how to:

1. Use embeddings created by OpenAI API.
2. Store embeddings in a Neon Serverless Postgres database.
3. Convert a raw text query to an embedding with OpenAI API.
4. Use Neon with the `pgvector` extension to perform vector similarity search.

## Prerequisites

Before you begin, ensure that you have the following:

1. A Neon Postgres database. You can create an account and set up a project with a ready-to-use `neondb` database in a few simple steps. For instructions, see [Sign up](https://neon.tech/docs/get-started-with-neon/signing-up) and [Create your first project](https://neon.tech/docs/get-started-with-neon/setting-up-a-project).
2. A connection string for your Neon database. You can copy it from the **Connection Details** widget on the Neon **Dashboard**. See [Connect from any application](https://neon.tech/docs/connect/connect-from-any-app).
3. The `pgvector` extension. Install the extension in Neon by running `CREATE EXTENSION vector;`. For instructions, see [Enable the pgvector extension](https://neon.tech/docs/extensions/pgvector#enable-the-pgvector-extension).
4. Your [OpenAI API key](https://platform.openai.com/account/api-keys).
5. Python and `pip`.

### Install required modules

This notebook requires the `openai`, `psycopg2`, `pandas`, `wget`, and `python-dotenv` packages. You can install them with `pip`:

```python
! pip install openai psycopg2 pandas wget python-dotenv
```

### Prepare your OpenAI API key

An OpenAI API key is required to generate vectors for documents and queries.

If you do not have an OpenAI API key, obtain one from https://platform.openai.com/account/api-keys.

Add the OpenAI API key as an operating system environment variable or provide it for the session when prompted. If you define an environment variable, name the variable `OPENAI_API_KEY`.

For information about configuring your OpenAI API key as an environment variable, refer to [Best Practices for API Key Safety](https://help.openai.com/en/articles/5112595-best-practices-for-api-key-safety).

### Test your OpenAPI key

```python
# Test to ensure that your OpenAI API key is defined as an environment variable or provide it when prompted
# If you run this notebook locally, you may have to reload the terminal and the notebook to make the environment available

import os
from getpass import getpass

# Check if OPENAI_API_KEY is set as an environment variable
if os.getenv("OPENAI_API_KEY") is not None:
    print("Your OPENAI_API_KEY is ready")
else:
    # If not, prompt for it
    api_key = getpass("Enter your OPENAI_API_KEY: ")
    if api_key:
        print("Your OPENAI_API_KEY is now available for this session")
        # Optionally, you can set it as an environment variable for the current session
        os.environ["OPENAI_API_KEY"] = api_key
    else:
        print("You did not enter your OPENAI_API_KEY")
```

## Connect to your Neon database

Provide your Neon database connection string below or define it in an `.env` file using a `DATABASE_URL` variable. For information about obtaining a Neon connection string, see [Connect from any application](https://neon.tech/docs/connect/connect-from-any-app).

```python
import os
import psycopg2
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# The connection string can be provided directly here.
# Replace the next line with Your Neon connection string.
connection_string = "postgres://<user>:<password>@<hostname>/<dbname>"

# If connection_string is not directly provided above,
# then check if DATABASE_URL is set in the environment or .env.
if not connection_string:
    connection_string = os.environ.get("DATABASE_URL")

    # If neither method provides a connection string, raise an error.
    if not connection_string:
        raise ValueError("Please provide a valid connection string either in the code or in the .env file as DATABASE_URL.")

# Connect using the connection string
connection = psycopg2.connect(connection_string)

# Create a new cursor object
cursor = connection.cursor()
```

Test the connection to your database:

```python
# Execute this query to test the database connection
cursor.execute("SELECT 1;")
result = cursor.fetchone()

# Check the query result
if result == (1,):
    print("Your database connection was successful!")
else:
    print("Your connection failed.")
```

This guide uses pre-computed Wikipedia article embeddings available in the OpenAI Cookbook `examples` directory so that you do not have to compute embeddings with your own OpenAI credits.

Import the pre-computed embeddings zip file:

```python
import wget

embeddings_url = "https://cdn.openai.com/API/examples/data/vector_database_wikipedia_articles_embedded.zip"

# The file is ~700 MB. Importing it will take several minutes.
wget.download(embeddings_url)
```

Extract the downloaded zip file:

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


# Check to see if the csv file was extracted
file_name = "vector_database_wikipedia_articles_embedded.csv"
data_directory = os.path.join(current_directory, "../../data")
file_path = os.path.join(data_directory, file_name)


if os.path.exists(file_path):
    print(f"The csv file {file_name} exists in the data directory.")
else:
    print(f"The csv file {file_name} does not exist in the data directory.")
```

## Create a table and add indexes for your vector embeddings

The vector table created in your database is called **articles**. Each object has **title** and **content** vectors.

An index is defined on both the **title** and **content** vector columns.

```python
create_table_sql = '''
CREATE TABLE IF NOT EXISTS public.articles (
    id INTEGER NOT NULL,
    url TEXT,
    title TEXT,
    content TEXT,
    title_vector vector(1536),
    content_vector vector(1536),
    vector_id INTEGER
);

ALTER TABLE public.articles ADD PRIMARY KEY (id);
'''

# SQL statement for creating indexes
create_indexes_sql = '''
CREATE INDEX ON public.articles USING ivfflat (content_vector) WITH (lists = 1000);

CREATE INDEX ON public.articles USING ivfflat (title_vector) WITH (lists = 1000);
'''

# Execute the SQL statements
cursor.execute(create_table_sql)
cursor.execute(create_indexes_sql)

# Commit the changes
connection.commit()
```

## Load the data

Load the pre-computed vector data into your `articles` table from the `.csv` file. There are 25000 records, so expect the operation to take several minutes.

```python
import io

# Path to your local CSV file
csv_file_path = '../../data/vector_database_wikipedia_articles_embedded.csv'

# Define a generator function to process the csv file
def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            yield line

# Create a StringIO object to store the modified lines
modified_lines = io.StringIO(''.join(list(process_file(csv_file_path))))

# Create the COPY command for copy_expert
copy_command = '''
COPY public.articles (id, url, title, content, title_vector, content_vector, vector_id)
FROM STDIN WITH (FORMAT CSV, HEADER true, DELIMITER ',');
'''

# Execute the COPY command using copy_expert
cursor.copy_expert(copy_command, modified_lines)

# Commit the changes
connection.commit()
```

Check the number of records to ensure the data has been been loaded. There should be 25000 records.

```python
# Check the size of the data
count_sql = """select count(*) from public.articles;"""
cursor.execute(count_sql)
result = cursor.fetchone()
print(f"Count:{result[0]}")
```

## Search your data

After the data is stored in your Neon database, you can query the data for nearest neighbors.

Start by defining the `query_neon` function, which is executed when you run the vector similarity search. The function creates an embedding based on the user's query, prepares the SQL query, and runs the SQL query with the embedding. The pre-computed embeddings that you loaded into your database were created with `text-embedding-3-small` OpenAI model, so you must use the same model to create an embedding for the similarity search.

A `vector_name` parameter is provided that allows you to search based on "title" or "content".

```python
def query_neon(query, collection_name, vector_name="title_vector", top_k=20):

    # Create an embedding vector from the user query
    embedded_query = openai.Embedding.create(
        input=query,
        model="text-embedding-3-small",
    )["data"][0]["embedding"]

    # Convert the embedded_query to PostgreSQL compatible format
    embedded_query_pg = "[" + ",".join(map(str, embedded_query)) + "]"

    # Create the SQL query
    query_sql = f"""
    SELECT id, url, title, l2_distance({vector_name},'{embedded_query_pg}'::VECTOR(1536)) AS similarity
    FROM {collection_name}
    ORDER BY {vector_name} <-> '{embedded_query_pg}'::VECTOR(1536)
    LIMIT {top_k};
    """
    # Execute the query
    cursor.execute(query_sql)
    results = cursor.fetchall()

    return results
```

Run a similarity search based on `title_vector` embeddings:

```python
# Query based on `title_vector` embeddings
import openai

query_results = query_neon("Greek mythology", "Articles")
for i, result in enumerate(query_results):
    print(f"{i + 1}. {result[2]} (Score: {round(1 - result[3], 3)})")
```

Run a similarity search based on `content_vector` embeddings:

```python
# Query based on `content_vector` embeddings
query_results = query_neon("Famous battles in Greek history", "Articles", "content_vector")
for i, result in enumerate(query_results):
    print(f"{i + 1}. {result[2]} (Score: {round(1 - result[3], 3)})")
```
