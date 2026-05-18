---
title: "Financial Document Analysis With Llamaindex"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - integration
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/third_party/financial_document_analysis_with_llamaindex
  - https://github.com/openai/openai-cookbook/blob/main/examples/third_party/financial_document_analysis_with_llamaindex.ipynb
---

# Financial Document Analysis With Llamaindex

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/third_party/financial_document_analysis_with_llamaindex
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/third_party/financial_document_analysis_with_llamaindex.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/third_party/financial_document_analysis_with_llamaindex.ipynb
- Source path: `examples/third_party/financial_document_analysis_with_llamaindex.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `6683f7e9dc26085c591be6138d6487d10a94c1c6a147424c8182fa4318ca6ad0`

## Classification

- Primary category: Third-party integrations
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Financial Document Analysis with LlamaIndex In this example notebook, we showcase how to perform financial analysis over 10-K documents with the LlamaIndex framework with just a few lines of code. Notebook Outline Introduction Setup Data Loading & Indexing Simple QA Advanced QA - Compare and Contrast Introduction LLamaIndex LlamaIndex is a data framework for...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: Third-party integrations.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Financial Document Analysis with LlamaIndex

In this example notebook, we showcase how to perform financial analysis over [**10-K**](https://en.wikipedia.org/wiki/Form_10-K) documents with the [**LlamaIndex**](https://gpt-index.readthedocs.io/en/latest/) framework with just a few lines of code.

## Notebook Outline
* [Introduction](#Introduction)
* [Setup](#Setup)
* [Data Loading & Indexing](#Data-Loading-and-Indexing)
* [Simple QA](#Simple-QA)
* [Advanced QA - Compare and Contrast](#Advanced-QA---Compare-and-Contrast)

## Introduction

### LLamaIndex
[LlamaIndex](https://gpt-index.readthedocs.io/en/latest/) is a data framework for LLM applications.
You can get started with just a few lines of code and build a retrieval-augmented generation (RAG) system in minutes.
For more advanced users, LlamaIndex offers a rich toolkit for ingesting and indexing your data, modules for retrieval and re-ranking, and composable components for building custom query engines.

See [full documentation](https://gpt-index.readthedocs.io/en/latest/) for more details.

### Financial Analysis over 10-K documents
A key part of a financial analyst's job is to extract information and synthesize insight from long financial documents.
A great example is the 10-K form - an annual report required by the U.S. Securities and Exchange Commission (SEC), that gives a comprehensive summary of a company's financial performance.
These documents typically run hundred of pages in length, and contain domain-specific terminology that makes it challenging for a layperson to digest quickly.


We showcase how LlamaIndex can support a financial analyst in quickly extracting information and synthesize insights **across multiple documents** with very little coding.

## Setup

To begin, we need to install the llama-index library

```python
!pip install llama-index pypdf
```

Now, we import all modules used in this tutorial

```python
from langchain import OpenAI

from llama_index import SimpleDirectoryReader, ServiceContext, VectorStoreIndex
from llama_index import set_global_service_context
from llama_index.response.pprint_utils import pprint_response
from llama_index.tools import QueryEngineTool, ToolMetadata
from llama_index.query_engine import SubQuestionQueryEngine
```

Before we start, we can configure the LLM provider and model that will power our RAG system.
Here, we pick `gpt-3.5-turbo-instruct` from OpenAI.

```python
llm = OpenAI(temperature=0, model_name="gpt-3.5-turbo-instruct", max_tokens=-1)
```

We construct a `ServiceContext` and set it as the global default, so all subsequent operations that depends on LLM calls will use the model we configured here.

```python
service_context = ServiceContext.from_defaults(llm=llm)
set_global_service_context(service_context=service_context)
```

## Data Loading and Indexing

Now, we load and parse 2 PDFs (one for Uber 10-K in 2021 and another for Lyft 10-k in 2021).
Under the hood, the PDFs are converted to plain text `Document` objects, separate by page.

> Note: this operation might take a while to run, since each document is more than 100 pages.

```python
lyft_docs = SimpleDirectoryReader(input_files=["../data/10k/lyft_2021.pdf"]).load_data()
uber_docs = SimpleDirectoryReader(input_files=["../data/10k/uber_2021.pdf"]).load_data()
```

```python
print(f'Loaded lyft 10-K with {len(lyft_docs)} pages')
print(f'Loaded Uber 10-K with {len(uber_docs)} pages')
```

Now, we can build an (in-memory) `VectorStoreIndex` over the documents that we've loaded.

> Note: this operation might take a while to run, since it calls OpenAI API for computing vector embedding over document chunks.

```python
lyft_index = VectorStoreIndex.from_documents(lyft_docs)
uber_index = VectorStoreIndex.from_documents(uber_docs)
```

## Simple QA

Now we are ready to run some queries against our indices!
To do so, we first configure a `QueryEngine`, which just captures a set of configurations for how we want to query the underlying index.

For a `VectorStoreIndex`, the most common configuration to adjust is `similarity_top_k` which controls how many document chunks (which we call `Node` objects) are retrieved to use as context for answering our question.

```python
lyft_engine = lyft_index.as_query_engine(similarity_top_k=3)
```

```python
uber_engine = uber_index.as_query_engine(similarity_top_k=3)
```

Let's see some queries in action!

```python
response = await lyft_engine.aquery('What is the revenue of Lyft in 2021? Answer in millions with page reference')
```

```python
print(response)
```

```python
response = await uber_engine.aquery('What is the revenue of Uber in 2021? Answer in millions, with page reference')
```

```python
print(response)
```

## Advanced QA - Compare and Contrast

For more complex financial analysis, one often needs to reference multiple documents.

As a example, let's take a look at how to do compare-and-contrast queries over both Lyft and Uber financials.
For this, we build a `SubQuestionQueryEngine`, which breaks down a complex compare-and-contrast query, into simpler sub-questions to execute on respective sub query engine backed by individual indices.

```python
query_engine_tools = [
    QueryEngineTool(
        query_engine=lyft_engine,
        metadata=ToolMetadata(name='lyft_10k', description='Provides information about Lyft financials for year 2021')
    ),
    QueryEngineTool(
        query_engine=uber_engine,
        metadata=ToolMetadata(name='uber_10k', description='Provides information about Uber financials for year 2021')
    ),
]

s_engine = SubQuestionQueryEngine.from_defaults(query_engine_tools=query_engine_tools)
```

Let's see these queries in action!

```python
response = await s_engine.aquery('Compare and contrast the customer segments and geographies that grew the fastest')
```

```python
print(response)
```

```python
response = await s_engine.aquery('Compare revenue growth of Uber and Lyft from 2020 to 2021')
```

```python
print(response)
```
