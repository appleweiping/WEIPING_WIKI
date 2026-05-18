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
  - https://developers.openai.com/cookbook/examples/vector_databases/supabase/readme
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/supabase/README.md
---

# Readme

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/supabase/readme
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/supabase/README.md
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/supabase/README.md
- Source path: `examples/vector_databases/supabase/README.md`
- Source kind: `examples`
- Source format: `.md`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `5cffac60cb5a7a849fcd735d5dbc794ec9885c4dd583532c08e7fb22e5aed7e8`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Supabase Vector Database Supabase is an open-source Firebase alternative built on top of Postgres, a production-grade SQL database. Supabase Vector is a vector toolkit built on pgvector, a Postgres extension that allows you to store your embeddings inside the same database that holds the rest of your application data. When combined with pgvector's indexing a...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Supabase Vector Database

[Supabase](https://supabase.com/docs) is an open-source Firebase alternative built on top of [Postgres](https://en.wikipedia.org/wiki/PostgreSQL), a production-grade SQL database.

[Supabase Vector](https://supabase.com/docs/guides/ai) is a vector toolkit built on [pgvector](https://github.com/pgvector/pgvector), a Postgres extension that allows you to store your embeddings inside the same database that holds the rest of your application data. When combined with pgvector's indexing algorithms, vector search remains [fast at large scales](https://supabase.com/blog/increase-performance-pgvector-hnsw).

Supabase adds an ecosystem of services and tools on top of Postgres that makes app development as quick as possible, including:

- [Auto-generated REST APIs](https://supabase.com/docs/guides/api)
- [Auto-generated GraphQL APIs](https://supabase.com/docs/guides/graphql)
- [Realtime APIs](https://supabase.com/docs/guides/realtime)
- [Authentication](https://supabase.com/docs/guides/auth)
- [File storage](https://supabase.com/docs/guides/storage)
- [Edge functions](https://supabase.com/docs/guides/functions)

We can use these services alongside pgvector to store and query embeddings within Postgres.

## OpenAI Cookbook Examples

Below are guides and resources that walk you through how to use OpenAI embedding models with Supabase Vector.

| Guide                                    | Description                                                |
| ---------------------------------------- | ---------------------------------------------------------- |
| [Semantic search](./semantic-search.mdx) | Store, index, and query embeddings at scale using pgvector |

## Additional resources

- [Vector columns](https://supabase.com/docs/guides/ai/vector-columns)
- [Vector indexes](https://supabase.com/docs/guides/ai/vector-indexes)
- [RAG with permissions](https://supabase.com/docs/guides/ai/rag-with-permissions)
- [Going to production](https://supabase.com/docs/guides/ai/going-to-prod)
- [Deciding on compute](https://supabase.com/docs/guides/ai/choosing-compute-addon)
