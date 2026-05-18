---
title: "Philosophical Quotes Cassio"
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
  - https://developers.openai.com/cookbook/examples/vector_databases/cassandra_astradb/philosophical_quotes_cassio
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_cassIO.ipynb
---

# Philosophical Quotes Cassio

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/cassandra_astradb/philosophical_quotes_cassio
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_cassIO.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_cassIO.ipynb
- Source path: `examples/vector_databases/cassandra_astradb/Philosophical_Quotes_cassIO.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `e7c580739e46f62d6aa433b845eb84e06a4dd7cb43007ab9257c6ac3cb43649f`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Philosophy with Vector Embeddings, OpenAI and Cassandra / Astra DB through CQL CassIO version In this quickstart you will learn how to build a "philosophy quote finder & generator" using OpenAI's vector embeddings and Apache Cassandra®, or equivalently DataStax Astra DB through CQL, as the vector store for data persistence. The basic workflow of this noteboo...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Philosophy with Vector Embeddings, OpenAI and Cassandra / Astra DB through CQL

### CassIO version

In this quickstart you will learn how to build a "philosophy quote finder & generator" using OpenAI's vector embeddings and [Apache Cassandra®](https://cassandra.apache.org), or equivalently DataStax [Astra DB through CQL](https://docs.datastax.com/en/astra-serverless/docs/vector-search/quickstart.html), as the vector store for data persistence.

The basic workflow of this notebook is outlined below. You will evaluate and store the vector embeddings for a number of quotes by famous philosophers, use them to build a powerful search engine and, after that, even a generator of new quotes!

The notebook exemplifies some of the standard usage patterns of vector search -- while showing how easy is it to get started with the vector capabilities of [Cassandra](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html) / [Astra DB through CQL](https://docs.datastax.com/en/astra-serverless/docs/vector-search/quickstart.html).

For a background on using vector search and text embeddings to build a question-answering system, please check out this excellent hands-on notebook: [Question answering using embeddings](https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_embeddings.ipynb).

#### _Choose-your-framework_

Please note that this notebook uses the [CassIO library](https://cassio.org), but we cover other choices of technology to accomplish the same task. Check out this folder's [README](https://github.com/openai/openai-cookbook/tree/main/examples/vector_databases/cassandra_astradb) for other options. This notebook can run either as a Colab notebook or as a regular Jupyter notebook.

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

![1_vector_indexing](https://user-images.githubusercontent.com/14221764/282440878-dc3ed680-7d0e-4b30-9a74-d2d66a7394f7.png)

**Search**

To find a quote similar to the provided search quote, the latter is made into an embedding vector on the fly, and this vector is used to query the store for similar vectors ... i.e. similar quotes that were previously indexed. The search can optionally be constrained by additional metadata ("find me quotes by Spinoza similar to this one ...").

![2_vector_search](https://user-images.githubusercontent.com/14221764/282440908-683e3ee1-0bf1-46b3-8621-86c31fc7f9c9.png)

The key point here is that "quotes similar in content" translates, in vector space, to vectors that are metrically close to each other: thus, vector similarity search effectively implements semantic similarity. _This is the key reason vector embeddings are so powerful._

The sketch below tries to convey this idea. Each quote, once it's made into a vector, is a point in space. Well, in this case it's on a sphere, since OpenAI's embedding vectors, as most others, are normalized to _unit length_. Oh, and the sphere is actually not three-dimensional, rather 1536-dimensional!

So, in essence, a similarity search in vector space returns the vectors that are closest to the query vector:

![3_vector_space](https://user-images.githubusercontent.com/14221764/262321363-c8c625c1-8be9-450e-8c68-b1ed518f990d.png)

**Generation**

Given a suggestion (a topic or a tentative quote), the search step is performed, and the first returned results (quotes) are fed into an LLM prompt which asks the generative model to invent a new text along the lines of the passed examples _and_ the initial suggestion.

![4_quote_generation](https://user-images.githubusercontent.com/14221764/282440927-d56f36eb-d611-4342-8026-7736edc6f5c9.png)

## Setup

First install some required packages:

```python
!pip install --quiet "cassio>=0.1.3" "openai>=1.0.0" datasets
```

```python
from getpass import getpass
from collections import Counter

import cassio
from cassio.table import MetadataVectorCassandraTable

import openai
from datasets import load_dataset
```

## Get DB connection

In order to connect to your Astra DB through CQL, you need two things:
- A Token, with role "Database Administrator" (it looks like `AstraCS:...`)
- the database ID (it looks like `3df2a5b6-...`)

    Make sure you have both strings -- which are obtained in the [Astra UI](https://astra.datastax.com) once you sign in. For more information, see here: [database ID](https://awesome-astra.github.io/docs/pages/astra/faq/#where-should-i-find-a-database-identifier) and [Token](https://awesome-astra.github.io/docs/pages/astra/create-token/#c-procedure).

If you want to _connect to a Cassandra cluster_ (which however must [support](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html) Vector Search), replace with `cassio.init(session=..., keyspace=...)` with suitable Session and keyspace name for your cluster.

```python
astra_token = getpass("Please enter your Astra token ('AstraCS:...')")
database_id = input("Please enter your database id ('3df2a5b6-...')")
```

```python
cassio.init(token=astra_token, database_id=database_id)
```

### Creation of the DB connection

This is how you create a connection to Astra DB through CQL:

_(Incidentally, you could also use any Cassandra cluster (as long as it provides Vector capabilities), just by [changing the parameters](https://docs.datastax.com/en/developer/python-driver/latest/getting_started/#connecting-to-cassandra) to the following `Cluster` instantiation.)_

### Creation of the Vector Store through CassIO

You need a table which support vectors and is equipped with metadata. Call it "philosophers_cassio":

```python
v_table = MetadataVectorCassandraTable(table="philosophers_cassio", vector_dimension=1536)
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

