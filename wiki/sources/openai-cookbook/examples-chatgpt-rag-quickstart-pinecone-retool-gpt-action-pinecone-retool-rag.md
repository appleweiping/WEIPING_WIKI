---
title: "Gpt Action Pinecone Retool Rag"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - chatgpt
  - cookbook
  - example
  - gpt-actions
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/chatgpt/rag-quickstart/pinecone-retool/gpt-action-pinecone-retool-rag
  - https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/rag-quickstart/pinecone-retool/gpt-action-pinecone-retool-rag.ipynb
---

# Gpt Action Pinecone Retool Rag

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/chatgpt/rag-quickstart/pinecone-retool/gpt-action-pinecone-retool-rag
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/rag-quickstart/pinecone-retool/gpt-action-pinecone-retool-rag.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/chatgpt/rag-quickstart/pinecone-retool/gpt-action-pinecone-retool-rag.ipynb
- Source path: `examples/chatgpt/rag-quickstart/pinecone-retool/gpt-action-pinecone-retool-rag.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `139ebbfc66a3e3cc920185d49c1f718ccc1f826cc849985caa6d05a92d5d1935`

## Classification

- Primary category: ChatGPT / GPT Actions
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

This notebook provides a step-by-step guide for using Pinecone as a vector database to store OpenAI embeddings. As an example, it demonstrates how to integrate this setup with Retool to create a REST endpoint, enabling seamless interaction with ChatGPT as an action. However, Retool is just one of many approaches available for connecting your Pinecone databas...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.
- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

This notebook provides a step-by-step guide for using Pinecone as a vector database to store OpenAI embeddings. As an example, it demonstrates how to integrate this setup with Retool to create a REST endpoint, enabling seamless interaction with ChatGPT as an action. However, Retool is just one of many approaches available for connecting your Pinecone database to ChatGPT.

[Pinecone](https://www.pinecone.io/) is a fully managed vector database designed for storing, indexing, and querying large-scale vector embeddings. It enables fast and efficient similarity searches, making it ideal for AI-powered applications like recommendation systems, semantic search, and natural language processing.

[Retool](https://retool.com/) is a low-code platform that simplifies building custom internal tools by connecting to databases, APIs, and third-party services. It enables users to create powerful, user-friendly interfaces and workflows with minimal coding, making it ideal for streamlining business operations and integrating complex systems.


## Pre-requisites

- A Pinecone account
- A Retool account
- A Custom GPT with actions enabled
- An OpenAI API key


## Table of Contents

1. [Setup Pinecone](#setup-pinecone)
2. [Setup Noteboook](#setup-notebook)
3. [Prepare Data](#prepare-data)
4. [Create a Pinecone Index](#create-a-pinecone-index)
5. [Populate the Pinecone Index](#populate-the-pinecone-index)
4. [Create a Retool Workflow](#create-a-retool-app)
5. [Create a Custom GPT Action](#create-a-custom-gpt-action)


## Setup Pinecone

If you haven't got a Pinecone account, sign up for an account. You're ready to move on to the next section once you get the following screen. Go to API Keys and create a new API key.


![Vectors in Pinecone](../../../../images/pinecone-dashboard.png)


## Setup Notebook

Install required libraries from OpenAI and Pinecone.

```python
!pip install -qU openai pinecone
```

Import the OpenAI and Pinecone libraries.

```python

from pinecone.grpc import PineconeGRPC as Pinecone
from pinecone import ServerlessSpec
from openai import OpenAI
client = OpenAI()

pc = Pinecone(api_key="YOUR API KEY")
## OpenAI key by default is set to the environment variable `OPENAI_API_KEY`
```

## Prepare Data

Define a sample dataset to embed store in Pinecone and to search over from ChatGPT.

```python
data = [
    {"id": "vec1", "text": "OpenAI is a leading AI research organization focused on advancing artificial intelligence."},
    {"id": "vec2", "text": "The ChatGPT platform is renowned for its natural language processing capabilities."},
    {"id": "vec3", "text": "Many users leverage ChatGPT for tasks like creative writing, coding assistance, and customer support."},
    {"id": "vec4", "text": "OpenAI has revolutionized AI development with innovations like GPT-4 and its user-friendly APIs."},
    {"id": "vec5", "text": "ChatGPT makes AI-powered conversations accessible to millions, enhancing productivity and creativity."},
    {"id": "vec6", "text": "OpenAI was founded in December 2015 as an organization dedicated to advancing digital intelligence for the benefit of humanity."}
]
```

We are now ready to convert the text to embeddings. The example below is the most simple implementation of this function. If your text is longer than the context window of the model you are using, you will need to chunk the text into smaller pieces.

```python
def embed(text):
    text = text.replace("\n", " ")  # Ensure text doesn't have newlines
    res = client.embeddings.create(input=[text], model="text-embedding-3-large")

    return res.data[0].embedding

