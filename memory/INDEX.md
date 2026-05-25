# Memory Index

Auto-maintained index of all shared agent memories.


## Decisions

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [agent-roles-and-skills.md](decisions/agent-roles-and-skills.md) | Agent 角色分工与技能使用规则 | roles, ARIS, skills, permanent, all-agents, critical | 2026-05-21 |
| [local-primary-server-experiment.md](decisions/local-primary-server-experiment.md) | 硬规则：本地主开发 + 服务器只跑实验 | workflow, server, local, hard-rule, permanent, all-agents, critical | 2026-05-21 |
| [memory-write-policy.md](decisions/memory-write-policy.md) | Memory Write Policy — 何时写入、谁来写、写什么 | memory, policy, all-agents, permanent, critical | 2026-05-22 |
| [pony-method-decisions-20260524.md](decisions/pony-method-decisions-20260524.md) | PonyRec 方案决策: v3 主表 + v4 验证 + 放弃 temperature | pony, decision, method, c-crp | unknown |
| [realtime-doc-update-rule.md](decisions/realtime-doc-update-rule.md) | 硬规则：实时更新文档和 memory | documentation, memory, hard-rule, permanent, all-agents, critical | 2026-05-21 |
| [research-hard-rules.md](decisions/research-hard-rules.md) | 科研项目硬规则 — 多模型协作与质量标准 | ARIS, hard-rule, multi-model, collaboration, quality, permanent | 2026-05-21 |
| [task-complexity-and-collaboration.md](decisions/task-complexity-and-collaboration.md) | 任务复杂度判定与协作规则 | complexity, multi-agent, collaboration, routing, permanent, all-agents, critical | 2026-05-21 |


## Facts

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [agent-cli-launch-config.md](facts/agent-cli-launch-config.md) | Agent CLI 启动方式与配置位置 | agent-cli, launch, config, infrastructure | 2026-05-21 |
| [all-projects-status.md](facts/all-projects-status.md) | 全部项目状态与优先级 | projects, priority, all-agents, critical | 2026-05-21 |
| [analog-agent-status.md](facts/analog-agent-status.md) | Analog-Agent (AI4EDA) 项目状态 | analog-agent, AI4EDA, circuit-design, research | 2026-05-21 |
| [api-keys-backup-channels.md](facts/api-keys-backup-channels.md) | API Key 备选通道 — 多 key 冗余策略 | api-key, infrastructure, backup, all-agents, critical | 2026-05-22 |
| [gpt-image-2-config.md](facts/gpt-image-2-config.md) | GPT Image 2 图像生成 API 配置 | gpt-image-2, api, image-generation, all-agents, infrastructure | 2026-05-21 |
| [openhands-official-cli-gui-agentmemory.md](facts/openhands-official-cli-gui-agentmemory.md) | OpenHands official CLI/GUI + agentmemory setup | openhands, agentmemory, cli, gui, gpt-5.5, setup, verified | 2026-05-22 |
| [pony-ccrp-decision-point.md](facts/pony-ccrp-decision-point.md) | Pony C-CRP 关键决策点 — 77% gap 分析 | pony, C-CRP, decision-point, pointwise-vs-listwise, critical | 2026-05-21 |
| [pony-ccrp-four-domain-status.md](facts/pony-ccrp-four-domain-status.md) | PonyRec 全状态: C-CRP v3 done + SRPD running + Paper draft done | pony, c-crp, srpd, experiment, status, four-domain | 2026-05-25 |
| [pony-current-status.md](facts/pony-current-status.md) | Pony C-CRP → RSC 项目当前状态 | pony, RSC, ranking-stability, conformal, LLM4Rec, critical | 2026-05-21 |
| [pony-experiment-plan.md](facts/pony-experiment-plan.md) | Pony Experiment Plan — Ranking Stability as Uncertainty | pony, experiment-plan, ARIS, listwise, conformal, critical | 2026-05-21 |
| [pony-pcr-experiment-plan.md](facts/pony-pcr-experiment-plan.md) | Pony PCR Experiment Plan — Calibration Cliffs in LLM Recommendation | pony, PCR, experiment-plan, ARIS, calibration-cliff, critical | 2026-05-21 |
| [pony-research-refine-listwise.md](facts/pony-research-refine-listwise.md) | Pony Research Refine — Listwise Conformal Recommendation | pony, research-refine, listwise, conformal-prediction, LLM4Rec, critical | 2026-05-21 |
| [pony-research-refine-v2.md](facts/pony-research-refine-v2.md) | Pony Research Refine v2 — Ranking Stability as Uncertainty | pony, research-refine, listwise, ranking-stability, conformal-prediction, LLM4Rec, critical | 2026-05-21 |
| [project-server-mapping.md](facts/project-server-mapping.md) | 项目-服务器映射 (Pony, TGL-Rec, TRUCE-Rec) | pony, TGL-Rec, TRUCE-Rec, server, mapping, critical | 2026-05-21 |
| [proteinshift-status.md](facts/proteinshift-status.md) | ProteinShift DA-BCP 方法升级 — research-refine 完成 | ProteinShift, DA-BCP, bilevel-conformal, protein-optimization, research-refine, ARIS, critical | 2026-05-23 |
| [terraria-project-plan.md](facts/terraria-project-plan.md) | My Terraria 项目计划 (Codex 制定) | terraria, game, codex-lead, plan | 2026-05-21 |
| [tglrec-current-status.md](facts/tglrec-current-status.md) | TGL-Rec 项目当前状态 — Phase 10 已启动 | TGL-Rec, temporal-graph, LLM4Rec, research, critical | 2026-05-21 |
| [truce-rec-current-status.md](facts/truce-rec-current-status.md) | TRUCE-Rec 项目当前状态 — 服务器部署阶段 | TRUCE-Rec, uncertainty, LLM4Rec, generative-recommendation, research, critical | 2026-05-21 |


