---
title: 这是我后面做的一些事：那我们做到了保证公平性的情况下其他都要官方原装实现的这个要求了吗
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

# 这是我后面做的一些事：那我们做到了保证公平性的情况下其他都要官方原装实现的这个要求了吗

## Metadata

- Stable ID: `codex-user-prompt:1d14a4a12207706b`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-07T22:06:17.987Z`
- Semantic hash: `1d14a4a12207706b032bd9c778980d6a69ca0617d37042b24142cba02bc2813d`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
这是我后面做的一些事：那我们做到了保证公平性的情况下其他都要官方原装实现的这个要求了吗
23:21

没有完全做到。

我们做到的是：

公平协议 + 核心模块适配实现
还没有做到：

公平协议 + 每个外部方法的官方原装完整实现
更具体地说：

已经比较接近“官方/标准原装”的

SASRec
GRU4Rec
BERT4Rec
LightGCN
这些 classical baselines 本来就有标准实现范式，我们在同协议下训练和评估，问题不大。

没有完全官方原装的

LLM2Rec-style
LLM-ESR-style
LLMEmb-style
RLMRec-style
IRLLRec-style
SETRec-style
它们是：

paper-style / core-framework adapted baselines
不是：

official full-code reproduction
所以如果标准是“必须每个外部 LLM-rec baseline 都用官方 repo、官方 checkpoint、官方训练 pipeline，只改 evaluation candidate set”，那我们还没完全达到。

但这并不等于现在不合格。顶会里这种 adapted baseline 是可以出现的，只是要诚实标注。如果你想把 baseline 做到更硬，可以选其中 2-3 个最强/最相关的外部方法，进一步做官方代码级适配；其他保留 paper-style adapted baseline。

我建议的优先级是：

LLM2Rec 官方 repo 适配，因为我们已经有 adapter 和 upstream scoring 路线。
LLM-ESR 官方 repo 适配，因为脚本也已经接了 repo format。
RLMRec 或 IRLLRec 选一个最强的，再尝试官方实现级适配。
这样写起来会非常稳：

We include official-code adaptations for the closest external methods where feasible, and paper-style controlled adaptations for additional representative frameworks.
这比硬说全部官方复现更安全。


23:21
六个baseline，要全部实现，官方原装算法 + 我们统一协议 + Qwen3-8B LoRA backbone。
23:28

可以，那我们就把标准提高到这个版本：

六个 external baselines 全部做成：
官方原装算法 / official-code-level implementation
+ 我们统一的 same-candidate protocol
+ 统一 Qwen3-8B LoRA backbone
但要注意一句：这会比现在的 paper-style adapted baseline 高一个等级。当前脚本可以当 pilot / scaffold，不能作为最终“六个官方原装 baseline”声称。

我建议正式标准写成：

We adapt official or official-code-level implementations of six representative LLM-rec frameworks to our controlled same-candidate protocol, replacing the text/LLM backbone with the same Qwen3-8B LoRA backbone where applicable.
接下来要做的是：

逐个确认官方 repo / 官方算法细节

LLM2Rec
LLM-ESR
LLMEmb
RLMRec
IRLLRec
SETRec
每个 baseline 写一个 official adapter

输入：我们的 train/valid/test、same candidates、item text、history
输出：source_event_id,user_id,item_id,score
评估仍然走我们的统一 importer
统一 Qwen3-8B LoRA backbone

如果原方法用 LLM embedding，就替换成同一个 Qwen3-8B LoRA item/text encoder
如果原方法用 LLM 生成/推理，也统一走 Qwen3-8B LoRA
recommender 模块本身保留原算法结构
每个 baseline 写 provenance

official repo commit
哪些模块原样保留
哪些地方为了 same-candidate protocol 改了
backbone replacement 说明
不混用原论文 full-catalog 指标
这样做完才可以说：

官方算法级 baseline + 公平统一协议
所以现在结论是：我们当前还没完全达到这个新标准，但可以把它作为下一步正式目标。
外部 baseline 这轮先跑出来可以作为 sanity check；最终 paper-facing 版本应升级成六个 official-code-level baselines。


23:28
你先做：接下来要做的是：

逐个确认官方 repo / 官方算法细节

LLM2Rec
LLM-ESR
LLMEmb
RLMRec
IRLLRec
SETRec
每个 baseline 写一个 official adapter

输入：我们的 train/valid/test、same candidates、item text、history
输出：source_event_id,user_id,item_id,score
评估仍然走我们的统一 importer
统一 Qwen3-8B LoRA backbone

如果原方法用 LLM embedding，就替换成同一个 Qwen3-8B LoRA item/text encoder
如果原方法用 LLM 生成/推理，也统一走 Qwen3-8B LoRA
recommender 模块本身保留原算法结构
每个 baseline 写 provenance

official repo commit
哪些模块原样保留
哪些地方为了 same-candidate protocol 改了
backbone replacement 说明
不混用原论文 full-catalog 指标
这样做完才可以说：

官方算法级 baseline + 公平统一协议

显示更多
23:31


已处理 3m 45s
我已经先把“六个 official algorithm-level baseline”的标准落成仓库里的正式 contract，并推到 GitHub 了。

这次新增了：

OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md
明确现在的 *_style_* 不能再当最终官方级 baseline
规定最终目标：官方算法/官方代码级实现 + 统一 same-candidate protocol + Qwen3-8B LoRA backbone
configs/official_external_baselines.yaml
六个官方 repo、pinned commit、需要保留的 official modules、允许改动的 protocol adapter、剩余工作
main_audit_official_external_repos.py
服务器上检查六个 official repo 是否 clone 到位、commit 是否对齐
main_make_official_external_adapter_plan.py
生成 24 个 official adapter 计划命令，四域 x 六方法，但它只是 plan，不假装 runner 已完成
我确认的 pinned repo/commit 是：

LLM2Rec 73b481f710f67166ab958f4985d27b27fb410871
LLM-ESR e5dc388c12509c88c65536ecd8d231325993d4ef
LLMEmb 3458a5e225062e94b4f1a01e41f3ec82089f0407
RLMRec 22413752246de3dee8ab0d509f7f7a8889080f95
IRLLRec ee8330b456e568f87869ec6c0c553c55d43fce6e
SETRec 2ed9a75ad1ad3784c61bba3c68cbedbe3cfce2d7
已推送：

commit: e48f6e3 Define official external baseline upgrade contract
branch: main
你服务器可以先：

cd ~/projects/pony-rec-rescue-shadow-v6
git pull --ff-only
python main_audit_official_external_repos.py
下一步才是逐个把 LLM2Rec / LLM-ESR / LLMEmb / RLMRec / IRLLRec / SETRec 的 official runner 真正实现出来。当前我已经把验收标准和缺口钉住了，不会再把 paper-style adapter 误叫官方实现。


OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md
文档 · MD

打开

4 个文件已更改
+579
-0
撤销
审核

OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md
configs/official_external_baselines.yaml
main_audit_official_external_repos.py
main_make_official_external_adapter_plan.py


23:35

那我现在这样当前跑的这个是先停掉吗
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
