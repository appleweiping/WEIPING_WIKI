---
title: "Philosophical Quotes Cql"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/cassandra_astradb/philosophical_quotes_cql
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_CQL.ipynb
---

# Philosophical Quotes Cql

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/cassandra_astradb/philosophical_quotes_cql
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_CQL.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_CQL.ipynb
- Source path: `examples/vector_databases/cassandra_astradb/Philosophical_Quotes_CQL.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `87a6bbb397086d3a5895c70e261eddf91260d748eef137b1bda0bf2c9c653a5a`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Philosophy with Vector Embeddings, OpenAI and Cassandra / Astra DB CQL Version In this quickstart you will learn how to build a "philosophy quote finder & generator" using OpenAI's vector embeddings and Apache Cassandra®, or equivalently DataStax Astra DB through CQL, as the vector store for data persistence. The basic workflow of this notebook is outlined b...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Philosophy with Vector Embeddings, OpenAI and Cassandra / Astra DB

### CQL Version

In this quickstart you will learn how to build a "philosophy quote finder & generator" using OpenAI's vector embeddings and [Apache Cassandra®](https://cassandra.apache.org), or equivalently DataStax [Astra DB through CQL](https://docs.datastax.com/en/astra-serverless/docs/vector-search/quickstart.html), as the vector store for data persistence.

The basic workflow of this notebook is outlined below. You will evaluate and store the vector embeddings for a number of quotes by famous philosophers, use them to build a powerful search engine and, after that, even a generator of new quotes!

The notebook exemplifies some of the standard usage patterns of vector search -- while showing how easy is it to get started with the vector capabilities of [Cassandra](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html) / [Astra DB through CQL](https://docs.datastax.com/en/astra-serverless/docs/vector-search/quickstart.html).

For a background on using vector search and text embeddings to build a question-answering system, please check out this excellent hands-on notebook: [Question answering using embeddings](https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_embeddings.ipynb).

#### _Choose-your-framework_

Please note that this notebook uses the [Cassandra drivers](https://docs.datastax.com/en/developer/python-driver/latest/) and runs CQL (Cassandra Query Language) statements directly, but we cover other choices of technology to accomplish the same task. Check out this folder's [README](https://github.com/openai/openai-cookbook/tree/main/examples/vector_databases/cassandra_astradb) for other options. This notebook can run either as a Colab notebook or as a regular Jupyter notebook.

Table of contents:
- Setup
- Get DB connection
- Connect to OpenAI
- Load quotes into the Vector Store
- Use case 1: **quote search engine**
- Use case 2: **quote generator**
- (Optional) exploit partitioning in the Vector Store

### How it works

**Indexing**

Each quote is made into an embedding vector with OpenAI's `Embedding`. These are saved in the Vector Store for later use in searching. Some metadata, including the author's name and a few other pre-computed tags, are stored alongside, to allow for search customization.

![1_vector_indexing_cql](https://user-images.githubusercontent.com/14221764/282437237-1e763166-a863-4332-99b8-323ba23d1b87.png)

**Search**

To find a quote similar to the provided search quote, the latter is made into an embedding vector on the fly, and this vector is used to query the store for similar vectors ... i.e. similar quotes that were previously indexed. The search can optionally be constrained by additional metadata ("find me quotes by Spinoza similar to this one ...").

![2_vector_search_cql](https://user-images.githubusercontent.com/14221764/282437291-85335612-a845-444e-bed7-e4cf014a9f17.png)

The key point here is that "quotes similar in content" translates, in vector space, to vectors that are metrically close to each other: thus, vector similarity search effectively implements semantic similarity. _This is the key reason vector embeddings are so powerful._

The sketch below tries to convey this idea. Each quote, once it's made into a vector, is a point in space. Well, in this case it's on a sphere, since OpenAI's embedding vectors, as most others, are normalized to _unit length_. Oh, and the sphere is actually not three-dimensional, rather 1536-dimensional!

So, in essence, a similarity search in vector space returns the vectors that are closest to the query vector:

![3_vector_space](https://user-images.githubusercontent.com/14221764/262321363-c8c625c1-8be9-450e-8c68-b1ed518f990d.png)

**Generation**

Given a suggestion (a topic or a tentative quote), the search step is performed, and the first returned results (quotes) are fed into an LLM prompt which asks the generative model to invent a new text along the lines of the passed examples _and_ the initial suggestion.

![4_quote_generation](https://user-images.githubusercontent.com/14221764/282437321-881bd273-3443-4987-9a11-350d3288dd8e.png)

## Setup

Install and import the necessary dependencies:

```python
!pip install --quiet "cassandra-driver>=0.28.0" "openai>=1.0.0" datasets
```

```python
import os
from uuid import uuid4
from getpass import getpass
from collections import Counter

