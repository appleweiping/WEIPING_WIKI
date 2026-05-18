---
title: "Search Reranking With Cross Encoders"
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
  - https://developers.openai.com/cookbook/examples/search_reranking_with_cross-encoders
  - https://github.com/openai/openai-cookbook/blob/main/examples/Search_reranking_with_cross-encoders.ipynb
---

# Search Reranking With Cross Encoders

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/search_reranking_with_cross-encoders
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/Search_reranking_with_cross-encoders.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/Search_reranking_with_cross-encoders.ipynb
- Source path: `examples/Search_reranking_with_cross-encoders.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `f8d5cc4515b7003fcca934657f8064dd1020b0b0bb43254ad9c980dfc9948278`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Search reranking with cross-encoders This notebook takes you through examples of using a cross-encoder to re-rank search results. This is a common use case with our customers, where you've implemented semantic search using embeddings (produced using a bi-encoder) but the results are not as accurate as your use case requires. A possible cause is that there is...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Search reranking with cross-encoders

This notebook takes you through examples of using a cross-encoder to re-rank search results.

This is a common use case with our customers, where you've implemented semantic search using embeddings (produced using a [bi-encoder](https://www.sbert.net/examples/applications/retrieve_rerank/README.html#retrieval-bi-encoder)) but the results are not as accurate as your use case requires. A possible cause is that there is some business rule you can use to rerank the documents such as how recent or how popular a document is.

However, often there are subtle domain-specific rules that help determine relevancy, and this is where a cross-encoder can be useful. Cross-encoders are more accurate than bi-encoders but they don't scale well, so using them to re-order a shortened list returned by semantic search is the ideal use case.

### Example

Consider a search task with D documents and Q queries.

The brute force approach of computing every pairwise relevance is expensive; its cost scales as ```D * Q```. This is known as **cross-encoding**.

A faster approach is **embeddings-based search**, in which an embedding is computed once for each document and query, and then re-used multiple times to cheaply compute pairwise relevance. Because embeddings are only computed once, its cost scales as ```D + Q```. This is known as **bi-encoding**.

Although embeddings-based search is faster, the quality can be worse. To get the best of both, one common approach is to use embeddings (or another bi-encoder) to cheaply identify top candidates, and then use GPT (or another cross-encoder) to expensively re-rank those top candidates. The cost of this hybrid approach scales as ```(D + Q) * cost of embedding + (N * Q) * cost of re-ranking```, where ```N``` is the number of candidates re-ranked.

### Walkthrough

To illustrate this approach we'll use ```text-davinci-003``` with ```logprobs``` enabled to build a GPT-powered cross-encoder. Our GPT models have strong general language understanding, which when tuned with some few-shot examples can provide a simple and effective cross-encoding option.

This notebook drew on this great [article](https://weaviate.io/blog/cross-encoders-as-reranker) by Weaviate, and this [excellent explanation](https://www.sbert.net/examples/applications/cross-encoder/README.html) of bi-encoders vs. cross-encoders from Sentence Transformers.

```python
!pip install openai
!pip install arxiv
!pip install tenacity
!pip install pandas
!pip install tiktoken
```

```python
import arxiv
from math import exp
import openai
import os
import pandas as pd
from tenacity import retry, wait_random_exponential, stop_after_attempt
import tiktoken

client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))

OPENAI_MODEL = "gpt-4"
```

## Search

We'll use the arXiv search service for this example, but this step could be performed by any search service you have. The key item to consider is over-fetching slightly to capture all the potentially relevant documents, before re-sorting them.

```python
query = "how do bi-encoders work for sentence embeddings"
search = arxiv.Search(
    query=query, max_results=20, sort_by=arxiv.SortCriterion.Relevance
)
```

```python
result_list = []

for result in search.results():
    result_dict = {}

    result_dict.update({"title": result.title})
    result_dict.update({"summary": result.summary})

    # Taking the first url provided
    result_dict.update({"article_url": [x.href for x in result.links][0]})
    result_dict.update({"pdf_url": [x.href for x in result.links][1]})
    result_list.append(result_dict)
```

```python
result_list[0]
```

```python
for i, result in enumerate(result_list):
    print(f"{i + 1}: {result['title']}")
