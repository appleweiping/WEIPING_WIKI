---
title: 就做ccrp和srpd这两个好了，我认为从观察（观察阶段基本就是beauty全域+其他三个域的各10000user（或者最好就是观察的数量和后面train...
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

# 就做ccrp和srpd这两个好了，我认为从观察（观察阶段基本就是beauty全域+其他三个域的各10000user（或者最好就是观察的数量和后面train...

## Metadata

- Stable ID: `codex-user-prompt:c366f0e1cf7418d4`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-08T19:56:00.726Z`
- Semantic hash: `c366f0e1cf7418d4a5f2885ff5e4ddb01464190ac8656fc06fe5eb44cb9eb77a`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
就做ccrp和srpd这两个好了，我认为从观察（观察阶段基本就是beauty全域+其他三个域的各10000user（或者最好就是观察的数量和后面train的数量一样））（观察即可用qwen3 8B作为调用，同时也要至少加上四组qwen3 8B+学长推荐的那几个（4个）baseline的情况下，能够发现我们在base（也就是只有qwen3 8B）调用下发现的现象和观察）我们发现了痛点或者说可以矫正，然后到baseline我们都是得重新做成一个formal（baseline的其他配置跟其他baseline相同）版本的，就是一个是confidence(srpd，我们之前在小版本的情况下其实在观察时候发现confidence坍缩的问题，所以这次你要自己想办法避免这个问题)，一个是evidence（ccrp），最后一个就是evidence加confidence了。那你告诉我，他们目前代码和方法设计部分跟baseline相比是否欠缺，最好派个reviewer审核一下，能不能在有创新性的情况下优化和升级，不必过分拘泥于当前的苟且，而是要深，细化，复杂，并且要效果好。要reviewer和实作的agent这么反复的对接，细细讨论，最终才能做好。可以参考学长推荐的顶会论文里面的项目的方法流程，但只能作为借鉴，实际自己的内容决不能是缝合或者抄袭的。我需要多agent协作，并且最好把这句话加进去（要参考或者调研时，可以仔细精读理解学长推荐论文项目或者其他顶会论文项目，但只能作为借鉴，实际自己的内容决不能是缝合或者抄袭的。）。做完了之后也要在相关文档上的milestone加上这两个，也是最重要的两个部分的内容,因为是我们自己的，必要时做增删改查。结束时可以做到直接上服务器跑指令的那种完成度，你要达到标准做完后才能停下，而不是糊弄，或者让我后续反复折腾。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