from cassandra.cluster import Cluster
from cassandra.auth import PlainTextAuthProvider

import openai
from datasets import load_dataset
```

_Don't mind the next cell too much, we need it to detect Colabs and let you upload the SCB file (see below):_

```python
try:
    from google.colab import files
    IS_COLAB = True
except ModuleNotFoundError:
    IS_COLAB = False
```

## Get DB connection

A couple of secrets are required to create a `Session` object (a connection to your Astra DB instance).

_(Note: some steps will be slightly different on Google Colab and on local Jupyter, that's why the notebook will detect the runtime type.)_

```python
# Your database's Secure Connect Bundle zip file is needed:
if IS_COLAB:
    print('Please upload your Secure Connect Bundle zipfile: ')
    uploaded = files.upload()
    if uploaded:
        astraBundleFileTitle = list(uploaded.keys())[0]
        ASTRA_DB_SECURE_BUNDLE_PATH = os.path.join(os.getcwd(), astraBundleFileTitle)
    else:
        raise ValueError(
            'Cannot proceed without Secure Connect Bundle. Please re-run the cell.'
        )
else:
    # you are running a local-jupyter notebook:
    ASTRA_DB_SECURE_BUNDLE_PATH = input("Please provide the full path to your Secure Connect Bundle zipfile: ")

ASTRA_DB_APPLICATION_TOKEN = getpass("Please provide your Database Token ('AstraCS:...' string): ")
ASTRA_DB_KEYSPACE = input("Please provide the Keyspace name for your Database: ")
```

### Creation of the DB connection

This is how you create a connection to Astra DB:

_(Incidentally, you could also use any Cassandra cluster (as long as it provides Vector capabilities), just by [changing the parameters](https://docs.datastax.com/en/developer/python-driver/latest/getting_started/#connecting-to-cassandra) to the following `Cluster` instantiation.)_

```python
# Don't mind the "Closing connection" error after "downgrading protocol..." messages you may see,
# it is really just a warning: the connection will work smoothly.
cluster = Cluster(
    cloud={
        "secure_connect_bundle": ASTRA_DB_SECURE_BUNDLE_PATH,
    },
    auth_provider=PlainTextAuthProvider(
        "token",
        ASTRA_DB_APPLICATION_TOKEN,
    ),
)

session = cluster.connect()
keyspace = ASTRA_DB_KEYSPACE
```

### Creation of the Vector table in CQL

You need a table which support vectors and is equipped with metadata. Call it "philosophers_cql".

Each row will store: a quote, its vector embedding, the quote author and a set of "tags". You also need a primary key to ensure uniqueness of rows.

The following is the full CQL command that creates the table (check out [this page](https://docs.datastax.com/en/dse/6.7/cql/cql/cqlQuickReference.html) for more on the CQL syntax of this and the following statements):

```python
create_table_statement = f"""CREATE TABLE IF NOT EXISTS {keyspace}.philosophers_cql (
    quote_id UUID PRIMARY KEY,
    body TEXT,
    embedding_vector VECTOR<FLOAT, 1536>,
    author TEXT,
    tags SET<TEXT>
);"""
```

Pass this statement to your database Session to execute it:

```python
session.execute(create_table_statement)
```

#### Add a vector index for ANN search

In order to run ANN (approximate-nearest-neighbor) searches on the vectors in the table, you need to create a specific index on the `embedding_vector` column.

_When creating the index, you can [optionally choose](https://docs.datastax.com/en/astra-serverless/docs/vector-search/cql.html#_create_the_vector_schema_and_load_the_data_into_the_database) the "similarity function" used to compute vector distances: since for unit-length vectors (such as those from OpenAI) the "cosine difference" is the same as the "dot product", you'll use the latter which is computationally less expensive._

Run this CQL statement:

```python
create_vector_index_statement = f"""CREATE CUSTOM INDEX IF NOT EXISTS idx_embedding_vector
    ON {keyspace}.philosophers_cql (embedding_vector)
    USING 'org.apache.cassandra.index.sai.StorageAttachedIndex'
    WITH OPTIONS = {{'similarity_function' : 'dot_product'}};
"""
# Note: the double '{{' and '}}' are just the F-string escape sequence for '{' and '}'

