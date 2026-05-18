---
title: "Using Vision Modality For Rag With Pinecone"
type: source
status: mirrored
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
  - https://developers.openai.com/cookbook/examples/vector_databases/pinecone/using_vision_modality_for_rag_with_pinecone
  - https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/pinecone/Using_vision_modality_for_RAG_with_Pinecone.ipynb
---

# Using Vision Modality For Rag With Pinecone

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/vector_databases/pinecone/using_vision_modality_for_rag_with_pinecone
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/vector_databases/pinecone/Using_vision_modality_for_RAG_with_Pinecone.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/vector_databases/pinecone/Using_vision_modality_for_RAG_with_Pinecone.ipynb
- Source path: `examples/vector_databases/pinecone/Using_vision_modality_for_RAG_with_Pinecone.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `e3d9fae1133919914c9bef2f3d66acbf437d6d508641e6472b2622c33010b071`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Optimizing Retrieval-Augmented Generation using GPT-4o Vision Modality Implementing Retrieval-Augmented Generation (RAG) presents unique challenges when working with documents rich in images, graphics and tables. Traditional RAG models excel with textual data but often falter when visual elements play a crucial role in conveying information. In this cookbook...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

## Optimizing Retrieval-Augmented Generation using GPT-4o Vision Modality

Implementing Retrieval-Augmented Generation (RAG) presents unique challenges when working with documents rich in images, graphics and tables. Traditional RAG models excel with textual data but often falter when visual elements play a crucial role in conveying information. In this cookbook, we bridge that gap by leveraging the vision modality to extract and interpret visual content, ensuring that the generated responses are as informative and accurate as possible.

Our approach involves parsing documents into images and utilizing metadata tagging to identify pages containing images, graphics and tables. When a semantic search retrieves such a page, we pass the page image to a vision model instead of relying solely on text. This method enhances the model's ability to understand and answer user queries that pertain to visual data.

In this cookbook, we will explore and demonstrate the following key concepts:

##### 1. Setting Up a Vector Store with Pinecone:
- Learn how to initialize and configure Pinecone to store vector embeddings efficiently.

##### 2. Parsing PDFs and Extracting Visual Information:
- Discover techniques for converting PDF pages into images.
- Use GPT-4o vision modality to extract textual information from pages with images, graphics or tables.

##### 3. Generating Embeddings:
- Utilize embedding models to create vector representations of textual data.
- Flag the pages that have visual content so that we set a metadata flag on vector store, and retrieve images to pass on the GPT-4o using vision modality.

##### 4. Uploading Embeddings to Pinecone:
- Upload these embeddings to Pinecone for storage and retrieval.

##### 5. Performing Semantic Search for Relevant Pages:
- Implement semantic search on page text to find pages that best match the user's query.
- Provide the matching page text to GPT-4o as context to answer user's query.

##### 6. Handling Pages with Visual Content (Optional Step):
- Learn how to pass the image using GPT-4o vision modality for question answering with additional context.
- Understand how this process improves the accuracy of responses involving visual data.

By the end of this cookbook, you will have a robust understanding of how to implement RAG systems capable of processing and interpreting documents with complex visual elements. This knowledge will empower you to build AI solutions that deliver richer, more accurate information, enhancing user satisfaction and engagement.

We will use the World Bank report - [A Better Bank for a Better World: Annual Report 2024](https://documents1.worldbank.org/curated/en/099101824180532047/pdf/BOSIB13bdde89d07f1b3711dd8e86adb477.pdf) to illustrate the concepts as this document has a mix of images, tables and graphics data.

Keep in mind that using the Vision Modality is resource-intensive, leading to increased latency and cost. It is advisable to use Vision Modality only for cases where performance on evaluation benchmarks is unsatisfactory with plain text extraction methods. With this context, let's dive in.

### Step 1: Setting up a Vector Store with Pinecone
In this section, we'll set up a vector store using Pinecone to store and manage our embeddings efficiently. Pinecone is a vector database optimized for handling high-dimensional vector data, which is essential for tasks like semantic search and similarity matching.

**Prerequisites**
1. Sign-up for Pinecone and obtain an API key by following the instructions here [Pinecone Database Quickstart](https://docs.pinecone.io/guides/get-started/quickstart)
2. Install the Pinecone SDK using `pip install "pinecone[grpc]"`. gRPC (gRPC Remote Procedure Call) is a high-performance, open-source universal RPC framework that uses HTTP/2 for transport, Protocol Buffers (protobuf) as the interface definition language, and enables client-server communication in a distributed system. It is designed to make inter-service communication more efficient and suitable for microservices architectures.

**Store the API Key Securely**
1. Store the API key in an .env file for security purposes in you project directory as follows:
 `PINECONE_API_KEY=your-api-key-here`.
 2. Install `pip install python-dotenv` to read the API Key from the .env file.

**Create the Pinecone Index**
We'll use the `create_index` function to initialize our embeddings database on Pinecone. There are two crucial parameters to consider:

1. Dimension: This must match the dimensionality of the embeddings produced by your chosen model. For example, OpenAI's text-embedding-ada-002 model produces embeddings with 1536 dimensions, while text-embedding-3-large produces embeddings with 3072 dimensions. We'll use the text-embedding-3-large model, so we'll set the dimension to 3072.

2. Metric: The distance metric determines how similarity is calculated between vectors. Pinecone supports several metrics, including cosine, dotproduct, and euclidean. For this cookbook, we'll use the cosine similarity metric. You can learn more about distance metrics in the [Pinecone Distance Metrics documentation](https://docs.pinecone.io/guides/indexes/understanding-indexes#distance-metrics).

```python
import os
import time
# Import the Pinecone library
from pinecone.grpc import PineconeGRPC as Pinecone
from pinecone import ServerlessSpec

