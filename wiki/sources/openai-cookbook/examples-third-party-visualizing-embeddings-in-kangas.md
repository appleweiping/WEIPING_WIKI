---
title: "Visualizing Embeddings In Kangas"
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
  - https://developers.openai.com/cookbook/examples/third_party/visualizing_embeddings_in_kangas
  - https://github.com/openai/openai-cookbook/blob/main/examples/third_party/Visualizing_embeddings_in_Kangas.ipynb
---

# Visualizing Embeddings In Kangas

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/third_party/visualizing_embeddings_in_kangas
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/third_party/Visualizing_embeddings_in_Kangas.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/third_party/Visualizing_embeddings_in_Kangas.ipynb
- Source path: `examples/third_party/Visualizing_embeddings_in_Kangas.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `5d8de28b14db3757d046536e1101ea36ba33f611e12aeeee499e977971a32279`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Visualizing the embeddings in Kangas In this Jupyter Notebook, we construct a Kangas DataGrid containing the data and projections of the embeddings into 2 dimensions. What is Kangas? Kangas as an open source, mixed-media, dataframe-like tool for data scientists. It was developed by Comet, a company designed to help reduce the friction of moving models into p...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

## Visualizing the embeddings in Kangas

In this Jupyter Notebook, we construct a Kangas DataGrid containing the data and projections of the embeddings into 2 dimensions.

## What is Kangas?

[Kangas](https://github.com/comet-ml/kangas/) as an open source, mixed-media, dataframe-like tool for data scientists. It was developed by [Comet](https://comet.com/), a company designed to help reduce the friction of moving models into production.

### 1. Setup

To get started, we pip install kangas, and import it.

```python
%pip install kangas --quiet
```

```python
import kangas as kg
```

### 2. Constructing a Kangas DataGrid

We create a Kangas Datagrid with the original data and the embeddings. The data is composed of a rows of reviews, and the embeddings are composed of 1536 floating-point values. In this example, we get the data directly from github, in case you aren't running this notebook inside OpenAI's repo.

We use Kangas to read the CSV file into a DataGrid for further processing.

```python
data = kg.read_csv("https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/data/fine_food_reviews_with_embeddings_1k.csv")
```

We can review the fields of the CSV file:

```python
data.info()
```

And get a glimpse of the first and last rows:

```python
data
```

Now, we create a new DataGrid, converting the numbers into an Embedding:

```python
import ast # to convert string of a list of numbers into a list of numbers

dg = kg.DataGrid(
    name="openai_embeddings",
    columns=data.get_columns(),
    converters={"Score": str},
)
for row in data:
    embedding = ast.literal_eval(row[8])
    row[8] = kg.Embedding(
        embedding,
        name=str(row[3]),
        text="%s - %.10s" % (row[3], row[4]),
        projection="umap",
    )
    dg.append(row)
```

The new DataGrid now has an Embedding column with proper datatype.

```python
dg.info()
```

We simply save the datagrid, and we're done.

```python
dg.save()
```

### 3. Render 2D Projections

To render the data directly in the notebook, simply show it. Note that each row contains an embedding projection.

Scroll to far right to see embeddings projection per row.

The color of the point in projection space represents the Score.

```python
dg.show()
```

Group by "Score" to see rows of each group.

```python
dg.show(group="Score", sort="Score", rows=5, select="Score,embedding")
```

An example of this datagrid is hosted here: https://kangas.comet.com/?datagrid=/data/openai_embeddings.datagrid