session.execute(create_vector_index_statement)
```

#### Add indexes for author and tag filtering

That is enough to run vector searches on the table ... but you want to be able to optionally specify an author and/or some tags to restrict the quote search. Create two other indexes to support this:

```python
create_author_index_statement = f"""CREATE CUSTOM INDEX IF NOT EXISTS idx_author
    ON {keyspace}.philosophers_cql (author)
    USING 'org.apache.cassandra.index.sai.StorageAttachedIndex';
"""
session.execute(create_author_index_statement)

create_tags_index_statement = f"""CREATE CUSTOM INDEX IF NOT EXISTS idx_tags
    ON {keyspace}.philosophers_cql (VALUES(tags))
    USING 'org.apache.cassandra.index.sai.StorageAttachedIndex';
"""
session.execute(create_tags_index_statement)
```

## Connect to OpenAI

### Set up your secret key

```python
OPENAI_API_KEY = getpass("Please enter your OpenAI API Key: ")
```

### A test call for embeddings

Quickly check how one can get the embedding vectors for a list of input texts:

```python
client = openai.OpenAI(api_key=OPENAI_API_KEY)
embedding_model_name = "text-embedding-3-small"

result = client.embeddings.create(
    input=[
        "This is a sentence",
        "A second sentence"
    ],
    model=embedding_model_name,
)
```

_Note: the above is the syntax for OpenAI v1.0+. If using previous versions, the code to get the embeddings will look different._

```python
print(f"len(result.data)              = {len(result.data)}")
print(f"result.data[1].embedding      = {str(result.data[1].embedding)[:55]}...")
print(f"len(result.data[1].embedding) = {len(result.data[1].embedding)}")
```

## Load quotes into the Vector Store

Get a dataset with the quotes. _(We adapted and augmented the data from [this Kaggle dataset](https://www.kaggle.com/datasets/mertbozkurt5/quotes-by-philosophers), ready to use in this demo.)_

```python
philo_dataset = load_dataset("datastax/philosopher-quotes")["train"]
```

A quick inspection:

```python
print("An example entry:")
print(philo_dataset[16])
```

Check the dataset size:

```python
author_count = Counter(entry["author"] for entry in philo_dataset)
print(f"Total: {len(philo_dataset)} quotes. By author:")
for author, count in author_count.most_common():
    print(f"    {author:<20}: {count} quotes")
```

### Insert quotes into vector store

You will compute the embeddings for the quotes and save them into the Vector Store, along with the text itself and the metadata planned for later use.

To optimize speed and reduce the calls, you'll perform batched calls to the embedding OpenAI service.

The DB write is accomplished with a CQL statement. But since you'll run this particular insertion several times (albeit with different values), it's best to _prepare_ the statement and then just run it over and over.

_(Note: for faster insertion, the Cassandra drivers would let you do concurrent inserts, which we don't do here for a more straightforward demo code.)_

```python
prepared_insertion = session.prepare(
    f"INSERT INTO {keyspace}.philosophers_cql (quote_id, author, body, embedding_vector, tags) VALUES (?, ?, ?, ?, ?);"
)

BATCH_SIZE = 20

