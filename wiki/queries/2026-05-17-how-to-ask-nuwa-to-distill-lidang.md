---
title: How To Ask Nuwa To Distill Lidang
type: query
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - query
  - skill
  - nuwa
  - lidang
source_pages:
  - nuwa-skill
  - lidang
  - lidang-idea-taxonomy
---

# How To Ask Nuwa To Distill Lidang

## Question

What should Vipin say when asking the Nuwa skill, with Opus involved throughout, to distill Lidang / `lidangzzz` into a reusable person-perspective skill?

## Short Answer

Use the prompt below. Because a local `lidang-perspective` skill already exists, the better request is an update/deepening pass rather than a duplicate new skill.

```text
请使用 $huashu-nuwa / 女娲造人流程，帮我蒸馏“立党老师 / Lidang / lidangzzz”的人物视角 skill。

这次不要做人物传记，也不要做粉丝式总结；目标是提炼一个可执行的思维顾问：他如何拆路径、看约束、判断成本、设计规格、验收 AI/coding/职业/移民/创业这类复杂目标。

请全程调用 Opus 做深度研究、提炼和最终审稿；Codex 只做协调、集成、落盘、验证。Opus 的角色是只读深度合作者，不改文件、不提交、不处理账号或凭据。

现有基础：
- 本机已有 `lidang-perspective` skill，请优先把它当作“待更新/加深”的目标，而不是新建重复 skill。
- 参考本地 wiki 中的 `lidang` 实体页、`lidang-idea-taxonomy`、`lidang-weekly-digests`、`2026-05-16-lidang-public-corpus`，以及已有的公开语料索引。
- 如果需要补充事实，优先使用公开一手来源：GitHub、YouTube、X 公开资料、项目 README、公开长文或访谈。不要使用知乎、微信公众号、百度百科作为主要依据。

请按女娲流程完整交付：
1. 先检查现有 `lidang-perspective/SKILL.md`，列出已有模型、薄弱处、需要更新的地方。
2. 建立/更新自包含的 `references/research/` 研究文件，至少覆盖：著作/项目与长文、对话/视频、表达 DNA、外部视角、决策/行动记录、时间线。
3. 提炼 3-7 个真正有排他性的心智模型；每个模型要有证据、适用场景、失效条件。
4. 提炼决策启发式、表达 DNA、价值观与反模式、内在张力、知识谱系、诚实边界。
5. 强化 Agentic Protocol：遇到政策、法律、签证、税务、学校项目、工具状态、项目近况等会变的信息，必须先查最新公开资料再回答。
6. 产出更新后的 `SKILL.md`，重点让它“拿到就会用”：先分类问题，再做必要事实检索，最后用立党式路径工程给结论、约束、路径表、失败点和下一步动作。
7. 做三类验证：已知立场 sanity check、边缘问题推断、表达风格检查。验证不过就回到提炼阶段修一轮，最多两轮。

边界要求：
- 不要编造立党没公开说过的话。
- 区分“公开材料直接说的”“他人评价的”“我们推断的”。
- 不要把通用聪明话包装成他的独特模型。
- 不要让 skill 冒充立党本人；它只能是基于公开材料蒸馏出的思维视角。
- 如果公开材料不足，直接在诚实边界里写清楚，不要硬凑。

最终输出请给我：
- 更新/创建的文件路径
- 关键心智模型摘要
- 验证结果
- 还缺哪些高价值一手材料
```

## Reuse Recommendation

Reuse and update the existing `lidang-perspective` skill. A new skill would likely duplicate the current one unless the goal changes from "Lidang perspective" to a narrower theme such as "Lidang AI coding reviewer" or "Lidang career-path engineer."

## Guardrails

- Keep the target as a thinking system, not a biography: the useful artifact is a reusable path-engineering lens with evidence, failure modes, and a fact-check protocol.
- Treat public facts as perishable: for immigration, law, tax, school programs, tools, projects, prices, and recent public posts, the skill must search current sources before making claims.

## Related

- [[nuwa-skill]]
- [[lidang]]
- [[lidang-idea-taxonomy]]
- [[lidang-weekly-digests]]
- [[queries-home]]
- [[index]]
- [[log]]
