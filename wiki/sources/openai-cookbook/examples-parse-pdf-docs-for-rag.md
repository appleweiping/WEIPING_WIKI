---
title: "Parse Pdf Docs For Rag"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-15
tags:
  - cookbook
  - example
  - notebook
  - openai
  - rag
  - retrieval
source_pages:
  - https://developers.openai.com/cookbook/examples/parse_pdf_docs_for_rag
  - https://github.com/openai/openai-cookbook/blob/main/examples/Parse_PDF_docs_for_RAG.ipynb
---

# Parse Pdf Docs For Rag

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/parse_pdf_docs_for_rag
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Parse_PDF_docs_for_RAG.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Parse_PDF_docs_for_RAG.ipynb
- Source path: `examples/Parse_PDF_docs_for_RAG.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `11253aeb531837f6e7c1c338a4cf7da680be5e10838d2d06434aff225829148b`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Parsing PDF documents for RAG applications This notebook shows how to leverage GPT-4o to turn rich PDF documents such as slide decks or exports from web pages into usable content for your RAG application. This technique can be used if you have a lot of unstructured data containing valuable information that you want to be able to retrieve as part of your RAG...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Parsing PDF documents for RAG applications

This notebook shows how to leverage GPT-4o to turn rich PDF documents such as slide decks or exports from web pages into usable content for your RAG application.

This technique can be used if you have a lot of unstructured data containing valuable information that you want to be able to retrieve as part of your RAG pipeline.

For example, you could build a Knowledge Assistant that could answer user queries about your company or product based on information contained in PDF documents.

The example documents used in this notebook are located at [data/example_pdfs](data/example_pdfs). They are related to OpenAI's APIs and various techniques that can be used as part of LLM projects.

## Data preparation

In this section, we will process our input data to prepare it for retrieval.

We will do this in 2 ways:

1. Extracting text with pdfminer
2. Converting the PDF pages to images to analyze them with GPT-4o

You can skip the 1st method if you want to only use the content inferred from the image analysis.

### Setup

We need to install a few libraries to convert the PDF to images and extract the text (optional).

**Note: You need to install `poppler` on your machine for the `pdf2image` library to work. You can follow the instructions to install it [here](https://pypi.org/project/pdf2image/).**

```python
%pip install pdf2image -q
%pip install pdfminer -q
%pip install pdfminer.six -q
%pip install openai -q
%pip install scikit-learn -q
%pip install rich -q
%pip install tqdm -q
%pip install pandas -q
```

```python
# Imports
from pdf2image import convert_from_path
from pdf2image.exceptions import (
    PDFInfoNotInstalledError,
    PDFPageCountError,
    PDFSyntaxError
)
from pdfminer.high_level import extract_text
import base64
import io
import os
import concurrent.futures
from tqdm import tqdm
from openai import OpenAI
import re
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
import json
import numpy as np
from rich import print
from ast import literal_eval
```

### File processing

```python
def convert_doc_to_images(path):
    images = convert_from_path(path)
    return images

def extract_text_from_doc(path):
    text = extract_text(path)
    return text
```

#### Testing with an example

```python
file_path = "data/example_pdfs/fine-tuning-deck.pdf"

images = convert_doc_to_images(file_path)
```

```python
text = extract_text_from_doc(file_path)
```

```python
for img in images:
    display(img)
```

### Image analysis with GPT-4o

After converting a PDF file to multiple images, we'll use GPT-4o to analyze the content based on the images.

```python
# Initializing OpenAI client - see https://platform.openai.com/docs/quickstart?context=python
client = OpenAI()
```

```python
# Converting images to base64 encoded images in a data URI format to use with the ChatCompletions API
def get_img_uri(img):
    png_buffer = io.BytesIO()
    img.save(png_buffer, format="PNG")
    png_buffer.seek(0)

    base64_png = base64.b64encode(png_buffer.read()).decode('utf-8')

    data_uri = f"data:image/png;base64,{base64_png}"
    return data_uri
```

```python
system_prompt = '''
You will be provided with an image of a PDF page or a slide. Your goal is to deliver a detailed and engaging presentation about the content you see, using clear and accessible language suitable for a 101-level audience.

If there is an identifiable title, start by stating the title to provide context for your audience.

Describe visual elements in detail:

- **Diagrams**: Explain each component and how they interact. For example, "The process begins with X, which then leads to Y and results in Z."

- **Tables**: Break down the information logically. For instance, "Product A costs X dollars, while Product B is priced at Y dollars."

Focus on the content itself rather than the format:

- **DO NOT** include terms referring to the content format.

- **DO NOT** mention the content type. Instead, directly discuss the information presented.

Keep your explanation comprehensive yet concise:

- Be exhaustive in describing the content, as your audience cannot see the image.

- Exclude irrelevant details such as page numbers or the position of elements on the image.

Use clear and accessible language:

- Explain technical terms or concepts in simple language appropriate for a 101-level audience.

Engage with the content:

- Interpret and analyze the information where appropriate, offering insights to help the audience understand its significance.

------

If there is an identifiable title, present the output in the following format:

{TITLE}

{Content description}

If there is no clear title, simply provide the content description.
'''

