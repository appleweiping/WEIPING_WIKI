---
title: "Rag With Graph Db"
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
  - https://developers.openai.com/cookbook/examples/rag_with_graph_db
  - https://github.com/openai/openai-cookbook/blob/main/examples/RAG_with_graph_db.ipynb
---

# Rag With Graph Db

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/rag_with_graph_db
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/RAG_with_graph_db.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/RAG_with_graph_db.ipynb
- Source path: `examples/RAG_with_graph_db.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `c935617662a1fb3a3e0adec32acad85370b0b15179ed4c59401e182eae5cf715`

## Classification

- Primary category: RAG / retrieval / vector databases
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Retrieval Augmented Generation with a Graph Database This notebook shows how to use LLMs in combination with Neo4j, a graph database, to perform Retrieval Augmented Generation (RAG). Why use RAG? If you want to use LLMs to generate answers based on your own content or knowledge base, instead of providing large context when prompting the model, you can fetch...

## What This Teaches

- How to connect OpenAI models with retrieval, embeddings, or external knowledge stores.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Retrieval Augmented Generation with a Graph Database

This notebook shows how to use LLMs in combination with [Neo4j](https://neo4j.com/), a graph database, to perform Retrieval Augmented Generation (RAG).

### Why use RAG?

If you want to use LLMs to generate answers based on your own content or knowledge base, instead of providing large context when prompting the model, you can fetch the relevant information in a database and use this information to generate a response.

This allows you to:
- Reduce hallucinations
- Provide relevant, up to date information to your users
- Leverage your own content/knowledge base

### Why use a graph database?

If you have data where relationships between data points are important and you might want to leverage that, then it might be worth considering graph databases instead of traditional relational databases.

Graph databases are good to address the following:
- Navigating deep hierarchies
- Finding hidden connections between items
- Discovering relationships between items

### Use cases

Graph databases are particularly relevant for recommendation systems, network relationships or analysing correlation between data points.

Example use cases for RAG with graph databases include:
- Recommendation chatbot
- AI-augmented CRM
- Tool to analyse customer behavior with natural language

Depending on your use case, you can assess whether using a graph database makes sense.

In this notebook, we will build a **product recommendation chatbot**, with a graph database that contains Amazon products data.

## Setup

We will start by installing and importing the relevant libraries.

Make sure you have your OpenAI account set up and you have your OpenAI API key handy.

```python
# Optional: run to install the libraries locally if you haven't already
!pip3 install langchain
!pip3 install openai
!pip3 install neo4j
```

```python
import os
import json
import pandas as pd
```

```python
# Optional: run to load environment variables from a .env file.
# This is not required if you have exported your env variables in another way or if you set it manually
!pip3 install python-dotenv
from dotenv import load_dotenv
load_dotenv()

# Set the OpenAI API key env variable manually
# os.environ["OPENAI_API_KEY"] = "<your_api_key>"

# print(os.environ["OPENAI_API_KEY"])
```

## Dataset

We will use a dataset that was created from a relational database and converted to a json format, creating relationships between entities with the completions API.

We will then load this data into the graph db to be able to query it.

### Loading dataset

```python
# Loading a json dataset from a file
file_path = 'data/amazon_product_kg.json'

with open(file_path, 'r') as file:
    jsonData = json.load(file)
```

```python
df =  pd.read_json(file_path)
df.head()
```

### Connecting to db

```python
# DB credentials
url = "bolt://localhost:7687"
username ="neo4j"
password = "<your_password_here>"
```

```python
from langchain.graphs import Neo4jGraph

graph = Neo4jGraph(
    url=url,
    username=username,
    password=password
)
```

### Importing data

```python
def sanitize(text):
    text = str(text).replace("'","").replace('"','').replace('{','').replace('}', '')
    return text

# Loop through each JSON object and add them to the db
i = 1
for obj in jsonData:
    print(f"{i}. {obj['product_id']} -{obj['relationship']}-> {obj['entity_value']}")
    i+=1
    query = f'''
        MERGE (product:Product {{id: {obj['product_id']}}})
        ON CREATE SET product.name = "{sanitize(obj['product'])}",
                       product.title = "{sanitize(obj['TITLE'])}",
                       product.bullet_points = "{sanitize(obj['BULLET_POINTS'])}",
                       product.size = {sanitize(obj['PRODUCT_LENGTH'])}

        MERGE (entity:{obj['entity_type']} {{value: "{sanitize(obj['entity_value'])}"}})

        MERGE (product)-[:{obj['relationship']}]->(entity)
        '''
    graph.query(query)