doc_embeds = [embed(d["text"]) for d in data]

print(doc_embeds)
```

## Create a Pinecone Index

The next step is to create a Pinecone index, we'll do this programmatically, alternatively you can do this from the Pinecone dashboard.

```python
def create_index():
    index_name = "openai-cookbook-pinecone-retool"

    if not pc.has_index(index_name):
        pc.create_index(
            name=index_name,
            dimension=3072,
            metric="cosine",
            spec=ServerlessSpec(
                cloud='aws',
                region='us-east-1'
            )
        )

    return pc.Index(index_name)

index = create_index()
```

## Populate the Pinecone Index

Now that we've created the index, we can populate it with our embeddings. Before we do this we need to append the ID to the embeddings along with the raw text, this is so we can retrieve the original text when we query the index.

When upserting vectors we choose a namespace, this is optional but can be useful if you want to store multiple datasets in the same index as it allows you to partition the data. For example if you needed to store a dataset of customer support queries and a dataset of product descriptions you could create two namespaces and query over each one separately.

```python
def append_vectors(data, doc_embeds):
    vectors = []
    for d, e in zip(data, doc_embeds):
        vectors.append({
            "id": d['id'],
            "values": e,
            "metadata": {'text': d['text']}
        })

    return vectors

vectors = append_vectors(data, doc_embeds)
```

```python
index.upsert(
    vectors=vectors,
    namespace="ns1"
)
```

You should now see the vectors in the Pinecone Dashboard.

![Vectors in Pinecone](../../../../images/pinecone-dashboard-2.png)

The vectors should now be visible in the Pincone Dashbaord.

To test the search functionality we can query the index. Below we are taking a sample question, running this through the same embedding function and then checking the index for matching vectors.

`top_k` refers to the number of results we want to return.
`include_values` and `include_metadata` are used to return the embeddings and original text of the results.

```python
query = "When was OpenAI founded?"

x = embed(query)

results = index.query(
    namespace="ns1",
    vector=x,
    top_k=1,
    include_values=False,
    include_metadata=True
)

print(results)
```

## Create a Retool Workflow

Now we have a working vector database, we can create a Retool workflow to connect to it to run our queries from ChatGPT.

Open Retool and create a new workflow.

<img src="../../../../images/retool-new-workflow.png" alt="Create Retool Workflowt" width="500"/>

You should now see the following screen.

![Retool Workflow 2](../../../../images/retool-workflow-1.png)

In this example we'll be using Python to query the Pinecone index. To do this we'll need to import the `pinecone` and `openai` library. First switch to Python.

<!--ARCADE EMBED START--><div style="position: relative; padding-bottom: calc(55.43981481481482% + 41px); height: 0; width: 100%;"><iframe src="https://demo.arcade.software/DnaN9MnRjDaBL9HWKabX?embed&embed_mobile=inline&embed_desktop=inline&show_copy_link=true" title="Cookbook - Retool Libraries" frameborder="0" loading="lazy" webkitallowfullscreen mozallowfullscreen allowfullscreen allow="clipboard-write" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; color-scheme: light;" ></iframe></div><!--ARCADE EMBED END-->

We are now ready to add our code to the code block.

Start by declaring the libraries we just imported to this workflow.

```python
from pinecone import Pinecone
from openai import OpenAI
```

We now need to set the API keys for Pinecone and OpenAI. You can put these directly in the code block or use [Retool Configuration Variables](https://docs.retool.com/org-users/guides/config-vars). Configuration variables are recommended as they are more secure, this shown below.

```python
client = OpenAI(api_key=retoolContext.configVars.openai_api_key)
pc = Pinecone(api_key=retoolContext.configVars.pinecone_api_key)
```

We can then reuse our OpenAI Embedding and Pinecone query functions from above in the Retool code snippet and return the results. Below is the completed code block.

```startTrigger.data.query``` is a variable passed in from the start trigger of the workflow. This is where the user query from ChatGPT will be passed in.

```python
from pinecone import Pinecone
from openai import OpenAI

