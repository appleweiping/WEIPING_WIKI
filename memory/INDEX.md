# Memory Index

Auto-maintained index of all shared agent memories.


## Decisions

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [agent-roles-and-skills.md](decisions/agent-roles-and-skills.md) | Agent 角色分工与技能使用规则 | roles, ARIS, skills, permanent, all-agents, critical | 2026-05-21 |
| [local-primary-server-experiment.md](decisions/local-primary-server-experiment.md) | 硬规则：本地主开发 + 服务器只跑实验 | workflow, server, local, hard-rule, permanent, all-agents, critical | 2026-05-21 |
| [memory-write-policy.md](decisions/memory-write-policy.md) | Memory Write Policy — 何时写入、谁来写、写什么 | memory, policy, all-agents, permanent, critical | 2026-05-22 |
| [no-8990-for-experiments-20260528.md](decisions/no-8990-for-experiments-20260528.md) | Hard rule: do not use local 8990 proxy for experiments | infrastructure, experiments, api, proxy, hard-rule, all-agents, critical | unknown |
| [pony-method-decisions-20260524.md](decisions/pony-method-decisions-20260524.md) | PonyRec 方案决策: v3 主表 + v4 验证 + 放弃 temperature | pony, decision, method, c-crp | unknown |
| [realtime-doc-update-rule.md](decisions/realtime-doc-update-rule.md) | 硬规则：实时更新文档和 memory | documentation, memory, hard-rule, permanent, all-agents, critical | 2026-05-21 |
| [research-core-rules.md](decisions/research-core-rules.md) | 科研项目核心执行规则 | research, rules, ARIS, permanent, all-agents | 2026-05-25 |
| [research-hard-rules.md](decisions/research-hard-rules.md) | 科研项目硬规则 — 多模型协作与质量标准 | ARIS, hard-rule, multi-model, collaboration, quality, permanent | 2026-05-21 |
| [task-complexity-and-collaboration.md](decisions/task-complexity-and-collaboration.md) | 任务复杂度判定与协作规则 | complexity, multi-agent, collaboration, routing, permanent, all-agents, critical | 2026-05-21 |


