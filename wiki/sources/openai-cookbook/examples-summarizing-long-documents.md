---
title: "Summarizing Long Documents"
type: source
status: mirrored
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/summarizing_long_documents
  - https://github.com/openai/openai-cookbook/blob/main/examples/Summarizing_long_documents.ipynb
---

# Summarizing Long Documents

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/summarizing_long_documents
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Summarizing_long_documents.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Summarizing_long_documents.ipynb
- Source path: `examples/Summarizing_long_documents.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `886c3d3736fbb225b0b0eb6693bdf28cbae53d7cfc242a16aeb845d685a4011d`

## Classification

- Primary category: General OpenAI API patterns
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Summarizing Long Documents The objective of this notebook is to demonstrate how to summarize large documents with a controllable level of detail. If you give a GPT model the task of summarizing a long document (e.g. 10k or more tokens), you'll tend to get back a relatively short summary that isn't proportional to the length of the document. For instance, a s...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: General OpenAI API patterns.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Summarizing Long Documents

The objective of this notebook is to demonstrate how to summarize large documents with a controllable level of detail.

If you give a GPT model the task of summarizing a long document (e.g. 10k or more tokens), you'll tend to get back a relatively short summary that isn't proportional to the length of the document. For instance, a summary of a 20k token document will not be twice as long as a summary of a 10k token document. One way we can fix this is to split our document up into pieces, and produce a summary piecewise. After many queries to a GPT model, the full summary can be reconstructed. By controlling the number of text chunks and their sizes, we can ultimately control the level of detail in the output.

```python
import os
from typing import List, Tuple, Optional
from openai import OpenAI
import tiktoken
from tqdm import tqdm
```

```python
# open dataset containing part of the text of the Wikipedia page for the United States
with open("data/artificial_intelligence_wikipedia.txt", "r") as file:
    artificial_intelligence_wikipedia_text = file.read()
```

```python
# load encoding and check the length of dataset
encoding = tiktoken.encoding_for_model('gpt-4-turbo')
len(encoding.encode(artificial_intelligence_wikipedia_text))
```

We'll define a simple utility to wrap calls to the OpenAI API.

```python
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def get_chat_completion(messages, model='gpt-4-turbo'):
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=0,
    )
    return response.choices[0].message.content
```

Next we'll define some utilities to chunk a large document into smaller pieces.

```python
def tokenize(text: str) -> List[str]:
    encoding = tiktoken.encoding_for_model('gpt-4-turbo')
    return encoding.encode(text)


# This function chunks a text into smaller pieces based on a maximum token count and a delimiter.
def chunk_on_delimiter(input_string: str,
                       max_tokens: int, delimiter: str) -> List[str]:
    chunks = input_string.split(delimiter)
    combined_chunks, _, dropped_chunk_count = combine_chunks_with_no_minimum(
        chunks, max_tokens, chunk_delimiter=delimiter, add_ellipsis_for_overflow=True
    )
    if dropped_chunk_count > 0:
        print(f"warning: {dropped_chunk_count} chunks were dropped due to overflow")
    combined_chunks = [f"{chunk}{delimiter}" for chunk in combined_chunks]
    return combined_chunks