```

## Cross-encoder

We'll create a cross-encoder using the ```Completions``` endpoint - the key factors to consider here are:
- Make your examples domain-specific - the strength of cross-encoders comes when you tailor them to your domain.
- There is a trade-off between how many potential examples to re-rank vs. processing speed. Consider batching and parallel processing cross-encoder requests to process them more quickly.

The steps here are:
- Build a prompt to assess relevance and provide few-shot examples to tune it to your domain.
- Add a ```logit bias``` for the tokens for ``` Yes``` and ``` No``` to decrease the likelihood of any other tokens occurring.
- Return the classification of yes/no as well as the ```logprobs```.
- Rerank the results by the ```logprobs``` keyed on ``` Yes```.

```python
tokens = [" Yes", " No"]
tokenizer = tiktoken.encoding_for_model(OPENAI_MODEL)
ids = [tokenizer.encode(token) for token in tokens]
ids[0], ids[1]
```

```python
prompt = '''
You are an Assistant responsible for helping detect whether the retrieved document is relevant to the query. For a given input, you need to output a single token: "Yes" or "No" indicating the retrieved document is relevant to the query.

Query: How to plant a tree?
Document: """Cars were invented in 1886, when German inventor Carl Benz patented his Benz Patent-Motorwagen.[3][4][5] Cars became widely available during the 20th century. One of the first cars affordable by the masses was the 1908 Model T, an American car manufactured by the Ford Motor Company. Cars were rapidly adopted in the US, where they replaced horse-drawn carriages.[6] In Europe and other parts of the world, demand for automobiles did not increase until after World War II.[7] The car is considered an essential part of the developed economy."""
Relevant: No

Query: Has the coronavirus vaccine been approved?
Document: """The Pfizer-BioNTech COVID-19 vaccine was approved for emergency use in the United States on December 11, 2020."""
Relevant: Yes

Query: What is the capital of France?
Document: """Paris, France's capital, is a major European city and a global center for art, fashion, gastronomy and culture. Its 19th-century cityscape is crisscrossed by wide boulevards and the River Seine. Beyond such landmarks as the Eiffel Tower and the 12th-century, Gothic Notre-Dame cathedral, the city is known for its cafe culture and designer boutiques along the Rue du Faubourg Saint-Honoré."""
Relevant: Yes

Query: What are some papers to learn about PPO reinforcement learning?
Document: """Proximal Policy Optimization and its Dynamic Version for Sequence Generation: In sequence generation task, many works use policy gradient for model optimization to tackle the intractable backpropagation issue when maximizing the non-differentiable evaluation metrics or fooling the discriminator in adversarial learning. In this paper, we replace policy gradient with proximal policy optimization (PPO), which is a proved more efficient reinforcement learning algorithm, and propose a dynamic approach for PPO (PPO-dynamic). We demonstrate the efficacy of PPO and PPO-dynamic on conditional sequence generation tasks including synthetic experiment and chit-chat chatbot. The results show that PPO and PPO-dynamic can beat policy gradient by stability and performance."""
Relevant: Yes

Query: Explain sentence embeddings
Document: """Inside the bubble: exploring the environments of reionisation-era Lyman-α emitting galaxies with JADES and FRESCO: We present a study of the environments of 16 Lyman-α emitting galaxies (LAEs) in the reionisation era (5.8<z<8) identified by JWST/NIRSpec as part of the JWST Advanced Deep Extragalactic Survey (JADES). Unless situated in sufficiently (re)ionised regions, Lyman-α emission from these galaxies would be strongly absorbed by neutral gas in the intergalactic medium (IGM). We conservatively estimate sizes of the ionised regions required to reconcile the relatively low Lyman-α velocity offsets (ΔvLyα<300kms−1) with moderately high Lyman-α escape fractions (fesc,Lyα>5%) observed in our sample of LAEs, indicating the presence of ionised ``bubbles'' with physical sizes of the order of 0.1pMpc≲Rion≲1pMpc in a patchy reionisation scenario where the bubbles are embedded in a fully neutral IGM. Around half of the LAEs in our sample are found to coincide with large-scale galaxy overdensities seen in FRESCO at z∼5.8-5.9 and z∼7.3, suggesting Lyman-α transmission is strongly enhanced in such overdense regions, and underlining the importance of LAEs as tracers of the first large-scale ionised bubbles. Considering only spectroscopically confirmed galaxies, we find our sample of UV-faint LAEs (MUV≳−20mag) and their direct neighbours are generally not able to produce the required ionised regions based on the Lyman-α transmission properties, suggesting lower-luminosity sources likely play an important role in carving out these bubbles. These observations demonstrate the combined power of JWST multi-object and slitless spectroscopy in acquiring a unique view of the early stages of Cosmic Reionisation via the most distant LAEs."""
Relevant: No

Query: {query}
Document: """{document}"""
Relevant:
'''