```

## Querying the database

### Creating vector indexes

In order to efficiently search our database for terms closely related to user queries, we need to use embeddings. To do this, we will create vector indexes on each type of property.

We will be using the OpenAIEmbeddings Langchain utility. It's important to note that Langchain adds a pre-processing step, so the embeddings will slightly differ from those generated directly with the OpenAI embeddings API.

```python
from langchain.vectorstores.neo4j_vector import Neo4jVector
from langchain.embeddings.openai import OpenAIEmbeddings
embeddings_model = "text-embedding-3-small"
```

```python
vector_index = Neo4jVector.from_existing_graph(
    OpenAIEmbeddings(model=embeddings_model),
    url=url,
    username=username,
    password=password,
    index_name='products',
    node_label="Product",
    text_node_properties=['name', 'title'],
    embedding_node_property='embedding',
)
```

```python
def embed_entities(entity_type):
    vector_index = Neo4jVector.from_existing_graph(
        OpenAIEmbeddings(model=embeddings_model),
        url=url,
        username=username,
        password=password,
        index_name=entity_type,
        node_label=entity_type,
        text_node_properties=['value'],
        embedding_node_property='embedding',
    )

entities_list = df['entity_type'].unique()

for t in entities_list:
    embed_entities(t)
```

### Querying the database directly

Using `GraphCypherQAChain`, we can generate queries against the database using Natural Language.

```python
from langchain.chains import GraphCypherQAChain
from langchain.chat_models import ChatOpenAI

chain = GraphCypherQAChain.from_llm(
    ChatOpenAI(temperature=0), graph=graph, verbose=True,
)
```

```python
chain.run("""
Help me find curtains
""")
```

### Extracting entities from the prompt

However, there is little added value here compared to just writing the Cypher queries ourselves, and it is prone to error.

Indeed, asking an LLM to generate a Cypher query directly might result in the wrong parameters being used, whether it's the entity type or the relationship type, as is the case above.

We will instead use LLMs to decide what to search for, and then generate the corresponding Cypher queries using templates.

For this purpose, we will instruct our model to find relevant entities in the user prompt that can be used to query our database.

```python
entity_types = {
    "product": "Item detailed type, for example 'high waist pants', 'outdoor plant pot', 'chef kitchen knife'",
    "category": "Item category, for example 'home decoration', 'women clothing', 'office supply'",
    "characteristic": "if present, item characteristics, for example 'waterproof', 'adhesive', 'easy to use'",
    "measurement": "if present, dimensions of the item",
    "brand": "if present, brand of the item",
    "color": "if present, color of the item",
    "age_group": "target age group for the product, one of 'babies', 'children', 'teenagers', 'adults'. If suitable for multiple age groups, pick the oldest (latter in the list)."
}

relation_types = {
    "hasCategory": "item is of this category",
    "hasCharacteristic": "item has this characteristic",
    "hasMeasurement": "item is of this measurement",
    "hasBrand": "item is of this brand",
    "hasColor": "item is of this color",
    "isFor": "item is for this age_group"
 }

entity_relationship_match = {
    "category": "hasCategory",
    "characteristic": "hasCharacteristic",
    "measurement": "hasMeasurement",
    "brand": "hasBrand",
    "color": "hasColor",
    "age_group": "isFor"
}
```

```python
system_prompt = f'''
    You are a helpful agent designed to fetch information from a graph database.

    The graph database links products to the following entity types:
    {json.dumps(entity_types)}

    Each link has one of the following relationships:
    {json.dumps(relation_types)}

    Depending on the user prompt, determine if it possible to answer with the graph database.

    The graph database can match products with multiple relationships to several entities.

    Example user input:
    "Which blue clothing items are suitable for adults?"

    There are three relationships to analyse:
    1. The mention of the blue color means we will search for a color similar to "blue"
    2. The mention of the clothing items means we will search for a category similar to "clothing"
    3. The mention of adults means we will search for an age_group similar to "adults"


    Return a json object following the following rules:
    For each relationship to analyse, add a key value pair with the key being an exact match for one of the entity types provided, and the value being the value relevant to the user query.

    For the example provided, the expected output would be:
    {{
        "color": "blue",
        "category": "clothing",
        "age_group": "adults"
    }}

    If there are no relevant entities in the user prompt, return an empty json object.
'''

print(system_prompt)
```

```python
from openai import OpenAI
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY", "<your OpenAI API key if not set as env var>"))