# This function combines text chunks into larger blocks without exceeding a specified token count. It returns the combined text blocks, their original indices, and the count of chunks dropped due to overflow.
def combine_chunks_with_no_minimum(
        chunks: List[str],
        max_tokens: int,
        chunk_delimiter="\n\n",
        header: Optional[str] = None,
        add_ellipsis_for_overflow=False,
) -> Tuple[List[str], List[int&#93;&#93;:
    dropped_chunk_count = 0
    output = []  # list to hold the final combined chunks
    output_indices = []  # list to hold the indices of the final combined chunks
    candidate = (
        [] if header is None else [header]
    )  # list to hold the current combined chunk candidate
    candidate_indices = []
    for chunk_i, chunk in enumerate(chunks):
        chunk_with_header = [chunk] if header is None else [header, chunk]
        if len(tokenize(chunk_delimiter.join(chunk_with_header))) > max_tokens:
            print(f"warning: chunk overflow")
            if (
                    add_ellipsis_for_overflow
                    and len(tokenize(chunk_delimiter.join(candidate + ["..."]))) <= max_tokens
            ):
                candidate.append("...")
                dropped_chunk_count += 1
            continue  # this case would break downstream assumptions
        # estimate token count with the current chunk added
        extended_candidate_token_count = len(tokenize(chunk_delimiter.join(candidate + [chunk])))
        # If the token count exceeds max_tokens, add the current candidate to output and start a new candidate
        if extended_candidate_token_count > max_tokens:
            output.append(chunk_delimiter.join(candidate))
            output_indices.append(candidate_indices)
            candidate = chunk_with_header  # re-initialize candidate
            candidate_indices = [chunk_i]
        # otherwise keep extending the candidate
        else:
            candidate.append(chunk)
            candidate_indices.append(chunk_i)
    # add the remaining candidate to output if it's not empty
    if (header is not None and len(candidate) > 1) or (header is None and len(candidate) > 0):
        output.append(chunk_delimiter.join(candidate))
        output_indices.append(candidate_indices)
    return output, output_indices, dropped_chunk_count
```

Now we can define a utility to summarize text with a controllable level of detail (note the `detail` parameter).

The function first determines the number of chunks by interpolating between a minimum and a maximum chunk count based on a controllable `detail` parameter. It then splits the text into chunks and summarizes each chunk.

```python
def summarize(text: str,
              detail: float = 0,
              model: str = 'gpt-4-turbo',
              additional_instructions: Optional[str] = None,
              minimum_chunk_size: Optional[int] = 500,
              chunk_delimiter: str = ".",
              summarize_recursively=False,
              verbose=False):
    """
    Summarizes a given text by splitting it into chunks, each of which is summarized individually.
    The level of detail in the summary can be adjusted, and the process can optionally be made recursive.

    Parameters:
    - text (str): The text to be summarized.
    - detail (float, optional): A value between 0 and 1 indicating the desired level of detail in the summary.
      0 leads to a higher level summary, and 1 results in a more detailed summary. Defaults to 0.
    - model (str, optional): The model to use for generating summaries. Defaults to 'gpt-3.5-turbo'.
    - additional_instructions (Optional[str], optional): Additional instructions to provide to the model for customizing summaries.
    - minimum_chunk_size (Optional[int], optional): The minimum size for text chunks. Defaults to 500.
    - chunk_delimiter (str, optional): The delimiter used to split the text into chunks. Defaults to ".".
    - summarize_recursively (bool, optional): If True, summaries are generated recursively, using previous summaries for context.
    - verbose (bool, optional): If True, prints detailed information about the chunking process.

    Returns:
    - str: The final compiled summary of the text.

    The function first determines the number of chunks by interpolating between a minimum and a maximum chunk count based on the `detail` parameter.
    It then splits the text into chunks and summarizes each chunk. If `summarize_recursively` is True, each summary is based on the previous summaries,
    adding more context to the summarization process. The function returns a compiled summary of all chunks.
    """

    # check detail is set correctly
    assert 0 <= detail <= 1

    # interpolate the number of chunks based to get specified level of detail
    max_chunks = len(chunk_on_delimiter(text, minimum_chunk_size, chunk_delimiter))
    min_chunks = 1
    num_chunks = int(min_chunks + detail * (max_chunks - min_chunks))

    # adjust chunk_size based on interpolated number of chunks
    document_length = len(tokenize(text))
    chunk_size = max(minimum_chunk_size, document_length // num_chunks)
    text_chunks = chunk_on_delimiter(text, chunk_size, chunk_delimiter)
    if verbose:
        print(f"Splitting the text into {len(text_chunks)} chunks to be summarized.")
        print(f"Chunk lengths are {[len(tokenize(x)) for x in text_chunks]}")

    # set system message
    system_message_content = "Rewrite this text in summarized form."
    if additional_instructions is not None:
        system_message_content += f"\n\n{additional_instructions}"

    accumulated_summaries = []
    for chunk in tqdm(text_chunks):
        if summarize_recursively and accumulated_summaries:
            # Creating a structured prompt for recursive summarization
            accumulated_summaries_string = '\n\n'.join(accumulated_summaries)
            user_message_content = f"Previous summaries:\n\n{accumulated_summaries_string}\n\nText to summarize next:\n\n{chunk}"
        else:
            # Directly passing the chunk for summarization without recursive context
            user_message_content = chunk

        # Constructing messages based on whether recursive summarization is applied
        messages = [
            {"role": "system", "content": system_message_content},
            {"role": "user", "content": user_message_content}
        ]

        # Assuming this function gets the completion and works as expected
        response = get_chat_completion(messages, model=model)
        accumulated_summaries.append(response)

    # Compile final summary from partial summaries
    final_summary = '\n\n'.join(accumulated_summaries)

    return final_summary
```

Now we can use this utility to produce summaries with varying levels of detail. By increasing `detail` from 0 to 1 we get progressively longer summaries of the underlying document. A higher value for the `detail` parameter results in a more detailed summary because the utility first splits the document into a greater number of chunks. Each chunk is then summarized, and the final summary is a concatenation of all the chunk summaries.

```python
summary_with_detail_0 = summarize(artificial_intelligence_wikipedia_text, detail=0, verbose=True)
```

```python
summary_with_detail_pt25 = summarize(artificial_intelligence_wikipedia_text, detail=0.25, verbose=True)
```

```python
summary_with_detail_pt5 = summarize(artificial_intelligence_wikipedia_text, detail=0.5, verbose=True)
```

```python
summary_with_detail_1 = summarize(artificial_intelligence_wikipedia_text, detail=1, verbose=True)
```

The original document is nearly 15k tokens long. Notice how large the gap is between the length of `summary_with_detail_0` and `summary_with_detail_1`. It's nearly 25 times longer!

```python
# lengths of summaries
[len(tokenize(x)) for x in
 [summary_with_detail_0, summary_with_detail_pt25, summary_with_detail_pt5, summary_with_detail_1&#93;&#93;
```

Let's inspect the summaries to see how the level of detail changes when the `detail` parameter is increased from 0 to 1.

```python
print(summary_with_detail_0)
```

```python
print(summary_with_detail_1)
```

Note that this utility also allows passing additional instructions.

```python
summary_with_additional_instructions = summarize(artificial_intelligence_wikipedia_text, detail=0.1,
                                                 additional_instructions="Write in point form and focus on numerical data.")
print(summary_with_additional_instructions)
```

Finally, note that the utility allows for recursive summarization, where each summary is based on the previous summaries, adding more context to the summarization process. This can be enabled by setting the `summarize_recursively` parameter to True. This is more computationally expensive, but can increase consistency and coherence of the combined summary.

```python
recursive_summary = summarize(artificial_intelligence_wikipedia_text, detail=0.1, summarize_recursively=True)
print(recursive_summary)
```