from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("PINECONE_API_KEY")

# Initialize a Pinecone client with your API key
pc = Pinecone(api_key)

# Create a serverless index
index_name = "my-test-index"

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

# Wait for the index to be ready
while not pc.describe_index(index_name).status['ready']:
    time.sleep(1)
```

Navigate to Indexes list on [Pinecone](https://app.pinecone.io/) and you should be able to view `my-test-index` in the list of indexes.

### Step 2: Parsing PDFs and Extracting Visual Information:

In this section, we will parse our PDF document the World Bank report - [A Better Bank for a Better World: Annual Report 2024](https://documents1.worldbank.org/curated/en/099101824180532047/pdf/BOSIB13bdde89d07f1b3711dd8e86adb477.pdf) and extract textual and visual information, such as describing images, graphics, and tables. The process involves three main steps:

1. **Parse the PDF into individual pages:** We split the PDF into separate pages for easier processing.
2. **Convert PDF pages to images:** This enabled vision GPT-4o vision capability to analyze the page as an image.
3. **Process images and tables:** Provide instructions to GPT-4o to extract text, and also describe the images, graphics or tables in the document.

**Prerequisites**

Before proceeding, make sure you have the following packages installed. Also ensure your OpenAI API key is set up as an environment variable. You may also need to install Poppler for PDF rendering.

`pip install PyPDF2 pdf2image pytesseract pandas tqdm`

**Step Breakdown:**

**1. Downloading and Chunking the PDF:**
- The `chunk_document` function downloads the PDF from the provided URL and splits it into individual pages using PyPDF2.
- Each page is stored as a separate PDF byte stream in a list.

**2. Converting PDF Pages to Images:**
- The `convert_page_to_image` function takes the PDF bytes of a single page and converts it into an image using pdf2image.
- The image is saved locally in an 'images' directory for further processing.

**3. Extracting Text Using GPT-4o vision modality:**
- The `extract_text_from_image` function uses GPT-4o vision capability to extract text from the image of the page.
- This method can extract textual information even from scanned documents.
- Note that this modality is resource intensive thus has higher latency and cost associated with it.

**4. Processing the Entire Document:**
- The process_document function orchestrates the processing of each page.
- It uses a progress bar (tqdm) to show the processing status.
- The extracted information from each page is collected into a list and then converted into a Pandas DataFrame.

```python
import base64
import requests
import os
import pandas as pd
from PyPDF2 import PdfReader, PdfWriter
from pdf2image import convert_from_bytes
from io import BytesIO
from openai import OpenAI
from tqdm import tqdm

# Link to the document we will use as the example
document_to_parse = "https://documents1.worldbank.org/curated/en/099101824180532047/pdf/BOSIB13bdde89d07f1b3711dd8e86adb477.pdf"

# OpenAI client
oai_client = OpenAI()