_Note: the above is the syntax for OpenAI v1.0+. If using previous versions, the code to get the embeddings will look different._

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

You will compute the embeddings for the quotes and save them into the Vector Store, along with the text itself and the metadata planned for later use. Note that the author is added as a metadata field along with the "tags" already found with the quote itself.

To optimize speed and reduce the calls, you'll perform batched calls to the embedding OpenAI service.

_(Note: for faster execution, Cassandra and CassIO would let you do concurrent inserts, which we don't do here for a more straightforward demo code.)_

```python
BATCH_SIZE = 50

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
        v_table.put(
            row_id=f"q_{author}_{entry_idx}",
            body_blob=quote,
            vector=emb_result.embedding,
            metadata={**{tag: True for tag in tags}, **{"author": author}},
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
    metadata = {}
    if author:
        metadata["author"] = author
    if tags:
        for tag in tags:
            metadata[tag] = True
    #
    results = v_table.ann_search(
        query_vector,
        n=n,
        metadata=metadata,
    )
    return [
        (result["body_blob"], result["metadata"]["author"])
        for result in results
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

To keep this issue under control, you can get the actual "distance" between the query and each result, and then set a cutoff on it, effectively discarding results that are beyond that threshold.
Tuning this threshold correctly is not an easy problem: here, we'll just show you the way.

To get a feeling on how this works, try the following query and play with the choice of quote and threshold to compare the results:

_Note (for the mathematically inclined): this "distance" is exactly the cosine similarity between the vectors, i.e. the scalar product divided by the product of the norms of the two vectors. As such, it is a number ranging from -1 to +1, where -1 is for exactly opposite-facing vectors and +1 for identically-oriented vectors. Elsewhere (e.g. in the "CQL" counterpart of this demo) you would get a rescaling of this quantity to fit the [0, 1] interval, which means the resulting numerical values and adequate thresholds there are transformed accordingly._

```python
quote = "Animals are our equals."
# quote = "Be good."
# quote = "This teapot is strange."

metric_threshold = 0.84

quote_vector = client.embeddings.create(
    input=[quote],
    model=embedding_model_name,
).data[0].embedding

results = list(v_table.metric_ann_search(
    quote_vector,
    n=8,
    metric="cos",
    metric_threshold=metric_threshold,
))

print(f"{len(results)} quotes within the threshold:")
for idx, result in enumerate(results):
    print(f"    {idx}. [distance={result['distance']:.3f}] \"{result['body_blob'][:70]}...\"")
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

First, you need a different table abstraction from CassIO:

```python
from cassio.table import ClusteredMetadataVectorCassandraTable
```

```python
v_table_partitioned = ClusteredMetadataVectorCassandraTable(table="philosophers_cassio_partitioned", vector_dimension=1536)
```

Now repeat the compute-embeddings-and-insert step on the new table.

Compared to what you have seen earlier, there is a crucial difference in that now the quote's author is stored as the _partition id_ for the inserted row, instead of being added to the catch-all "metadata" dictionary.

While you are at it, by way of demonstration, you will insert all quotes by a given author _concurrently_: with CassIO, this is done by usng the asynchronous `put_async` method for each quote, collecting the resulting list of `Future` objects, and calling the `result()` method on them all afterwards, to ensure they all have executed. Cassandra / Astra DB well supports a high degree of concurrency in I/O operations.

_(Note: one could have cached the embeddings computed previously to save a few API tokens -- here, however, we wanted to keep the code easier to inspect.)_

```python
BATCH_SIZE = 50

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
    futures = []
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
        futures.append(v_table_partitioned.put_async(
            partition_id=author,
            row_id=f"q_{author}_{entry_idx}",
            body_blob=quote,
            vector=emb_result.embedding,
            metadata={tag: True for tag in tags},
        ))
    #
    for future in futures:
        future.result()
    #
    print(f" done ({len(b_emb_results.data)})")

print("\nFinished storing entries.")
```

With this new table, the similarity search changes accordingly (note the arguments to `ann_search`):

```python
def find_quote_and_author_p(query_quote, n, author=None, tags=None):
    query_vector = client.embeddings.create(
        input=[query_quote],
        model=embedding_model_name,
    ).data[0].embedding
    metadata = {}
    partition_id = None
    if author:
        partition_id = author
    if tags:
        for tag in tags:
            metadata[tag] = True
    #
    results = v_table_partitioned.ann_search(
        query_vector,
        n=n,
        partition_id=partition_id,
        metadata=metadata,
    )
    return [
        (result["body_blob"], result["partition_id"])
        for result in results
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

Congratulations! You have learned how to use OpenAI for vector embeddings and Cassandra / Astra DB through CQL for storage in order to build a sophisticated philosophical search engine and quote generator.

This example used [CassIO](https://cassio.org) to interface with the Vector Store - but this is not the only choice. Check the [README](https://github.com/openai/openai-cookbook/tree/main/examples/vector_databases/cassandra_astradb) for other options and integration with popular frameworks.

To find out more on how Astra DB's Vector Search capabilities can be a key ingredient in your ML/GenAI applications, visit [Astra DB](https://docs.datastax.com/en/astra/home/astra.html)'s web page on the topic.

## Cleanup

If you want to remove all resources used for this demo, run this cell (_warning: this will delete the tables and the data inserted in them!_):

```python
# we peek at CassIO's config to get a direct handle to the DB connection
session = cassio.config.resolve_session()
keyspace = cassio.config.resolve_keyspace()

session.execute(f"DROP TABLE IF EXISTS {keyspace}.philosophers_cassio;")
session.execute(f"DROP TABLE IF EXISTS {keyspace}.philosophers_cassio_partitioned;")
```
