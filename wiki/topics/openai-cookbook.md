---
title: OpenAI Cookbook
type: topic
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - openai
  - cookbook
  - llm
  - api-patterns
---

# OpenAI Cookbook

The OpenAI Cookbook is a high-value implementation reference for OpenAI API usage patterns, agent workflows, evaluations, RAG, multimodal systems, Realtime/voice, fine-tuning, Codex, and production integrations.

## Why It Matters

- EXTRACTED: The current ingest discovered 235 Cookbook article/example pages from https://developers.openai.com/cookbook.
- EXTRACTED: Every discovered developers page mapped to a source file in the MIT-licensed openai/openai-cookbook GitHub repository during this crawl.
- INFERRED: This source should be treated as a living implementation library rather than a static tutorial because new examples and articles can appear over time.

## How To Use This Hub

- Start with [[openai-cookbook-taxonomy]] when choosing examples by domain.
- Use individual mirrored source pages under `wiki/sources/openai-cookbook/` for exact example content.
- Check current official OpenAI docs before copying model names, SDK calls, or parameters into production code.
- Run `scripts/ingest-openai-cookbook.ps1` to refresh the mirror and detect new or changed examples.

## Major Categories

- Agents SDK / agent workflows: 16 pages
- ChatGPT / GPT Actions: 34 pages
- Codex / coding agents: 9 pages
- Deep Research / MCP: 2 pages
- Evaluation / eval flywheels: 23 pages
- Fine-tuning / reinforcement fine-tuning: 10 pages
- General OpenAI API patterns: 26 pages
- GPT-5 / reasoning / prompting: 13 pages
- gpt-oss / open-weight deployment: 11 pages
- Multimodal / image / video: 13 pages
- RAG / retrieval / vector databases: 46 pages
- Realtime / voice / transcription: 14 pages
- Responses API / tool orchestration: 3 pages
- Structured outputs / function calling: 6 pages
- Third-party integrations: 9 pages

## Related

- [[2026-05-15-openai-cookbook]]
- [[openai-cookbook-taxonomy]]
- [[llm-based-recommendation]]
- [[personal-knowledge-systems]]

## Counterpoints And Gaps

- Some Cookbook examples may lag the newest OpenAI API guidance; always check current official docs before production use.
- The taxonomy is path-and-keyword based, so cross-cutting examples may belong to more than one category.
