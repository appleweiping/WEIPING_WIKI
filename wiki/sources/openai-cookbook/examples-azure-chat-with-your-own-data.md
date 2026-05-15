---
title: "Chat With Your Own Data"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - integration
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/azure/chat_with_your_own_data
  - https://github.com/openai/openai-cookbook/blob/main/examples/azure/chat_with_your_own_data.ipynb
---

# Chat With Your Own Data

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/azure/chat_with_your_own_data
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/azure/chat_with_your_own_data.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/azure/chat_with_your_own_data.ipynb
- Source path: `examples/azure/chat_with_your_own_data.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `9fe673a5736d13a8e088d01bc568e03875b604a15a9e29b444ea91e72d57bcef`

## Classification

- Primary category: Third-party integrations
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Azure chat completion models with your own data (preview) This example shows how to use Azure OpenAI service models with your own data. The feature is currently in preview. Azure OpenAI on your data enables you to run supported chat models such as GPT-3.5-Turbo and GPT-4 on your data without needing to train or fine-tune models. Running models on your data e...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: Third-party integrations.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Azure chat completion models with your own data (preview)
This example shows how to use Azure OpenAI service models with your own data. The feature is currently in preview.

Azure OpenAI on your data enables you to run supported chat models such as GPT-3.5-Turbo and GPT-4 on your data without needing to train or fine-tune models. Running models on your data enables you to chat on top of, and analyze your data with greater accuracy and speed. One of the key benefits of Azure OpenAI on your data is its ability to tailor the content of conversational AI. Because the model has access to, and can reference specific sources to support its responses, answers are not only based on its pretrained knowledge but also on the latest information available in the designated data source. This grounding data also helps the model avoid generating responses based on outdated or incorrect information.

Azure OpenAI on your own data with Azure AI Search (f.k.a. Azure Cognitive Search) provides a customizable, pre-built solution for knowledge retrieval, from which a conversational AI application can be built. To see alternative methods for knowledge retrieval and semantic search, check out the cookbook examples for [vector databases](https://github.com/openai/openai-cookbook/tree/main/examples/vector_databases).

## How it works

[Azure OpenAI on your own data](https://learn.microsoft.com/azure/ai-services/openai/concepts/use-your-data) connects the model with your data, giving it the ability to retrieve and utilize data in a way that enhances the model's output. Together with Azure AI Search, data is retrieved from designated data sources based on the user input and provided conversation history. The data is then augmented and resubmitted as a prompt to the model, giving the model contextual information it can use to generate a response.

See the [Data, privacy, and security for Azure OpenAI Service](https://learn.microsoft.com/legal/cognitive-services/openai/data-privacy?context=%2Fazure%2Fai-services%2Fopenai%2Fcontext%2Fcontext) for more information.

## Prerequisites
To get started, we'll cover a few prerequisites.

To properly access the Azure OpenAI Service, we need to create the proper resources at the [Azure Portal](https://portal.azure.com) (you can check a detailed guide on how to do this in the [Microsoft Docs](https://learn.microsoft.com/azure/cognitive-services/openai/how-to/create-resource?pivots=web-portal))

To use your own data with Azure OpenAI models, you will need:

1. Azure OpenAI access and a resource with a chat model deployed (for example, GPT-3 or GPT-4)
2. Azure AI Search (f.k.a. Azure Cognitive Search) resource
3. Azure Blob Storage resource
4. Your documents to be used as data (See [data source options](https://learn.microsoft.com/azure/ai-services/openai/concepts/use-your-data#data-source-options))


For a full walk-through on how to upload your documents to blob storage and create an index using the Azure AI Studio, see this [Quickstart](https://learn.microsoft.com/azure/ai-services/openai/use-your-data-quickstart?pivots=programming-language-studio&tabs=command-line).

## Setup

First, we install the necessary dependencies.

```python
! pip install "openai>=1.0.0,<2.0.0"
! pip install python-dotenv
```

In this example, we'll use `dotenv` to load our environment variables. To connect with Azure OpenAI and the Search index, the following variables should be added to a `.env` file in `KEY=VALUE` format:

* `AZURE_OPENAI_ENDPOINT` - the Azure OpenAI endpoint. This can be found under "Keys and Endpoints" for your Azure OpenAI resource in the Azure Portal.
* `AZURE_OPENAI_API_KEY` - the Azure OpenAI API key. This can be found under "Keys and Endpoints" for your Azure OpenAI resource in the Azure Portal. Omit if using Azure Active Directory authentication (see below `Authentication using Microsoft Active Directory`)
* `SEARCH_ENDPOINT` - the AI Search endpoint. This URL be found on the "Overview" of your Search resource on the Azure Portal.
* `SEARCH_KEY` - the AI Search API key. Found under "Keys" for your Search resource in the Azure Portal.
* `SEARCH_INDEX_NAME` - the name of the index you created with your own data.

```python
import os
import openai
import dotenv