# Chunk the PDF document into single page chunks
def chunk_document(document_url):
    # Download the PDF document
    response = requests.get(document_url)
    pdf_data = response.content

    # Read the PDF data using PyPDF2
    pdf_reader = PdfReader(BytesIO(pdf_data))
    page_chunks = []

    for page_number, page in enumerate(pdf_reader.pages, start=1):
        pdf_writer = PdfWriter()
        pdf_writer.add_page(page)
        pdf_bytes_io = BytesIO()
        pdf_writer.write(pdf_bytes_io)
        pdf_bytes_io.seek(0)
        pdf_bytes = pdf_bytes_io.read()
        page_chunk = {
            'pageNumber': page_number,
            'pdfBytes': pdf_bytes
        }
        page_chunks.append(page_chunk)

    return page_chunks


# Function to encode the image
def encode_image(local_image_path):
    with open(local_image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')


# Function to convert page to image
def convert_page_to_image(pdf_bytes, page_number):
    # Convert the PDF page to an image
    images = convert_from_bytes(pdf_bytes)
    image = images[0]  # There should be only one page

    # Define the directory to save images (relative to your script)
    images_dir = 'images'  # Use relative path here

    # Ensure the directory exists
    os.makedirs(images_dir, exist_ok=True)

    # Save the image to the images directory
    image_file_name = f"page_{page_number}.png"
    image_file_path = os.path.join(images_dir, image_file_name)
    image.save(image_file_path, 'PNG')

    # Return the relative image path
    return image_file_path


# Pass the image to the LLM for interpretation
def get_vision_response(prompt, image_path):
    # Getting the base64 string
    base64_image = encode_image(image_path)

    response = oai_client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{base64_image}"
                        },
                    },
                ],
            }
        ],
    )
    return response


# Process document function that brings it all together
def process_document(document_url):
    try:
        # Update document status to 'Processing'
        print("Document processing started")

        # Get per-page chunks
        page_chunks = chunk_document(document_url)
        total_pages = len(page_chunks)

        # Prepare a list to collect page data
        page_data_list = []

        # Add progress bar here
        for page_chunk in tqdm(page_chunks, total=total_pages, desc='Processing Pages'):
            page_number = page_chunk['pageNumber']
            pdf_bytes = page_chunk['pdfBytes']

            # Convert page to image
            image_path = convert_page_to_image(pdf_bytes, page_number)

            # Prepare question for vision API
            system_prompt = (
                "The user will provide you an image of a document file. Perform the following actions: "
                "1. Transcribe the text on the page. **TRANSCRIPTION OF THE TEXT:**"
                "2. If there is a chart, describe the image and include the text **DESCRIPTION OF THE IMAGE OR CHART**"
                "3. If there is a table, transcribe the table and include the text **TRANSCRIPTION OF THE TABLE**"
            )

            # Get vision API response
            vision_response = get_vision_response(system_prompt, image_path)

            # Extract text from vision response
            text = vision_response.choices[0].message.content

            # Collect page data
            page_data = {
                'PageNumber': page_number,
                'ImagePath': image_path,
                'PageText': text
            }
            page_data_list.append(page_data)

        # Create DataFrame from page data
        pdf_df = pd.DataFrame(page_data_list)
        print("Document processing completed.")
        print("DataFrame created with page data.")

        # Return the DataFrame
        return pdf_df

    except Exception as err:
        print(f"Error processing document: {err}")
        # Update document status to 'Error'


df = process_document(document_to_parse)
```

Let's examine the DataFrame to ensure that the pages have been processed correctly. For brevity, we will retrieve and display only the first five rows. Additionally, you should be able to see the page images generated in the 'images' directory.

```python
from IPython.display import display, HTML

# Convert the DataFrame to an HTML table and display top 5 rows
display(HTML(df.head().to_html()))
```

Let's take a look at a sample page, such as page 21, which contains embedded graphics and text. We can observe that the vision modality effectively extracted and described the visual information. For instance, the pie chart on this page is accurately described as:

`"FIGURE 6: MIDDLE EAST AND NORTH AFRICA IBRD AND IDA LENDING BY SECTOR - FISCAL 2024 SHARE OF TOTAL OF $4.6 BILLION" is a circular chart, resembling a pie chart, illustrating the percentage distribution of funds among different sectors. The sectors include:`

```python
# Filter and print rows where pageNumber is 21
filtered_rows = df[df['PageNumber'] == 21]
for text in filtered_rows.PageText:
    print(text)
