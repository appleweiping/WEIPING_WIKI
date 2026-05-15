---
title: "Readme"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - markdown-source
  - openai
  - rag
  - retrieval
source_pages:
  - https://developers.openai.com/cookbook/examples/vector_databases/cassandra_astradb/readme
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/README.md
---

# Readme

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/cassandra_astradb/readme
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/README.md
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/cassandra_astradb/README.md
- Source path: `examples/vector_databases/cassandra_astradb/README.md`
- Source kind: `examples`
- Source format: `.md`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `c195e22bf41b95cca2231b74c16673b9aadbeb28192a1aa5b7792d2feb78b011`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

RAG with Astra DB and Cassandra The demos in this directory show how to use the Vector Search capabilities available today in DataStax Astra DB , a serverless Database-as-a-Service built on Apache Cassandra®. These example notebooks demonstrate implementation of the same GenAI standard RAG workload with different libraries and APIs. To use $1 with its HTTP A...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# RAG with Astra DB and Cassandra

The demos in this directory show how to use the Vector
Search capabilities available today in **DataStax Astra DB**, a serverless
Database-as-a-Service built on Apache Cassandra®.

These example notebooks demonstrate implementation of
the same GenAI standard RAG workload with different libraries and APIs.

To use [Astra DB](https://docs.datastax.com/en/astra/home/astra.html)
with its HTTP API interface, head to the "AstraPy" notebook (`astrapy`
is the Python client to interact with the database).

If you prefer CQL access to the database (either with
[Astra DB](https://docs.datastax.com/en/astra-serverless/docs/vector-search/overview.html)
or a Cassandra cluster
[supporting vector search](https://cassandra.apache.org/doc/trunk/cassandra/vector-search/overview.html)),
check the "CQL" or "CassIO" notebooks -- they differ in the level of abstraction you get to work at.

If you want to know more about Astra DB and its Vector Search capabilities,
head over to [datastax.com](https://docs.datastax.com/en/astra/home/astra.html).

### Example notebooks

The following examples show how easily OpenAI and DataStax Astra DB can
work together to power vector-based AI applications. You can run them either
with your local Jupyter engine or as Colab notebooks:

| Use case | Target database | Framework | Notebook | Google Colab |
| -------- | --------------- | --------- | -------- | ------------ |
| Search/generate quotes | Astra DB | AstraPy | [Notebook](./Philosophical_Quotes_AstraPy.ipynb) | [![Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_AstraPy.ipynb) |
| Search/generate quotes | Cassandra / Astra DB through CQL | CassIO | [Notebook](./Philosophical_Quotes_cassIO.ipynb) | [![Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_cassIO.ipynb) |
| Search/generate quotes | Cassandra / Astra DB through CQL | Plain Cassandra language | [Notebook](./Philosophical_Quotes_CQL.ipynb) | [![Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/openai/openai-cookbook/blob/main/examples/vector_databases/cassandra_astradb/Philosophical_Quotes_CQL.ipynb) |

### Vector similarity, visual representation

![3_vector_space](https://user-images.githubusercontent.com/14221764/262321363-c8c625c1-8be9-450e-8c68-b1ed518f990d.png)