dotenv.load_dotenv()
```

### Authentication

The Azure OpenAI service supports multiple authentication mechanisms that include API keys and Azure Active Directory token credentials.

```python
use_azure_active_directory = False  # Set this flag to True if you are using Azure Active Directory
```

#### Authentication using API key

To set up the OpenAI SDK to use an *Azure API Key*, we need to set `api_key` to a key associated with your endpoint (you can find this key in *"Keys and Endpoints"* under *"Resource Management"* in the [Azure Portal](https://portal.azure.com)). You'll also find the endpoint for your resource here.

```python
if not use_azure_active_directory:
    endpoint = os.environ["AZURE_OPENAI_ENDPOINT"]
    api_key = os.environ["AZURE_OPENAI_API_KEY"]
    # set the deployment name for the model we want to use
    deployment = "<deployment-id-of-the-model-to-use>"

    client = openai.AzureOpenAI(
        base_url=f"{endpoint}/openai/deployments/{deployment}/extensions",
        api_key=api_key,
        api_version="2023-09-01-preview"
    )
```

#### Authentication using Azure Active Directory
Let's now see how we can authenticate via Azure Active Directory. We'll start by installing the `azure-identity` library. This library will provide the token credentials we need to authenticate and help us build a token credential provider through the `get_bearer_token_provider` helper function. It's recommended to use `get_bearer_token_provider` over providing a static token to `AzureOpenAI` because this API will automatically cache and refresh tokens for you.

For more information on how to set up Azure Active Directory authentication with Azure OpenAI, see the [documentation](https://learn.microsoft.com/azure/ai-services/openai/how-to/managed-identity).

```python
! pip install "azure-identity>=1.15.0"
```

```python
from azure.identity import DefaultAzureCredential, get_bearer_token_provider

if use_azure_active_directory:
    endpoint = os.environ["AZURE_OPENAI_ENDPOINT"]
    api_key = os.environ["AZURE_OPENAI_API_KEY"]
    # set the deployment name for the model we want to use
    deployment = "<deployment-id-of-the-model-to-use>"

    client = openai.AzureOpenAI(
        base_url=f"{endpoint}/openai/deployments/{deployment}/extensions",
        azure_ad_token_provider=get_bearer_token_provider(DefaultAzureCredential(), "https://cognitiveservices.azure.com/.default"),
        api_version="2023-09-01-preview"
    )
```

> Note: the AzureOpenAI infers the following arguments from their corresponding environment variables if they are not provided:

- `api_key` from `AZURE_OPENAI_API_KEY`
- `azure_ad_token` from `AZURE_OPENAI_AD_TOKEN`
- `api_version` from `OPENAI_API_VERSION`
- `azure_endpoint` from `AZURE_OPENAI_ENDPOINT`

## Chat completion model with your own data

### Setting the context

In this example, we want our model to base its responses on Azure AI services documentation data. Following the [Quickstart](https://learn.microsoft.com/azure/ai-services/openai/use-your-data-quickstart?tabs=command-line&pivots=programming-language-studio) shared previously, we have added the [markdown](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/ai-services/cognitive-services-and-machine-learning.md) file for the [Azure AI services and machine learning](https://learn.microsoft.com/azure/ai-services/cognitive-services-and-machine-learning) documentation page to our search index. The model is now ready to answer questions about Azure AI services and machine learning.

### Code

Now we can use Azure on your own data with Chat Completions. Providing our search endpoint, key, and index name in `dataSources`, any questions posed to the model will now be grounded in our own data. An additional property, `context`, will be provided in the response to show the data the model referenced to answer the question.

```python
completion = client.chat.completions.create(
    messages=[{"role": "user", "content": "What are the differences between Azure Machine Learning and Azure AI services?"}],
    model=deployment,
    extra_body={
        "dataSources": [
            {
                "type": "AzureCognitiveSearch",
                "parameters": {
                    "endpoint": os.environ["SEARCH_ENDPOINT"],
                    "key": os.environ["SEARCH_KEY"],
                    "indexName": os.environ["SEARCH_INDEX_NAME"],
                }
            }
        ]
    }
)
print(f"{completion.choices[0].message.role}: {completion.choices[0].message.content}")

# `context` is in the model_extra for Azure
print(f"\nContext: {completion.choices[0].message.model_extra['context']['messages'][0]['content']}")
```

If you would prefer to stream the response from the model, you can pass the `stream=True` keyword argument:

```python
response = client.chat.completions.create(
    messages=[{"role": "user", "content": "What are the differences between Azure Machine Learning and Azure AI services?"}],
    model=deployment,
    extra_body={
        "dataSources": [
            {
                "type": "AzureCognitiveSearch",
                "parameters": {
                    "endpoint": os.environ["SEARCH_ENDPOINT"],
                    "key": os.environ["SEARCH_KEY"],
                    "indexName": os.environ["SEARCH_INDEX_NAME"],
                }
            }
        ]
    },
    stream=True,
)

for chunk in response:
    delta = chunk.choices[0].delta

    if delta.role:
        print("\n"+ delta.role + ": ", end="", flush=True)
    if delta.content:
        print(delta.content, end="", flush=True)
    if delta.model_extra.get("context"):
        print(f"Context: {delta.model_extra['context']}", end="", flush=True)
```