```

### Step 3: Generating Embeddings:

In this section, we focus on transforming the textual content extracted from each page of the document into vector embeddings. These embeddings capture the semantic meaning of the text, enabling efficient similarity searches and various Natural Language Processing (NLP) tasks. We also identify pages containing visual elements, such as images, graphics, or tables, and flag them for special handling.

**Step Breakdown:**

**1. Adding a flag for visual content**

To process pages containing visual information, in Step 2 we used the vision modality to extract content from charts, tables, and images. By including specific instructions in our prompt, we ensure that the model adds markers such as `DESCRIPTION OF THE IMAGE OR CHART` or `TRANSCRIPTION OF THE TABLE` when describing visual content. In this step, if such a marker is detected, we set the Visual_Input_Processed flag to 'Y'; otherwise, it remains 'N'.

While the vision modality captures most visual information effectively, some details—particularly in complex visuals like engineering drawings—may be lost in translation. In Step 6, we will use this flag to determine when to pass the image of the page to GPT-4 Vision as additional context. This is an optional enhancement that can significantly improve the effectiveness of a RAG solution.

**2. Generating Embeddings with OpenAI's Embedding Model**

We use OpenAI's embedding model, `text-embedding-3-large`, to generate high-dimensional embeddings that represent the semantic content of each page.

Note: It is crucial to ensure that the dimensions of the embedding model you use are consistent with the configuration of your Pinecone vector store. In our case, we set up the Pinecone database with 3072 dimensions to match the default dimensions of `text-embedding-3-large`.

```python
# Add a column to flag pages with visual content
df['Visual_Input_Processed'] = df['PageText'].apply(
    lambda x: 'Y' if 'DESCRIPTION OF THE IMAGE OR CHART' in x or 'TRANSCRIPTION OF THE TABLE' in x else 'N'
)


# Function to get embeddings
def get_embedding(text_input):
    response = oai_client.embeddings.create(
        input=text_input,
        model="text-embedding-3-large"
    )
    return response.data[0].embedding


# Generate embeddings with a progress bar
embeddings = []
for text in tqdm(df['PageText'], desc='Generating Embeddings'):
    embedding = get_embedding(text)
    embeddings.append(embedding)

# Add the embeddings to the DataFrame
df['Embeddings'] = embeddings
```

We can verify that our logic correctly flagged pages requiring visual input. For instance, page 21, which we previously examined, has the Visual_Input_Needed flag set to "Y".

```python
# Display the flag for page 21
filtered_rows = df[df['PageNumber'] == 21]
print(filtered_rows.Visual_Input_Processed)
```

#### Step 4: Uploading embeddings to Pinecone:

In this section, we will upload the embeddings we've generated for each page of our document to Pinecone. Along with the embeddings, we'll include relevant metadata tags that describe each page, such as the page number, text content, image paths, and whether the page includes graphics.

**Step Breakdown:**

**1. Create Metadata Fields:**
Metadata enhances our ability to perform more granular searches, find the text or image associated with the vector, and enables filtering within the vector database.
* pageId: Combines the document_id and pageNumber to create a unique identifier for each page. We will use this as a unique identifier for our embeddings.
* pageNumber: The numerical page number within the document.
* text: The extracted text content from the page.
* ImagePath: The file path to the image associated with the page.
* GraphicIncluded: A boolean or flag indicating whether the page includes graphical elements that may require visual processing.

**2. Upload embeddings:**
We will use Pinecone API to in function `upsert_vector` to "upserts" the values -

* A unique identifier
* Embeddings
* Metadata as defined above

Note: "Upsert" is a combination of the words "update" and "insert." In database operations, an upsert is an atomic operation that updates an existing record if it exists or inserts a new record if it doesn't. This is particularly useful when you want to ensure that your database has the most recent data without having to perform separate checks for insertion or updating.

```python
# reload the index from Pinecone
index = pc.Index(index_name)

# Create a document ID prefix
document_id = 'WB_Report'


# Define the async function correctly
def upsert_vector(identifier, embedding, metadata):
    try:
        index.upsert([
            {
                'id': identifier,
                'values': embedding,
                'metadata': metadata
            }
        ])
    except Exception as e:
        print(f"Error upserting vector with ID {identifier}: {e}")
        raise


for idx, row in tqdm(df.iterrows(), total=df.shape[0], desc='Uploading to Pinecone'):
    pageNumber = row['PageNumber']

    # Create meta-data tags to be added to Pinecone
    metadata = {
        'pageId': f"{document_id}-{pageNumber}",
        'pageNumber': pageNumber,
        'text': row['PageText'],
        'ImagePath': row['ImagePath'],
        'GraphicIncluded': row['Visual_Input_Processed']
    }

    upsert_vector(metadata['pageId'], row['Embeddings'], metadata)
