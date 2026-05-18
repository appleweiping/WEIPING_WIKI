---
title: "Question Answering Using A Search Api"
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
  - https://developers.openai.com/cookbook/examples/question_answering_using_a_search_api
  - https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_a_search_API.ipynb
---

# Question Answering Using A Search Api

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/question_answering_using_a_search_api
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_a_search_API.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Question_answering_using_a_search_API.ipynb
- Source path: `examples/Question_answering_using_a_search_API.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `ef5b052d05762fba75c98daee6ee209a762d9c3cacbd98580b21796fc30a225d`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Question answering using a search API and re-ranking Searching for relevant information can sometimes feel like looking for a needle in a haystack, but don’t despair, GPTs can actually do a lot of this work for us. In this guide we explore a way to augment existing search systems with various AI techniques, helping us sift through the noise. Two ways of retr...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Question answering using a search API and re-ranking

Searching for relevant information can sometimes feel like looking for a needle in a haystack, but don’t despair, GPTs can actually do a lot of this work for us. In this guide we explore a way to augment existing search systems with various AI techniques, helping us sift through the noise.

Two ways of retrieving information for GPT are:

1. **Mimicking Human Browsing:** [GPT triggers a search](https://openai.com/blog/chatgpt-plugins#browsing), evaluates the results, and modifies the search query if necessary. It can also follow up on specific search results to form a chain of thought, much like a human user would do.
2. **Retrieval with Embeddings:** Calculate [embeddings](https://platform.openai.com/docs/guides/embeddings) for your content and a user query, and then [retrieve the content](Question_answering_using_embeddings.ipynb) most related as measured by cosine similarity. This technique is [used heavily](https://blog.google/products/search/search-language-understanding-bert/) by search engines like Google.

These approaches are both promising, but each has their shortcomings: the first one can be slow due to its iterative nature and the second one requires embedding your entire knowledge base in advance, continuously embedding new content and maintaining a vector database.

By combining these approaches, and drawing inspiration from [re-ranking](https://www.sbert.net/examples/applications/retrieve_rerank/README.html) methods, we identify an approach that sits in the middle. **This approach can be implemented on top of any existing search system, like the Slack search API, or an internal ElasticSearch instance with private data**. Here’s how it works:

![search_augmented_by_query_generation_and_embeddings_reranking.png](../images/search_rerank_answer.png)

**Step 1: Search**

1.  User asks a question.
2.  GPT generates a list of potential queries.
3.  Search queries are executed in parallel.

**Step 2: Re-rank**

1.  Embeddings for each result are used to calculate semantic similarity to a generated hypothetical ideal answer to the user question.
2.  Results are ranked and filtered based on this similarity metric.

**Step 3: Answer**

1.  Given the top search results, the model generates an answer to the user’s question, including references and links.

This hybrid approach offers relatively low latency and can be integrated into any existing search endpoint, without requiring the upkeep of a vector database. Let's dive into it! We will use the [News API](https://newsapi.org/) as an example domain to search over.

## Setup

In addition to your `OPENAI_API_KEY`, you'll have to include a `NEWS_API_KEY` in your environment. You can get an API key [here](https://newsapi.org/).

```python
%%capture
%env NEWS_API_KEY = YOUR_NEWS_API_KEY
```

```python
# Dependencies
from datetime import date, timedelta  # date handling for fetching recent news
from IPython import display  # for pretty printing
import json  # for parsing the JSON api responses and model outputs
from numpy import dot  # for cosine similarity
from openai import OpenAI
import os  # for loading environment variables
import requests  # for making the API requests
from tqdm.notebook import tqdm  # for printing progress bars

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))

# Load environment variables
news_api_key = os.getenv("NEWS_API_KEY")

GPT_MODEL = "gpt-3.5-turbo"


# Helper functions
def json_gpt(input: str):
    completion = client.chat.completions.create(model=GPT_MODEL,
    messages=[
        {"role": "system", "content": "Output only valid JSON"},
        {"role": "user", "content": input},
    ],
    temperature=0.5)

    text = completion.choices[0].message.content
    parsed = json.loads(text)

    return parsed


