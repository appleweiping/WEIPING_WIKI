---
title: Codex Prompt Corpus
type: topic
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - topic
  - codex-prompts
---

# Codex Prompt Corpus

## Summary

This corpus preserves high-quality user-authored Codex prompts and automation prompts as reusable prompt engineering material.

## Selection Rules

- EXTRACTED: Include user prompts and automation prompts that are substantive, clean, reusable, and not mostly code/log output.
- EXTRACTED: Exclude short prompts, duplicates, mojibake/noise, pasted stack traces, server logs, source-code dumps, and secret-like/private material.
- EXTRACTED: Public pages may include full selected prompt text, but only after safety filtering.

## Current Counts

- Selected prompts: `353`
- Rejected candidates: `1424`
- Manifest: `raw/codex-prompts-public/manifest.json`

## Categories

### automation

- [[sources/codex-prompts/codex-user-prompt-7832b29cb044ac0c|这不是 BLOCKER，不要继续在 max_requests 这种 trivial safety mismatch 上停住。]] - `codex-user-prompt:7832b29cb044ac0c`
- [[sources/codex-prompts/codex-user-prompt-7c237abb8652745e|你先做：接下来要做的是：]] - `codex-user-prompt:7c237abb8652745e`
- [[sources/codex-prompts/codex-user-prompt-a8d14c84ce2411d6|You own configs/official_external_baselines.yaml and any provenance-oriented...]] - `codex-user-prompt:a8d14c84ce2411d6`
- [[sources/codex-prompts/codex-user-prompt-66468b8bf1baafa5|我建议你采用多agent工作，整理一下我们所有的文件和后续要走的清单和我们的计划，尽量详细一点。readme也重新更新一下。把 official base...]] - `codex-user-prompt:66468b8bf1baafa5`
- [[sources/codex-prompts/codex-user-prompt-1e996ee21e493a71|Please re-review the current fixed diff for the findings you raised. Focus on...]] - `codex-user-prompt:1e996ee21e493a71`
- [[sources/codex-prompts/codex-user-prompt-320a3cc1dea995f9|你是 DoneBench 的 artifact/repro checker。请只读检查当前计划文档改动是否满足 AGENTS.md 的复杂任务要求：证据路...]] - `codex-user-prompt:320a3cc1dea995f9`
- [[sources/codex-prompts/codex-user-prompt-5eb688f439065259|以后都要记得自动commit push。然后我建议你不要那么保守，请你直接落成完整的prompt wiki，具体参考的六个项目，你要自己去看一下，学习他们...]] - `codex-user-prompt:5eb688f439065259`
- [[sources/codex-prompts/codex-user-prompt-42ab3d53a4f1cb0e|In D:\Research\Uncertainty, act as server-diagnostic planner for SETRec. Base...]] - `codex-user-prompt:42ab3d53a4f1cb0e`
- [[sources/codex-prompts/codex-user-prompt-1687034557a9eb9a|Read the docs folder first, especially:]] - `codex-user-prompt:1687034557a9eb9a`
- [[sources/codex-prompts/codex-user-prompt-ca641720d17374f1|commit and push]] - `codex-user-prompt:ca641720d17374f1`
- [[sources/codex-prompts/codex-user-prompt-7cbf27b02da1e40b|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:7cbf27b02da1e40b`
- [[sources/codex-prompts/codex-user-prompt-adf1736a425fa5cc|Automation: Light Crawl Lidang Public Ideas]] - `codex-user-prompt:adf1736a425fa5cc`
- [[sources/codex-prompts/codex-user-prompt-9d27f4d021416dd6|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:9d27f4d021416dd6`
- [[sources/codex-prompts/codex-automation-prompt-light-crawl-lidang-public-ideas|Run the daily light capture for the Lidang public ideas corpus in the vipin w...]] - `codex-automation-prompt:light-crawl-lidang-public-ideas`

### coding-agent-workflow

- [[sources/codex-prompts/codex-automation-prompt-reviewer-truce-rec|你现在不是 Storyflow / TRUCE-Rec 的实现代理，而是本项目的独立 Reviewer / Research Quality Monito...]] - `codex-automation-prompt:reviewer-truce-rec`
- [[sources/codex-prompts/codex-automation-prompt-worker1-truce-rec|我批准审核]] - `codex-automation-prompt:worker1-truce-rec`
- [[sources/codex-prompts/codex-user-prompt-1add83f8a5d5e350|R2-real-LLM subgate returned PASS WITH MINOR FIXES.]] - `codex-user-prompt:1add83f8a5d5e350`
- [[sources/codex-prompts/codex-user-prompt-a49c2f62f5e1d0e9|更新到github main，]] - `codex-user-prompt:a49c2f62f5e1d0e9`
- [[sources/codex-prompts/codex-user-prompt-74ef89b3b1e3a340|Phase 9C main accuracy multi-seed aggregation is complete.]] - `codex-user-prompt:74ef89b3b1e3a340`
- [[sources/codex-prompts/codex-user-prompt-ba3d86b5fa9d6b8f|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:ba3d86b5fa9d6b8f`
- [[sources/codex-prompts/codex-user-prompt-7a1ebba005a21194|你是实验复现和benchmark setting explorer。请在当前仓库 C:\Users\admin\.codex\worktrees\da20...]] - `codex-user-prompt:7a1ebba005a21194`
- [[sources/codex-prompts/codex-user-prompt-45801b82a3740170|你是顶会审稿视角的代码/方法 explorer。请在当前仓库 C:\Users\admin\.codex\worktrees\da20\Uncertain...]] - `codex-user-prompt:45801b82a3740170`
- [[sources/codex-prompts/codex-user-prompt-ef80b41b1c352a51|Files mentioned by the user:]] - `codex-user-prompt:ef80b41b1c352a51`
- [[sources/codex-prompts/codex-user-prompt-c384604dfd126b3e|工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...]] - `codex-user-prompt:c384604dfd126b3e`
- [[sources/codex-prompts/codex-user-prompt-5cd68ebeac91ce41|工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：设计/实现 AI-assisted audit 管线...]] - `codex-user-prompt:5cd68ebeac91ce41`
- [[sources/codex-prompts/codex-user-prompt-637b0181007b6d9d|工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：补 Reproducibility package。...]] - `codex-user-prompt:637b0181007b6d9d`
- [[sources/codex-prompts/codex-user-prompt-befad3783ccc0580|You own README.md plus the high-level planning docs: OFFICIAL_EXTERNAL_BASELI...]] - `codex-user-prompt:befad3783ccc0580`
- [[sources/codex-prompts/codex-user-prompt-1d14a4a12207706b|这是我后面做的一些事：那我们做到了保证公平性的情况下其他都要官方原装实现的这个要求了吗]] - `codex-user-prompt:1d14a4a12207706b`
- [[sources/codex-prompts/codex-user-prompt-6ce8c3f5f372da8d|Read-only task for TGL-Rec. Audit current repo for runnable server workflow g...]] - `codex-user-prompt:6ce8c3f5f372da8d`
- [[sources/codex-prompts/codex-user-prompt-a127153fd0eaaa7a|Repository: D:\Research\TGL-Rec. Narrow audit task while parent edits: inspec...]] - `codex-user-prompt:a127153fd0eaaa7a`
- [[sources/codex-prompts/codex-user-prompt-ddb6f72fd5a2895a|在Security helper这个文件夹下，直接做一个网页项目，这个网页的要求很简单，用户能够在框内输入学号，然后直接产生对应lab的token，目前版...]] - `codex-user-prompt:ddb6f72fd5a2895a`
- [[sources/codex-prompts/codex-user-prompt-e5563d88490b1fce|这样就可以了吧，其他还需要做什么，你能不能直接看看他们在gitlab其他模块已经做的东西，然后看看我们的computer software 和ui的ven...]] - `codex-user-prompt:e5563d88490b1fce`
- [[sources/codex-prompts/codex-user-prompt-8c4152181895b3cc|Files mentioned by the user:]] - `codex-user-prompt:8c4152181895b3cc`
- [[sources/codex-prompts/codex-user-prompt-7ea12ee937162c4c|请只读检查 D:\Research\Uncertainty 之外服务器官方 repo 无法本地访问时的替代：在本地仓库中查 main_prepare_ll...]] - `codex-user-prompt:7ea12ee937162c4c`
- [[sources/codex-prompts/codex-user-prompt-968add0df371b58b|能不能让agent以后都记住，我们的大方向以及学长的一些话，精确，详细（你需要汲取我先前说的话和你的对应文档，做完一部分也要记得更新，不然一直陈旧的后面的...]] - `codex-user-prompt:968add0df371b58b`
- [[sources/codex-prompts/codex-user-prompt-f4478b666788fc5b|采用多agent协作，推进下一步，同时梳理全部的项目和文档，整理适配于agent工作的文档，让之后的codex能够清楚的知道已经做了什么目前要做什么后面要...]] - `codex-user-prompt:f4478b666788fc5b`
- [[sources/codex-prompts/codex-user-prompt-b5307a63b3c9f880|你是 audit 工作流梳理 agent。只读梳理 audit gate / AI audit / human audit 工作流现状。请重点阅读 don...]] - `codex-user-prompt:b5307a63b3c9f880`
- [[sources/codex-prompts/codex-user-prompt-94869b67eddc78fd|做这些：跑 GPT-5.5 targeted audit，处理 ai_adjudication_queue_nonempty。]] - `codex-user-prompt:94869b67eddc78fd`
- [[sources/codex-prompts/codex-user-prompt-bae6b6b52b1920ce|你是 Codex/GPT-5.5 targeted audit worker D。只读审计 DoneBench 的这些任务：sheet_db_025, s...]] - `codex-user-prompt:bae6b6b52b1920ce`
- [[sources/codex-prompts/codex-user-prompt-e2d076c9c57d75b6|你是 Codex/GPT-5.5 targeted audit worker C。只读审计 DoneBench 的这些任务：file_doc_024, f...]] - `codex-user-prompt:e2d076c9c57d75b6`
- [[sources/codex-prompts/codex-user-prompt-743f0f7a953b714a|你觉得有必要用gpt5.2,跑full域吗。这个也请你来代劳一下，你可以搞多个小agent然后跑full域，最好就是如果中断了也能保留已经跑的部分，不至于...]] - `codex-user-prompt:743f0f7a953b714a`
- [[sources/codex-prompts/codex-user-prompt-0e8857057ed04891|先修复/重新生成这 100 个 human-audit queue 任务的 initial state、reference trace、final sta...]] - `codex-user-prompt:0e8857057ed04891`
- [[sources/codex-prompts/codex-user-prompt-45b13bfd906afcbc|Repository: D:\Research\TGL-Rec. Audit handoff/server docs for what a future...]] - `codex-user-prompt:45b13bfd906afcbc`
- [[sources/codex-prompts/codex-user-prompt-29fc7586fdfc7208|Repository: D:\Research\TGL-Rec. Audit the docs and root files that future Co...]] - `codex-user-prompt:29fc7586fdfc7208`
- [[sources/codex-prompts/codex-user-prompt-79dc7b01e932c221|You are implementation-planner worker for TGL-Rec Phase 10. You are not alone...]] - `codex-user-prompt:79dc7b01e932c221`
- [[sources/codex-prompts/codex-user-prompt-377d219b8fa7193f|Review TRUCE-Rec's current docs and method implementation for the user's late...]] - `codex-user-prompt:377d219b8fa7193f`
- [[sources/codex-prompts/codex-user-prompt-814438af7b7bd76e|Small-scope implementation planner. Read only src/llm4rec/experiments/four_do...]] - `codex-user-prompt:814438af7b7bd76e`
- [[sources/codex-prompts/codex-user-prompt-14c4c364bc502e0a|多agent协作先做好这些，除非确实做不了，把 paper submission-ready 化]] - `codex-user-prompt:14c4c364bc502e0a`
- [[sources/codex-prompts/codex-user-prompt-b01b034ae755071e|Complex TRUCE-Rec task. Read startup docs and inspect scripts/src/tests aroun...]] - `codex-user-prompt:b01b034ae755071e`
- [[sources/codex-prompts/codex-user-prompt-a231a4b4e69ed34d|Implementation planner for TGL-Rec method upgrade. You are not alone in the c...]] - `codex-user-prompt:a231a4b4e69ed34d`
- [[sources/codex-prompts/codex-user-prompt-35966d55a80d1da6|Implementation planner. Read docs/codex_project_memory.md, docs/server_runboo...]] - `codex-user-prompt:35966d55a80d1da6`
- [[sources/codex-prompts/codex-user-prompt-d8a788278565e797|Milestone M4/M5, LLM-ESR official external baseline upgrade. Please inspect t...]] - `codex-user-prompt:d8a788278565e797`
- [[sources/codex-prompts/codex-user-prompt-34cd5eadf15df022|只读研究任务，不要修改文件。请浏览/查阅近年顶会或强相关 benchmark 项目，聚焦 realistic agent benchmarks：WebAr...]] - `codex-user-prompt:34cd5eadf15df022`
- [[sources/codex-prompts/codex-user-prompt-39e440060264ca1f|只读研究任务，不要修改文件。请浏览/查阅真实任务/leaderboard/reproducibility 型顶会项目：SWE-bench、SWE-benc...]] - `codex-user-prompt:39e440060264ca1f`
- [[sources/codex-prompts/codex-user-prompt-ef245c1c14e4f2e4|Files mentioned by the user:]] - `codex-user-prompt:ef245c1c14e4f2e4`
- [[sources/codex-prompts/codex-user-prompt-44e6a80871db8715|我想利用harness engineering 的全套思路，重新构建这个项目，内容需要保留，但是架构需要做调整，并增加网页，这个项目需要一个网页，同时请你...]] - `codex-user-prompt:44e6a80871db8715`
- [[sources/codex-prompts/codex-user-prompt-9834d6338190d1be|我想利用harness engineering 的全套思路（自己去搜寻里面包含什么概念），重新构建这个项目，内容idea只做部分保留，给你大的权限删去已有...]] - `codex-user-prompt:9834d6338190d1be`
- [[sources/codex-prompts/codex-user-prompt-c382ed7dfc607cee|本地大重构与服务器就绪计划]] - `codex-user-prompt:c382ed7dfc607cee`
- [[sources/codex-prompts/codex-user-prompt-986784ea9231d53e|https://github.com/appleweiping/analog-agent.git这个是目前的项目在github的状态，我想对codex说对...]] - `codex-user-prompt:986784ea9231d53e`
- [[sources/codex-prompts/codex-user-prompt-df4060f2a683cce9|只读探索任务，不要修改任何文件。工作目录是 D:\Research\Agent-AI4EDA，真正仓库很可能在 D:\Research\Agent-AI4...]] - `codex-user-prompt:df4060f2a683cce9`
- [[sources/codex-prompts/codex-user-prompt-ea89b0a29355e38a|研究规划任务，不要修改文件。请围绕“LLM/agent 自动模拟电路设计、AI4EDA、world model / model-based plannin...]] - `codex-user-prompt:ea89b0a29355e38a`
- [[sources/codex-prompts/codex-user-prompt-39cf3e1ec375383a|只读探索任务，不要修改文件。请把当前 analog-agent 与外部参考（AnalogGym、AnalogCoder、AnalogGenie、AICir...]] - `codex-user-prompt:39cf3e1ec375383a`
- [[sources/codex-prompts/codex-user-prompt-d97cc039572e7ad3|Repository: D:\Research\UncertaintyProtein-AI4S. Plan-mode only. Do not edit...]] - `codex-user-prompt:d97cc039572e7ad3`
- [[sources/codex-prompts/codex-user-prompt-3fba5dbbca4ddf63|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:3fba5dbbca4ddf63`
- [[sources/codex-prompts/codex-user-prompt-004a1e12ed7135e8|Repository: D:\Research\UncertaintyProtein-AI4S. You are not alone in the cod...]] - `codex-user-prompt:004a1e12ed7135e8`
- [[sources/codex-prompts/codex-user-prompt-0e4e86bce96e6794|Review branch for a coding task. Repo: D:\Research\Agent-AI4EDA\analog-agent,...]] - `codex-user-prompt:0e4e86bce96e6794`
- [[sources/codex-prompts/codex-user-prompt-dcbeb13718668c40|只读架构规划任务，不要编辑文件。请为一个无服务器、本地优先、Next.js 前端 + FastAPI 后端 + SQLite/vector store +...]] - `codex-user-prompt:dcbeb13718668c40`
- [[sources/codex-prompts/codex-user-prompt-39876879fb82e663|你是 Research Recon Prototype 的“自检/验证 agent”。仓库在 D:\Research\Research Recon Pro...]] - `codex-user-prompt:39876879fb82e663`
- [[sources/codex-prompts/codex-user-prompt-c7250a678fb7ec2e|你是 Research Recon Prototype 的“故障修复 agent”。仓库在 D:\Research\Research Recon Prot...]] - `codex-user-prompt:c7250a678fb7ec2e`
- [[sources/codex-prompts/codex-user-prompt-2db804d0607875d2|你是 Research Recon Prototype 的真实用户模拟 Agent A。请在仓库 D:\Research\Research Recon P...]] - `codex-user-prompt:2db804d0607875d2`
- [[sources/codex-prompts/codex-user-prompt-2d49732a289386e2|你是 Research Recon Prototype 的真实用户模拟 Agent B。请在仓库 D:\Research\Research Recon P...]] - `codex-user-prompt:2d49732a289386e2`
- [[sources/codex-prompts/codex-user-prompt-8af3a913c408de2f|目前这个项目，有一个问题就是按一下抓取，如果已经有20个了，他就一直都是20个。然后也不能拿掉一些论文，也许我的判断也不一定对，但是给我的直观感受是这样的...]] - `codex-user-prompt:8af3a913c408de2f`
- [[sources/codex-prompts/codex-user-prompt-7c848f951a38aca7|做完这些，派六个agent，其中两个充当真实用户reviewer（不单单只是看一下界面那么简单，要实际使用（所有环节），多环境模拟，多api调用模拟，co...]] - `codex-user-prompt:7c848f951a38aca7`
- [[sources/codex-prompts/codex-user-prompt-10c92f30b6c7753f|你是 Research Agent 3，负责顶会/热门 GitHub/HF 项目调研，用来发现 Research Recon 应该补的 idea 和功能。...]] - `codex-user-prompt:10c92f30b6c7753f`
- [[sources/codex-prompts/codex-user-prompt-e7deef72abf42369|你是 Research Agent 4，专门搜寻热门 HF/GitHub/top-conference 方向来扩展产品能力。只读，不修改 repo。请用网...]] - `codex-user-prompt:e7deef72abf42369`
- [[sources/codex-prompts/codex-user-prompt-5600cbbe57749c3b|你是 Implementation Agent 5，但先不要改代码。工作目录 D:\Research\Research Recon Prototype。等...]] - `codex-user-prompt:5600cbbe57749c3b`
- [[sources/codex-prompts/codex-user-prompt-0dbde13815f47abb|现在开始实作，写入范围限定在后端/CLI/tests/docs，避免碰 frontend dashboard 以免和主 agent 冲突。你不是一个人在代...]] - `codex-user-prompt:0dbde13815f47abb`
- [[sources/codex-prompts/codex-user-prompt-2adf219cf187bdbf|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:2adf219cf187bdbf`
- [[sources/codex-prompts/codex-user-prompt-7579b6069a9d4ffc|In D:\Research\TRUCE-Rec, inspect the repository docs relevant to creating a...]] - `codex-user-prompt:7579b6069a9d4ffc`
- [[sources/codex-prompts/codex-user-prompt-7cb930cc905d6bc4|Prompt Wiki reference Agent 1: Study Langfuse as a reference for prompt manag...]] - `codex-user-prompt:7cb930cc905d6bc4`
- [[sources/codex-prompts/codex-user-prompt-59d500a3a583948d|Prompt Wiki reference Agent 2: Study PromptLayer as a reference for prompt re...]] - `codex-user-prompt:59d500a3a583948d`
- [[sources/codex-prompts/codex-user-prompt-b5eb230936e58acb|Prompt Wiki reference Agent 3: Study Humanloop as a reference for prompt engi...]] - `codex-user-prompt:b5eb230936e58acb`
- [[sources/codex-prompts/codex-user-prompt-2a5c1cfc8c981315|Prompt Wiki reference Agent 4: Study promptfoo as a reference for prompt eval...]] - `codex-user-prompt:2a5c1cfc8c981315`
- [[sources/codex-prompts/codex-user-prompt-7a8ca5729a329e44|Prompt Wiki reference Agent 6: Study Open WebUI prompts/tools/community promp...]] - `codex-user-prompt:7a8ca5729a329e44`
- [[sources/codex-prompts/codex-user-prompt-b4f4dd5c74c33882|Agent 1: Read-only inspect D:\Research\vipin's knowledgebase and D:\Research\...]] - `codex-user-prompt:b4f4dd5c74c33882`
- [[sources/codex-prompts/codex-user-prompt-59c0990bf7c2d1a6|Agent 3: Read-only inspect Prompt Wiki packages. Focus on preserving the prom...]] - `codex-user-prompt:59c0990bf7c2d1a6`
- [[sources/codex-prompts/codex-user-prompt-3955af5786171acd|Agent 4: Read-only inspect current GitHub Pages setup and wiki output in Prom...]] - `codex-user-prompt:3955af5786171acd`
- [[sources/codex-prompts/codex-user-prompt-7e30f2ebd3fa501e|Read-only planning task. Do not modify files. Based on the user's request, fo...]] - `codex-user-prompt:7e30f2ebd3fa501e`
- [[sources/codex-prompts/codex-user-prompt-adfcb36ff0fb8019|你在电脑上应该能够看到两个vscode一个是本地的一个是我想去连接服务器，但我不知道为什么现在这么慢跑的，还有我也想问你，我该怎么样才能让codex在服务...]] - `codex-user-prompt:adfcb36ff0fb8019`
- [[sources/codex-prompts/codex-user-prompt-2dae1affb72672ac|In D:\Research\Uncertainty, inspect the existing official runner patterns and...]] - `codex-user-prompt:2dae1affb72672ac`
- [[sources/codex-prompts/codex-user-prompt-694c7787265c710d|你现在接手这个项目：`chronicles-of-many-ages`。]] - `codex-user-prompt:694c7787265c710d`
- [[sources/codex-prompts/codex-user-prompt-fbbbe8ecc8565b19|只做只读诊断，不要编辑文件。你是 Game Director Agent。仓库路径：D:\Game_develop\Chronicles of Many...]] - `codex-user-prompt:fbbbe8ecc8565b19`
- [[sources/codex-prompts/codex-user-prompt-6a7abc41c1a6c149|只做只读诊断，不要编辑文件。你是 Simulation Architect Agent。仓库路径：D:\Game_develop\Chronicles o...]] - `codex-user-prompt:6a7abc41c1a6c149`
- [[sources/codex-prompts/codex-user-prompt-12d1a896754181e7|只做只读诊断，不要编辑文件。你是 UX / Game Feel Agent。仓库路径：D:\Game_develop\Chronicles of Many...]] - `codex-user-prompt:12d1a896754181e7`
- [[sources/codex-prompts/codex-user-prompt-5b325301863f416d|只做只读诊断，不要编辑文件。你是 Narrative Systems Agent。仓库路径：D:\Game_develop\Chronicles of M...]] - `codex-user-prompt:5b325301863f416d`
- [[sources/codex-prompts/codex-user-prompt-6342d2b82b9a3db9|只做只读诊断，不要编辑文件。你是 Technical Refactor Agent。仓库路径：D:\Game_develop\Chronicles of...]] - `codex-user-prompt:6342d2b82b9a3db9`
- [[sources/codex-prompts/codex-user-prompt-5a2cea62be6b31e1|只做只读诊断，不要编辑文件。你是 Version Upgrade / Integration Agent。仓库路径：D:\Game_develop\Chr...]] - `codex-user-prompt:5a2cea62be6b31e1`
- [[sources/codex-prompts/codex-user-prompt-902ac6d571a1fe84|我们要创建一个名为 Agent gamedevelopmentstudio 的项目。]] - `codex-user-prompt:902ac6d571a1fe84`
- [[sources/codex-prompts/codex-user-prompt-8ef9777c4280712f|请重写并强化根目录的 AGENTS.md。]] - `codex-user-prompt:8ef9777c4280712f`
- [[sources/codex-prompts/codex-user-prompt-bb760ac5f9048f36|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:bb760ac5f9048f36`
- [[sources/codex-prompts/codex-user-prompt-9acd6933fba67cbb|现在基于根目录 AGENTS.md，创建该项目的的制度层文档和模板。]] - `codex-user-prompt:9acd6933fba67cbb`
- [[sources/codex-prompts/codex-user-prompt-69c5c5deea528a19|现在基于 AGENTS.md、docs/ 和 templates/，实现 Agent GD Studio 的最小客户旅程原型。]] - `codex-user-prompt:69c5c5deea528a19`
- [[sources/codex-prompts/codex-user-prompt-d49b2d7b6fe89bb1|https://github.com/appleweiping/game-development-studio-agent.git帮我连接，分批次comm...]] - `codex-user-prompt:d49b2d7b6fe89bb1`
- [[sources/codex-prompts/codex-user-prompt-19dffc3d3fe29469|Selected text:]] - `codex-user-prompt:19dffc3d3fe29469`
- [[sources/codex-prompts/codex-user-prompt-9ae29678b2e96198|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:9ae29678b2e96198`
- [[sources/codex-prompts/codex-user-prompt-9bfeb51892401a7f|你先连接一下这个仓库。https://github.com/appleweiping/Medora.git]] - `codex-user-prompt:9bfeb51892401a7f`
- [[sources/codex-prompts/codex-user-prompt-0c740691f12d242e|Read the docs folder first.]] - `codex-user-prompt:0c740691f12d242e`
- [[sources/codex-prompts/codex-user-prompt-b5161ded533ee0f2|Read the docs folder first.]] - `codex-user-prompt:b5161ded533ee0f2`
- [[sources/codex-prompts/codex-user-prompt-df18e1ea73b73f60|Read the docs folder first.]] - `codex-user-prompt:df18e1ea73b73f60`
- [[sources/codex-prompts/codex-user-prompt-917ddae462b16361|Read the docs folder first.]] - `codex-user-prompt:917ddae462b16361`
- [[sources/codex-prompts/codex-user-prompt-1ce5f3a9c1f44018|Read the docs folder first, especially:]] - `codex-user-prompt:1ce5f3a9c1f44018`
- [[sources/codex-prompts/codex-user-prompt-165dd7a3730aa431|这是我跟gpt的对话：只想同步作者更新的话，也建议 fork + clone，但你尽量不要在自己的 fork 里改内容。这样同步最省心。]] - `codex-user-prompt:165dd7a3730aa431`
- [[sources/codex-prompts/codex-user-prompt-29fe98ad78455319|Context from my IDE setup:]] - `codex-user-prompt:29fe98ad78455319`
- [[sources/codex-prompts/codex-user-prompt-3f7b781414e5edb2|Context from my IDE setup:]] - `codex-user-prompt:3f7b781414e5edb2`
- [[sources/codex-prompts/codex-user-prompt-45b12b7f5fbaf1ab|Context from my IDE setup:]] - `codex-user-prompt:45b12b7f5fbaf1ab`
- [[sources/codex-prompts/codex-user-prompt-9c6aed1261d62e88|https://github.com/appleweiping/skill.git这个是我fork了别人的skill收录项目，里面有一个video-cre...]] - `codex-user-prompt:9c6aed1261d62e88`
- [[sources/codex-prompts/codex-user-prompt-97a5e41572b6ddb4|Files mentioned by the user:]] - `codex-user-prompt:97a5e41572b6ddb4`
- [[sources/codex-prompts/codex-user-prompt-42a176a5e33670f5|你负责为“professional concert pianist grand piano performing Canon in D elegant c...]] - `codex-user-prompt:42a176a5e33670f5`
- [[sources/codex-prompts/codex-user-prompt-e7bde27dcc7fecf0|我的意思是这样，我现在还想创建一些新的世界和人物的存档，我觉得我们可以搜寻一下github其他人的仓库或者资料来源，最好是那种高端的，热门的那种，跟我们不...]] - `codex-user-prompt:e7bde27dcc7fecf0`
- [[sources/codex-prompts/codex-user-prompt-4816ab78d91d8f6a|Karpathy他的完整github和他的所有项目和他的所有公开发布信息，这个你要仔细ingest，这个对我过分重要，主要就是得分好类，然后具体说说讲了什...]] - `codex-user-prompt:4816ab78d91d8f6a`
- [[sources/codex-prompts/codex-user-prompt-7d055b980af160f8|姚顺宇和姚顺雨这两个人的他们的完整github和他的所有项目和他的所有公开发布信息以及他们的所有论文，这个你要仔细ingest，这个对我过分重要，主要就是...]] - `codex-user-prompt:7d055b980af160f8`
- [[sources/codex-prompts/codex-user-prompt-4738c8ab2f376b85|热门前端框架，的完整github和他们的所有项目和他的所有公开发布信息，这个你要仔细ingest，这个对我过分重要，主要就是得分好类，然后具体说说讲了什么...]] - `codex-user-prompt:4738c8ab2f376b85`

### general-high-quality-prompt

- [[sources/codex-prompts/codex-user-prompt-f68c64f7705aaa5d|e-shadow-v6$ pgrep -af 'run_week8_large_scale_10k_100neg|main_generate_llmesr...]] - `codex-user-prompt:f68c64f7705aaa5d`
- [[sources/codex-prompts/codex-user-prompt-c2622e24d0ebd143|我想生成一个真实感怀旧风格的视频，画面像第一人称视角走在中国杭州的街道上。整体氛围是温柔、安静、带一点青春回忆感，不要赛博朋克，不要旅游宣传片感，要像普通...]] - `codex-user-prompt:c2622e24d0ebd143`
- [[sources/codex-prompts/codex-user-prompt-1770ed9eefb4da1c|任务仍然偏 synthetic / templated]] - `codex-user-prompt:1770ed9eefb4da1c`
- [[sources/codex-prompts/codex-user-prompt-8db19ee20e4f667a|有个问题，目前的这个前端他其实就是想把什么都展示在一个页面上了，他没有比方说有一侧是目录栏，然后我点击一个链接，然后主页面就跳转到一个相应的页面里，这个就...]] - `codex-user-prompt:8db19ee20e4f667a`
- [[sources/codex-prompts/codex-user-prompt-0fd7b37b6f931eca|你负责分析用户给的两个本地参考视频的视觉风格，用于创建“钢琴家在音乐厅演奏 Canon in D”的 AI 视频生成项目。参考视频路径：]] - `codex-user-prompt:0fd7b37b6f931eca`
- [[sources/codex-prompts/codex-user-prompt-bccbe8e206ebd388|这是一个 vanilla 1.4.x large master getfixedboi 种子世界，作为非 toy 原创项目的 base world；我没有...]] - `codex-user-prompt:bccbe8e206ebd388`

### personal-rules

- [[sources/codex-prompts/codex-user-prompt-15cf68518090bc02|Read the docs folder first.]] - `codex-user-prompt:15cf68518090bc02`

### prompt-engineering-pattern

- [[sources/codex-prompts/codex-user-prompt-ac95e31f14dbed9f|你是 Codex/GPT-5.5 targeted audit worker A。只读审计 DoneBench 的这些任务：calendar_028, c...]] - `codex-user-prompt:ac95e31f14dbed9f`
- [[sources/codex-prompts/codex-user-prompt-659ddaeb49f6e481|你是 Codex/GPT-5.5 targeted audit worker B。只读审计 DoneBench 的这些任务：crm_workflow_03...]] - `codex-user-prompt:659ddaeb49f6e481`
- [[sources/codex-prompts/codex-user-prompt-1fc8c23d67503821|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:1fc8c23d67503821`
- [[sources/codex-prompts/codex-user-prompt-9d9df849dc02a87f|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:9d9df849dc02a87f`
- [[sources/codex-prompts/codex-user-prompt-39e6611a43c0e26f|Prompt Wiki reference Agent 5: Study Dify as a reference for prompt/app workf...]] - `codex-user-prompt:39e6611a43c0e26f`
- [[sources/codex-prompts/codex-user-prompt-0c8fc0ba998bee5c|Read-only task in D:\Research\Prompt wiki. Inspect the current Prompt Wiki co...]] - `codex-user-prompt:0c8fc0ba998bee5c`
- [[sources/codex-prompts/codex-user-prompt-f7f5d729ae6f9c13|Read-only user modeling task for Prompt Wiki. Infer realistic target users an...]] - `codex-user-prompt:f7f5d729ae6f9c13`
- [[sources/codex-prompts/codex-user-prompt-2515dd78d5e90a5f|目前这个link graph的图颜值太低，且缺乏动态，需要重新修改]] - `codex-user-prompt:2515dd78d5e90a5f`

### research-workflow

- [[sources/codex-prompts/codex-automation-prompt-daily-tgl-rec-research-review|Repository:]] - `codex-automation-prompt:daily-tgl-rec-research-review`
- [[sources/codex-prompts/codex-user-prompt-de0fdd7a5a32897b|R2-real-LLM subgate provider is now approved.]] - `codex-user-prompt:de0fdd7a5a32897b`
- [[sources/codex-prompts/codex-user-prompt-4f19015bf6dd7d8d|当前状态：]] - `codex-user-prompt:4f19015bf6dd7d8d`
- [[sources/codex-prompts/codex-user-prompt-4d075c616684094b|Context from my IDE setup:]] - `codex-user-prompt:4d075c616684094b`
- [[sources/codex-prompts/codex-user-prompt-2c34f26f67a2c8d8|作为reviewer，对这个项目进行顶会级审稿，然后再多agent协同工作，把这个项目搞到顶会级别，必要时也可查阅其他顶会论文的setting，把你认为应...]] - `codex-user-prompt:2c34f26f67a2c8d8`
- [[sources/codex-prompts/codex-user-prompt-3a5b1353e403cab1|你是相关论文/顶会setting explorer。这个项目名是 UncertaintyProtein-AI4S，目录 protein_bo_confor...]] - `codex-user-prompt:3a5b1353e403cab1`
- [[sources/codex-prompts/codex-user-prompt-776fdd4df3f88dc7|工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...]] - `codex-user-prompt:776fdd4df3f88dc7`
- [[sources/codex-prompts/codex-user-prompt-de8c7cf95961d2f8|工作区：D:\Research\DoneBench。你不是独自在代码库中工作，请不要回退他人的改动。当前项目是 DoneBench benchmark M...]] - `codex-user-prompt:de8c7cf95961d2f8`
- [[sources/codex-prompts/codex-user-prompt-de54a7595ceb8302|最关键不是继续跑 API，而是去模板化任务生成，让 300 tasks 的内容多样性也真正对齐顶会。当前模块骨架已经像了，内容审计也诚实暴露了风险。现在还...]] - `codex-user-prompt:de54a7595ceb8302`
- [[sources/codex-prompts/codex-user-prompt-e61e0cf823d613e0|工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：Reviewer 2 / 顶会相关工作差距分析。请联...]] - `codex-user-prompt:e61e0cf823d613e0`
- [[sources/codex-prompts/codex-user-prompt-9e0ce10d574ddb71|工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：专注于去模板化任务生成质量。阅读 donebench...]] - `codex-user-prompt:9e0ce10d574ddb71`
- [[sources/codex-prompts/codex-user-prompt-de2594e500941789|看看我们还差哪些模块，建议直接全部补齐。]] - `codex-user-prompt:de2594e500941789`
- [[sources/codex-prompts/codex-user-prompt-8d140d88dafd1b24|工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：补 Human Audit / Human Base...]] - `codex-user-prompt:8d140d88dafd1b24`
- [[sources/codex-prompts/codex-user-prompt-ab959833e00b8406|工作区 D:\Research\DoneBench。你不是独自在代码库中工作，不要回退他人改动。任务：补统计与错误 taxonomy 模块。职责范围：do...]] - `codex-user-prompt:ab959833e00b8406`
- [[sources/codex-prompts/codex-user-prompt-903f4f1511e26676|Please audit D:\Research\DoneBench for benchmark-module completeness. Do not...]] - `codex-user-prompt:903f4f1511e26676`
- [[sources/codex-prompts/codex-user-prompt-0296024d0a192f2d|Please act as Reviewer 2 for D:\Research\DoneBench. Do not edit files. Compar...]] - `codex-user-prompt:0296024d0a192f2d`
- [[sources/codex-prompts/codex-user-prompt-f38a91585edc14c5|Inspect the current repository file set and identify which docs/plans should...]] - `codex-user-prompt:f38a91585edc14c5`
- [[sources/codex-prompts/codex-user-prompt-f7c8b8dd66a4dd66|在 D:\Research\TRUCE-Rec 中检查 controlled baseline 相关代码、YAML 和测试。重点找：base_model/...]] - `codex-user-prompt:f7c8b8dd66a4dd66`
- [[sources/codex-prompts/codex-user-prompt-e5180275a57da774|基于 D:\Research\TRUCE-Rec 现有 docs/external_project_baseline_packets.md 和 LLM4R...]] - `codex-user-prompt:e5180275a57da774`
- [[sources/codex-prompts/codex-user-prompt-3c0fbdfba4c1e064|在 D:\Research\TRUCE-Rec 中整理当前 README、docs/PHASE_HANDOFF.md、docs/qwen3_lora_co...]] - `codex-user-prompt:3c0fbdfba4c1e064`
- [[sources/codex-prompts/codex-user-prompt-997d6c0f7262951c|In D:\Research\TGL-Rec, audit source/config/tests for baseline provenance and...]] - `codex-user-prompt:997d6c0f7262951c`
- [[sources/codex-prompts/codex-user-prompt-087ea905bb37bf9e|In D:\Research\TGL-Rec, inspect the current project docs and produce a detail...]] - `codex-user-prompt:087ea905bb37bf9e`
- [[sources/codex-prompts/codex-user-prompt-67401ccd6cb7b8cc|In D:\Research\TGL-Rec, audit README.md and docs/*.md for outdated wording ar...]] - `codex-user-prompt:67401ccd6cb7b8cc`
- [[sources/codex-prompts/codex-user-prompt-efa018abaaf54d50|Audit D:\Research\TGL-Rec for stale wording after the new official baseline c...]] - `codex-user-prompt:efa018abaaf54d50`
- [[sources/codex-prompts/codex-user-prompt-0734f3a1ad9d7aad|Audit D:\Research\TGL-Rec for baseline provenance schema/config locations. Fo...]] - `codex-user-prompt:0734f3a1ad9d7aad`
- [[sources/codex-prompts/codex-user-prompt-08be80405062fb9e|对于整个项目进行一次大改，保留几个重要的milestone，week1-4，pony12，light系列，shadow系列，baseline，从小域到四大...]] - `codex-user-prompt:08be80405062fb9e`
- [[sources/codex-prompts/codex-user-prompt-b9a3c8948d160985|You own the milestone architecture only. Read the current repo docs and draft...]] - `codex-user-prompt:b9a3c8948d160985`
- [[sources/codex-prompts/codex-user-prompt-eac70cefcfd63480|You own the top-conference review pass only. Use official conference sources...]] - `codex-user-prompt:eac70cefcfd63480`
- [[sources/codex-prompts/codex-user-prompt-099052ce642c17ef|You own the reviewer persona pass only. Act like a top-conference reviewer re...]] - `codex-user-prompt:099052ce642c17ef`
- [[sources/codex-prompts/codex-user-prompt-c1fbb4c9d766bfe1|Read-only task for TGL-Rec. Produce a top-conference-aware literature/baselin...]] - `codex-user-prompt:c1fbb4c9d766bfe1`
- [[sources/codex-prompts/codex-user-prompt-d944fe05f732ac53|请充当顶会审稿人（RecSys/SIGIR/WWW/NeurIPS 风格）只读评审 D:\Research\TRUCE-Rec 当前研究工程路线。输出：可...]] - `codex-user-prompt:d944fe05f732ac53`
- [[sources/codex-prompts/codex-user-prompt-42c36e9b904fced0|在 D:\Research\TRUCE-Rec 只读审计四域/Week8 same-candidate 数据接入路径。重点看 docs/week8_lar...]] - `codex-user-prompt:42c36e9b904fced0`
- [[sources/codex-prompts/codex-user-prompt-bd46f6cf993cd3eb|Read-only task for TGL-Rec. Act as a strict top-conference reviewer. Inspect...]] - `codex-user-prompt:bd46f6cf993cd3eb`
- [[sources/codex-prompts/codex-user-prompt-0408abebc4fb4c1a|Read-only task. Act as a strict top-conference reviewer for TGL-Rec's current...]] - `codex-user-prompt:0408abebc4fb4c1a`
- [[sources/codex-prompts/codex-user-prompt-e1bd08287b7c2746|Read-only task. Audit D:\Research\TGL-Rec for server-run blockers in the full...]] - `codex-user-prompt:e1bd08287b7c2746`
- [[sources/codex-prompts/codex-user-prompt-a21bc01f8b13cb33|你是 Reviewer/Related-work agent。请在 D:\Research\DoneBench 中只做只读分析，并结合公开顶会 agent...]] - `codex-user-prompt:a21bc01f8b13cb33`
- [[sources/codex-prompts/codex-user-prompt-d936c2c10c885dd4|你是 Codebase/Execution agent。请在 D:\Research\DoneBench 中只读分析当前真实 tool-plan exec...]] - `codex-user-prompt:d936c2c10c885dd4`
- [[sources/codex-prompts/codex-user-prompt-881474b76b729526|你是 Experiment/Artifact agent。请在 D:\Research\DoneBench 中只读分析 configs、CLI、repor...]] - `codex-user-prompt:881474b76b729526`
- [[sources/codex-prompts/codex-user-prompt-4d41bfc3ffb05d1c|Repository: D:\Research\TGL-Rec. Narrow review task while parent edits: inspe...]] - `codex-user-prompt:4d41bfc3ffb05d1c`
- [[sources/codex-prompts/codex-user-prompt-8f25e9708b8fc2ac|采用多agent协作方式，看看我们目前的framework设计是否足够强大，要原创不缝合，同时性能和复杂程度要上来很多，然后看看能否打败这些baselin...]] - `codex-user-prompt:8f25e9708b8fc2ac`
- [[sources/codex-prompts/codex-user-prompt-92df1b33c5d14a8e|学长的建议：关于如何比较baseline是公平的，其实不同paper的定义不同，只要看起来你的标准是统一的就可以，我可以举几个例子]] - `codex-user-prompt:92df1b33c5d14a8e`
- [[sources/codex-prompts/codex-user-prompt-d60194f3db48cef5|You own the fairness-policy design review. Based on the user's senior advice,...]] - `codex-user-prompt:d60194f3db48cef5`
- [[sources/codex-prompts/codex-user-prompt-2637b4df1ae9c5b0|You own the code/config audit for implementing the new fairness policy. Inspe...]] - `codex-user-prompt:2637b4df1ae9c5b0`
- [[sources/codex-prompts/codex-user-prompt-a8f7b6c92a402045|You own the paper/report update audit. Inspect README, docs/paper_claims_and_...]] - `codex-user-prompt:a8f7b6c92a402045`
- [[sources/codex-prompts/codex-user-prompt-a304d778f43c0dd9|请作为顶会审稿人/实验设置审计员，快速检查当前仓库关于 external baseline fairness 的改动方向是否还有明显口径风险。重点看 RE...]] - `codex-user-prompt:a304d778f43c0dd9`
- [[sources/codex-prompts/codex-user-prompt-d5b66dfbb1e0f372|In repo D:\Research\TRUCE-Rec, audit the current baseline/fairness/provenance...]] - `codex-user-prompt:d5b66dfbb1e0f372`
- [[sources/codex-prompts/codex-user-prompt-23bdba74a880b055|In repo D:\Research\TRUCE-Rec, inspect the Ours framework code and docs. Judg...]] - `codex-user-prompt:23bdba74a880b055`
- [[sources/codex-prompts/codex-user-prompt-71d9da56d95831b7|In repo D:\Research\TRUCE-Rec, inspect server run scripts/docs and four-domai...]] - `codex-user-prompt:71d9da56d95831b7`
- [[sources/codex-prompts/codex-user-prompt-f27adfd965356006|Repository: D:\Research\TGL-Rec. Audit what must change so server-side runs f...]] - `codex-user-prompt:f27adfd965356006`
- [[sources/codex-prompts/codex-user-prompt-b9ef71749c5072b3|Repository: D:\Research\TGL-Rec. Review docs/configs for baseline fairness po...]] - `codex-user-prompt:b9ef71749c5072b3`
- [[sources/codex-prompts/codex-user-prompt-ee032e74c8e9aba7|把这些结果整理进 paper/report，并自动生成一份 pilot_findings.md：]] - `codex-user-prompt:ee032e74c8e9aba7`
- [[sources/codex-prompts/codex-user-prompt-23a96bc400f5d3ae|In D:\Research\DoneBench, inspect the existing report/paper structure and tel...]] - `codex-user-prompt:23a96bc400f5d3ae`
- [[sources/codex-prompts/codex-user-prompt-264f195604df8c5d|In D:\Research\DoneBench, inspect audit-related modules and configs. Find the...]] - `codex-user-prompt:264f195604df8c5d`
- [[sources/codex-prompts/codex-user-prompt-e523b5077ce737a6|In D:\Research\DoneBench, inspect experiment/full-run readiness: configs, par...]] - `codex-user-prompt:e523b5077ce737a6`
- [[sources/codex-prompts/codex-user-prompt-f87b64b58be9a705|在 D:\Research\Uncertainty 仓库中检查 LLM2Rec 和 LLM-ESR 相关脚本。请回答：现有哪些 export/prepar...]] - `codex-user-prompt:f87b64b58be9a705`
- [[sources/codex-prompts/codex-user-prompt-f0ad343d989437c9|在 D:\Research\Uncertainty 仓库中检查 main_make_official_external_adapter_plan.py、m...]] - `codex-user-prompt:f0ad343d989437c9`
- [[sources/codex-prompts/codex-user-prompt-71d5d8b67a2e5a87|请只读检查 D:\Research\Uncertainty 仓库的 README.md、docs/server_runbook.md、docs/miles...]] - `codex-user-prompt:71d5d8b67a2e5a87`
- [[sources/codex-prompts/codex-user-prompt-2d03b3b845895c93|请只读审查 D:\Research\Uncertainty 中 baseline/protocol/official runner 相关文档和脚本，重点找...]] - `codex-user-prompt:2d03b3b845895c93`
- [[sources/codex-prompts/codex-user-prompt-912a7b2434c5f986|请只读检查 D:\Research\Uncertainty 中所有 LLM2Rec 相关脚本和测试，重点回答：现有 export/prepare/gene...]] - `codex-user-prompt:912a7b2434c5f986`
- [[sources/codex-prompts/codex-user-prompt-b9d606d23d938f0a|请只读设计 LLM2Rec 四域 official runner 的执行链。基于 AGENTS.md、configs/official_external_...]] - `codex-user-prompt:b9d606d23d938f0a`
- [[sources/codex-prompts/codex-user-prompt-2a5ab3701d78adb2|你作为仓库清理审计 agent，只读检查 D:\Research\Uncertainty。请给出：1) 根目录哪些 Markdown/报告属于 legac...]] - `codex-user-prompt:2a5ab3701d78adb2`
- [[sources/codex-prompts/codex-user-prompt-2db4cbc33f661e58|你作为文档一致性 reviewer，只读检查 AGENTS.md、README.md、docs/server_runbook.md、OFFICIAL_EX...]] - `codex-user-prompt:2db4cbc33f661e58`
- [[sources/codex-prompts/codex-user-prompt-52a7e0cce0ba1bd8|You are the Reviewer/Auditor agent. In this repo, evaluate whether the curren...]] - `codex-user-prompt:52a7e0cce0ba1bd8`
- [[sources/codex-prompts/codex-user-prompt-30402d1703b51f98|You are the Implementation agent. Inspect current CCRP/Shadow and SRPD code/c...]] - `codex-user-prompt:30402d1703b51f98`
- [[sources/codex-prompts/codex-user-prompt-cb4aff10b848b272|You are the Literature/Protocol Scout. Use only local repository files unless...]] - `codex-user-prompt:cb4aff10b848b272`
- [[sources/codex-prompts/codex-user-prompt-b73843ae79780526|Repo: D:\Research\Uncertainty. 请作为 reviewer/auditor 审核当前未提交的 SRPD formal 配置与...]] - `codex-user-prompt:b73843ae79780526`
- [[sources/codex-prompts/codex-user-prompt-c366f0e1cf7418d4|就做ccrp和srpd这两个好了，我认为从观察（观察阶段基本就是beauty全域+其他三个域的各10000user（或者最好就是观察的数量和后面train...]] - `codex-user-prompt:c366f0e1cf7418d4`
- [[sources/codex-prompts/codex-user-prompt-4636540f704376cd|同时本地/代码侧可以继续补 SRPD formal 配置模板，但模板必须 fail-fast：缺 train/valid teacher 就不跑，不允许偷...]] - `codex-user-prompt:4636540f704376cd`
- [[sources/codex-prompts/codex-user-prompt-677d969b78e6bf83|你是项目文档梳理 agent。只读梳理 D:\Research\DoneBench 的已有文档和代码结构，为后续 Codex handoff 文档提供事实...]] - `codex-user-prompt:677d969b78e6bf83`
- [[sources/codex-prompts/codex-user-prompt-ba00b8d35ae19612|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:ba00b8d35ae19612`
- [[sources/codex-prompts/codex-user-prompt-fc87385eaaaf9512|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:fc87385eaaaf9512`
- [[sources/codex-prompts/codex-user-prompt-bc63fbd3dfc98e4d|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:bc63fbd3dfc98e4d`
- [[sources/codex-prompts/codex-user-prompt-cdd80fca2d5b4419|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:cdd80fca2d5b4419`
- [[sources/codex-prompts/codex-user-prompt-62189a1bfef60dc7|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:62189a1bfef60dc7`
- [[sources/codex-prompts/codex-user-prompt-529cdcd2c8a8d4bc|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:529cdcd2c8a8d4bc`
- [[sources/codex-prompts/codex-user-prompt-41026be2af97c765|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:41026be2af97c765`
- [[sources/codex-prompts/codex-user-prompt-1e30685ca6c788de|You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...]] - `codex-user-prompt:1e30685ca6c788de`
- [[sources/codex-prompts/codex-user-prompt-5300686e01b28643|你在 D:\Research\DoneBench 做只读审查，不修改文件。请以顶会 ML/NLP/AI benchmark 论文审稿人视角审这个项目：先读...]] - `codex-user-prompt:5300686e01b28643`
- [[sources/codex-prompts/codex-user-prompt-a8f28f42af9c6262|你在 D:\Research\DoneBench 做只读资源/相关工作侦察，不修改文件。请阅读 reports/agent_handoff.md 和 pa...]] - `codex-user-prompt:a8f28f42af9c6262`
- [[sources/codex-prompts/codex-user-prompt-dbd9268a3e42d1b4|最值得补的是 full corpus strict validation、oracle-spec ablation、token-matched ablat...]] - `codex-user-prompt:dbd9268a3e42d1b4`
- [[sources/codex-prompts/codex-user-prompt-a14158167ab588a4|在 D:\Research\DoneBench 做只读代码/报告侦察。目标：找出已有的 oracle-spec、token-matched、cross-f...]] - `codex-user-prompt:a14158167ab588a4`
- [[sources/codex-prompts/codex-user-prompt-1700179aaa56c40d|在 D:\Research\DoneBench 做只读论文同步审查。请读 paper/sections/results.tex、experiments.t...]] - `codex-user-prompt:1700179aaa56c40d`
- [[sources/codex-prompts/codex-user-prompt-4716cf0a2ce60e37|In D:\Research\TRUCE-Rec, inspect AGENTS.md, README.md, docs/PHASE_HANDOFF.md...]] - `codex-user-prompt:4716cf0a2ce60e37`
- [[sources/codex-prompts/codex-user-prompt-bf245358f3deb7e0|In D:\Research\TRUCE-Rec, review docs for the experiment/project framework na...]] - `codex-user-prompt:bf245358f3deb7e0`
- [[sources/codex-prompts/codex-user-prompt-c0aa0dfebd31cf22|In D:\Research\TRUCE-Rec, act as a top-conference reviewer. Review docs/PROJE...]] - `codex-user-prompt:c0aa0dfebd31cf22`
- [[sources/codex-prompts/codex-user-prompt-34252dec931467b9|In D:\Research\TRUCE-Rec, act as an implementation architect. Inspect Ours/ba...]] - `codex-user-prompt:34252dec931467b9`
- [[sources/codex-prompts/codex-user-prompt-4b15f3cf1a4dbd76|In D:\Research\TRUCE-Rec, audit documentation entrypoints: docs/PROJECT_MEMOR...]] - `codex-user-prompt:4b15f3cf1a4dbd76`
- [[sources/codex-prompts/codex-user-prompt-0bfac25dcabeea2d|You are reviewer for TGL-Rec Phase 10. Read docs/codex_project_memory.md, doc...]] - `codex-user-prompt:0bfac25dcabeea2d`
- [[sources/codex-prompts/codex-user-prompt-d83a69ed778bcd51|Small-scope reviewer task. Read only docs/codex_project_memory.md, docs/phase...]] - `codex-user-prompt:d83a69ed778bcd51`
- [[sources/codex-prompts/codex-user-prompt-5c9de60b7c938f68|在 D:\Research\DoneBench 中做顶会审稿式 paper audit。请只读不改。重点检查 paper/sections/*.tex、r...]] - `codex-user-prompt:5c9de60b7c938f68`
- [[sources/codex-prompts/codex-user-prompt-b6e8fc6e92a569cd|在 D:\Research\DoneBench 中只读审查 LaTeX/表格投递风险。重点：paper/main.tex 或 paper/*.tex 结构...]] - `codex-user-prompt:b6e8fc6e92a569cd`
- [[sources/codex-prompts/codex-user-prompt-d0f53be992730a1d|在 D:\Research\DoneBench 中研究现有模型/provider 配置，提出 Qwen/GLM/Kimi cross-family sli...]] - `codex-user-prompt:d0f53be992730a1d`
- [[sources/codex-prompts/codex-user-prompt-98a479c6b788a20b|我希望能在agent这边加一句，每次碰到复杂任务都要用多agent协作工作，工作开始时默认阅读几个重要文档（这个要你自行决定和搜索你觉得重要的文档，一般是...]] - `codex-user-prompt:98a479c6b788a20b`
- [[sources/codex-prompts/codex-user-prompt-99c79f1078ae8eaf|在 D:\Research\DoneBench 中只读查找：未来 Codex/agent 应该优先阅读哪些项目文档、长期操作规约应该放在哪些文件最有效。重...]] - `codex-user-prompt:99c79f1078ae8eaf`
- [[sources/codex-prompts/codex-user-prompt-a83f386568cf5bc4|在 D:\Research\DoneBench 中只读做顶会 reviewer 视角审查：用户想加一条规则，复杂任务必须多agent协作、开工默认读关键文...]] - `codex-user-prompt:a83f386568cf5bc4`
- [[sources/codex-prompts/codex-user-prompt-8e6885e290493b40|Repo: D:\Research\Uncertainty. 作为 Method Engineer，审查我们自己的 C-CRP 与 SRPD 代码/配置/...]] - `codex-user-prompt:8e6885e290493b40`
- [[sources/codex-prompts/codex-user-prompt-1d5304b252568051|Repo: D:\Research\Uncertainty. 作为 Literature/Protocol Scout，对照多个 RecSys/SIGIR...]] - `codex-user-prompt:1d5304b252568051`
- [[sources/codex-prompts/codex-user-prompt-8b860b1c625a0040|Repo: D:\Research\Uncertainty. 作为 top-conference Reviewer/Auditor，强势挑刺：我们自己的...]] - `codex-user-prompt:8b860b1c625a0040`
- [[sources/codex-prompts/codex-user-prompt-cec89807cc7d817a|Complex TRUCE-Rec task. Read AGENTS.md, docs/PROJECT_MEMORY.md, docs/RESEARCH...]] - `codex-user-prompt:cec89807cc7d817a`
- [[sources/codex-prompts/codex-user-prompt-23abf0f842656324|You are the literature/protocol scout for this repository. User asks whether...]] - `codex-user-prompt:23abf0f842656324`
- [[sources/codex-prompts/codex-user-prompt-9c7042b90c806b2a|You are the top-conference reviewer/auditor for this repository. Review the c...]] - `codex-user-prompt:9c7042b90c806b2a`
- [[sources/codex-prompts/codex-user-prompt-0d33f28e8468a1eb|Literature scout for TGL-Rec method upgrade. Read docs/codex_project_memory.m...]] - `codex-user-prompt:0d33f28e8468a1eb`
- [[sources/codex-prompts/codex-user-prompt-3b819a8949c74bbe|Top-conference reviewer for TGL-Rec. Read docs/codex_project_memory.md, docs/...]] - `codex-user-prompt:3b819a8949c74bbe`
- [[sources/codex-prompts/codex-user-prompt-066dafd0c49ec61d|Data-layout auditor. Read docs/codex_project_memory.md and inspect local file...]] - `codex-user-prompt:066dafd0c49ec61d`
- [[sources/codex-prompts/codex-user-prompt-90cdd9fb8c024581|在 D:\Research\DoneBench 中只读梳理当前项目已有能力和缺口，目标是回答：除了 benchmark 贡献，还能自然长出哪些非缝合、非照...]] - `codex-user-prompt:90cdd9fb8c024581`
- [[sources/codex-prompts/codex-user-prompt-7621309f64f2bbef|在 D:\Research\DoneBench 中只读做顶会 reviewer/area chair 视角：如果 DoneBench 不只作为 bench...]] - `codex-user-prompt:7621309f64f2bbef`
- [[sources/codex-prompts/codex-user-prompt-3d761dcf2aedb13d|你是 DoneBench 的实现助手。请只读分析以下文件并给出最小实现方案，不要改文件：donebench/scripts/advanced_stats....]] - `codex-user-prompt:3d761dcf2aedb13d`
- [[sources/codex-prompts/codex-user-prompt-11c113201accfa0b|你是 DoneBench 的 skeptical reviewer。请只读审查 M6.1 诊断表计划的 claim 风险：四象限表、自我违反 taxono...]] - `codex-user-prompt:11c113201accfa0b`
- [[sources/codex-prompts/codex-user-prompt-c59967b9b0543b8a|你是顶会级别 skeptical reviewer/AC，只读，不要修改文件。请基于当前 DoneBench 状态挑刺：阅读 reports/agent_...]] - `codex-user-prompt:c59967b9b0543b8a`
- [[sources/codex-prompts/codex-user-prompt-76a27b2c15ef5701|只读研究任务，不要修改文件。请浏览/查阅 specification/evaluation/formal-verification 相关论文和项目：Age...]] - `codex-user-prompt:76a27b2c15ef5701`
- [[sources/codex-prompts/codex-user-prompt-efb9e75078fcae34|只读复核任务。请检查 DoneBench 当前论文/报告状态，聚焦本轮计划的实现风险：M6.2 analysis.tex 写法、repaired diag...]] - `codex-user-prompt:efb9e75078fcae34`
- [[sources/codex-prompts/codex-user-prompt-2e77b97419c0ee75|If you are available, act as a domain/task-sampling reviewer for the DoneBenc...]] - `codex-user-prompt:2e77b97419c0ee75`
- [[sources/codex-prompts/codex-user-prompt-834558664795bf05|Read-only task. Inspect D:\Research for the AI4S and AI4eda / analog-agent re...]] - `codex-user-prompt:834558664795bf05`
- [[sources/codex-prompts/codex-user-prompt-0ac812da9b7e2c06|Read-only task. Inspect D:\Research for Uncertainty-related research projects...]] - `codex-user-prompt:0ac812da9b7e2c06`
- [[sources/codex-prompts/codex-user-prompt-2e82ff84bc08aa25|Read-only task. Inspect D:\Research for truce-rec, tgl-rec, and donebench rel...]] - `codex-user-prompt:2e82ff84bc08aa25`
- [[sources/codex-prompts/codex-user-prompt-85fd8fa1055d9513|For D:\Research\vipin's knowledgebase, inspect AGENTS.md, WORKFLOWS.md, reade...]] - `codex-user-prompt:85fd8fa1055d9513`
- [[sources/codex-prompts/codex-user-prompt-c40559bb3a274a05|你是并行审计子 agent。请在仓库 D:\Research\UncertaintyProtein-AI4S 中做只读代码/文档审计，不要修改文件。目标：...]] - `codex-user-prompt:c40559bb3a274a05`
- [[sources/codex-prompts/codex-user-prompt-edc989d0ae27cc09|你是并行科研定位审计子 agent。请只读仓库 D:\Research\UncertaintyProtein-AI4S，不要修改文件。目标：从科研叙事角度...]] - `codex-user-prompt:edc989d0ae27cc09`
- [[sources/codex-prompts/codex-user-prompt-0265e11e8c560a10|而且你的baseline目前也比较单薄，没有比较新的25年，26年出的那些顶会论文项目baseline，baseline一般至少要有8个，这些你不要口头说...]] - `codex-user-prompt:0265e11e8c560a10`
- [[sources/codex-prompts/codex-user-prompt-df18d1bedaa2b600|你是顶会 reviewer 子 agent，只读仓库 D:\Research\UncertaintyProtein-AI4S，不要修改。基于用户最新要求进...]] - `codex-user-prompt:df18d1bedaa2b600`
- [[sources/codex-prompts/codex-user-prompt-91f3ee293bf9f680|你是实现设计子 agent。请在你自己的工作区修改文件，注意你不是唯一 agent，不要撤销别人改动。任务：为 D:\Research\Uncertain...]] - `codex-user-prompt:91f3ee293bf9f680`
- [[sources/codex-prompts/codex-user-prompt-9c081859b7858b00|observation也可最先从调用普通deepseek的api开始，然后再是上服务器用小模型去观察，发现确实有这个现象，然后我们就lora finetu...]] - `codex-user-prompt:9c081859b7858b00`
- [[sources/codex-prompts/codex-user-prompt-c7cc5a8352df7386|deepseek要并行，qwen3 8B也要考虑调用并行，怎么快怎么来，但不影响实验，项目质量。]] - `codex-user-prompt:c7cc5a8352df7386`
- [[sources/codex-prompts/codex-user-prompt-c8feeb8a0b3abefd|我想利用harness engineering 的全套思路（自己去搜寻里面包含什么概念），重新构建这个项目，内容idea只做部分保留，给你大的权限删去已有...]] - `codex-user-prompt:c8feeb8a0b3abefd`
- [[sources/codex-prompts/codex-user-prompt-498e14cac586adae|我希望能在上服务器之前，本地先把所有已经能搭的项目都搭好，做好服务器上只需要跑指令即可。我还看到本地这个文件夹有很多东西是多余的可删的，你一定要大胆的做删...]] - `codex-user-prompt:498e14cac586adae`
- [[sources/codex-prompts/codex-user-prompt-32f15e8990e16635|Plan-mode read-only audit only. Repo: D:\Research\UncertaintyProtein-AI4S. Us...]] - `codex-user-prompt:32f15e8990e16635`
- [[sources/codex-prompts/codex-user-prompt-dd7112df34ef630b|Plan-mode read-only research reviewer. Repo: D:\Research\UncertaintyProtein-A...]] - `codex-user-prompt:dd7112df34ef630b`
- [[sources/codex-prompts/codex-user-prompt-7ab57db4cc0ce8cc|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:7ab57db4cc0ce8cc`
- [[sources/codex-prompts/codex-user-prompt-a59c95f7a7254839|本地再清一轮旧结构]] - `codex-user-prompt:a59c95f7a7254839`
- [[sources/codex-prompts/codex-user-prompt-69525abd1d8bd103|在仓库 D:\Research\UncertaintyProtein-AI4S 中做一个只读审计：找出现有 day/main5/smoke 旧配置、pap...]] - `codex-user-prompt:69525abd1d8bd103`
- [[sources/codex-prompts/codex-user-prompt-75d9a7d7c08332e4|系统调研 2025/2026 相关顶会/强论文的 PLM、LLM4Protein、protein design、active/few-shot optim...]] - `codex-user-prompt:75d9a7d7c08332e4`
- [[sources/codex-prompts/codex-user-prompt-5349e92c0fac7f1b|做 server-ready adapter skeleton：为 registry 里优先级最高的 ProSpero、DPLM-2、GLID2E、ESM...]] - `codex-user-prompt:5349e92c0fac7f1b`
- [[sources/codex-prompts/codex-user-prompt-ea5baa990066559d|如果你还可用，请做只读 reviewer 审计：我们要把 ESM3 API 和 METL adapters 从 blocker skeleton 推进到真...]] - `codex-user-prompt:ea5baa990066559d`
- [[sources/codex-prompts/codex-user-prompt-0d75cd686a79dbf4|以后强制要利用harness engineering的思维去实现和维护项目，参考内容如下https://zhuanlan.zhihu.com/p/2014...]] - `codex-user-prompt:0d75cd686a79dbf4`
- [[sources/codex-prompts/codex-user-prompt-04e3aaaa98a3fba2|Repository: D:\Research\UncertaintyProtein-AI4S. Plan-mode only. Do not edit...]] - `codex-user-prompt:04e3aaaa98a3fba2`
- [[sources/codex-prompts/codex-user-prompt-e1eb09e28541f256|Repository: D:\Research\UncertaintyProtein-AI4S. Plan-mode only. Do not edit...]] - `codex-user-prompt:e1eb09e28541f256`
- [[sources/codex-prompts/codex-user-prompt-1164d1ee329f43e7|Read-only audit task in D:\Research\UncertaintyProtein-AI4S. The user locked...]] - `codex-user-prompt:1164d1ee329f43e7`
- [[sources/codex-prompts/codex-user-prompt-ace4e05c41f6eba6|Read-only audit task in D:\Research\UncertaintyProtein-AI4S. Please inspect s...]] - `codex-user-prompt:ace4e05c41f6eba6`
- [[sources/codex-prompts/codex-user-prompt-61ad48a16badabc1|在 D:\Research\Agent-AI4EDA\analog-agent 中快速检查 world model 相关代码结构，回答：1) 适合新增 d...]] - `codex-user-prompt:61ad48a16badabc1`
- [[sources/codex-prompts/codex-user-prompt-d69057177bf964bb|请作为 reviewer agent 对 D:\Research\Agent-AI4EDA\analog-agent 当前未提交 diff 做只读代码审查...]] - `codex-user-prompt:d69057177bf964bb`
- [[sources/codex-prompts/codex-user-prompt-8983321fc3c7f7e5|只读调研任务，不要编辑文件。请基于当前对话目标，核对这些 GitHub 参考项目的真实状态和可借鉴点：dw-dengwei/daily-arXiv-ai-...]] - `codex-user-prompt:8983321fc3c7f7e5`
- [[sources/codex-prompts/codex-user-prompt-5d2e0ba581239dd0|只读调研任务，不要编辑文件。请调研同类科研趋势/论文发现产品的产品信息架构和可本地化功能：Papers with Code, Hugging Face T...]] - `codex-user-prompt:5d2e0ba581239dd0`
- [[sources/codex-prompts/codex-user-prompt-c5d6bff537bb137e|你是 Research Recon Prototype 的“实现/编码 agent”。仓库在 D:\Research\Research Recon Pro...]] - `codex-user-prompt:c5d6bff537bb137e`
- [[sources/codex-prompts/codex-user-prompt-1a3717f3f138aaee|你是 Research Recon Prototype 的“评审 agent”。仓库在 D:\Research\Research Recon Protot...]] - `codex-user-prompt:1a3717f3f138aaee`
- [[sources/codex-prompts/codex-user-prompt-6896bb65287b0e91|你是 Research Recon Prototype 的“文档/知识库维护 agent”。仓库在 D:\Research\Research Recon...]] - `codex-user-prompt:6896bb65287b0e91`
- [[sources/codex-prompts/codex-user-prompt-548c8051c3db87fc|你是 Research Recon Prototype 的“doc-gardening / 清理 agent”。仓库在 D:\Research\Resea...]] - `codex-user-prompt:548c8051c3db87fc`
- [[sources/codex-prompts/codex-user-prompt-eb9851b3d49f40ed|你是 Research Recon Prototype 的项目 reviewer。请在仓库 D:\Research\Research Recon Prot...]] - `codex-user-prompt:eb9851b3d49f40ed`
- [[sources/codex-prompts/codex-user-prompt-403927342fccf060|你是 Research Recon Prototype 的实现 worker，但先不要动手改文件。请在仓库 D:\Research\Research Re...]] - `codex-user-prompt:403927342fccf060`
- [[sources/codex-prompts/codex-user-prompt-f12042b38ec7d588|你是 Research Recon Prototype 的真实用户 reviewer A。请不要修改文件。按用户要求实际使用并评审项目：本地页面/Code...]] - `codex-user-prompt:f12042b38ec7d588`
- [[sources/codex-prompts/codex-user-prompt-95a712a86cff9434|你是 Research Recon Prototype 的真实用户 reviewer B。请不要修改文件。请从另一种用户画像评审：实验室同事/外部用户第一...]] - `codex-user-prompt:95a712a86cff9434`
- [[sources/codex-prompts/codex-user-prompt-8130036803f10d39|你是 reference research agent A。请不要修改文件。请搜寻/调研顶会论文工具、热门 Hugging Face/GitHub res...]] - `codex-user-prompt:8130036803f10d39`
- [[sources/codex-prompts/codex-user-prompt-c8f851e6a7105ea4|你是 reference research agent B。请不要修改文件。请从竞品和成熟产品角度搜寻：Elicit、Semantic Scholar、C...]] - `codex-user-prompt:c8f851e6a7105ea4`
- [[sources/codex-prompts/codex-user-prompt-fac1ae12f847bcb8|你是 Reviewer Agent 1，扮演真实科研用户/PI，不只是看界面。工作目录是 D:\Research\Research Recon Proto...]] - `codex-user-prompt:fac1ae12f847bcb8`
- [[sources/codex-prompts/codex-user-prompt-20b97fb7478d5966|你是 Reviewer Agent 2，扮演真实 power user / Codex automation user，要像用户一样实际跑端到端，不只是...]] - `codex-user-prompt:20b97fb7478d5966`
- [[sources/codex-prompts/codex-user-prompt-5bf42e552b131cd9|你是 QA Agent 6。先不要改代码。工作目录 D:\Research\Research Recon Prototype。任务：]] - `codex-user-prompt:5bf42e552b131cd9`
- [[sources/codex-prompts/codex-user-prompt-1ca6f85b01aa68b2|追加 reviewer 发现，请纳入你的后端实作范围：]] - `codex-user-prompt:1ca6f85b01aa68b2`
- [[sources/codex-prompts/codex-user-prompt-223ebc8aba98d87d|只读规划任务。仓库路径 D:\Research\Research Recon Prototype。作为“实现/编码 agent”，检查现有推荐/LLM/A...]] - `codex-user-prompt:223ebc8aba98d87d`
- [[sources/codex-prompts/codex-user-prompt-8ea469fe5bd89574|只读规划任务。仓库路径 D:\Research\Research Recon Prototype。作为“自检/验证 agent”，检查现有测试与 eval...]] - `codex-user-prompt:8ea469fe5bd89574`
- [[sources/codex-prompts/codex-user-prompt-e0ee370592152c00|只读规划任务。仓库路径 D:\Research\Research Recon Prototype。作为“评审 agent”，审查给 Research Re...]] - `codex-user-prompt:e0ee370592152c00`
- [[sources/codex-prompts/codex-user-prompt-37d804e8c7353000|只读规划任务。仓库路径 D:\Research\Research Recon Prototype。作为“文档/知识库维护 agent”，检查 README...]] - `codex-user-prompt:37d804e8c7353000`
- [[sources/codex-prompts/codex-user-prompt-0c9a527257694c53|只读规划任务。仓库路径 D:\Research\Research Recon Prototype。作为“doc-gardening / 清理 agent”...]] - `codex-user-prompt:0c9a527257694c53`
- [[sources/codex-prompts/codex-user-prompt-05c40f59c4ff1809|只读规划任务。仓库路径 D:\Research\Research Recon Prototype。作为“故障修复 agent”，预判实现 LLM4Rec...]] - `codex-user-prompt:05c40f59c4ff1809`
- [[sources/codex-prompts/codex-user-prompt-50efe2c7d46f746c|In D:\Research\TRUCE-Rec, perform a protocol/fairness reviewer pass for a pro...]] - `codex-user-prompt:50efe2c7d46f746c`
- [[sources/codex-prompts/codex-user-prompt-6bd47058f9460e1b|Use $truce-rec at D:\Research\TRUCE-Rec\.codex\skills\truce-rec to prepare fo...]] - `codex-user-prompt:6bd47058f9460e1b`
- [[sources/codex-prompts/codex-user-prompt-ea33c6b4a9e5a006|In D:\Research\Uncertainty, inspect main_train_score_setrec_upstream_adapter....]] - `codex-user-prompt:ea33c6b4a9e5a006`
- [[sources/codex-prompts/codex-user-prompt-1a34c4388d2e6051|In D:\Research\Uncertainty, do a quick reviewer/auditor pass for the SETRec o...]] - `codex-user-prompt:1a34c4388d2e6051`
- [[sources/codex-prompts/codex-user-prompt-aac1d1a20b9f26f4|In D:\Research\Uncertainty, inspect the current SETRec official adapter code,...]] - `codex-user-prompt:aac1d1a20b9f26f4`
- [[sources/codex-prompts/codex-user-prompt-99f2eccf5d746691|In D:\Research\Uncertainty, focus on memory mitigation for the SETRec officia...]] - `codex-user-prompt:99f2eccf5d746691`
- [[sources/codex-prompts/codex-user-prompt-09f54fd46dc0b387|In D:\Research\Uncertainty, inspect the SETRec official adapter/training code...]] - `codex-user-prompt:09f54fd46dc0b387`
- [[sources/codex-prompts/codex-user-prompt-6131c215c59fc34f|In D:\Research\Uncertainty, act as reviewer/auditor for the pasted SETRec off...]] - `codex-user-prompt:6131c215c59fc34f`
- [[sources/codex-prompts/codex-user-prompt-964c7257489e914a|我感觉这个baseline错误好像特别多，我们也改了很久了，没啥效果。这样吧，我们做其他的学长推荐的baseline吧，然后另外我不知道你记不记得之前你找...]] - `codex-user-prompt:964c7257489e914a`
- [[sources/codex-prompts/codex-user-prompt-e2066354f40dc8a4|在 D:\Research\Uncertainty 仓库中快速检查 ProEx/ProMax/ELMRec official runner 的命令面、输出...]] - `codex-user-prompt:e2066354f40dc8a4`
- [[sources/codex-prompts/codex-user-prompt-cc408adbf0dd9ed9|在 D:\Research\Uncertainty 仓库中做 reviewer/auditor 只读检查：针对用户当前服务器上 book 域第七个 off...]] - `codex-user-prompt:cc408adbf0dd9ed9`

### wiki-ingest

- [[sources/codex-prompts/codex-user-prompt-bf803d25f570bcd6|跑full的话如果说他能做到中途中断还能接续，就跑。如果不能，就先做到这点，然后再跑。还有跑的时候要间断性的报告跑了多少，还要跑多久等，但不必过分频繁。高...]] - `codex-user-prompt:bf803d25f570bcd6`
- [[sources/codex-prompts/codex-user-prompt-6ca099be41f4c475|跑full的话如果说他能做到中途中断还能接续，就跑。如果不能，就先做到这点，然后再跑。还有跑的时候要间断性的报告跑了多少，还要跑多久等，但不必过分频繁。高...]] - `codex-user-prompt:6ca099be41f4c475`
- [[sources/codex-prompts/codex-user-prompt-d6fd98533dcff877|只读 artifact/repro checker。请检查如何实现 claim_to_artifact_map、leaderboard_contamina...]] - `codex-user-prompt:d6fd98533dcff877`
- [[sources/codex-prompts/codex-user-prompt-8aaa918c83611f31|Plan-mode exploration only: do not edit files. Workspace: D:\Research\vipin's...]] - `codex-user-prompt:8aaa918c83611f31`
- [[sources/codex-prompts/codex-user-prompt-ed25a7d3da4e0e76|In workspace D:\Research\vipin's knowledgebase, do read-only exploration for...]] - `codex-user-prompt:ed25a7d3da4e0e76`
- [[sources/codex-prompts/codex-user-prompt-a3146fab9498e0f5|d盘下的academic-portfolio,undergraducate-project-netherlands,undergraduate-study...]] - `codex-user-prompt:a3146fab9498e0f5`
- [[sources/codex-prompts/codex-user-prompt-85ab75319b6d44c7|Read-only exploration. Inspect D:\academic-portfolio and D:\weipingyan-portfo...]] - `codex-user-prompt:85ab75319b6d44c7`
- [[sources/codex-prompts/codex-user-prompt-4633bf483676282f|Read-only exploration. Inspect D:\undergraducate-project-netherlands and D:\u...]] - `codex-user-prompt:4633bf483676282f`
- [[sources/codex-prompts/codex-user-prompt-9fed3741f5dc3052|为啥网页只是readme上的东西，还有这个readme不要出现这个内容wiki/graph-data.json and wiki/knowledge-gr...]] - `codex-user-prompt:9fed3741f5dc3052`
- [[sources/codex-prompts/codex-user-prompt-f502f65fa0227372|In D:\Research\vipin's knowledgebase, inspect the local vipin wiki site publi...]] - `codex-user-prompt:f502f65fa0227372`
- [[sources/codex-prompts/codex-user-prompt-38de5993c7dc6194|Files mentioned by the user:]] - `codex-user-prompt:38de5993c7dc6194`
- [[sources/codex-prompts/codex-user-prompt-25511c6845f07781|Files mentioned by the user:]] - `codex-user-prompt:25511c6845f07781`
- [[sources/codex-prompts/codex-user-prompt-8c218b00fbabd7bb|Agent 2: Read-only inspect Prompt Wiki prompt assets and docs. Focus on conte...]] - `codex-user-prompt:8c218b00fbabd7bb`
- [[sources/codex-prompts/codex-user-prompt-89c9f5b5e4b5d61f|Agent 6: Read-only QA/product reviewer. Inspect Prompt Wiki current web/stati...]] - `codex-user-prompt:89c9f5b5e4b5d61f`
- [[sources/codex-prompts/codex-user-prompt-f12610877d683317|Agent 5: Apply OpenAI harness-engineering mindset conceptually to Prompt Wiki...]] - `codex-user-prompt:f12610877d683317`
- [[sources/codex-prompts/codex-user-prompt-86db633112406c1e|我建议仿照vipin-wiki来做，特别是前端，但别动那个项目的代码，大胆删去我们这边多余的一些文件。但我们的内核仍然是prompt-wiki，所以原材料...]] - `codex-user-prompt:86db633112406c1e`
- [[sources/codex-prompts/codex-user-prompt-d2830e19aca38bcd|Read-only exploration task for Prompt Wiki. Do not modify files. In D:\Resear...]] - `codex-user-prompt:d2830e19aca38bcd`
- [[sources/codex-prompts/codex-user-prompt-2b67a78f4a8b4661|Read-only exploration task for Prompt Wiki. Do not modify files. In D:\Resear...]] - `codex-user-prompt:2b67a78f4a8b4661`
- [[sources/codex-prompts/codex-user-prompt-5b8934d4af7fd78f|Read-only exploration task for vipin reference project. Do not modify files....]] - `codex-user-prompt:5b8934d4af7fd78f`
- [[sources/codex-prompts/codex-user-prompt-455136be71870ba1|Read-only exploration task. Compare Prompt Wiki content assets in D:\Research...]] - `codex-user-prompt:455136be71870ba1`
- [[sources/codex-prompts/codex-user-prompt-f36fdafc41743906|Read-only exploration task for cleanup planning. Do not modify files. In D:\R...]] - `codex-user-prompt:f36fdafc41743906`
- [[sources/codex-prompts/codex-user-prompt-987e43ff1c700b41|Read-only task in D:\Research\Prompt wiki. Inspect packages/prompts, packages...]] - `codex-user-prompt:987e43ff1c700b41`
- [[sources/codex-prompts/codex-user-prompt-0f9a76c50c6deec9|Research task. Using official/public sources if available, benchmark top adja...]] - `codex-user-prompt:0f9a76c50c6deec9`
- [[sources/codex-prompts/codex-user-prompt-72cebbbe4b664fef|Read the docs folder first.]] - `codex-user-prompt:72cebbbe4b664fef`
- [[sources/codex-prompts/codex-user-prompt-e06bc73154199aa8|更新到wiki]] - `codex-user-prompt:e06bc73154199aa8`
- [[sources/codex-prompts/codex-user-prompt-46875507a5030d77|https://developers.openai.com/cookbook 这个你要仔细ingest，这个对我过分重要，主要就是得分好类，然后具体说说讲...]] - `codex-user-prompt:46875507a5030d77`
- [[sources/codex-prompts/codex-user-prompt-e4f43c728942913c|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:e4f43c728942913c`
- [[sources/codex-prompts/codex-user-prompt-be10f475d897d016|立党老师他的所有公开发布信息，主要是X上和youtube上，这个你要仔细ingest，这个对我过分重要，主要就是得分好类，然后具体说说讲了什么。然后之后这...]] - `codex-user-prompt:be10f475d897d016`
- [[sources/codex-prompts/codex-user-prompt-6d46b284910d5ef4|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:6d46b284910d5ef4`
- [[sources/codex-prompts/codex-user-prompt-f588ceb0f4571c69|X 官方 profile 可访问，但未直接暴露 status 链接；3 个辅助 mirror 当前不可达，已作为 3 条 crawl errors 记录进...]] - `codex-user-prompt:f588ceb0f4571c69`
- [[sources/codex-prompts/codex-user-prompt-8e8c4e6f90663c30|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:8e8c4e6f90663c30`
- [[sources/codex-prompts/codex-user-prompt-193eb2f7cef5392e|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:193eb2f7cef5392e`
- [[sources/codex-prompts/codex-user-prompt-797e551aa4577a62|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:797e551aa4577a62`
- [[sources/codex-prompts/codex-user-prompt-2748a5a90b2cac88|你应该能看到我skill文件夹下的一些文件吧，这些都是从别人的仓库移植进来的，但你现在要做的事就是追溯原始仓库，这个归类应该为skill，然后ingest...]] - `codex-user-prompt:2748a5a90b2cac88`
- [[sources/codex-prompts/codex-user-prompt-840448f9bd1b24f6|你应该能看到我本地codex的所有我对codex的prompt吧，这个对我过分重要，我希望能让wiki ingest，分好类，定时自动爬取加更新东西。然后...]] - `codex-user-prompt:840448f9bd1b24f6`
- [[sources/codex-prompts/codex-user-prompt-bed42e1493ef08d3|PLEASE IMPLEMENT THIS PLAN:]] - `codex-user-prompt:bed42e1493ef08d3`
- [[sources/codex-prompts/codex-automation-prompt-update-codex-prompt-corpus|Run the weekly update for the selected local Codex prompt corpus in the vipin...]] - `codex-automation-prompt:update-codex-prompt-corpus`
- [[sources/codex-prompts/codex-automation-prompt-weekly-research-inspiration-digest|Run the weekly research inspiration digest in the vipin wiki repository. From...]] - `codex-automation-prompt:weekly-research-inspiration-digest`
- [[sources/codex-prompts/codex-automation-prompt-digest-lidang-public-ideas|Run the weekly digest for the Lidang public ideas corpus in the vipin wiki re...]] - `codex-automation-prompt:digest-lidang-public-ideas`
- [[sources/codex-prompts/codex-automation-prompt-update-shunyu-yao-public-corpora|Run the weekly update for the Shunyu Yao public corpora in the vipin wiki rep...]] - `codex-automation-prompt:update-shunyu-yao-public-corpora`
- [[sources/codex-prompts/codex-automation-prompt-update-frontend-frameworks-public-corpus|Run the weekly update for the frontend project frameworks public corpus in th...]] - `codex-automation-prompt:update-frontend-frameworks-public-corpus`
- [[sources/codex-prompts/codex-automation-prompt-update-karpathy-public-corpus|Run the Karpathy public corpus ingest workflow in the vipin wiki repository....]] - `codex-automation-prompt:update-karpathy-public-corpus`
- [[sources/codex-prompts/codex-automation-prompt-weekly-openai-cookbook-wiki-ingest|Refresh the OpenAI Cookbook mirror in vipin wiki. Work in D:/Research/vipin's...]] - `codex-automation-prompt:weekly-openai-cookbook-wiki-ingest`

## Sources

- EXTRACTED: Raw manifest and capture metadata are stored under `raw/codex-prompts-public/`.
- EXTRACTED: Source material comes from local Codex session JSONL files and local Codex automation TOML files.

## Counterpoints and Gaps

- AMBIGUOUS: Local session encodings can be messy; future runs should continue filtering mojibake, terminal paste, and sensitive personal data aggressively.
- INFERRED: Full-text prompt preservation is useful only for selected reusable prompts; rejected candidates should remain raw audit metadata, not public pages.

## Related

- [[codex-prompt-taxonomy]]
- [[index]]
- [[log]]
