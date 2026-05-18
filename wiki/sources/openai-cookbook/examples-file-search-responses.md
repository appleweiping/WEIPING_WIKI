---
title: "File Search Responses"
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
  - https://developers.openai.com/cookbook/examples/file_search_responses
  - https://github.com/openai/openai-cookbook/blob/main/examples/File_Search_Responses.ipynb
---

# File Search Responses

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/file_search_responses
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/File_Search_Responses.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/File_Search_Responses.ipynb
- Source path: `examples/File_Search_Responses.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `760f1713972d252373178d3193be81cd2fddd0229c997052184d9f0478feae99`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Using file search tool in the Responses API Although RAG can be overwhelming, searching amongst PDF file shouldn't be complicated. One of the most adopted options as of now is parsing your PDF, defining your chunking strategies, uploading those chunks to a storage provider, running embeddings on those chunks of texts and storing those embeddings in a vector...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Using file search tool in the Responses API

Although RAG can be overwhelming, searching amongst PDF file shouldn't be complicated. One of the most adopted options as of now is parsing your PDF, defining your chunking strategies, uploading those chunks to a storage provider, running embeddings on those chunks of texts and storing those embeddings in a vector database. And that's only the setup — retrieving content in our LLM workflow also requires multiple steps.

This is where file search — a hosted tool you can use in the Responses API — comes in. It allows you to search your knowledge base and generate an answer based on the retrieved content. In this cookbook, we'll upload those PDFs to a vector store on OpenAI and use file search to fetch additional context from this vector store to answer the questions we generated in the first step. Then, we'll initially create a small set of questions based on PDFs extracted from OpenAI's blog ([openai.com/news](https://openai.com/news)).

_File search was previously available on the Assistants API. It's now available on the new Responses API, an API that can be stateful or stateless, and with from new features like metadata filtering_

# Creating Vector Store with our PDFs

```python
!pip install PyPDF2 pandas tqdm openai -q
```

```python
from openai import OpenAI
from concurrent.futures import ThreadPoolExecutor
from tqdm import tqdm
import concurrent
import PyPDF2
import os
import pandas as pd
import base64

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
dir_pdfs = 'openai_blog_pdfs' # have those PDFs stored locally here
pdf_files = [os.path.join(dir_pdfs, f) for f in os.listdir(dir_pdfs)]
```

We will create a Vector Store on OpenAI API and upload our PDFs to the Vector Store. OpenAI will read those PDFs, separate the content into multiple chunks of text, run embeddings on those and store those embeddings and the text in the Vector Store. It will enable us to query this Vector Store to return relevant content based on a query.

```python
def upload_single_pdf(file_path: str, vector_store_id: str):
    file_name = os.path.basename(file_path)
    try:
        file_response = client.files.create(file=open(file_path, 'rb'), purpose="assistants")
        attach_response = client.vector_stores.files.create(
            vector_store_id=vector_store_id,
            file_id=file_response.id
        )
        return {"file": file_name, "status": "success"}
    except Exception as e:
        print(f"Error with {file_name}: {str(e)}")
        return {"file": file_name, "status": "failed", "error": str(e)}

def upload_pdf_files_to_vector_store(vector_store_id: str):
    pdf_files = [os.path.join(dir_pdfs, f) for f in os.listdir(dir_pdfs)]
    stats = {"total_files": len(pdf_files), "successful_uploads": 0, "failed_uploads": 0, "errors": []}

    print(f"{len(pdf_files)} PDF files to process. Uploading in parallel...")

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(upload_single_pdf, file_path, vector_store_id): file_path for file_path in pdf_files}
        for future in tqdm(concurrent.futures.as_completed(futures), total=len(pdf_files)):
            result = future.result()
            if result["status"] == "success":
                stats["successful_uploads"] += 1
            else:
                stats["failed_uploads"] += 1
                stats["errors"].append(result)

    return stats

def create_vector_store(store_name: str) -> dict:
    try:
        vector_store = client.vector_stores.create(name=store_name)
        details = {
            "id": vector_store.id,
            "name": vector_store.name,
            "created_at": vector_store.created_at,
            "file_count": vector_store.file_counts.completed
        }
        print("Vector store created:", details)
        return details
    except Exception as e:
        print(f"Error creating vector store: {e}")
        return {}