```

Navigate to Indexes list on [Pinecone](https://app.pinecone.io/) and you should be able to view the vectors upserted into the database with metadata.

### Step 5: Performing Semantic Search for Relevant Pages:
In this section, we implement a semantic search to find the most relevant pages in our document that answer a user's question. This approach uses the embeddings stored in the Pinecone vector database to retrieve pages based on the semantic similarity of their content to the user's query. By doing so, we can effectively search textual content, and provide it as context to GPT-4o for answering user's question.

**Step Breakdown:**

**1. Generate an Embedding for the User's Question**

* We use OpenAI's embedding model to generate a high-dimensional vector representation of the user's question.
* This vector captures the semantic meaning of the question, allowing us to perform an efficient similarity search against our stored embeddings.
* The embedding is crucial for ensuring that the search query is semantically aligned with the content of the document, even if the exact words do not match.

**2. Query the Pinecone Index for Relevant Pages**

* Using the generated embedding, we query the Pinecone index to find the most relevant pages.
* Pinecone performs a similarity search by comparing the question's embedding to the embeddings stored in the vector database using `cosine` similarity. If you recall, we set this as `metric` parameter in Step 1 when we created our Pinecone database.
* We specify the number of top matches to retrieve, typically based on a balance between coverage and relevance. For instance, retrieving the top 3-5 pages is often sufficient to provide a comprehensive answer without overwhelming the model with too much context.


**3. Compile the Metadata of Matched Pages to Provide Context**

* Once the relevant embeddings are identified, we gather their associated metadata, including the extracted text and the page number.
* This metadata is essential for structuring the context provided to GPT-4o.
* We also format the compiled information as a JSON to make it easy for the LLM to interpret.

**4. Use the GPT-4o Model to Generate an Answer**

* Finally, we pass the compiled context to the GPT-4o.
* The model uses the context to generate an informative, coherent, and contextually relevant answer to the user's question.
* The retrieved context helps the LLM answer questions with greater accuracy, as it has access to relevant information from the document.

```python
import json


# Function to get response to a user's question
def get_response_to_question(user_question, pc_index):
    # Get embedding of the question to find the relevant page with the information
    question_embedding = get_embedding(user_question)

    # get response vector embeddings
    response = pc_index.query(
        vector=question_embedding,
        top_k=2,
        include_values=True,
        include_metadata=True
    )

    # Collect the metadata from the matches
    context_metadata = [match['metadata'] for match in response['matches'&#93;&#93;

    # Convert the list of metadata dictionaries to prompt a JSON string
    context_json = json.dumps(context_metadata, indent=3)

    prompt = f"""You are a helpful assistant. Use the following context and images to answer the question. In the answer, include the reference to the document, and page number you found the information on between <source></source> tags. If you don't find the information, you can say "I couldn't find the information"

    question: {user_question}

    <SOURCES>
    {context_json}
    </SOURCES>
    """

    # Call completions end point with the prompt
    completion = oai_client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": prompt}
        ]
    )

    return completion.choices[0].message.content
```

Now, let's pose a question that requires information from a diagram. In this case, the relevant details are found within a pie chart.

```python
question = "What percentage was allocated to social protections in Western and Central Africa?"
answer = get_response_to_question(question, index)

print(answer)
```

Let's make it more challenging by asking a question that requires interpretation of information presented in a table. In our Step 2, we extracted this information using the GPT-4o vision modality.

```python
question = "What was the increase in access to electricity between 2000 and 2012 in Western and Central Africa?"
answer = get_response_to_question(question, index)

print(answer)
```

This approach worked well. However, there may be cases where information is embedded within images or graphics that lose fidelity when translated to text, such as complex engineering drawings.

By using the GPT-4o Vision modality, we can pass the image of the page directly to the model as context. In the next section, we will explore how to improve the accuracy of model responses using image inputs.

### Step 6: Handling Pages with Visual Content (Optional Step):
When metadata indicates the presence of an image, graphic or a table, we can pass the image as the context to GPT-4o instead of the extracted text. This approach can be useful in cases where text description of the visual information is not sufficient to convey the context. It can be the case for complex graphics such as engineering drawings or complex diagrams.

**Step Breakdown:**

The difference between this Step and Step 5, is that we've added additional logic to identify when `Visual_Input_Processed` flag is set for an embedding. In that case, instead of passing the text as the context, we pass the image of the page using GPT-4o vision modality as the context.

Note: This approach does increase both latency and cost, as processing image inputs is more resource intensive and expensive. Therefore, it should only be used if the desired results cannot be achieved with the text-only modality as outlined in Step 5 above.

```python
import base64
import json