client = OpenAI(api_key=retoolContext.configVars.openai_api_key)
pc = Pinecone(api_key=retoolContext.configVars.pinecone_api_key)
index = pc.Index("openai-cookbook-pinecone-retool")


def embed(query):
    res = client.embeddings.create(
        input=query,
        model="text-embedding-3-large"
    )
    doc_embeds = [r.embedding for r in res.data]
    return doc_embeds

x = embed([startTrigger.data.query])

results = index.query(
    namespace="ns1",
    vector=x[0],
    top_k=2,
    include_values=False,
    include_metadata=True
)

return results.to_dict()['matches']
```

This should look like this in the UI. You can test this by clicking the run button at the top of the code block. You should see the results returned in the Data section at the bottom of the code block.

![Retool Workflow 3](../../../../images/retool-workflow-2.png)

We now have a workflow with a start trigger that will take a user query pass this to our Vector_Search code block. This will return the top 2 results from the Pinecone index. Next we need to add a block that will take these results and respond to the start trigger request.


<!--ARCADE EMBED START--><div style="position: relative; padding-bottom: calc(55.43981481481482% + 41px); height: 0; width: 100%;"><iframe src="https://demo.arcade.software/6lyRo3PP2iWq814KvY1f?embed&embed_mobile=tab&embed_desktop=inline&show_copy_link=true" title="Cookbook - Retool Return" frameborder="0" loading="lazy" webkitallowfullscreen mozallowfullscreen allowfullscreen allow="clipboard-write" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; color-scheme: light;" ></iframe></div><!--ARCADE EMBED END-->

Finally we need to configure the start trigger to support calling via API to allow it to be used as a ChatGPT action.

Go to Triggers, and toggle the switch to enable the Webhook. Click on the Webhook to open the configuration screen. We can optionally add an Alias to better describe what this webhook will trigger. In this case we'll call it `vector_search`. This provides a more identifiable name in the URL. When complete click Save Changes.

![Retool Workflow 4](../../../../images/retool-workflow-3.png)

The final step is to deploy this workflow. Click the Deploy button at the top of the screen. The workflow is now accessible via API. You can test this by clicking the copy button next to the Alias URL, choosing Copy as cURL and then running this in the terminal.

<img src="../../../../images/retool-workflow-4.png" alt="Retool Workflow 5" width="400"/>

## Create a Custom GPT Action

We now have a working Vector Database, and a way of querying this over API through the Retool Workflow. The next step is to connect the Retool Workflow to ChatGPT via an action.

Go to you GPT, and create a new action. Below is an example of the OpenAPI spec required to connect to the Retool Workflow. You will need to replace the URL and API key with your own.

```openapi
openapi: 3.1.0
info:
  title: Vector Search API
  description: An API for performing vector-based search queries.
  version: 1.0.0
servers:
  - url: YOUR_URL_HERE
    description: Sandbox server for the Vector Search API
paths:
  /url/vector-search:
    post:
      operationId: performVectorSearch
      summary: Perform a vector-based search query.
      description: Sends a query to the vector search API and retrieves results.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                query:
                  type: string
                  description: The search query.
              required:
                - query
      responses:
        '200':
          description: Successful response containing search results.
        '400':
          description: Bad Request. The input data is invalid.
        '500':
          description: Internal Server Error. Something went wrong on the server side.
```

Under the Authentication section set the auth method to API Key. Paste in your API from the Retool Workflow trigger settings. Then set Auth Type to Custom and set the Custom Header Name to ```X-Workflow-Api-Key```

<img src="../../../../images/chatgpt-auth-config.png" alt="ChatGPT Auth Config" width="400"/>


Your setup is now complete. You can test this by sending a message to your GPT asking for information from the vector database.

<img src="../../../../images/gpt-rag-result.png" alt="GPT RAG Result" width="600"/>