def embeddings(input: list[str]) -> list[list[str&#93;&#93;:
    response = client.embeddings.create(model="text-embedding-3-small", input=input)
    return [data.embedding for data in response.data]
```

## 1. Search

It all starts with a user question.

```python
# User asks a question
USER_QUESTION = "Who won the NBA championship? And who was the MVP? Tell me a bit about the last game."
```

Now, in order to be as exhaustive as possible, we use the model to generate a list of diverse queries based on this question.

```python
QUERIES_INPUT = f"""
You have access to a search API that returns recent news articles.
Generate an array of search queries that are relevant to this question.
Use a variation of related keywords for the queries, trying to be as general as possible.
Include as many queries as you can think of, including and excluding terms.
For example, include queries like ['keyword_1 keyword_2', 'keyword_1', 'keyword_2'].
Be creative. The more queries you include, the more likely you are to find relevant results.

User question: {USER_QUESTION}

Format: {{"queries": ["query_1", "query_2", "query_3"]}}
"""

queries = json_gpt(QUERIES_INPUT)["queries"]

# Let's include the original question as well for good measure
queries.append(USER_QUESTION)

queries
```

The queries look good, so let's run the searches.

```python
def search_news(
    query: str,
    news_api_key: str = news_api_key,
    num_articles: int = 50,
    from_datetime: str = "2023-06-01",  # the 2023 NBA finals were played in June 2023
    to_datetime: str = "2023-06-30",
) -> dict:
    response = requests.get(
        "https://newsapi.org/v2/everything",
        params={
            "q": query,
            "apiKey": news_api_key,
            "pageSize": num_articles,
            "sortBy": "relevancy",
            "from": from_datetime,
            "to": to_datetime,
        },
    )

    return response.json()


articles = []

for query in tqdm(queries):
    result = search_news(query)
    if result["status"] == "ok":
        articles = articles + result["articles"]
    else:
        raise Exception(result["message"])

# remove duplicates
articles = list({article["url"]: article for article in articles}.values())

print("Total number of articles:", len(articles))
print("Top 5 articles of query 1:", "\n")

for article in articles[0:5]:
    print("Title:", article["title"])
    print("Description:", article["description"])
    print("Content:", article["content"][0:100] + "...")
    print()
```

As we can see, oftentimes, the search queries will return a large number of results, many of which are not relevant to the original question asked by the user. In order to improve the quality of the final answer, we use embeddings to re-rank and filter the results.

## 2. Re-rank

Drawing inspiration from [HyDE (Gao et al.)](https://arxiv.org/abs/2212.10496), we first generate a hypothetical ideal answer to rerank our compare our results against. This helps prioritize results that look like good answers, rather than those similar to our question. Here’s the prompt we use to generate our hypothetical answer.

```python
HA_INPUT = f"""
Generate a hypothetical answer to the user's question. This answer will be used to rank search results.
Pretend you have all the information you need to answer, but don't use any actual facts. Instead, use placeholders
like NAME did something, or NAME said something at PLACE.

User question: {USER_QUESTION}

Format: {{"hypotheticalAnswer": "hypothetical answer text"}}
"""

hypothetical_answer = json_gpt(HA_INPUT)["hypotheticalAnswer"]

hypothetical_answer
```

Now, let's generate embeddings for the search results and the hypothetical answer. We then calculate the cosine distance between these embeddings, giving us a semantic similarity metric. Note that we can simply calculate the dot product in lieu of doing a full cosine similarity calculation since the OpenAI embeddings are returned normalized in our API.

```python
hypothetical_answer_embedding = embeddings(hypothetical_answer)[0]
article_embeddings = embeddings(
    [
        f"{article['title']} {article['description']} {article['content'][0:100]}"
        for article in articles
    ]
)

# Calculate cosine similarity
cosine_similarities = []
for article_embedding in article_embeddings:
    cosine_similarities.append(dot(hypothetical_answer_embedding, article_embedding))

cosine_similarities[0:10]
```

Finally, we use these similarity scores to sort and filter the results.

```python
scored_articles = zip(articles, cosine_similarities)

# Sort articles by cosine similarity
sorted_articles = sorted(scored_articles, key=lambda x: x[1], reverse=True)

# Print top 5 articles
print("Top 5 articles:", "\n")

for article, score in sorted_articles[0:5]:
    print("Title:", article["title"])
    print("Description:", article["description"])
    print("Content:", article["content"][0:100] + "...")
    print("Score:", score)
    print()
```

Awesome! These results look a lot more relevant to our original query. Now, let's use the top 5 results to generate a final answer.

## 3. Answer

```python
formatted_top_results = [
    {
        "title": article["title"],
        "description": article["description"],
        "url": article["url"],
    }
    for article, _score in sorted_articles[0:5]
]

ANSWER_INPUT = f"""
Generate an answer to the user's question based on the given search results.
TOP_RESULTS: {formatted_top_results}
USER_QUESTION: {USER_QUESTION}

Include as much information as possible in the answer. Reference the relevant search result urls as markdown links.
"""

completion = client.chat.completions.create(
    model=GPT_MODEL,
    messages=[{"role": "user", "content": ANSWER_INPUT}],
    temperature=0.5,
    stream=True,
)

text = ""
for chunk in completion:
    text += chunk.choices[0].delta.content
    display.clear_output(wait=True)
    display.display(display.Markdown(text))
```