def get_response_to_question_with_images(user_question, pc_index):
    # Get embedding of the question to find the relevant page with the information
    question_embedding = get_embedding(user_question)

    # Get response vector embeddings
    response = pc_index.query(
        vector=question_embedding,
        top_k=3,
        include_values=True,
        include_metadata=True
    )

    # Collect the metadata from the matches
    context_metadata = [match['metadata'] for match in response['matches'&#93;&#93;

    # Build the message content
    message_content = []

    # Add the initial prompt
    initial_prompt = f"""You are a helpful assistant. Use the text and images provided by the user to answer the question. You must include the reference to the page number or title of the section you the answer where you found the information. If you don't find the information, you can say "I couldn't find the information"

    question: {user_question}
    """

    message_content.append({"role": "system", "content": initial_prompt})

    context_messages = []

    # Process each metadata item to include text or images based on 'Visual_Input_Processed'
    for metadata in context_metadata:
        visual_flag = metadata.get('GraphicIncluded')
        page_number = metadata.get('pageNumber')
        page_text = metadata.get('text')
        message =""

        if visual_flag =='Y':
            # Include the image
            print(f"Adding page number {page_number} as an image to context")
            image_path = metadata.get('ImagePath', None)
            try:
                base64_image = encode_image(image_path)
                image_type = 'jpeg'
                # Prepare the messages for the API call
                context_messages.append({
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/{image_type};base64,{base64_image}"
                    },
                })
            except Exception as e:
                print(f"Error encoding image at {image_path}: {e}")
        else:
            # Include the text
            print(f"Adding page number {page_number} as text to context")
            context_messages.append({
                    "type": "text",
                    "text": f"Page {page_number} - {page_text}",
                })

                # Prepare the messages for the API call
        messages =  {
                "role": "user",
                "content": context_messages
        }

    message_content.append(messages)

    completion = oai_client.chat.completions.create(
    model="gpt-4o",
    messages=message_content
    )

    return completion.choices[0].message.content
```

Let's examine the same questions we asked for the text only semantic search in Step 5. We notice that the GPT-4o model can identify the diagram that has relevant information to answer the question.

```python
question = "What percentage was allocated to social protections in Western and Central Africa?"
answer = get_response_to_question_with_images(question, index)

print(answer)
```

Now let's ask a question that possibly cannot be answered by text-only modality, such as find a relevant image in the document and describe the image.

```python
question = "Can you find the image associated with digital improvements and describe what you see in the images?"
answer = get_response_to_question_with_images(question, index)

print(answer)
```

### Conclusion

In this cookbook, we embarked on a journey to enhance Retrieval-Augmented Generation (RAG) systems for documents rich in images, graphics and tables. Traditional RAG models, while proficient with textual data, often overlook the wealth of information conveyed through visual elements. By integrating vision models and leveraging metadata tagging, we've bridged this gap, enabling AI to interpret and utilize visual content effectively.

We began by setting up a vector store using Pinecone, establishing a foundation for efficient storage and retrieval of vector embeddings. Parsing PDFs and extracting visual information using GPT-4o vision modality allowed us to convert document pages into relevant text. By generating embeddings and flagging pages with visual content, we created a robust metadata filtering system within our vector store.

Uploading these embeddings to Pinecone facilitated seamless integration with our RAG processing workflow. Through semantic search, we retrieved relevant pages that matched user queries, ensuring that both textual and visual information were considered. Handling pages with visual content by passing them to vision models enhanced the accuracy and depth of the responses, particularly for queries dependent on images or tables.

Using the World Bank's **A Better Bank for a Better World: Annual Report 2024** as our guiding example, we demonstrated how these techniques come together to process and interpret complex documents. This approach not only enriches the information provided to users but also significantly enhances user satisfaction and engagement by delivering more comprehensive and accurate responses.

By following the concepts outlined in this cookbook, you are now equipped to build RAG systems capable of processing and interpreting documents with intricate visual elements. This advancement opens up new possibilities for AI applications across various domains where visual data plays a pivotal role.
