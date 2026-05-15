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
  - https://developers.openai.com/cookbook/examples/vector_databases/elasticsearch/readme
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/elasticsearch/README.md
---

# Readme

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/elasticsearch/readme
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/elasticsearch/README.md
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/elasticsearch/README.md
- Source path: `examples/vector_databases/elasticsearch/README.md`
- Source kind: `examples`
- Source format: `.md`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `e6d665195b9e54a16360fc46cb34ded6c4e8982839e02cdea4879ff5c870029f`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Elasticsearch Elasticsearch is a popular search/analytics engine and $1. Elasticsearch offers an efficient way to create, store, and search vector embeddings at scale. For technical details, refer to the $1. The $1 repo contains executable Python notebooks, sample apps, and resources for testing out the Elastic platform. OpenAI cookbook notebooks 📒 Check ou...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Elasticsearch

Elasticsearch is a popular search/analytics engine and [vector database](https://www.elastic.co/elasticsearch/vector-database).
Elasticsearch offers an efficient way to create, store, and search vector embeddings at scale.

For technical details, refer to the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/knn-search.html).

The [`elasticsearch-labs`](https://github.com/elastic/elasticsearch-labs) repo contains executable Python notebooks, sample apps, and resources for testing out the Elastic platform.

## OpenAI cookbook notebooks 📒

Check out our notebooks in this repo for working with OpenAI, using Elasticsearch as your vector database.

### [Semantic search](https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/elasticsearch/elasticsearch-semantic-search.ipynb)

In this notebook you'll learn how to:

 - Index the OpenAI Wikipedia embeddings dataset into Elasticsearch
 - Encode a question with the `openai ada-02` model
 - Perform a semantic search

<hr>


### [Retrieval augmented generation](https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/elasticsearch/elasticsearch-retrieval-augmented-generation.ipynb)

This notebooks builds on the semantic search notebook by:

- Selecting the top hit from a semantic search
- Sending that result to the OpenAI [Chat Completions](https://platform.openai.com/docs/guides/gpt/chat-completions-api) API endpoint for retrieval augmented generation (RAG)
