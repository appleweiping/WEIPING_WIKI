---
title: ".Gpt Action Getting Started"
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
  - https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/.gpt_action_getting_started
  - https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/.gpt_action_getting_started.ipynb
---

# .Gpt Action Getting Started

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/chatgpt/gpt_actions_library/.gpt_action_getting_started
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/chatgpt/gpt_actions_library/.gpt_action_getting_started.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/chatgpt/gpt_actions_library/.gpt_action_getting_started.ipynb
- Source path: `examples/chatgpt/gpt_actions_library/.gpt_action_getting_started.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `3eab97bc61e01d15fdc980811153acef379c25c10d2387f224cc7bae0111fb8f`

## Classification

- Primary category: ChatGPT / GPT Actions
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

GPT Action Library: Getting Started (Weather.gov) Introduction This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information: - Introduction to GPT Actions - Introduction to GPT Actions Library - Example of Buliding a GPT Ac...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: ChatGPT / GPT Actions.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# GPT Action Library: Getting Started (Weather.gov)

## Introduction

This page provides an instruction & guide for developers building a GPT Action for a specific application. Before you proceed, make sure to first familiarize yourself with the following information:
- [Introduction to GPT Actions](https://platform.openai.com/docs/actions)
- [Introduction to GPT Actions Library](https://platform.openai.com/docs/actions/actions-library)
- [Example of Buliding a GPT Action from Scratch](https://platform.openai.com/docs/actions/getting-started)

This particular GPT Action provides an overview of how to connect to a **Weather.gov** weather forecast. This Action takes a user’s question about a location, converts the lat-long into a weather forecast office (WFO), x, and y coordinates, then converts those 3 values into a weather forecast.

Note: When setting up the GPT Action, for authentication, leave it with "None". This is a public API and does not require any Authentication

### Value + Example Business Use Cases

**Value**: Users can now leverage ChatGPT's natural language capability to forecast the weather

**Example Use Cases**:
- Users can plan out their day based on weather patterns
- Users can quickly visualize (including graphs) what the weather is forecasted to look like

## Application Information

### Application Key Links

Check out these links from the application before you get started:
- Application Website: https://www.weather.gov/
- Application API Documentation: https://www.weather.gov/documentation/services-web-api

## ChatGPT Steps

### Custom GPT Instructions

Once you've created a Custom GPT, copy the text below in the Instructions panel. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

```python
**Context**: A user needs information related to a weather forecast of a specific location.

**Instructions**:
1. The user will provide a lat-long point or a general location or landmark (e.g. New York City, the White House). If the user does not provide one, ask for the relevant location
2. If the user provides a general location or landmark, convert that into a lat-long coordinate. If required, browse the web to look up the lat-long point.
3. Run the "getPointData" API action and retrieve back the gridId, gridX, and gridY parameters.
4. Apply those variables as the office, gridX, and gridY variables in the "getGridpointForecast" API action to retrieve back a forecast
5. Use that forecast to answer the user's question

**Additional Notes**:
- Assume the user uses US weather units (e.g. Farenheit) unless otherwise specified
- If the user says "Let's get started" or "What do I do?", explain the purpose of this Custom GPT
```

### OpenAPI Schema

Once you've created a Custom GPT, copy the text below in the Actions panel. Have questions? Check out [Getting Started Example](https://platform.openai.com/docs/actions/getting-started) to see how this step works in more detail.

```python
openapi: 3.1.0
info:
  title: NWS Weather API
  description: Access to weather data including forecasts, alerts, and observations.
  version: 1.0.0
servers:
  - url: https://api.weather.gov
    description: Main API Server
paths:
  /points/{latitude},{longitude}:
    get:
      operationId: getPointData
      summary: Get forecast grid endpoints for a specific location
      parameters:
        - name: latitude
          in: path
          required: true
          schema:
            type: number
            format: float
          description: Latitude of the point
        - name: longitude
          in: path
          required: true
          schema:
            type: number
            format: float
          description: Longitude of the point
      responses:
        '200':
          description: Successfully retrieved grid endpoints
          content:
            application/json:
              schema:
                type: object
                properties:
                  properties:
                    type: object
                    properties:
                      forecast:
                        type: string
                        format: uri
                      forecastHourly:
                        type: string
                        format: uri
                      forecastGridData:
                        type: string
                        format: uri

  /gridpoints/{office}/{gridX},{gridY}/forecast:
    get:
      operationId: getGridpointForecast
      summary: Get forecast for a given grid point
      parameters:
        - name: office
          in: path
          required: true
          schema:
            type: string
          description: Weather Forecast Office ID
        - name: gridX
          in: path
          required: true
          schema:
            type: integer
          description: X coordinate of the grid
        - name: gridY
          in: path
          required: true
          schema:
            type: integer
          description: Y coordinate of the grid
      responses:
        '200':
          description: Successfully retrieved gridpoint forecast
          content:
            application/json:
              schema:
                type: object
                properties:
                  properties:
                    type: object
                    properties:
                      periods:
                        type: array
                        items:
                          type: object
                          properties:
                            number:
                              type: integer
                            name:
                              type: string
                            startTime:
                              type: string
                              format: date-time
                            endTime:
                              type: string
                              format: date-time
                            temperature:
                              type: integer
                            temperatureUnit:
                              type: string
                            windSpeed:
                              type: string
                            windDirection:
                              type: string
                            icon:
                              type: string
                              format: uri
                            shortForecast:
                              type: string
                            detailedForecast:
                              type: string
```

### FAQ & Troubleshooting

*Are there integrations that you’d like us to prioritize? Are there errors in our integrations? File a PR or issue in our github, and we’ll take a look.*
