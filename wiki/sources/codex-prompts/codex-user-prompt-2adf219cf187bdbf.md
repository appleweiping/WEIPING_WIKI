---
title: PLEASE IMPLEMENT THIS PLAN -
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - coding-agent-workflow
source_pages:
  - codex-prompt-corpus
---

# PLEASE IMPLEMENT THIS PLAN:

## Metadata

- Stable ID: `codex-user-prompt:2adf219cf187bdbf`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T22:40:52.798Z`
- Semantic hash: `2adf219cf187bdbfd5d52b2ba0bc399665fe0e64b7fc40252690a6d8c59b1709`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
PLEASE IMPLEMENT THIS PLAN:
# Research Recon LLM4Rec 全路线补齐计划

## Summary

在现有 deterministic 推荐基础上，补齐一条完整 LLM4Rec 路线：**本地候选召回 + LLM reasoning rerank + 用户兴趣记忆 + reflection hint KB + 完整评测 + 前端控制台**。默认行为按你的选择：当真实 LLM provider 可用时自动启用 LLM4Rec；provider 不可用、超时、JSON 无效或成本超限时自动回退到现有 deterministic 推荐，并在响应里标明 fallback 原因。

六个角色覆盖如下：

- 实现/编码 agent：后端模型、推荐策略、API、CLI、前端控制台。
- 自检/验证 agent：单测、mock LLM、eval 指标、回归 fixture。
- 评审 agent：隐私、成本、静态模式、多环境、可解释性风险。
- 文档/知识库 agent：README、DESIGN、EVALUATION、ROADMAP、ADR。
- doc-gardening agent：清理“已实现/计划中”的能力声明，避免夸大。
- 故障修复 agent：JSON 容错、候选外 id、超时、缓存、fallback、迁移风险。

## Key Changes

- 新增推荐策略层：保留当前 `deterministic` scorer 作为 candidate recall；新增 `hybrid_llm` 默认策略，用 LLM 对 top-N 候选重排；新增 `reasoning_reflection` 策略，在 rerank 时加入用户兴趣记忆和失败反思 hints。
- 新增数据模型：`UserInterestMemory`、`LLMRecommendationTrace`、`RecommendationReflectionHint`、`RecommendationStrategySettings`。扩展 `PaperRecommendation`，加入 `rank_source`、`preference_match`、`novelty`、`risk`、`llm_reasoning_summary`、`evidence_seed_ids`。
- 新增后端服务：`personalization/llm_rerank.py` 负责严格 JSON rerank；`personalization/interest_memory.py` 从 saved/read/hide/tag/query/library 行为生成兴趣记忆；`personalization/reflection.py` 从 eval 失败生成 hints。
- API 扩展：`GET /recommendations/personalized` 增加 `strategy`、`candidate_limit`、`use_memory`、`use_reflection` 参数；新增 `/recommendations/memory`、`/recommendations/settings`、`/recommendations/reflection-hints`、`POST /recommendations/evaluate` 的 strategy 对比输出。
- 前端完整控制台：推荐面板升级为 LLM4Rec Console，包含策略开关、provider 状态、成本/延迟 trace、兴趣记忆编辑、reflection hints 查看、eval 对比表、fallback 状态。静态 Pages 无后端时只显示 sample/disabled 状态，不假装运行 LLM。
- 成本与缓存：新增 env 配置 `LLM_REC_AUTO_ENABLED=true`、`LLM_REC_CANDIDATE_LIMIT=50`、`LLM_REC_TIMEOUT_SECONDS=45`、`LLM_REC_CACHE_TTL_HOURS=24`、`LLM_REC_MAX_DAILY_CALLS`。所有 LLM rerank 记录 provider、model、latency、token/cost、cache_hit。
- 多环境行为：workstation/self-hosted/cloud split 可运行完整 LLM4Rec；GitHub Pages 只能连接后端后运行；team/lab 暂不共享 memory，文档明确需要 per-user isolation 后才能启用共享推荐。

## Implementation Route

1. 后端策略骨架 
 把当前 `build_personalized_recommendations` 拆成 candidate recall 与 final rank 两层；默认先算 deterministic candidates，再根据策略决定是否调用 LLM reranker。

2. LLM reranker 
 使用现有 `LLMProvider.chat_json`，prompt 只传候选摘要、用户记忆、seed 证据、blocked topics；LLM 只能返回候选内 paper ids。无效 id 丢弃，缺失候选按 deterministic 顺序补齐。

3. 用户兴趣记忆 
 从 library entries、saved/read/hidden、tags、collections、queries 汇总 evidence；LLM 生成短期/长期兴趣摘要，原始 evidence ids 保留。先存在 SQLite `settings` JSON，文档注明 team/lab 后续迁移到 per-user 表。

4. Reflection hints 
 eval 失败时生成结构化 hints：失败 case、误推原因、应提升/压低的主题、证据 paper ids、过期时间。rerank prompt 可检索最近相关 hints。

5. 前端控制台 
 在现有 RecommendationPanel 上扩展，不另起孤立页面：策略选择、自动启用状态、memory/hints/eval 三个 tab、每条推荐展示 deterministic score + LLM score + reasoning summary。

6. 文档与能力声明 
 更新 README、DESIGN、ARCHITECTURE_DECISIONS、EVALUATION、DEPLOYMENT_MODES、ROADMAP、REFERENCE_AUDIT；明确这是 LLM4Rec-inspired，不声称复现某篇论文，引用 UR4Rec/Re2LLM/ThinkRec/MSR-Rec 作为设计来源。

## Test Plan

- 后端单测：deterministic 结果不回归；mock provider 返回合法 JSON 时 LLM rerank 改变排序；返回候选外 id、坏 JSON、空结果、超时时回退。
- Storage 测试：interest memory、strategy settings、reflection hints 可保存、读取、覆盖、清理。
- API 测试：`strategy=deterministic`、`hybrid_llm`、`reasoning_reflection` 都返回兼容 `RecommendationResponse`；mock provider 下 trace/fallback 字段正确。
- Eval 测试：新增 NDCG@k、MRR、Hit@k、diversity、novelty、blocked leak、fallback count、LLM latency/cost；支持 deterministic vs LLM 策略对比。
- 前端测试：控制台在 backend 可用、provider mock、provider real、static fallback 四种状态都不崩；长 reasoning 文本不撑破布局。
- 验证命令：`uv run --project apps/api pytest`、`pnpm test:web`、`pnpm typecheck:web`、`pnpm build`、`POST /evaluation/run`。

## Assumptions

- 按你的选择，首版做完整范式，不只做最小 rerank。
- 真实 provider 配好后默认自动启用 LLM4Rec，但保留 env 和 UI 开关可关闭。
- 不做模型 fine-tuning、LoRA、RLHF 或多用户协同训练；当前数据量不够，先用 prompt-based reasoning + memory + reflection。
- 不把 API key、用户 private memory、LLM traces 写入前端静态 artifact。
- 所有 LLM 输出只作为排序与解释信号，不能新增不存在的论文、代码仓库、引用或外部能力。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