@retry(wait=wait_random_exponential(min=1, max=40), stop=stop_after_attempt(3))
def document_relevance(query, document):
    response = openai.chat.completions.create(
        model="text-davinci-003",
        message=prompt.format(query=query, document=document),
        temperature=0,
        logprobs=True,
        logit_bias={3363: 1, 1400: 1},
    )

    return (
        query,
        document,
        response.choices[0].message.content,
        response.choices[0].logprobs.token_logprobs[0],
    )
```

```python
content = result_list[0]["title"] + ": " + result_list[0]["summary"]

# Set logprobs to 1 so our response will include the most probable token the model identified
response = openai.chat.completions.create(
    model=OPENAI_MODEL,
    prompt=prompt.format(query=query, document=content),
    temperature=0,
    logprobs=1,
    logit_bias={3363: 1, 1400: 1},
    max_tokens=1,
)
```

```python
result = response.choices[0]
print(f"Result was {result.message.content}")
print(f"Logprobs was {result.logprobs.token_logprobs[0]}")
print("\nBelow is the full logprobs object\n\n")
print(result["logprobs"])
```

```python
output_list = []
for x in result_list:
    content = x["title"] + ": " + x["summary"]

    try:
        output_list.append(document_relevance(query, document=content))

    except Exception as e:
        print(e)
```

```python
output_list[:10]
```

```python
output_df = pd.DataFrame(
    output_list, columns=["query", "document", "prediction", "logprobs"]
).reset_index()
# Use exp() to convert logprobs into probability
output_df["probability"] = output_df["logprobs"].apply(exp)
# Reorder based on likelihood of being Yes
output_df["yes_probability"] = output_df.apply(
    lambda x: x["probability"] * -1 + 1
    if x["prediction"] == "No"
    else x["probability"],
    axis=1,
)
output_df.head()
```

```python
# Return reranked results
reranked_df = output_df.sort_values(
    by=["yes_probability"], ascending=False
).reset_index()
reranked_df.head(10)
```

```python
# Inspect our new top document following reranking
reranked_df["document"][0]
```

## Conclusion

We've shown how to create a tailored cross-encoder to rerank academic papers. This approach will work best where there are domain-specific nuances that can be used to pick the most relevant corpus for your users, and where some pre-filtering has taken place to limit the amount of data the cross-encoder will need to process.

A few typical use cases we've seen are:
- Returning a list of 100 most relevant stock reports, then re-ordering into a top 5 or 10 based on the detailed context of a particular set of customer portfolios
- Running after a classic rules-based search that gets the top 100 or 1000 most relevant results to prune it according to a specific user's context


### Taking this forward

Taking the few-shot approach, as we have here, can work well when the domain is general enough that a small number of examples will cover most reranking cases. However, as the differences between documents become more specific you may want to consider the ```Fine-tuning``` endpoint to make a more elaborate cross-encoder with a wider variety of examples.

There is also a latency impact of using ```text-davinci-003``` that you'll need to consider, with even our few examples above taking a couple seconds each - again, the ```Fine-tuning``` endpoint may help you here if you are able to get decent results from an ```ada``` or ```babbage``` fine-tuned model.

We've used the ```Completions``` endpoint from OpenAI to build our cross-encoder, but this area is well-served by the open-source community. [Here](https://huggingface.co/jeffwan/mmarco-mMiniLMv2-L12-H384-v1) is an example from HuggingFace, for example.

We hope you find this useful for tuning your search use cases, and look forward to seeing what you build.