```

```python
store_name = "openai_blog_store"
vector_store_details = create_vector_store(store_name)
upload_pdf_files_to_vector_store(vector_store_details["id"])
```

# Standalone vector search

Now that our vector store is ready, we are able to query the Vector Store directly and retrieve relevant content for a specific query. Using the new [vector search API](https://platform.openai.com/docs/api-reference/vector-stores/search), we're able to find relevant items from our knowledge base without necessarily integrating it in an LLM query.

```python
query = "What's Deep Research?"
search_results = client.vector_stores.search(
    vector_store_id=vector_store_details['id'],
    query=query
)
```

```python
for result in search_results.data:
    print(str(len(result.content[0].text)) + ' of character of content from ' + result.filename + ' with a relevant score of ' + str(result.score))
```

We can see that different size (and under-the-hood different texts) have been returned from the search query. They all have different relevancy score that are calculated by our ranker which uses hybrid search.

# Integrating search results with LLM in a single API call

However instead of querying the vector store and then passing the data into the Responses or Chat Completion API call, an even more convenient way to use this search results in an LLM query would be to plug use file_search tool as part of OpenAI Responses API.

```python
query = "What's Deep Research?"
response = client.responses.create(
    input= query,
    model="gpt-4o-mini",
    tools=[{
        "type": "file_search",
        "vector_store_ids": [vector_store_details['id'&#93;&#93;,
    }]
)

# Extract annotations from the response
annotations = response.output[1].content[0].annotations

# Get top-k retrieved filenames
retrieved_files = set([result.filename for result in annotations])

print(f'Files used: {retrieved_files}')
print('Response:')
print(response.output[1].content[0].text) # 0 being the filesearch call
```

We can see that `gpt-4o-mini` was able to answer a query that required more recent, specialised knowledge about OpenAI's Deep Research. It used content from the file `Introducing deep research _ OpenAI.pdf` that had chunks of texts that were the most relevant. If we want to go even deeper in the analysis of chunk of text retrieved, we can also analyse the different texts that were returned by the search engine by adding `include=["output[*].file_search_call.search_results"]` to our query.

# Evaluating performance

What is key for those information retrieval system is to also measure the relevance & quality of files retrieved for those answers. The following steps of this cookbook will consist in generating an evaluation dataset and calculating different metrics over this generated dataset. This is an imperfect approach and we'll always recommend to have a human-verified evaluation dataset for your own use-cases, but it will show you the methodology to evaluate those.  It will be imperfect because some of the questions generated might be generic (e.g: What's said by the main stakeholder in this document) and our retrieval test will have a hard time to figure out which document that question was generated for.

## Generating evaluations

We will create functions that will read through the PDFs we have locally and generate a question that can only be answered by this document. Therefore it'll create our evaluation dataset that we can use after.

```python
def extract_text_from_pdf(pdf_path):
    text = ""
    try:
        with open(pdf_path, "rb") as f:
            reader = PyPDF2.PdfReader(f)
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text
    except Exception as e:
        print(f"Error reading {pdf_path}: {e}")
    return text

def generate_questions(pdf_path):
    text = extract_text_from_pdf(pdf_path)

    prompt = (
        "Can you generate a question that can only be answered from this document?:\n"
        f"{text}\n\n"
    )

    response = client.responses.create(
        input=prompt,
        model="gpt-4o",
    )

    question = response.output[0].content[0].text

    return question
```

If we run the function generate_question for the first PDF file we will be able to see the kind of question it generates.

```python
generate_questions(pdf_files[0])
```

We can now generate all the questions for all the PDFs we've got stored locally.

```python
# Generate questions for each PDF and store in a dictionary
questions_dict = {}
for pdf_path in pdf_files:
    questions = generate_questions(pdf_path)
    questions_dict[os.path.basename(pdf_path)] = questions
```

```python
questions_dict
```

We now have a dictionary of `filename:question` that we can loop through and ask gpt-4o(-mini) about without providing the document, and gpt-4o should be able to find the relevant document in the Vector Store.

## Evaluating

We'll convert our dictionary into a dataframe and process it using gpt-4o-mini. We will look out for the expected file

```python
rows = []
for filename, query in questions_dict.items():
    rows.append({"query": query, "_id": filename.replace(".pdf", "")})

# Metrics evaluation parameters
k = 5
total_queries = len(rows)
correct_retrievals_at_k = 0
reciprocal_ranks = []
average_precisions = []

def process_query(row):
    query = row['query']
    expected_filename = row['_id'] + '.pdf'
    # Call file_search via Responses API
    response = client.responses.create(
        input=query,
        model="gpt-4o-mini",
        tools=[{
            "type": "file_search",
            "vector_store_ids": [vector_store_details['id'&#93;&#93;,
            "max_num_results": k,
        }],
        tool_choice="required" # it will force the file_search, while not necessary, it's better to enforce it as this is what we're testing
    )
    # Extract annotations from the response
    annotations = None
    if hasattr(response.output[1], 'content') and response.output[1].content:
        annotations = response.output[1].content[0].annotations
    elif hasattr(response.output[1], 'annotations'):
        annotations = response.output[1].annotations

    if annotations is None:
        print(f"No annotations for query: {query}")
        return False, 0, 0

    # Get top-k retrieved filenames
    retrieved_files = [result.filename for result in annotations[:k&#93;&#93;
    if expected_filename in retrieved_files:
        rank = retrieved_files.index(expected_filename) + 1
        rr = 1 / rank
        correct = True
    else:
        rr = 0
        correct = False

    # Calculate Average Precision
    precisions = []
    num_relevant = 0
    for i, fname in enumerate(retrieved_files):
        if fname == expected_filename:
            num_relevant += 1
            precisions.append(num_relevant / (i + 1))
    avg_precision = sum(precisions) / len(precisions) if precisions else 0

    if expected_filename not in retrieved_files:
        print("Expected file NOT found in the retrieved files!")

    if retrieved_files and retrieved_files[0] != expected_filename:
        print(f"Query: {query}")
        print(f"Expected file: {expected_filename}")
        print(f"First retrieved file: {retrieved_files[0]}")
        print(f"Retrieved files: {retrieved_files}")
        print("-" * 50)


    return correct, rr, avg_precision
```

```python
process_query(rows[0])
```

Recall & Precision are at 1 for this example, and our file ranked first so we're having a MRR and MAP = 1 on this example.

We can now execute this processing on our set of questions.

```python
with ThreadPoolExecutor() as executor:
    results = list(tqdm(executor.map(process_query, rows), total=total_queries))

correct_retrievals_at_k = 0
reciprocal_ranks = []
average_precisions = []

for correct, rr, avg_precision in results:
    if correct:
        correct_retrievals_at_k += 1
    reciprocal_ranks.append(rr)
    average_precisions.append(avg_precision)

recall_at_k = correct_retrievals_at_k / total_queries
precision_at_k = recall_at_k  # In this context, same as recall
mrr = sum(reciprocal_ranks) / total_queries
map_score = sum(average_precisions) / total_queries
```

The outputs logged above would either show that a file wasn't ranked first when our evaluation dataset expected it to rank first or that it wasn't found at all. As we can see from our imperfect evaluation dataset, some questions were generic and expected another doc, which our retrieval system didn't specifically retrieved for this question.

```python
# Print the metrics with k
print(f"Metrics at k={k}:")
print(f"Recall@{k}: {recall_at_k:.4f}")
print(f"Precision@{k}: {precision_at_k:.4f}")
print(f"Mean Reciprocal Rank (MRR): {mrr:.4f}")
print(f"Mean Average Precision (MAP): {map_score:.4f}")
```

With this cookbook we were able to see how to:
- Generate a dataset of evaluations using PDF context-stuffing (leveraging vision modality of 4o) and traditional PDF readers
- Create a vector store and populate it with PDF
- Get an LLM answer to a query, leveraging a RAG system available out-of-the-box with `file_search` tool call in OpenAI's Response API
- Understand how chunks of texts are retrieved, ranked and used as part of the Response API
- Measure accuracy, precision, retrieval, MRR and MAP on the dataset of evaluations previously generated

By using file search with Responses, you can simplify RAG architecture and leverage this in a single API call using the new Responses API. File storage, embeddings, retrieval all integrated in one tool!