num_batches = ((len(philo_dataset) + BATCH_SIZE - 1) // BATCH_SIZE)

quotes_list = philo_dataset["quote"]
authors_list = philo_dataset["author"]
tags_list = philo_dataset["tags"]

print("Starting to store entries:")
for batch_i in range(num_batches):
    b_start = batch_i * BATCH_SIZE
    b_end = (batch_i + 1) * BATCH_SIZE
    # compute the embedding vectors for this batch
    b_emb_results = client.embeddings.create(
        input=quotes_list[b_start : b_end],
        model=embedding_model_name,
    )
    # prepare the rows for insertion
    print("B ", end="")
    for entry_idx, emb_result in zip(range(b_start, b_end), b_emb_results.data):
        if tags_list[entry_idx]:
            tags = {
                tag
                for tag in tags_list[entry_idx].split(";")
            }
        else:
            tags = set()
        author = authors_list[entry_idx]
        quote = quotes_list[entry_idx]
        quote_id = uuid4()  # a new random ID for each quote. In a production app you'll want to have better control...
        session.execute(
            prepared_insertion,
            (quote_id, author, quote, emb_result.embedding, tags),
        )
        print("*", end="")
    print(f" done ({len(b_emb_results.data)})")

print("\nFinished storing entries.")
```

## Use case 1: **quote search engine**

For the quote-search functionality, you need first to make the input quote into a vector, and then use it to query the store (besides handling the optional metadata into the search call, that is).

Encapsulate the search-engine functionality into a function for ease of re-use:

```python
def find_quote_and_author(query_quote, n, author=None, tags=None):
    query_vector = client.embeddings.create(
        input=[query_quote],
        model=embedding_model_name,
    ).data[0].embedding
    # depending on what conditions are passed, the WHERE clause in the statement may vary.
    where_clauses = []
    where_values = []
    if author:
        where_clauses += ["author = %s"]
        where_values += [author]
    if tags:
        for tag in tags:
            where_clauses += ["tags CONTAINS %s"]
            where_values += [tag]
    # The reason for these two lists above is that when running the CQL search statement the values passed
    # must match the sequence of "?" marks in the statement.
    if where_clauses:
        search_statement = f"""SELECT body, author FROM {keyspace}.philosophers_cql
            WHERE {' AND '.join(where_clauses)}
            ORDER BY embedding_vector ANN OF %s
            LIMIT %s;
        """
    else:
        search_statement = f"""SELECT body, author FROM {keyspace}.philosophers_cql
            ORDER BY embedding_vector ANN OF %s
            LIMIT %s;
        """
    # For best performance, one should keep a cache of prepared statements (see the insertion code above)
    # for the various possible statements used here.
    # (We'll leave it as an exercise to the reader to avoid making this code too long.
    # Remember: to prepare a statement you use '?' instead of '%s'.)
    query_values = tuple(where_values + [query_vector] + [n])
    result_rows = session.execute(search_statement, query_values)
    return [
        (result_row.body, result_row.author)
        for result_row in result_rows
    ]
```

### Putting search to test

Passing just a quote:

```python
find_quote_and_author("We struggle all our life for nothing", 3)
```

Search restricted to an author:

```python
find_quote_and_author("We struggle all our life for nothing", 2, author="nietzsche")
```

Search constrained to a tag (out of those saved earlier with the quotes):

```python
find_quote_and_author("We struggle all our life for nothing", 2, tags=["politics"])
```

### Cutting out irrelevant results

The vector similarity search generally returns the vectors that are closest to the query, even if that means results that might be somewhat irrelevant if there's nothing better.

To keep this issue under control, you can get the actual "similarity" between the query and each result, and then set a cutoff on it, effectively discarding results that are beyond that threshold.
Tuning this threshold correctly is not an easy problem: here, we'll just show you the way.

To get a feeling on how this works, try the following query and play with the choice of quote and threshold to compare the results:

_Note (for the mathematically inclined): this value is **a rescaling between zero and one** of the cosine difference between the vectors, i.e. of the scalar product divided by the product of the norms of the two vectors. In other words, this is 0 for opposite-facing vecors and +1 for parallel vectors. For other measures of similarity, check the [documentation](https://docs.datastax.com/en/astra-serverless/docs/vector-search/cql.html#_create_the_vector_schema_and_load_the_data_into_the_database) -- and keep in mind that the metric in the `SELECT` query should match the one used when creating the index earlier for meaningful, ordered results._

```python
quote = "Animals are our equals."
# quote = "Be good."
# quote = "This teapot is strange."

similarity_threshold = 0.92

quote_vector = client.embeddings.create(
    input=[quote],
    model=embedding_model_name,
).data[0].embedding

# Once more: remember to prepare your statements in production for greater performance...

search_statement = f"""SELECT body, similarity_dot_product(embedding_vector, %s) as similarity
    FROM {keyspace}.philosophers_cql
    ORDER BY embedding_vector ANN OF %s
    LIMIT %s;
"""
query_values = (quote_vector, quote_vector, 8)

result_rows = session.execute(search_statement, query_values)
results = [
    (result_row.body, result_row.similarity)
    for result_row in result_rows
    if result_row.similarity >= similarity_threshold
]

print(f"{len(results)} quotes within the threshold:")
for idx, (r_body, r_similarity) in enumerate(results):
    print(f"    {idx}. [similarity={r_similarity:.3f}] \"{r_body[:70]}...\"")
```

## Use case 2: **quote generator**

For this task you need another component from OpenAI, namely an LLM to generate the quote for us (based on input obtained by querying the Vector Store).

You also need a template for the prompt that will be filled for the generate-quote LLM completion task.

```python
completion_model_name = "gpt-3.5-turbo"

generation_prompt_template = """"Generate a single short philosophical quote on the given topic,
similar in spirit and form to the provided actual example quotes.
Do not exceed 20-30 words in your quote.

REFERENCE TOPIC: "{topic}"

ACTUAL EXAMPLES:
{examples}
"""
```

Like for search, this functionality is best wrapped into a handy function (which internally uses search):

```python
def generate_quote(topic, n=2, author=None, tags=None):
    quotes = find_quote_and_author(query_quote=topic, n=n, author=author, tags=tags)
    if quotes:
        prompt = generation_prompt_template.format(
            topic=topic,
            examples="\n".join(f"  - {quote[0]}" for quote in quotes),
        )
        # a little logging:
        print("** quotes found:")
        for q, a in quotes:
            print(f"**    - {q} ({a})")
        print("** end of logging")
        #
        response = client.chat.completions.create(
            model=completion_model_name,
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7,
            max_tokens=320,
        )
        return response.choices[0].message.content.replace('"', '').strip()
    else:
        print("** no quotes found.")
        return None
```

_Note: similar to the case of the embedding computation, the code for the Chat Completion API would be slightly different for OpenAI prior to v1.0._

#### Putting quote generation to test

Just passing a text (a "quote", but one can actually just suggest a topic since its vector embedding will still end up at the right place in the vector space):

```python
q_topic = generate_quote("politics and virtue")
print("\nA new generated quote:")
print(q_topic)
```

Use inspiration from just a single philosopher:

```python
q_topic = generate_quote("animals", author="schopenhauer")
print("\nA new generated quote:")
print(q_topic)
```

## (Optional) **Partitioning**

There's an interesting topic to examine before completing this quickstart. While, generally, tags and quotes can be in any relationship (e.g. a quote having multiple tags), _authors_ are effectively an exact grouping (they define a "disjoint partitioning" on the set of quotes): each quote has exactly one author (for us, at least).

Now, suppose you know in advance your application will usually (or always) run queries on a _single author_. Then you can take full advantage of the underlying database structure: if you group quotes in **partitions** (one per author), vector queries on just an author will use less resources and return much faster.

We'll not dive into the details here, which have to do with the Cassandra storage internals: the important message is that **if your queries are run within a group, consider partitioning accordingly to boost performance**.

You'll now see this choice in action.

The partitioning per author calls for a new table schema: create a new table called "philosophers_cql_partitioned", along with the necessary indexes:

```python
create_table_p_statement = f"""CREATE TABLE IF NOT EXISTS {keyspace}.philosophers_cql_partitioned (
    author TEXT,
    quote_id UUID,
    body TEXT,
    embedding_vector VECTOR<FLOAT, 1536>,
    tags SET<TEXT>,
    PRIMARY KEY ( (author), quote_id )
) WITH CLUSTERING ORDER BY (quote_id ASC);"""

session.execute(create_table_p_statement)

create_vector_index_p_statement = f"""CREATE CUSTOM INDEX IF NOT EXISTS idx_embedding_vector_p
    ON {keyspace}.philosophers_cql_partitioned (embedding_vector)
    USING 'org.apache.cassandra.index.sai.StorageAttachedIndex'
    WITH OPTIONS = {{'similarity_function' : 'dot_product'}};
"""

session.execute(create_vector_index_p_statement)

create_tags_index_p_statement = f"""CREATE CUSTOM INDEX IF NOT EXISTS idx_tags_p
    ON {keyspace}.philosophers_cql_partitioned (VALUES(tags))
    USING 'org.apache.cassandra.index.sai.StorageAttachedIndex';
"""
session.execute(create_tags_index_p_statement)
```

Now repeat the compute-embeddings-and-insert step on the new table.

You could use the very same insertion code as you did earlier, because the differences are hidden "behind the scenes": the database will store the inserted rows differently according to the partitioning scheme of this new table.

However, by way of demonstration, you will take advantage of a handy facility offered by the Cassandra drivers to easily run several queries (in this case, `INSERT`s) concurrently. This is something that Cassandra / Astra DB through CQL supports very well and can lead to a significant speedup, with very little changes in the client code.

_(Note: one could additionally have cached the embeddings computed previously to save a few API tokens -- here, however, we wanted to keep the code easier to inspect.)_

```python
from cassandra.concurrent import execute_concurrent_with_args
```

```python
prepared_insertion = session.prepare(
    f"INSERT INTO {keyspace}.philosophers_cql_partitioned (quote_id, author, body, embedding_vector, tags) VALUES (?, ?, ?, ?, ?);"
)

BATCH_SIZE = 50

num_batches = ((len(philo_dataset) + BATCH_SIZE - 1) // BATCH_SIZE)

quotes_list = philo_dataset["quote"]
authors_list = philo_dataset["author"]
tags_list = philo_dataset["tags"]

print("Starting to store entries:")
for batch_i in range(num_batches):
    print("[...", end="")
    b_start = batch_i * BATCH_SIZE
    b_end = (batch_i + 1) * BATCH_SIZE
    # compute the embedding vectors for this batch
    b_emb_results = client.embeddings.create(
        input=quotes_list[b_start : b_end],
        model=embedding_model_name,
    )
    # prepare this batch's entries for insertion
    tuples_to_insert = []
    for entry_idx, emb_result in zip(range(b_start, b_end), b_emb_results.data):
        if tags_list[entry_idx]:
            tags = {
                tag
                for tag in tags_list[entry_idx].split(";")
            }
        else:
            tags = set()
        author = authors_list[entry_idx]
        quote = quotes_list[entry_idx]
        quote_id = uuid4()  # a new random ID for each quote. In a production app you'll want to have better control...
        # append a *tuple* to the list, and in the tuple the values are ordered to match "?" in the prepared statement:
        tuples_to_insert.append((quote_id, author, quote, emb_result.embedding, tags))
    # insert the batch at once through the driver's concurrent primitive
    conc_results = execute_concurrent_with_args(
        session,
        prepared_insertion,
        tuples_to_insert,
    )
    # check that all insertions succeed (better to always do this):
    if any([not success for success, _ in conc_results]):
        print("Something failed during the insertions!")
    else:
        print(f"{len(b_emb_results.data)}] ", end="")

print("\nFinished storing entries.")
```

Despite the different table schema, the DB query behind the similarity search is essentially the same:

```python
def find_quote_and_author_p(query_quote, n, author=None, tags=None):
    query_vector = client.embeddings.create(
        input=[query_quote],
        model=embedding_model_name,
    ).data[0].embedding
    # Depending on what conditions are passed, the WHERE clause in the statement may vary.
    # Construct it accordingly:
    where_clauses = []
    where_values = []
    if author:
        where_clauses += ["author = %s"]
        where_values += [author]
    if tags:
        for tag in tags:
            where_clauses += ["tags CONTAINS %s"]
            where_values += [tag]
    if where_clauses:
        search_statement = f"""SELECT body, author FROM {keyspace}.philosophers_cql_partitioned
            WHERE {' AND '.join(where_clauses)}
            ORDER BY embedding_vector ANN OF %s
            LIMIT %s;
        """
    else:
        search_statement = f"""SELECT body, author FROM {keyspace}.philosophers_cql_partitioned
            ORDER BY embedding_vector ANN OF %s
            LIMIT %s;
        """
    query_values = tuple(where_values + [query_vector] + [n])
    result_rows = session.execute(search_statement, query_values)
    return [
        (result_row.body, result_row.author)
        for result_row in result_rows
    ]
```

That's it: the new table still supports the "generic" similarity searches all right ...

```python
find_quote_and_author_p("We struggle all our life for nothing", 3)
```

... but it's when an author is specified that you would notice a _huge_ performance advantage:

```python
find_quote_and_author_p("We struggle all our life for nothing", 2, author="nietzsche")
```

Well, you _would_ notice a performance gain, if you had a realistic-size dataset. In this demo, with a few tens of entries, there's no noticeable difference -- but you get the idea.

## Conclusion

Congratulations! You have learned how to use OpenAI for vector embeddings and Astra DB / Cassandra for storage in order to build a sophisticated philosophical search engine and quote generator.

This example used the [Cassandra drivers](https://docs.datastax.com/en/developer/python-driver/latest/) and runs CQL (Cassandra Query Language) statements directly to interface with the Vector Store - but this is not the only choice. Check the [README](https://github.com/openai/openai-cookbook/tree/main/examples/vector_databases/cassandra_astradb) for other options and integration with popular frameworks.

To find out more on how Astra DB's Vector Search capabilities can be a key ingredient in your ML/GenAI applications, visit [Astra DB](https://docs.datastax.com/en/astra-serverless/docs/vector-search/overview.html)'s web page on the topic.

## Cleanup

If you want to remove all resources used for this demo, run this cell (_warning: this will delete the tables and the data inserted in them!_):

```python
session.execute(f"DROP TABLE IF EXISTS {keyspace}.philosophers_cql;")
session.execute(f"DROP TABLE IF EXISTS {keyspace}.philosophers_cql_partitioned;")
```
