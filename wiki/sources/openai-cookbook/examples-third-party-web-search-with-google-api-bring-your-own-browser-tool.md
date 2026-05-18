---
title: "Web Search With Google Api Bring Your Own Browser Tool"
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
  - https://developers.openai.com/cookbook/examples/third_party/web_search_with_google_api_bring_your_own_browser_tool
  - https://github.com/openai/openai-cookbook/blob/main/examples/third_party/Web_search_with_google_api_bring_your_own_browser_tool.ipynb
---

# Web Search With Google Api Bring Your Own Browser Tool

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/third_party/web_search_with_google_api_bring_your_own_browser_tool
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/third_party/Web_search_with_google_api_bring_your_own_browser_tool.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/third_party/Web_search_with_google_api_bring_your_own_browser_tool.ipynb
- Source path: `examples/third_party/Web_search_with_google_api_bring_your_own_browser_tool.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `e0c53cdb172e7570418be55088d815e3ce174792583459084647f1a39ebd8b27`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Building a Bring Your Own Browser (BYOB) Tool for Web Browsing and Summarization Disclaimer: This cookbook is for educational purposes only. Ensure that you comply with all applicable laws and service terms when using web search and scraping technologies. This cookbook will restrict the search to openai.com domain to retrieve the public information to illust...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.
- How to expose tools, APIs, schemas, or structured outputs to model workflows.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

## Building a Bring Your Own Browser (BYOB) Tool for Web Browsing and Summarization

**Disclaimer: This cookbook is for educational purposes only. Ensure that you comply with all applicable laws and service terms when using web search and scraping technologies. This cookbook will restrict the search to openai.com domain to retrieve the public information to illustrate the concepts.**

Large Language Models (LLMs) such as GPT-4o have a knowledge cutoff date, which means they lack information about events that occurred after that point. In scenarios where the most recent data is essential, it's necessary to provide LLMs with access to current web information to ensure accurate and relevant responses.

In this guide, we will build a Bring Your Own Browser (BYOB) tool using Python to overcome this limitation. Our goal is to create a system that provides up-to-date answers in your application, including the most recent developments such as the latest product launches by OpenAI. By integrating web search capabilities with an LLM, we'll enable the model to generate responses based on the latest information available online.

While you can use any publicly available search APIs, we'll utilize Google's Custom Search API to perform web searches. The retrieved information from the search results will be processed and passed to the LLM to generate the final response through Retrieval-Augmented Generation (RAG).

**Bring Your Own Browser (BYOB)** tools allow users to perform web browsing tasks programmatically. In this notebook, we'll create a BYOB tool that:

**#1. Set Up a Search Engine:** Use a public search API, such as Google's Custom Search API, to perform web searches and obtain a list of relevant search results.

**#2. Build a Search Dictionary:** Collect the title, URL, and a summary of each web page from the search results to create a structured dictionary of information.

**#3. Generate a RAG Response:** Implement Retrieval-Augmented Generation (RAG) by passing the gathered information to the LLM, which then generates a final response to the user's query.

### Use Case
In this cookbook, we'll take the example of a user who wants to list recent product launches by OpenAI in chronological order. Because the current GPT-4o model has a knowledge cutoff date, it is not expected that the model will know about recent product launches such as the o1-preview model launched in September 2024.

```python
from openai import OpenAI

client = OpenAI()

search_query = "List the latest OpenAI product launches in chronological order from latest to oldest in the past 2 years"


response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a helpful agent."},
        {"role": "user", "content": search_query}]
).choices[0].message.content