## Facts

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [2026-06-01_pony_rlmrec_llm2rec_recovery.md](facts/2026-06-01_pony_rlmrec_llm2rec_recovery.md) | Pony sports RLMRec completed and LLM2Rec valid-history fix |  | unknown |
| [2026-06-01_pony_toys_official_progress.md](facts/2026-06-01_pony_toys_official_progress.md) | Pony toys official-baseline progress |  | 2026-06-01 |
| [agent-cli-launch-config.md](facts/agent-cli-launch-config.md) | Agent CLI 启动方式与配置位置 | agent-cli, launch, config, infrastructure | 2026-05-21 |
| [all-projects-status.md](facts/all-projects-status.md) | 全部项目状态与优先级 | projects, priority, all-agents, critical | 2026-05-21 |
| [analog-agent-status.md](facts/analog-agent-status.md) | CSATG-EDA (Analog-Agent) 项目状态 — Phase 6c 全对比完成 | CSATG-EDA, analog-agent, AI4EDA, circuit-design, research, sky130, SOTA, critical | 2026-05-27 |
| [donebench-status.md](facts/donebench-status.md) | DoneBench 项目状态 — Experiment Expansion + ARIS Review Loop | DoneBench, benchmark, specification-grounding, research, experiment-expansion, ARIS, critical | 2026-05-31 |
| [gpt-image-2-config.md](facts/gpt-image-2-config.md) | GPT Image 2 图像生成 API 配置 | gpt-image-2, api, image-generation, all-agents, infrastructure | 2026-05-21 |
| [openhands-official-cli-gui-agentmemory.md](facts/openhands-official-cli-gui-agentmemory.md) | OpenHands official CLI/GUI + agentmemory setup | openhands, agentmemory, cli, gui, gpt-5.5, setup, verified | 2026-05-22 |
| [pony-ccrp-decision-point.md](facts/pony-ccrp-decision-point.md) | Pony C-CRP 关键决策点 — 77% gap 分析 | pony, C-CRP, decision-point, pointwise-vs-listwise, critical | 2026-05-21 |
| [pony-ccrp-four-domain-status.md](facts/pony-ccrp-four-domain-status.md) | PonyRec 项目全状态 (2026-05-25 更新) | pony, c-crp, srpd, experiment, status, four-domain | 2026-05-25 |
| [pony-current-status.md](facts/pony-current-status.md) | Pony C-CRP → RSC 项目当前状态 | pony, RSC, ranking-stability, conformal, LLM4Rec, critical | 2026-05-21 |
| [pony-experiment-plan.md](facts/pony-experiment-plan.md) | Pony Experiment Plan — Ranking Stability as Uncertainty | pony, experiment-plan, ARIS, listwise, conformal, critical | 2026-05-21 |
| [pony-pcr-experiment-plan.md](facts/pony-pcr-experiment-plan.md) | Pony PCR Experiment Plan — Calibration Cliffs in LLM Recommendation | pony, PCR, experiment-plan, ARIS, calibration-cliff, critical | 2026-05-21 |
| [pony-research-refine-listwise.md](facts/pony-research-refine-listwise.md) | Pony Research Refine — Listwise Conformal Recommendation | pony, research-refine, listwise, conformal-prediction, LLM4Rec, critical | 2026-05-21 |
| [pony-research-refine-v2.md](facts/pony-research-refine-v2.md) | Pony Research Refine v2 — Ranking Stability as Uncertainty | pony, research-refine, listwise, ranking-stability, conformal-prediction, LLM4Rec, critical | 2026-05-21 |
| [project-server-mapping.md](facts/project-server-mapping.md) | 项目-服务器映射 (Pony, TGL-Rec, TRUCE-Rec) | pony, TGL-Rec, TRUCE-Rec, server, mapping, critical | 2026-05-21 |
| [proteinshift-status.md](facts/proteinshift-status.md) | ProteinShift DA-BCP — Paper draft v1 complete, AUCE SOTA | ProteinShift, DA-BCP, bilevel-conformal, protein-optimization, paper-writing, ARIS, critical | 2026-05-27 |
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
| [git-workflow-local-primary.md](preferences/git-workflow-local-primary.md) | 科研项目 Git 工作流 — 本地为主，服务器只跑实验 | git, workflow, server, permanent, all-agents, critical | 2026-05-25 |
| [local-primary-server-experiment.md](preferences/local-primary-server-experiment.md) | 本地主开发 + 服务器只跑实验 | hard-rule, workflow, server, local, git, all-agents, permanent, critical | 2026-05-22 |
| [mandatory-step-update.md](preferences/mandatory-step-update.md) | 强制更新规则 — 每步完成必须同步 memory + 项目文档 | hard-rule, memory, documentation, all-agents, permanent, critical | 2026-05-21 |
| [pony-no-deviation.md](preferences/pony-no-deviation.md) | Pony 项目主线警告 — 不要偏离 | pony, warning, permanent, all-agents, critical | 2026-05-21 |


## Lessons

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [pony-server-troubleshooting-20260524.md](lessons/pony-server-troubleshooting-20260524.md) | PonyRec 服务器实验碰壁全记录 (2026-05-23~25) | pony, server, lesson, troubleshooting | 2026-05-25 |


## Workflows

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [agent-resources-guide.md](workflows/agent-resources-guide.md) | Agent Resources 技能与工具索引 | skills, resources, tools, all-agents, permanent, infrastructure | 2026-05-21 |
| [srpd-pipeline-full-guide.md](workflows/srpd-pipeline-full-guide.md) | SRPD Pipeline 完整操作手册 — 任何 Agent 可接手 | pony, srpd, pipeline, workflow, handoff, all-agents, critical | 2026-05-27 |


## Sessions

