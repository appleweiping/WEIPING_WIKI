---
title: 目前这个项目，有一个问题就是按一下抓取，如果已经有20个了，他就一直都是20个。然后也不能拿掉一些论文，也许我的判断也不一定对，但是给我的直观感受是这样的...
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

# 目前这个项目，有一个问题就是按一下抓取，如果已经有20个了，他就一直都是20个。然后也不能拿掉一些论文，也许我的判断也不一定对，但是给我的直观感受是这样的...

## Metadata

- Stable ID: `codex-user-prompt:8af3a913c408de2f`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T11:46:25.994Z`
- Semantic hash: `8af3a913c408de2f81289903bbcf0cc5b7f91086b1f39ed32d81a11b599c8d77`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
目前这个项目，有一个问题就是按一下抓取，如果已经有20个了，他就一直都是20个。然后也不能拿掉一些论文，也许我的判断也不一定对，但是给我的直观感受是这样的。然后也没有一个专门的帮助页面，教用户具体怎么使用，要注意什么等。另外我想让他的保存功能能够在下次连接时也能做到保存，而不是下次又重新来过了（这个你自己验证一下，因为我不确保是不是这样）

做完这些，派四个agent，其中两个充当真实用户reviewer（不单单只是看一下界面那么简单，要实际使用（所有环节），多环境模拟，多api调用模拟，codex模拟）找出项目的核心问题，缺漏的功能（跟其他项目相比），以及挑刺，其中两个去搜寻顶会或者热门的hf github相关的项目，用于寻找idea和功能，能够让我们目前的项目和产品功能更多，综合更多。然后接着让一个agent来实作，把这些问题解决（顶级项目级别实现，非toy），一个agent来做测试和检验，确保实作没有问题。 
结束时候我需要看到的和用到的是，我本人能够非常舒服便捷的使用该项目，在本地不管是直接在codex上还是在页面上还是用deepseek api调用（这个api调用后面我自行设置key）。同时别人如果有相应环境，也能非常舒服便捷功能齐全的使用该项目，不管是用哪个环境还是在哪个api上，他们自己能够做到一键部署等，不管是在哪个环境。
readme要记得大改，全面细节，而不只是往后面堆东西。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