def analyze_image(data_uri):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt},
            {
                "role": "user",
                "content": [
                    {
                    "type": "image_url",
                    "image_url": {
                        "url": f"{data_uri}"
                    }
                    }
                ]
                },
        ],
        max_tokens=500,
        temperature=0,
        top_p=0.1
    )
    return response.choices[0].message.content
```

#### Testing with an example

```python
img = images[2]
display(img)
data_uri = get_img_uri(img)
```

```python
res = analyze_image(data_uri)
print(res)
```

#### Processing all documents

```python
files_path = "data/example_pdfs"

all_items = os.listdir(files_path)
files = [item for item in all_items if os.path.isfile(os.path.join(files_path, item))]
```

```python
def analyze_doc_image(img):
    img_uri = get_img_uri(img)
    data = analyze_image(img_uri)
    return data
```

We will list all files in the example folder and process them by
1. Extracting the text
2. Converting the docs to images
3. Analyzing pages with GPT-4o

Note: This takes about ~2 mins to run. Feel free to skip and load directly the result file (see below).

```python
docs = []

for f in files:

    path = f"{files_path}/{f}"
    doc = {
        "filename": f
    }
    text = extract_text_from_doc(path)
    doc['text'] = text
    imgs = convert_doc_to_images(path)
    pages_description = []

    print(f"Analyzing pages for doc {f}")

    # Concurrent execution
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:

        # Removing 1st slide as it's usually just an intro
        futures = [
            executor.submit(analyze_doc_image, img)
            for img in imgs[1:]
        ]

        with tqdm(total=len(imgs)-1) as pbar:
            for _ in concurrent.futures.as_completed(futures):
                pbar.update(1)

        for f in futures:
            res = f.result()
            pages_description.append(res)

    doc['pages_description'] = pages_description
    docs.append(doc)
```

```python
# Saving result to file for later
json_path = "data/parsed_pdf_docs.json"

with open(json_path, 'w') as f:
    json.dump(docs, f)
```

```python
# Optional: load content from the saved file
with open(json_path, 'r') as f:
    docs = json.load(f)
```

### Embedding content
Before embedding the content, we will chunk it logically by page.
For real-world scenarios, you could explore more advanced ways to chunk the content:
- Cutting it into smaller pieces
- Adding data - such as the slide title, deck title and/or the doc description - at the beginning of each piece of content. That way, each independent chunk can be in context

For the sake of brevity, we will use a very simple chunking strategy and rely on separators to split the text by page.

```python
# Chunking content by page and merging together slides text & description if applicable
content = []
for doc in docs:
    # Removing first slide as well
    text = doc['text'].split('\f')[1:]
    description = doc['pages_description']
    description_indexes = []
    for i in range(len(text)):
        slide_content = text[i] + '\n'
        # Trying to find matching slide description
        slide_title = text[i].split('\n')[0]
        for j in range(len(description)):
            description_title = description[j].split('\n')[0]
            if slide_title.lower() == description_title.lower():
                slide_content += description[j].replace(description_title, '')
                # Keeping track of the descriptions added
                description_indexes.append(j)
        # Adding the slide content + matching slide description to the content pieces
        content.append(slide_content)
    # Adding the slides descriptions that weren't used
    for j in range(len(description)):
        if j not in description_indexes:
            content.append(description[j])
```

```python
for c in content:
    print(c)
    print("\n\n-------------------------------\n\n")
```

```python
# Cleaning up content
# Removing trailing spaces, additional line breaks, page numbers and references to the content being a slide
clean_content = []
for c in content:
    text = c.replace(' \n', '').replace('\n\n', '\n').replace('\n\n\n', '\n').strip()
    text = re.sub(r"(?<=\n)\d{1,2}", "", text)
    text = re.sub(r"\b(?:the|this)\s*slide\s*\w+\b", "", text, flags=re.IGNORECASE)
    clean_content.append(text)
```

```python
for c in clean_content:
    print(c)
    print("\n\n-------------------------------\n\n")
```

```python
# Creating the embeddings
# We'll save to a csv file here for testing purposes but this is where you should load content in your vectorDB.
df = pd.DataFrame(clean_content, columns=['content'])
print(df.shape)
df.head()
```

```python
embeddings_model = "text-embedding-3-large"