| File | Title | Tags | Updated |
|------|-------|------|---------|
| [2026-05-21_deepseek-cli-alignment.md](sessions/2026-05-21_deepseek-cli-alignment.md) | DeepSeek CLI terminal alignment | deepseek-cli, cli, terminal-ui, agent-tools, infrastructure | 2026-05-21 |
| [2026-05-22_infrastructure-audit-fix.md](sessions/2026-05-22_infrastructure-audit-fix.md) | 2026-05-22 基础设施审计与修复 | infrastructure, agent-hub, agentmemory, PATH, bugfix, session | 2026-05-22 |
| [2026-05-22_openhands-gpt55-dual-llm-config.md](sessions/2026-05-22_openhands-gpt55-dual-llm-config.md) | OpenHands dual LLM config with gpt55 | openhands, gpt55, llm-config, codex, agentmemory | unknown |
| [2026-05-22_openhands-local-gui-upgrade.md](sessions/2026-05-22_openhands-local-gui-upgrade.md) | OpenHands Local GUI 升级与本机启动 | openhands, local-gui, docker, llm-profiles, infrastructure, session | unknown |
| [2026-05-22_venus-update.md](sessions/2026-05-22_venus-update.md) | Venus Team 28 UI/software update uploaded | venus, team-28, gitlab, github, ui, communication, mqtt | unknown |
| [2026-05-26_liqivora-logo-motion-refresh.md](sessions/2026-05-26_liqivora-logo-motion-refresh.md) | Liqivora logo motion refresh | liqivora, frontend, logo, motion, brand | 2026-05-26 |
| [2026-05-26_pixel-ai-town-delivery-polish.md](sessions/2026-05-26_pixel-ai-town-delivery-polish.md) | Pixel AI Town delivery polish | pixel-ai-town, frontend, backend, qa, delivery | unknown |
| [2026-05-29_ai-town-godot-rebuild-start.md](sessions/2026-05-29_ai-town-godot-rebuild-start.md) | AI Town Godot rebuild started |  | 2026-05-29 |
| [2026-05-29_ai-town-windows-mcp-desktop-ui.md](sessions/2026-05-29_ai-town-windows-mcp-desktop-ui.md) | AI Town Windows-MCP desktop UI testing setup | ai-town, godot, windows-mcp, codex, desktop-ui, infrastructure | 2026-05-29 |
| [2026-05-29_venus-uart-ui-sync.md](sessions/2026-05-29_venus-uart-ui-sync.md) | Venus Team 28 UART UI compatibility and snapshot sync | venus, team-28, gitlab, github, ui, uart, mqtt, snapshot | unknown |
| [2026-05-30_ai-town-agent-runner-readiness.md](sessions/2026-05-30_ai-town-agent-runner-readiness.md) | AI Town Agent Runner readiness and dispatch previews |  | 2026-05-30 |
| [2026-05-30_ai-town-agent-task-cancel.md](sessions/2026-05-30_ai-town-agent-task-cancel.md) | AI Town Agent Task Queue cancellation |  | 2026-05-30 |
| [2026-05-30_ai-town-agent-task-concurrency-policy.md](sessions/2026-05-30_ai-town-agent-task-concurrency-policy.md) | AI Town Agent Task concurrency policy | ai-town, agent-hub, agent-task-queue, concurrency, safety, godot, session | 2026-05-30 |
| [2026-05-30_ai-town-agent-task-log-archive.md](sessions/2026-05-30_ai-town-agent-task-log-archive.md) | AI Town Agent Task log archive | ai-town, agent-hub, agent-task-queue, logs, evidence, safety, godot, session | 2026-05-30 |
| [2026-05-30_ai-town-agent-tool-log-archive.md](sessions/2026-05-30_ai-town-agent-tool-log-archive.md) | AI Town Agent Tool durable log archive |  | 2026-05-30 |
| [2026-05-30_ai-town-all-room-visual-manifest.md](sessions/2026-05-30_ai-town-all-room-visual-manifest.md) | AI Town all-room visual manifest |  | 2026-05-30 |
| [2026-05-30_ai-town-backend-job-logs.md](sessions/2026-05-30_ai-town-backend-job-logs.md) | AI Town persistent backend job logs | ai-town, godot, backend, jobs, observability, system-monitor | 2026-05-30 |
| [2026-05-30_ai-town-capability-atlas.md](sessions/2026-05-30_ai-town-capability-atlas.md) | AI Town Town Capability Atlas |  | 2026-05-30 |
| [2026-05-30_ai-town-citation-audit.md](sessions/2026-05-30_ai-town-citation-audit.md) | AI Town Paper Reading Room citation audit | ai-town, godot, paper-reading-room, citation-audit, bibtex | 2026-05-30 |
| [2026-05-30_ai-town-file-vault-incremental-index.md](sessions/2026-05-30_ai-town-file-vault-incremental-index.md) | AI Town File Vault incremental index | ai-town, file-vault, incremental-index, cache, godot, safety, session | 2026-05-30 |
| [2026-05-30_ai-town-file-vault-organization-audit.md](sessions/2026-05-30_ai-town-file-vault-organization-audit.md) | AI Town File Vault organization audit | ai-town, file-vault, organization-audit, godot, safety, session | 2026-05-30 |
| [2026-05-30_ai-town-github-publish-readiness.md](sessions/2026-05-30_ai-town-github-publish-readiness.md) | AI Town GitHub Harbor publish readiness and PR plans | ai-town, godot, github-harbor, release, safety | 2026-05-30 |
| [2026-05-30_ai-town-godot-build-readiness.md](sessions/2026-05-30_ai-town-godot-build-readiness.md) | AI Town Godot build readiness audit | ai-town, godot, release-plaza, build-readiness, export | 2026-05-30 |
| [2026-05-30_ai-town-godot-export-complete.md](sessions/2026-05-30_ai-town-godot-export-complete.md) | AI Town Godot Windows export completed locally | ai-town, godot, release-plaza, export, packaging, executable | 2026-05-30 |
| [2026-05-30_ai-town-godot-export-tool.md](sessions/2026-05-30_ai-town-godot-export-tool.md) | AI Town Godot export tool and packaging blocker | ai-town, godot, release-plaza, export, packaging | 2026-05-30 |
| [2026-05-30_ai-town-packaged-launcher.md](sessions/2026-05-30_ai-town-packaged-launcher.md) | AI Town packaged launcher readiness | ai-town, godot, release-plaza, packaged-launch, executable | 2026-05-30 |
| [2026-05-30_ai-town-plugin-manifests.md](sessions/2026-05-30_ai-town-plugin-manifests.md) | AI Town typed plugin manifests and activation plans | ai-town, godot, plugin-registry, extension-system, safety | 2026-05-30 |
| [2026-05-30_ai-town-registry-health.md](sessions/2026-05-30_ai-town-registry-health.md) | AI Town registry health validation slice | ai-town, godot, registry, validation, architecture-hardening | 2026-05-30 |
| [2026-05-30_ai-town-release-package-manifest.md](sessions/2026-05-30_ai-town-release-package-manifest.md) | AI Town release package manifest audit | ai-town, godot, release-plaza, release-manifest, packaging, executable | 2026-05-30 |
| [2026-05-30_ai-town-room-scene-expansion-14.md](sessions/2026-05-30_ai-town-room-scene-expansion-14.md) | AI Town room scene expansion to 14 buildings |  | 2026-05-30 |
| [2026-05-30_ai-town-room-scene-expansion-17.md](sessions/2026-05-30_ai-town-room-scene-expansion-17.md) | AI Town room scene expansion to 17 buildings |  | 2026-05-30 |
| [2026-05-30_ai-town-room-scene-expansion-20.md](sessions/2026-05-30_ai-town-room-scene-expansion-20.md) | AI Town room scene expansion to 20 buildings |  | 2026-05-30 |
| [2026-05-30_ai-town-room-scene-expansion-23.md](sessions/2026-05-30_ai-town-room-scene-expansion-23.md) | AI Town room scene expansion to 23 buildings | ai-town, godot, room-scenes, npc-chains, operations, safety | unknown |
| [2026-05-30_ai-town-room-scene-expansion-26.md](sessions/2026-05-30_ai-town-room-scene-expansion-26.md) | AI Town room scene expansion to 26 buildings | ai-town, godot, room-scenes, npc-chains, task-board, writing, automation | unknown |
| [2026-05-30_ai-town-room-scene-expansion-29.md](sessions/2026-05-30_ai-town-room-scene-expansion-29.md) | AI Town room scene expansion to 29 buildings | ai-town, godot, room-scenes, npc-chains, diagnostics, project-management, assets | unknown |
| [2026-05-30_ai-town-room-scene-expansion-35.md](sessions/2026-05-30_ai-town-room-scene-expansion-35.md) | AI Town room scene expansion to 35 buildings | ai-town, godot, room-scenes, npc-chains, full-coverage, workflow-buildings | unknown |
| [2026-05-30_ai-town-room-visual-polish.md](sessions/2026-05-30_ai-town-room-visual-polish.md) | AI Town room visual polish pass | ai-town, godot, visual-baseline, room-scenes, storybook-style | unknown |
| [2026-05-30_ai-town-secret-audit.md](sessions/2026-05-30_ai-town-secret-audit.md) | AI Town Permission Hall secret exposure audit | ai-town, godot, permission-hall, secrets, safety | 2026-05-30 |
| [2026-05-30_ai-town-smoke-registry-action-hardening.md](sessions/2026-05-30_ai-town-smoke-registry-action-hardening.md) | AI Town smoke registry/action hardening |  | 2026-05-30 |
| [2026-05-30_ai-town-terminal-command-preview.md](sessions/2026-05-30_ai-town-terminal-command-preview.md) | AI Town Terminal Control command preview |  | 2026-05-30 |
| [2026-05-30_ai-town-visual-manifest-audit.md](sessions/2026-05-30_ai-town-visual-manifest-audit.md) | AI Town visual manifest audit |  | 2026-05-30 |
| [2026-05-30_ai-town-workflow-routes.md](sessions/2026-05-30_ai-town-workflow-routes.md) | AI Town Workflow Routes |  | 2026-05-30 |
| [2026-05-30_d-drive-performance-audit.md](sessions/2026-05-30_d-drive-performance-audit.md) | D drive and Codex performance audit | infrastructure, d-drive, performance, codex, memory, disk-audit | 2026-05-30 |
| [2026-05-31_donebench_official_api_artifact_alignment.md](sessions/2026-05-31_donebench_official_api_artifact_alignment.md) | DoneBench official API artifact alignment |  | unknown |
| [2026-05-31_donebench_pipeline_figure_redesign.md](sessions/2026-05-31_donebench_pipeline_figure_redesign.md) | 2026-05-31_donebench_pipeline_figure_redesign |  | unknown |
| [2026-05-31_pony-ccrp-v3-phase1-complete.md](sessions/2026-05-31_pony-ccrp-v3-phase1-complete.md) | Pony C-CRP v3 Phase 1 complete; Phase 2 runner ready |  | 2026-06-01 |
| [2026-05-31_voice-sample-public-ingest.md](sessions/2026-05-31_voice-sample-public-ingest.md) | Public voice sample archive ingested |  | 2026-05-31 |
| [2026-06-01_donebench-private-publish-readme.md](sessions/2026-06-01_donebench-private-publish-readme.md) | DoneBench private GitHub publish and README rewrite | DoneBench, github, private, readme, release, lfs, artifacts | 2026-06-01 |
| [2026-06-01_pony-official-evidence-audit-tool.md](sessions/2026-06-01_pony-official-evidence-audit-tool.md) | Pony official evidence package audit gate |  | 2026-06-01 |
| [20260530-060701-ai-town-promotion-api-verification.md](sessions/20260530-060701-ai-town-promotion-api-verification.md) | AI Town promotion API verification | ai-town, verification, memory-promotion, promoted | unknown |
