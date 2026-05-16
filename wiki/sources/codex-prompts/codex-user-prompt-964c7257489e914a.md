---
title: 我感觉这个baseline错误好像特别多，我们也改了很久了，没啥效果。这样吧，我们做其他的学长推荐的baseline吧，然后另外我不知道你记不记得之前你找...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - research-workflow
source_pages:
  - codex-prompt-corpus
---

# 我感觉这个baseline错误好像特别多，我们也改了很久了，没啥效果。这样吧，我们做其他的学长推荐的baseline吧，然后另外我不知道你记不记得之前你找...

## Metadata

- Stable ID: `codex-user-prompt:964c7257489e914a`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-14T15:39:22.780Z`
- Semantic hash: `964c7257489e914ad3291350112f187df4a36cf8ef22eba39552f64198ed4ddb`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
我感觉这个baseline错误好像特别多，我们也改了很久了，没啥效果。这样吧，我们做其他的学长推荐的baseline吧，然后另外我不知道你记不记得之前你找的新的baseline，学长当时是这么说的baseline的话6个可能有点少，最好8个 
我找的哪些都是24 25d
好的
今年也出了一些新的工作
可以去dblp搜一下recommendation
挑俩今年的放进去

所以我们就再从他的reference里推荐一个，然后再选两个今年的baseline，标准和规则也要跟之前做其他五个baseline一样，目前这个baseline就先不作为考量了，麻烦太多，总是报错，然后也不常规。我们小模型是qwen3 8B你应该知道，backbone都要是qwen3 8B,

学长他之前说的话，我这边再说一遍：关于如何比较baseline是公平的，其实不同paper的定义不同，只要看起来你的标准是统一的就可以，我可以举几个例子
1. 直接按照原本的代码跑，它里面用的什么backbone就用什么backbone，参数也不变，就只把输入的接口变成你自己比较的数据集。2. 数据集和比较的某个工作统一，直接用那个工作里面report的所有baseline的效果。3. 适配llm backbone，比如说你打算用qwen3.5 8B做finetune，那不管别人backbone本来用的是llama还是gemma之类的，你都把他们那个改成qwen3.5，用默认参数跑你的数据集。4. 前面都是不去给baseline调参，但你自己会给自己调参。因为用在不同数据集，或者相同数据集不同划分之类的上面，同样参数模型会有一些变化，所以得给baseline也调参
一般比较常见的就这几种
关于lora的问题，这个得看你比较的工作是否用了lora，因为你full finetune的效果大概率是比lora要高几个点的。这种情况下主要看你用的机器能不能负担，lora其实在8B上的推荐也并不会比full finetune快很多，所以机器可以负担的话就看你的选择了。有的工作的核心共享是包括lora的，所以这种工作你没法删，但如果你用full fineture report你自己的工作和这种工作比，你觉得是公平还是不公平呢？
我自己使用的配置一般是，全部full finetune或者全部lora，统一backbone到某个模型比如qwen3.5 8B，直接用baseline默认参数，但我自己的调参去比较
在experimental setting那里写清楚，get source code from their official implementation, using backbone Qwen3.5 8B, with their optimal (default) hyparameters, (under lora). 就可以了
一般没有reviewer会质疑
因为不少工作都是这么做的，这其实是一个默认的公平做法了
但也有追求更公平的，比如说都给调到最优去比
但我个人认为一般不需要非得这么做，毕竟给他们调参也太费时间了
这个也是我说工程化思维和研究思维不同的一点，因为你去做工程，你比较一个其他厂商的东西，只report别人default的参数，然后有了些许提升，大家真用你这个产品肯定不买账，你看多少被吐槽过的打榜performance了。但学界和业界这点就很不同，大家都心照不宣的把这种看似公平实际上不公平的比较作为约定俗成
确实偶尔会有reviewer挑刺，问这个问题，但这种一般就是为了拒你来的，你即使给baseline finetune了去比，他也会找其它离谱的理由，比如说lack of novelty拒绝你
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
