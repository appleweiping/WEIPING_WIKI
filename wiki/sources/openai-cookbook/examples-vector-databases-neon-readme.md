---
title: "Readme"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - markdown-source
  - openai
  - rag
  - retrieval
source_pages:
  - https://developers.openai.com/cookbook/examples/vector_databases/neon/readme
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/neon/README.md
---

# Readme

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/neon/readme
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/neon/README.md
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/neon/README.md
- Source path: `examples/vector_databases/neon/README.md`
- Source kind: `examples`
- Source format: `.md`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `23a2c65c8f64920e774b975636bb97ed4c29b05a23f6234a91477bb710d84b36`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

What is Neon? Neon is Serverless Postgres built for the cloud. Neon separates compute and storage to offer modern developer features such as autoscaling, database branching, scale-to-zero, and more. Vector search Neon supports vector search using the pgvector open-source PostgreSQL extension, which enables Postgres as a vector database for storing and queryi...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# What is Neon?

[Neon](https://neon.tech/) is Serverless Postgres built for the cloud. Neon separates compute and storage to offer modern developer features such as autoscaling, database branching, scale-to-zero, and more.

## Vector search

Neon supports vector search using the [pgvector](https://neon.tech/docs/extensions/pgvector) open-source PostgreSQL extension, which enables Postgres as a vector database for storing and querying embeddings.

## OpenAI cookbook notebook

Check out the notebook in this repo for working with Neon Serverless Postgres as your vector database.

### Semantic search using Neon Postgres with pgvector and OpenAI

In this notebook you will learn how to:

1. Use embeddings created by OpenAI API
2. Store embeddings in a Neon Serverless Postgres database
3. Convert a raw text query to an embedding with OpenAI API
4. Use Neon with the `pgvector` extension to perform vector similarity search

## Scaling Support

Neon enables you to scale your AI applications with the following features:

- [Autoscaling](https://neon.tech/docs/introduction/read-replicas): If your AI application experiences heavy load during certain hours of the day or at different times, Neon can automatically scale compute resources without manual intervention. During periods of inactivity, Neon is able to scale to zero.
- [Instant read replicas](https://neon.tech/docs/introduction/read-replicas): Neon supports instant read replicas, which are independent read-only compute instances designed to perform read operations on the same data as your read-write computes. With read replicas, you can offload reads from your read-write compute instance to a dedicated read-only compute instance for your AI application.
- [The Neon serverless driver](https://neon.tech/docs/serverless/serverless-driver): Neon supports a low-latency serverless PostgreSQL driver for JavaScript and TypeScript applications that allows you to query data from serverless and edge environments, making it possible to achieve sub-10ms queries.

## More Examples

- [Build an AI-powered semantic search application](https://github.com/neondatabase/yc-idea-matcher) - Submit a startup idea and get a list of similar ideas that YCombinator has invested in before
- [Build an AI-powered chatbot](https://github.com/neondatabase/ask-neon) - A Postgres Q&A chatbot that uses Postgres as a vector database
- [Vercel Postgres pgvector Starter](https://vercel.com/templates/next.js/postgres-pgvector) - Vector similarity search with Vercel Postgres (powered by Neon)

## Additional Resources

- [Building AI applications with Neon](https://neon.tech/ai)
- [Neon AI & embeddings documentation](https://neon.tech/docs/ai/ai-intro)
- [Building an AI-powered Chatbot using Vercel, OpenAI, and Postgres](neon.tech/blog/building-an-ai-powered-chatbot-using-vercel-openai-and-postgres)
- [Web-based AI SQL Playground and connecting to Postgres from the browser](https://neon.tech/blog/postgres-ai-playground)
- [pgvector GitHub repository](https://github.com/pgvector/pgvector)
