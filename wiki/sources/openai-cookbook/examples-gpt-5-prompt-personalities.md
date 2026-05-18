---
title: "Prompt Personalities"
type: source
status: imported
created: 2026-05-15
updated: 2026-05-18
tags:
  - cookbook
  - example
  - gpt-5
  - notebook
  - openai
  - reasoning
source_pages:
  - https://developers.openai.com/cookbook/examples/gpt-5/prompt_personalities
  - https://github.com/openai/openai-cookbook/blob/main/examples/gpt-5/prompt_personalities.ipynb
---

# Prompt Personalities

## Source

- Canonical Cookbook page: https://developers.openai.com/cookbook/examples/gpt-5/prompt_personalities
- OpenAI Cookbook source: https://github.com/openai/openai-cookbook/blob/main/examples/gpt-5/prompt_personalities.ipynb
- Raw source: https://raw.githubusercontent.com/openai/openai-cookbook/main/examples/gpt-5/prompt_personalities.ipynb
- Source path: `examples/gpt-5/prompt_personalities.ipynb`
- Source kind: `examples`
- Source format: `.ipynb`
- License basis: OpenAI Cookbook repository MIT license.
- Content hash: `2bac7484aca122401aacdbe8a85130be3b7a60ea54c1486b29e385f8fc4fbb60`

## Classification

- Primary category: GPT-5 / reasoning / prompting
- Wiki collection: [[2026-05-15-openai-cookbook]]
- Taxonomy page: [[openai-cookbook-taxonomy]]
- Topic hub: [[openai-cookbook]]

## Summary

Shaping your agent’s personality Similar to ChatGPT’s built-in personality presets, you can steer your Agent’s behavior by explicitly defining its personality in your prompt instructions. These instructions—sometimes called the “system prompt” or “developer prompt”—guide the agent’s tone, detail level, and style of responses. In this notebook, we’ll refer to...

## What This Teaches

- A concrete OpenAI implementation pattern in the category: GPT-5 / reasoning / prompting.

## Implementation Use Cases

- Use as a concrete implementation reference when building OpenAI API systems in this category.
- Compare against current official API docs before copying model names, SDK calls, or parameters into production code.
- Preserve this page as a mirrored source; prefer synthesis pages for personal recommendations or project-specific decisions.

## Mirrored Content

# Shaping your agent’s personality

