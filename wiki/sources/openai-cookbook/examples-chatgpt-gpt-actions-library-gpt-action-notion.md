---
title: "Gpt Action Notion"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - chatgpt
  - cookbook
  - example
  - gpt-actions
  - notebook
  - openai
source_pages:
  - https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/gpt_action_notion
  - https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/gpt_action_notion.ipynb
---

# Gpt Action Notion

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/gpt_action_notion
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/gpt_action_notion.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/chatgpt/gpt_actions_library/gpt_action_notion.ipynb
- Source path: `examples/chatgpt/gpt_actions_library/gpt_action_notion.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `a1e6ee4f65fe9810ecdbac2460c144d6941160685feb17cea6351b8e234dcda6`

## Classification

- Primary category: ChatGPT / GPT Actions
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

GPT Action Library: Notion Introduction This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information: - Introduction to GPT Actions - Introduction to GPT Actions Library - Example of Buliding a GPT Action from Scratch This...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: ChatGPT / GPT Actions.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# GPT Action Library: Notion

## Introduction

This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information:
- [Introduction to GPT Actions](https://platform.openai.com/docs/actions)
- [Introduction to GPT Actions Library](https://platform.openai.com/docs/actions/actions-library)
- [Example of Buliding a GPT Action from Scratch](https://platform.openai.com/docs/actions/getting-started)

This particular GPT Action provides an overview of how to connect to **Notion**. This Action takes a user’s question, scans the relevant Notion pages using Notions search functionality, and then returns information on the matching pages.

### Value + Example Business Use Cases

**Value**: Users can now harness ChatGPT’s natural language capabilities to directly connect to, query, and synthesize their knowledge within Notion. Administrators can explicitly share pages with the integration to manage access.

**Example Use Cases**:
- A new employee seeks quick how-to information on setting up a new system
- A support agent needs to quickly retrieve information from Notion without reading the entire document
- Users want to synthesize information and create summaries or transformations for use in other aspects of their work

## Application Information

### Application Key Links

Check out these links from the application before you get started:
- Application Website: https://www.notion.so/
- Application API Documentation: https://developers.notion.com/reference/intro
- Notion Authorization Approach: https://developers.notion.com/docs/authorization
    - NOTE:  Notion only allows OAuth with "Public Integrations."  Refer to the linked documentation to determine what is best suited for your needs

### Application Prerequisites

Before you get started, make sure you go through the following steps in your application environment:
- Set up a notion workspace with populated pages
- Sharing pages through notion works best with specific Wikis.  Consider organizing your knowledge base into a wiki or set of wikis

## ChatGPT Steps

### Custom GPT Instructions

Once you've created a Custom GPT, copy the text below in the Instructions panel. Have questions? Check out [Getting Started Example](https://cookbook.openai.com/examples/chatgpt/gpt_actions_library/.gpt_action_getting_started) to see how this step works in more detail.

```python
**Context**: You are a helpful chatbot focussed on retrieving information from a company's Notion. An administrator has given you access to a number of useful Notion pages.  You are to act similar to a librarian and be helpful answering and finding answers for users' questions.

**Instructions**:
1. Use the search functionality to find the most relevant page or pages.
- Display the top 3 pages.  Include a formatted list containing: Title, Last Edit Date, Author.
- The Title should be a link to that page.
1.a. If there are no relevant pages, reword the search and try again (up to 3x)
1.b. If there are no relevant pages after retries, return "I'm sorry, I cannot find the right info to help you with that question"
2. Open the most relevant article, retrieve and read all of the contents (including any relevant linked pages or databases), and provide a 3 sentence summary.  Always provide a quick summary before moving to the next step.
3. Ask the user if they'd like to see more detail.  If yes, provide it and offer to explore more relevant pages.

**Additional Notes**:
- If the user says "Let's get started", introduce yourself as a librarian for the Notion workspace, explain that the user can provide a topic or question, and that you will help to look for relevant pages.
- If there is a database on the page.  Always read the database when looking at page contents.
```

### OpenAPI Schema

Once you've created a Custom GPT, copy the text below in the Actions panel. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

```python
openapi: 3.1.0
info:
  title: Notion API
  description: API for interacting with Notion's pages, databases, and users.
  version: 1.0.0
servers:
  - url: https://api.notion.com/v1
    description: Main Notion API server