## Preferences

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [auto-update-docs.md](preferences/auto-update-docs.md) | 自动更新文档规则 | documentation, auto-update, permanent | 2026-05-21 |
| [coding-preference.md](preferences/coding-preference.md) | 编码偏好 — Opus 优于 Codex | coding, model-preference, opus | 2026-05-21 |
| [d-drive-rule.md](preferences/d-drive-rule.md) | D盘规则 — 所有 Agent 配置和数据必须在 D:\devtools | d-drive, infrastructure, permanent, all-agents | 2026-05-21 |
| [experiment-fairness.md](preferences/experiment-fairness.md) | 实验公平性规则 — 指标和数据必须对齐 | fairness, experiment, baseline, permanent, all-agents, critical | 2026-05-22 |
| [git-workflow-local-primary.md](preferences/git-workflow-local-primary.md) | 科研项目 Git 工作流 — 本地为主，服务器只跑实验 | git, workflow, server, permanent, all-agents, critical | 2026-05-22 |
| [local-primary-server-experiment.md](preferences/local-primary-server-experiment.md) | 本地主开发 + 服务器只跑实验 | hard-rule, workflow, server, local, git, all-agents, permanent, critical | 2026-05-22 |
| [mandatory-step-update.md](preferences/mandatory-step-update.md) | 强制更新规则 — 每步完成必须同步 memory + 项目文档 | hard-rule, memory, documentation, all-agents, permanent, critical | 2026-05-21 |
| [pony-no-deviation.md](preferences/pony-no-deviation.md) | Pony 项目主线警告 — 不要偏离 | pony, warning, permanent, all-agents, critical | 2026-05-21 |


## Lessons

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [pony-server-troubleshooting-20260524.md](lessons/pony-server-troubleshooting-20260524.md) | PonyRec 服务器实验碰壁全记录 (2026-05-23~24) | pony, server, lesson, troubleshooting | unknown |


## Workflows

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [agent-resources-guide.md](workflows/agent-resources-guide.md) | Agent Resources 技能与工具索引 | skills, resources, tools, all-agents, permanent, infrastructure | 2026-05-21 |


## Sessions

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [2026-05-21_deepseek-cli-alignment.md](sessions/2026-05-21_deepseek-cli-alignment.md) | DeepSeek CLI terminal alignment | deepseek-cli, cli, terminal-ui, agent-tools, infrastructure | 2026-05-21 |
| [2026-05-22_infrastructure-audit-fix.md](sessions/2026-05-22_infrastructure-audit-fix.md) | 2026-05-22 基础设施审计与修复 | infrastructure, agent-hub, agentmemory, PATH, bugfix, session | 2026-05-22 |
| [2026-05-22_openhands-gpt55-dual-llm-config.md](sessions/2026-05-22_openhands-gpt55-dual-llm-config.md) | OpenHands dual LLM config with gpt55 | openhands, gpt55, llm-config, codex, agentmemory | unknown |
| [2026-05-22_openhands-local-gui-upgrade.md](sessions/2026-05-22_openhands-local-gui-upgrade.md) | OpenHands Local GUI 升级与本机启动 | openhands, local-gui, docker, llm-profiles, infrastructure, session | unknown |
| [2026-05-22_venus-update.md](sessions/2026-05-22_venus-update.md) | Venus Team 28 UI/software update uploaded | venus, team-28, gitlab, github, ui, communication, mqtt | unknown |