def get_embeddings(text):
    embeddings = client.embeddings.create(
      model="text-embedding-3-small",
      input=text,
      encoding_format="float"
    )
    return embeddings.data[0].embedding
```

```python
df['embeddings'] = df['content'].apply(lambda x: get_embeddings(x))
df.head()
```

```python
# Saving locally for later
data_path = "data/parsed_pdf_docs_with_embeddings.csv"
df.to_csv(data_path, index=False)
```

```python
# Optional: load data from saved file
df = pd.read_csv(data_path)
df["embeddings"] = df.embeddings.apply(literal_eval).apply(np.array)
```

## Retrieval-augmented generation

The last step of the process is to generate outputs in response to input queries, after retrieving content as context to reply.

```python
system_prompt = '''
    You will be provided with an input prompt and content as context that can be used to reply to the prompt.

    You will do 2 things:

    1. First, you will internally assess whether the content provided is relevant to reply to the input prompt.

    2a. If that is the case, answer directly using this content. If the content is relevant, use elements found in the content to craft a reply to the input prompt.

    2b. If the content is not relevant, use your own knowledge to reply or say that you don't know how to respond if your knowledge is not sufficient to answer.

    Stay concise with your answer, replying specifically to the input prompt without mentioning additional information provided in the context content.
'''

model="gpt-4o"

def search_content(df, input_text, top_k):
    embedded_value = get_embeddings(input_text)
    df["similarity"] = df.embeddings.apply(lambda x: cosine_similarity(np.array(x).reshape(1,-1), np.array(embedded_value).reshape(1, -1)))
    res = df.sort_values('similarity', ascending=False).head(top_k)
    return res

def get_similarity(row):
    similarity_score = row['similarity']
    if isinstance(similarity_score, np.ndarray):
        similarity_score = similarity_score[0][0]
    return similarity_score

def generate_output(input_prompt, similar_content, threshold = 0.5):

    content = similar_content.iloc[0]['content']

    # Adding more matching content if the similarity is above threshold
    if len(similar_content) > 1:
        for i, row in similar_content.iterrows():
            similarity_score = get_similarity(row)
            if similarity_score > threshold:
                content += f"\n\n{row['content']}"

    prompt = f"INPUT PROMPT:\n{input_prompt}\n-------\nCONTENT:\n{content}"

    completion = client.chat.completions.create(
        model=model,
        temperature=0.5,
        messages=[
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": prompt
            }
        ]
    )

    return completion.choices[0].message.content
```

```python
# Example user queries related to the content
example_inputs = [
    'What are the main models you offer?',
    'Do you have a speech recognition model?',
    'Which embedding model should I use for non-English use cases?',
    'Can I introduce new knowledge in my LLM app using RAG?',
    'How many examples do I need to fine-tune a model?',
    'Which metric can I use to evaluate a summarization task?',
    'Give me a detailed example for an evaluation process where we are looking for a clear answer to compare to a ground truth.',
]
```

```python
# Running the RAG pipeline on each example
for ex in example_inputs:
    print(f"[deep_pink4][bold]QUERY:[/bold] {ex}[/deep_pink4]\n\n")
    matching_content = search_content(df, ex, 3)
    print(f"[grey37][b]Matching content:[/b][/grey37]\n")
    for i, match in matching_content.iterrows():
        print(f"[grey37][i]Similarity: {get_similarity(match):.2f}[/i][/grey37]")
        print(f"[grey37]{match['content'][:100]}{'...' if len(match['content']) > 100 else ''}[/[grey37&#93;&#93;\n\n")
    reply = generate_output(ex, matching_content)
    print(f"[turquoise4][b]REPLY:[/b][/turquoise4]\n\n[spring_green4]{reply}[/spring_green4]\n\n--------------\n\n")
```

## Wrapping up

In this notebook, we have learned how to develop a basic RAG pipeline based on PDF documents. This includes:

- How to parse pdf documents, taking slide decks and an export from an HTML page as examples, using a python library as well as GPT-4o to interpret the visuals
- How to process the extracted content, clean it and chunk it into several pieces
- How to embed the processed content using OpenAI embeddings
- How to retrieve content that is relevant to an input query
- How to use GPT-4o to generate an answer using the retrieved content as context

If you want to explore further, consider these optimisations:

- Playing around with the prompts provided as examples
- Chunking the content further and adding metadata as context to each chunk
- Adding rule-based filtering on the retrieval results or re-ranking results to surface to most relevant content

You can apply the techniques covered in this notebook to multiple use cases, such as assistants that can access your proprietary data, customer service or FAQ bots that can read from your internal policies, or anything that requires leveraging rich documents that would be better understood as images.