print(response)
```

Given the knowledge cutoff, as expected the model does not know about the recent product launches by OpenAI.

### Setting up a BYOB tool
To provide the model with recent events information, we'll follow these steps:

##### Step 1: Set Up a Search Engine to Provide Web Search Results
##### Step 2: Build a Search Dictionary with Titles, URLs, and Summaries of Web Pages
##### Step 3: Pass the information to the model to generate a RAG Response to the User Query


Before we begin, ensure you have the following: **Python 3.12 or later** installed on your machine. You will also need a Google Custom Search API key and Custom Search Engine ID (CSE ID). Necessary Python packages installed: `requests`, `beautifulsoup4`, `openai`. And ensure the OPENAI_API_KEY is set up as an environment variable.

#### Step 1: Set Up a Search Engine to Provide Web Search Results
You can use any publicly available web search APIs to perform this task. We will configure a custom search engine using Google's Custom Search API. This engine will fetch a list of relevant web pages based on the user's query, focusing on obtaining the most recent and pertinent results.

**a. Configure Search API key and Function:** Acquire a Google API key and a Custom Search Engine ID (CSE ID) from the Google Developers Console. You can navigate to this [Programmable Search Engine Link](https://developers.google.com/custom-search/v1/overview) to set up an API key as well as Custom Search Engine ID (CSE ID).

The `search` function below sets up the search based on search term, the API and CSE ID keys, as well as number of search results to return. We'll introduce a parameter `site_filter` to restrict the output to only `openai.com`

```python
import requests  # For making HTTP requests to APIs and websites

def search(search_item, api_key, cse_id, search_depth=10, site_filter=None):
    service_url = 'https://www.googleapis.com/customsearch/v1'

    params = {
        'q': search_item,
        'key': api_key,
        'cx': cse_id,
        'num': search_depth
    }

    try:
        response = requests.get(service_url, params=params)
        response.raise_for_status()
        results = response.json()

        # Check if 'items' exists in the results
        if 'items' in results:
            if site_filter is not None:

                # Filter results to include only those with site_filter in the link
                filtered_results = [result for result in results['items'] if site_filter in result['link'&#93;&#93;

                if filtered_results:
                    return filtered_results
                else:
                    print(f"No results with {site_filter} found.")
                    return []
            else:
                if 'items' in results:
                    return results['items']
                else:
                    print("No search results found.")
                    return []

    except requests.exceptions.RequestException as e:
        print(f"An error occurred during the search: {e}")
        return []
```

**b. Identify the search terms for search engine:** Before we can retrieve specific results from a 3rd Party API, we may need to use Query Expansion to identify specific terms our browser search API should retrieve. **Query expansion** is a process where we broaden the original user query by adding related terms, synonyms, or variations. This technique is essential because search engines, like Google's Custom Search API, are often better at matching a range of related terms rather than just the natural language prompt used by a user.

For example, searching with only the raw query `"List the latest OpenAI product launches in chronological order from latest to oldest in the past 2 years"` may return fewer and less relevant results than a more specific and direct search on a succinct phrase such as `"Latest OpenAI product launches"`. In the code below, we will use the user's original `search_query` to produce a more specific search term to use with the Google API to retrieve the results.

```python
search_term = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "Provide a google search term based on search query provided below in 3-4 words"},
        {"role": "user", "content": search_query}]
).choices[0].message.content

print(search_term)
```

**c. Invoke the search function:** Now that we have the search term, we will invoke the search function to retrieve the results from Google search API. The results only have the link of the web page and a snippet at this point. In the next step, we will retrieve more information from the webpage and summarize it in a dictionary to pass to the model.

```python
from dotenv import load_dotenv
import os

load_dotenv('.env')

api_key = os.getenv('API_KEY')
cse_id = os.getenv('CSE_ID')

search_items = search(search_item=search_term, api_key=api_key, cse_id=cse_id, search_depth=10, site_filter="https://openai.com")
```

```python
for item in search_items:
    print(f"Link: {item['link']}")
    print(f"Snippet: {item['snippet']}\n")
```

#### Step 2: Build a Search Dictionary with Titles, URLs, and Summaries of Web Pages
After obtaining the search results, we'll extract and organize the relevant information, so it can be passed to the LLM for final output.

**a. Scrape Web Page Content:** For each URL in the search results, retrieve the web page to extract textual content while filtering out non-relevant data like scripts and advertisements as demonstrated in function `retrieve_content`.

**b. Summarize Content:** Use an LLM to generate concise summaries of the scraped content, focusing on information pertinent to the user's query. Model can be provided the original search text, so it can focus on summarizing the content for the search intent as outlined in function `summarize_content`.

**c. Create a Structured Dictionary:** Organize the data into a dictionary or a DataFrame containing the title, link, and summary for each web page. This structure can be passed on to the LLM to generate the summary with the appropriate citations.

```python
import requests
from bs4 import BeautifulSoup

