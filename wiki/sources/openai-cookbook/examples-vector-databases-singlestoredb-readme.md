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
  - https://developers.openai.com/cookbook/examples/vector_databases/singlestoredb/readme
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/SingleStoreDB/README.md
---

# Readme

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/singlestoredb/readme
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/SingleStoreDB/README.md
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/SingleStoreDB/README.md
- Source path: `examples/vector_databases/SingleStoreDB/README.md`
- Source kind: `examples`
- Source format: `.md`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `bdba1125e8947ac465b18a81de92d17a01325581d4c17db1612e0ffbef66d629`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

$1 has first-class support for vector search through our $1. Our vector database subsystem, first made available in 2017 and subsequently enhanced, allows extremely fast nearest-neighbor search to find objects that are semantically similar, easily using SQL. SingleStoreDB supports vectors and vector similarity search using dot product (for cosine similarity)...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

**[SingleStoreDB](https://singlestore.com)** has first-class support for vector search through our [Vector Functions](https://docs.singlestore.com/managed-service/en/reference/sql-reference/vector-functions.html). Our vector database subsystem, first made available in 2017 and subsequently enhanced, allows extremely fast nearest-neighbor search to find objects that are semantically similar, easily using SQL.

SingleStoreDB supports vectors and vector similarity search using dot_product (for cosine similarity) and euclidean_distance functions. These functions are used by our customers for applications including face recognition, visual product photo search and text-based semantic search. With the explosion of generative AI technology, these capabilities form a firm foundation for text-based AI chatbots.

But remember, SingleStoreDB is a high-performance, scalable, modern SQL DBMS that supports multiple data models including structured data, semi-structured data based on JSON, time-series, full text, spatial, key-value and of course vector data. Start powering your next intelligent application with SingleStoreDB today!

![SingleStore Open AI](https://user-images.githubusercontent.com/8846480/236985121-48980956-fdc5-49c8-b006-f3a412142676.png)

## Example

This folder contains examples of using SingleStoreDB and OpenAI together. We will keep adding more scenarios so stay tuned!

| Name | Description |
| --- | --- |
| [OpenAI wikipedia semantic search](./OpenAI_wikipedia_semantic_search.ipynb) | Improve ChatGPT accuracy through SingleStoreDB semantic Search in QA |