# Define the entities to look for
def define_query(prompt, model="gpt-4o"):
    completion = client.chat.completions.create(
        model=model,
        temperature=0,
        response_format= {
            "type": "json_object"
        },
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
example_queries = [
    "Which pink items are suitable for children?",
    "Help me find gardening gear that is waterproof",
    "I'm looking for a bench with dimensions 100x50 for my living room"
]

for q in example_queries:
    print(f"Q: '{q}'\n{define_query(q)}\n")
```

### Generating queries

Now that we know what to look for, we can generate the corresponding Cypher queries to query our database.

However, the entities extracted might not be an exact match with the data we have, so we will use the GDS cosine similarity function to return products that have relationships with entities similar to what the user is asking.

```python
def create_embedding(text):
    result = client.embeddings.create(model=embeddings_model, input=text)
    return result.data[0].embedding
```

```python
# The threshold defines how closely related words should be. Adjust the threshold to return more or less results
def create_query(text, threshold=0.81):
    query_data = json.loads(text)
    # Creating embeddings
    embeddings_data = []
    for key, val in query_data.items():
        if key != 'product':
            embeddings_data.append(f"${key}Embedding AS {key}Embedding")
    query = "WITH " + ",\n".join(e for e in embeddings_data)
    # Matching products to each entity
    query += "\nMATCH (p:Product)\nMATCH "
    match_data = []
    for key, val in query_data.items():
        if key != 'product':
            relationship = entity_relationship_match[key]
            match_data.append(f"(p)-[:{relationship}]->({key}Var:{key})")
    query += ",\n".join(e for e in match_data)
    similarity_data = []
    for key, val in query_data.items():
        if key != 'product':
            similarity_data.append(f"gds.similarity.cosine({key}Var.embedding, ${key}Embedding) > {threshold}")
    query += "\nWHERE "
    query += " AND ".join(e for e in similarity_data)
    query += "\nRETURN p"
    return query
```

```python
def query_graph(response):
    embeddingsParams = {}
    query = create_query(response)
    query_data = json.loads(response)
    for key, val in query_data.items():
        embeddingsParams[f"{key}Embedding"] = create_embedding(val)
    result = graph.query(query, params=embeddingsParams)
    return result
```

```python
example_response = '''{
    "category": "clothes",
    "color": "blue",
    "age_group": "adults"
}'''

result = query_graph(example_response)
```

```python
# Result
print(f"Found {len(result)} matching product(s):\n")
for r in result:
    print(f"{r['p']['name']} ({r['p']['id']})")
```

### Finding similar items

We can then leverage the graph db to find similar products based on common characteristics.

This is where the use of a graph db really comes into play.

For example, we can look for products that are the same category and have another characteristic in common, or find products that have relationships to the same entities.

This criteria is arbitrary and completely depends on what is the most relevant in relation to your use case.

```python
# Adjust the relationships_threshold to return products that have more or less relationships in common
def query_similar_items(product_id, relationships_threshold = 3):

    similar_items = []

    # Fetching items in the same category with at least 1 other entity in common
    query_category = '''
            MATCH (p:Product {id: $product_id})-[:hasCategory]->(c:category)
            MATCH (p)-->(entity)
            WHERE NOT entity:category
            MATCH (n:Product)-[:hasCategory]->(c)
            MATCH (n)-->(commonEntity)
            WHERE commonEntity = entity AND p.id <> n.id
            RETURN DISTINCT n;
        '''


    result_category = graph.query(query_category, params={"product_id": int(product_id)})
    #print(f"{len(result_category)} similar items of the same category were found.")

    # Fetching items with at least n (= relationships_threshold) entities in common
    query_common_entities = '''
        MATCH (p:Product {id: $product_id})-->(entity),
            (n:Product)-->(entity)
            WHERE p.id <> n.id
            WITH n, COUNT(DISTINCT entity) AS commonEntities
            WHERE commonEntities >= $threshold
            RETURN n;
        '''
    result_common_entities = graph.query(query_common_entities, params={"product_id": int(product_id), "threshold": relationships_threshold})
    #print(f"{len(result_common_entities)} items with at least {relationships_threshold} things in common were found.")

    for i in result_category:
        similar_items.append({
            "id": i['n']['id'],
            "name": i['n']['name']
        })

    for i in result_common_entities:
        result_id = i['n']['id']
        if not any(item['id'] == result_id for item in similar_items):
            similar_items.append({
                "id": result_id,
                "name": i['n']['name']
            })
    return similar_items
```

```python
product_ids = ['1519827', '2763742']

for product_id in product_ids:
    print(f"Similar items for product #{product_id}:\n")
    result = query_similar_items(product_id)
    print("\n")
    for r in result:
        print(f"{r['name']} ({r['id']})")
    print("\n\n")
```

## Final result

Now that we have all the pieces working, we will stitch everything together.

We can also add a fallback option to do a product name/title similarity search if we can't find relevant entities in the user prompt.

We will explore 2 options, one with a Langchain agent for a conversational experience, and one that is more deterministic based on code only.

Depending on your use case, you might choose one or the other option and tailor it to your needs.

```python
def query_db(params):
    matches = []
    # Querying the db
    result = query_graph(params)
    for r in result:
        product_id = r['p']['id']
        matches.append({
            "id": product_id,
            "name":r['p']['name']
        })
    return matches
```

```python
def similarity_search(prompt, threshold=0.8):
    matches = []
    embedding = create_embedding(prompt)
    query = '''
            WITH $embedding AS inputEmbedding
            MATCH (p:Product)
            WHERE gds.similarity.cosine(inputEmbedding, p.embedding) > $threshold
            RETURN p
            '''
    result = graph.query(query, params={'embedding': embedding, 'threshold': threshold})
    for r in result:
        product_id = r['p']['id']
        matches.append({
            "id": product_id,
            "name":r['p']['name']
        })
    return matches
```

```python
prompt_similarity = "I'm looking for nice curtains"
print(similarity_search(prompt_similarity))
```

### Building a Langchain agent

We will create a Langchain agent to handle conversations and probing the user for more context.

We need to define exactly how the agent should behave, and give it access to our query and similarity search tools.

```python
from langchain.agents import Tool, AgentExecutor, LLMSingleActionAgent, AgentOutputParser
from langchain.schema import AgentAction, AgentFinish, HumanMessage, SystemMessage


tools = [
    Tool(
        name="Query",
        func=query_db,
        description="Use this tool to find entities in the user prompt that can be used to generate queries"
    ),
    Tool(
        name="Similarity Search",
        func=similarity_search,
        description="Use this tool to perform a similarity search with the products in the database"
    )
]

tool_names = [f"{tool.name}: {tool.description}" for tool in tools]
```

```python
from langchain.prompts import StringPromptTemplate
from typing import Callable


prompt_template = '''Your goal is to find a product in the database that best matches the user prompt.
You have access to these tools:

{tools}

Use the following format:

Question: the input prompt from the user
Thought: you should always think about what to do
Action: the action to take (refer to the rules below)
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Rules to follow:

1. Start by using the Query tool with the prompt as parameter. If you found results, stop here.
2. If the result is an empty array, use the similarity search tool with the full initial user prompt. If you found results, stop here.
3. If you cannot still cannot find the answer with this, probe the user to provide more context on the type of product they are looking for.

Keep in mind that we can use entities of the following types to search for products:

{entity_types}.

3. Repeat Step 1 and 2. If you found results, stop here.

4. If you cannot find the final answer, say that you cannot help with the question.

Never return results if you did not find any results in the array returned by the query tool or the similarity search tool.

If you didn't find any result, reply: "Sorry, I didn't find any suitable products."

If you found results from the database, this is your final answer, reply to the user by announcing the number of results and returning results in this format (each new result should be on a new line):

name_of_the_product (id_of_the_product)"

Only use exact names and ids of the products returned as results when providing your final answer.


User prompt:
{input}

{agent_scratchpad}

'''

# Set up a prompt template
class CustomPromptTemplate(StringPromptTemplate):
    # The template to use
    template: str

    def format(self, **kwargs) -> str:
        # Get the intermediate steps (AgentAction, Observation tuples)
        # Format them in a particular way
        intermediate_steps = kwargs.pop("intermediate_steps")
        thoughts = ""
        for action, observation in intermediate_steps:
            thoughts += action.log
            thoughts += f"\nObservation: {observation}\nThought: "
        # Set the agent_scratchpad variable to that value
        kwargs["agent_scratchpad"] = thoughts
        ############## NEW ######################
        #tools = self.tools_getter(kwargs["input"])
        # Create a tools variable from the list of tools provided
        kwargs["tools"] = "\n".join(
            [f"{tool.name}: {tool.description}" for tool in tools]
        )
        # Create a list of tool names for the tools provided
        kwargs["tool_names"] = ", ".join([tool.name for tool in tools])
        kwargs["entity_types"] = json.dumps(entity_types)
        return self.template.format(**kwargs)


prompt = CustomPromptTemplate(
    template=prompt_template,
    tools=tools,
    input_variables=["input", "intermediate_steps"],
)
```

```python
from typing import List, Union
import re

class CustomOutputParser(AgentOutputParser):

    def parse(self, llm_output: str) -> Union[AgentAction, AgentFinish]:

        # Check if agent should finish
        if "Final Answer:" in llm_output:
            return AgentFinish(
                # Return values is generally always a dictionary with a single `output` key
                # It is not recommended to try anything else at the moment :)
                return_values={"output": llm_output.split("Final Answer:")[-1].strip()},
                log=llm_output,
            )

        # Parse out the action and action input
        regex = r"Action: (.*?)[\n]*Action Input:[\s]*(.*)"
        match = re.search(regex, llm_output, re.DOTALL)

        # If it can't parse the output it raises an error
        # You can add your own logic here to handle errors in a different way i.e. pass to a human, give a canned response
        if not match:
            raise ValueError(f"Could not parse LLM output: `{llm_output}`")
        action = match.group(1).strip()
        action_input = match.group(2)

        # Return the action and action input
        return AgentAction(tool=action, tool_input=action_input.strip(" ").strip('"'), log=llm_output)

output_parser = CustomOutputParser()
```

```python
from langchain.chat_models import ChatOpenAI
from langchain import LLMChain
from langchain.agents.output_parsers.openai_tools import OpenAIToolsAgentOutputParser


llm = ChatOpenAI(temperature=0, model="gpt-4o")

# LLM chain consisting of the LLM and a prompt
llm_chain = LLMChain(llm=llm, prompt=prompt)

# Using tools, the LLM chain and output_parser to make an agent
tool_names = [tool.name for tool in tools]

agent = LLMSingleActionAgent(
    llm_chain=llm_chain,
    output_parser=output_parser,
    stop=["\Observation:"],
    allowed_tools=tool_names
)


agent_executor = AgentExecutor.from_agent_and_tools(agent=agent, tools=tools, verbose=True)
```

```python
def agent_interaction(user_prompt):
    agent_executor.run(user_prompt)
```

```python
prompt1 = "I'm searching for pink shirts"
agent_interaction(prompt1)
```

```python
prompt2 = "Can you help me find a toys for my niece, she's 8"
agent_interaction(prompt2)
```

```python
prompt3 = "I'm looking for nice curtains"
agent_interaction(prompt3)
```

### Building a code-only experience

As our experiments show, using an agent for this type of task might not be the best option.

Indeed, the agent seems to retrieve results from the tools, but comes up with made-up responses.

For this specific use case, if the conversational aspect is less relevant, we can actually create a function that will call our previously-defined tasks and provide an answer.

```python
import logging

def answer(prompt, similar_items_limit=10):
    print(f'Prompt: "{prompt}"\n')
    params = define_query(prompt)
    print(params)
    result = query_db(params)
    print(f"Found {len(result)} matches with Query function.\n")
    if len(result) == 0:
        result = similarity_search(prompt)
        print(f"Found {len(result)} matches with Similarity search function.\n")
        if len(result) == 0:
            return "I'm sorry, I did not find a match. Please try again with a little bit more details."
    print(f"I have found {len(result)} matching items:\n")
    similar_items = []
    for r in result:
        similar_items.extend(query_similar_items(r['id']))
        print(f"{r['name']} ({r['id']})")
    print("\n")
    if len(similar_items) > 0:
        print("Similar items that might interest you:\n")
        for i in similar_items[:similar_items_limit]:
            print(f"{i['name']} ({i['id']})")
    print("\n\n\n")
    return result
```

```python
prompt1 = "I'm looking for food items to gift to someone for Christmas. Ideally chocolate."
answer(prompt1)

prompt2 = "Help me find women clothes for my wife. She likes blue."
answer(prompt2)

prompt3 = "I'm looking for nice things to decorate my living room."
answer(prompt3)

prompt4 = "Can you help me find a gift for my niece? She's 8 and she likes pink."
answer(prompt4)
```

## Conclusion

### User experience

When the primary objective is to extract specific information from our database, Large Language Models (LLMs) can significantly enhance our querying capabilities.

However, it's crucial to base much of this process on robust code logic to ensure a foolproof user experience.

For crafting a genuinely conversational chatbot, further exploration in prompt engineering is necessary, possibly incorporating few-shot examples. This approach helps mitigate the risk of generating inaccurate or misleading information and ensures more precise responses.

Ultimately, the design choice depends on the desired user experience. For instance, if the aim is to create a visual recommendation system, the importance of a conversational interface is less relevant.

### Working with a knowledge graph

Retrieving content from a knowledge graph adds complexity but can be useful if you want to leverage connections between items.

The querying part of this notebook would work on a relational database as well, the knowledge graph comes in handy when we want to couple the results with similar items that the graph is surfacing.

Considering the added complexity, make sure using a knowledge graph is the best option for your use case.
If it is the case, feel free to refine what this cookbook presents to match your needs and perform even better!