paths:
  /users:
    get:
      operationId: listAllUsers
      summary: List all users
      parameters:
        - name: Notion-Version
          in: header
          required: true
          schema:
            type: string
          example: 2022-06-28
          constant: 2022-06-28
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  results:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                        name:
                          type: string
                        avatar_url:
                          type: string
                        type:
                          type: string
  /blocks/{block_id}/children:
    get:
      operationId: retrieveBlockChildren
      summary: Retrieve block children
      parameters:
        - name: block_id
          in: path
          required: true
          schema:
            type: string
        - name: Notion-Version
          in: header
          required: true
          schema:
            type: string
          example: 2022-06-28
          constant: 2022-06-28
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  object:
                    type: string
                  results:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                        type:
                          type: string
                        has_children:
                          type: boolean
  /comments:
    get:
      operationId: retrieveComments
      summary: Retrieve comments
      parameters:
        - name: Notion-Version
          in: header
          required: true
          schema:
            type: string
          example: 2022-06-28
          constant: 2022-06-28
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  results:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                        text:
                          type: string
                        created_time:
                          type: string
                          format: date-time
                        created_by:
                          type: object
                          properties:
                            id:
                              type: string
                            name:
                              type: string
  /pages/{page_id}/properties/{property_id}:
    get:
      operationId: retrievePagePropertyItem
      summary: Retrieve a page property item
      parameters:
        - name: page_id
          in: path
          required: true
          schema:
            type: string
        - name: property_id
          in: path
          required: true
          schema:
            type: string
        - name: Notion-Version
          in: header
          required: true
          schema:
            type: string
          example: 2022-06-28
          constant: 2022-06-28
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
                  type:
                    type: string
                  title:
                    type: array
                    items:
                      type: object
                      properties:
                        type:
                          type: string
                        text:
                          type: object
                          properties:
                            content:
                              type: string
  /databases/{database_id}/query:
    post:
      operationId: queryDatabase
      summary: Query a database
      parameters:
        - name: database_id
          in: path
          required: true
          schema:
            type: string
        - name: Notion-Version
          in: header
          required: true
          schema:
            type: string
          example: 2022-06-28
          constant: 2022-06-28
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                filter:
                  type: object
                sorts:
                  type: array
                  items:
                    type: object
                start_cursor:
                  type: string
                page_size:
                  type: integer
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  object:
                    type: string
                  results:
                    type: array
                    items:
                      type: object
                  next_cursor:
                    type: string
                  has_more:
                    type: boolean
  /search:
    post:
      operationId: search
      summary: Search
      parameters:
        - name: Notion-Version
          in: header
          required: true
          schema:
            type: string
          example: 2022-06-28
          constant: 2022-06-28
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                query:
                  type: string
                filter:
                  type: object
                  properties:
                    value:
                      type: string
                    property:
                      type: string
                sort:
                  type: object
                  properties:
                    direction:
                      type: string
                    timestamp:
                      type: string
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  object:
                    type: string
                  results:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: string
                        title:
                          type: array
                          items:
                            type: object
                            properties:
                              type:
                                type: string
                              text:
                                type: object
                                properties:
                                  content:
                                    type: string
```

## Authentication Instructions

Below are instructions on setting up authentication with this 3rd party application.

### Pre-Action Steps

Before you set up authentication in ChatGPT, please take the following steps in the Notion.

1. Go to the Notion Settings Page for your workspace
2. Navigate to My Connections > Develop or Manage Integrations
3. Create new Integration marked as Internal
4. Locate your integration and find the API Key labeled: Internal Integration Secret.  This is the bearer token for this integration.

**NOTE!** You need to share specific pages, databases, or wikis with the integration in order to access them in ChatGPT.  Do this by selecting the ... button on the upper right of a page and select the appropriate connection.

**NOTE!** Notion allows integrations to leverage OAuth if they are marked as "Public."  Review [Notion's Auth Documentation](https://developers.notion.com/docs/authorization) to determine what integration path is best for your needs.

![notion_connections.png](../../../images/creating_notion_integration.png)

![sharing_notion_pages.png](../../../images/sharing_notion_with_GPT.png)

### In ChatGPT

In ChatGPT, click on "Authentication" and choose **"API Key"**. Enter in the information below.

- **API Key**: Use Internal Integration Secret from steps above
- **Auth Type**: Bearer

### FAQ & Troubleshooting

- *Search returns nothing* If you don't see any pages returned when running a search, double check that you've shared relevant pages with the application from Notion

*Are there integrations that you’d like us to prioritize? Are there errors in our integrations? File a PR or issue in our github, and we’ll take a look.*