TRUNCATE_SCRAPED_TEXT = 50000  # Adjust based on your model's context window
SEARCH_DEPTH = 5

def retrieve_content(url, max_tokens=TRUNCATE_SCRAPED_TEXT):
        try:
            headers = {'User-Agent': 'Mozilla/5.0'}
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()

            soup = BeautifulSoup(response.content, 'html.parser')
            for script_or_style in soup(['script', 'style']):
                script_or_style.decompose()

            text = soup.get_text(separator=' ', strip=True)
            characters = max_tokens * 4  # Approximate conversion
            text = text[:characters]
            return text
        except requests.exceptions.RequestException as e:
            print(f"Failed to retrieve {url}: {e}")
            return None

def summarize_content(content, search_term, character_limit=500):
        prompt = (
            f"You are an AI assistant tasked with summarizing content relevant to '{search_term}'. "
            f"Please provide a concise summary in {character_limit} characters or less."
        )
        try:
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[
                    {"role": "system", "content": prompt},
                    {"role": "user", "content": content}]
            )
            summary = response.choices[0].message.content
            return summary
        except Exception as e:
            print(f"An error occurred during summarization: {e}")
            return None

def get_search_results(search_items, character_limit=500):
    # Generate a summary of search results for the given search term
    results_list = []
    for idx, item in enumerate(search_items, start=1):
        url = item.get('link')

        snippet = item.get('snippet', '')
        web_content = retrieve_content(url, TRUNCATE_SCRAPED_TEXT)

        if web_content is None:
            print(f"Error: skipped URL: {url}")
        else:
            summary = summarize_content(web_content, search_term, character_limit)
            result_dict = {
                'order': idx,
                'link': url,
                'title': snippet,
                'Summary': summary
            }
            results_list.append(result_dict)
    return results_list
```

```python
results = get_search_results(search_items)

for result in results:
    print(f"Search order: {result['order']}")
    print(f"Link: {result['link']}")
    print(f"Snippet: {result['title']}")
    print(f"Summary: {result['Summary']}")
    print('-' * 80)
```

We retrieved the most recent results. (Note these will vary depending on when you execute this script.)

#### Step 3: Pass the information to the model to generate a RAG Response to the User Query
With the search data organized in a JSON data structure, we will pass this information to the LLM with the original user query to generate the final response. Now, the LLM response includes information beyond its original knowledge cutoff, providing current insights.

```python
import json

final_prompt = (
    f"The user will provide a dictionary of search results in JSON format for search query {search_term} Based on on the search results provided by the user, provide a detailed response to this query: **'{search_query}'**. Make sure to cite all the sources at the end of your answer."
)

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": final_prompt},
        {"role": "user", "content": json.dumps(results)}],
    temperature=0

)
summary = response.choices[0].message.content

print(summary)
```

### Conclusion

Large Language Models (LLMs) have a knowledge cutoff and may not be aware of recent events. To provide them with the latest information, you can build a Bring Your Own Browser (BYOB) tool using Python. This tool retrieves current web data and feeds it to the LLM, enabling up-to-date responses.

The process involves three main steps:

**#1 Set Up a Search Engine:** Use a public search API, like Google's Custom Search API, to perform web searches and obtain a list of relevant search results.

**#2 Build a Search Dictionary:** Collect the title, URL, and a summary of each web page from the search results to create a structured dictionary of information.

**#3. Generate a RAG Response:** Implement Retrieval-Augmented Generation (RAG) by passing the gathered information to the LLM, which then generates a final response to the user's query.

By following these steps, you enhance the LLMs ability to provide up-to-date answers in your application that include the most recent developments, such as the latest product launches by OpenAI.