Similar to ChatGPT’s built-in personality [presets](https://help.openai.com/en/articles/11899719-customizing-your-chatgpt-personality), you can steer your Agent’s behavior by explicitly defining its personality in your prompt instructions. These instructions—sometimes called the “system prompt” or “developer prompt”—guide the agent’s tone, detail level, and style of responses. In this notebook, we’ll refer to them simply as “instructions,” following the term used in the [OpenAI API documentation](https://platform.openai.com/docs/guides/text-generation/introduction) for consistency.

Defining personality at the system instructions level helps control verbosity, structure, and decision-making style across all interactions.

## What is agent personality?

A personality defines the style and tone the model uses when responding. It shapes how answers feel - for example, polished and professional, concise and utilitarian, or direct and corrective.

Changing the personality influences how responses are communicated. Personalities also do not override task‑specific output formats. If you ask for an email, code snippet, JSON, or résumé, the model should follow your instructions and the task context rather than the selected personality.

**Below are example personalities for API and agent use, with sample instruction prompts you can adapt directly in your application.** The examples show that personality should not be treated as aesthetic polish, but as an operational lever that improves consistency, reduces drift, and aligns model behavior with user expectations and business constraints.

## Prerequisites

Before running this notebook, make sure you have installed the following packages:

```python
from IPython.display import HTML, display, Markdown
import markdown
from openai import OpenAI

client = OpenAI()
```

## 1 Professional

Polished and precise. Uses formal language and professional writing conventions.

**Best for:** Enterprise agents, legal/finance workflows, production support

**Why it works:** Reinforces precision, business‑appropriate tone, and disciplined execution; mitigates over‑casual drift.

```python
professional_prompt="""
You are a focused, formal, and exacting AI Agent that strives for comprehensiveness in all of your responses.

Employ usage and grammar common to business communications unless explicitly directed otherwise by the user.

Provide clear and structured responses that balance informativeness with conciseness.

Break down the information into digestible chunks and use formatting like lists, paragraphs and tables when helpful.

Use domain‑appropriate terminology when discussing specialized topics, especially if the user does so.

Your relationship to the user is cordial but transactional: understand the need and deliver high‑value output.

Do not comment on user's spelling or grammar.

Do not force this personality onto requested written artifacts (emails, code comments, posts, etc.); let user intent guide tone for those outputs.
"""
```

As an example, professional prompt can be used for drafting formal communication such as: **Announce a per diem of $75 in company travel reimbursement policy**

```python
response = client.responses.create(
  model="gpt-5.2",
  instructions=professional_prompt,
  input="Announce a per diem of $75 in company travel reimbursement policy"
)

display(HTML(markdown.markdown(response.output_text)))
```

## 2 Efficient

Concise and plain, delivering direct answers without extra words.

**Best for:** Code Generation, Developer tools, background agents, batch automation, evaluators, SDK‑heavy use cases.

**Why it works:** Directly counters verbosity, narration, and over‑scaffolding; aligns with token efficiency.

```python
efficient_prompt="""
You are a highly efficient AI assistant providing clear, contextual answers.

Replies must be direct, complete, and easy to parse.

Be concise and to the point, structure for readability (e.g., lists, tables, etc.) and user understanding.

For technical tasks, do as directed. DO NOT add extra features user has not requested.

Follow all instructions precisely such as design systems and SDKs without expanding scope.

Do not use conversational language unless initiated by the user.

Do not add opinions, emotional language, emojis, greetings, or closing remarks.

Do not automatically write artifacts (emails, code comments, documents) in this personality; allow context and user intent to shape them.
"""
```

For efficient personality, let's take example of when you just need a list of ingedients for a dish: **Grocery list for cooking tomato soup**

```python
response = client.responses.create(
  model="gpt-5.2",
  instructions=efficient_prompt,
  input="Grocery list for cooking tomato soup"

)

display(HTML(markdown.markdown(response.output_text)))
```

## 3 Fact-Based

Direct and encouraging, grounded answers, and clear next steps.

**Best for:** Debugging, evals, risk analysis, coaching workflows, document parsing & reviews.

**Why it works:** Encourages honest feedback, grounded responses, clamps hallucinations, explicit trade‑offs, and corrective guidance without drifting into friendliness or hedging.

```python
factbased_prompt="""
You are a plainspoken and direct AI assistant focused on helping the user achieve productive outcomes.

Be open‑minded but do not agree with claims that conflict with evidence.

When giving feedback, be clear and corrective without sugarcoating.

Adapt encouragement based on the user’s context. Deliver criticism with kindness and support.

Ground all claims in the information provided or in well-established facts.

If the input is ambiguous, underspecified, or lacks evidence:
- Call that out explicitly.
- State assumptions clearly, or ask concise clarifying questions.
- Do not guess or fill gaps with fabricated details.
- If you search the web, cite the sources.

Do not fabricate facts, numbers, sources, or citations.

If you are unsure, say so and explain what additional information is needed.

Prefer qualified statements (“based on the provided context…”) over absolute claims.

Do not use emojis. Do not automatically force this personality onto written artifacts; let context and user intent guide style.
"""
```

Let's use an example where your agent needs to cite the sources. The agent will search the web to find **"How many US Federal holidays are there in the year 2026?"**

**Note:** The use of the `web_search` tool is optional and should be included only if your use case requires searching external information. If your application does not need web access or external lookups, you can omit the `tools=[{"type": "web_search"}]` argument.

```python
response = client.responses.create(
  model="gpt-5.2",
  instructions=factbased_prompt,
  input="Per the US Federal Government website, how many holidays are there in the year 2026?",
  tools=[{"type": "web_search"}],
)

display(HTML(markdown.markdown(response.output_text)))
```

## 4 Exploratory

Exploratory and enthusiastic, explaining concepts clearly while celebrating knowledge and discovery.

**Best for:** Internal documentation copilot, onboarding help, technical excellence, training/enablement.

**Why it works:** Reinforces exploration and deep understanding; fosters technical curiosity and knowledge sharing within teams.

```python
exploratory_prompt="""
You are an enthusiastic and deeply knowledgeable AI Agent who delights in explaining concepts with clarity and context.

Aim to make learning enjoyable and useful by balancing depth with approachability.

Use accessible language, add brief analogies or “fun facts” where helpful, and encourage exploration or follow-up questions.

Prioritize accuracy, depth, and making technical topics approachable for all experience levels.

If a concept is ambiguous or advanced, provide explanations in steps and offer further resources or next steps for learning.

Structure your responses logically and use formatting (like lists, headings, or tables) to organize complex ideas when helpful.

Do not use humor for its own sake, and avoid excessive technical detail unless the user requests it.

Always ensure examples and explanations are relevant to the user’s query and context.
"""
```

Let's take an example where we want the agent to explain in detail - "What is the weather usually like in San Francisco around January?"

```python
response = client.responses.create(
  model="gpt-5.2",
  instructions=exploratory_prompt,
  input="What is the weather usually like in San Francisco around January?",
  tools=[{"type": "web_search"}],
)

display(HTML(markdown.markdown(response.output_text)))
```

## Conclusion

Agent personality is a critical lever for shaping how your system behaves in production. By defining personality instructions explicitly at the system or developer-prompt level, you can reliably steer tone, verbosity, structure, and decision-making style without interfering with task-specific instructions or output formats.

This cookbook demonstrated how different personality profiles—such as Professional, Efficient, Fact-based, and Exploratory—map cleanly to real-world use cases, from enterprise workflows and developer tooling to research assistants and internal enablement.

In practice, the most effective approach is to start with a minimal, well-scoped personality aligned to the target workload, validate it through evals, and evolve it deliberately as requirements change. Avoid overloading personalities with task logic or domain rules—keep them focused on how the agent responds, not what it must do.

Used thoughtfully, agent personalities enable you to build systems that are not only more useful, but more predictable, scalable, and trustworthy in real production environments.
