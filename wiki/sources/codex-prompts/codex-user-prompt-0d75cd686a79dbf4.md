---
title: 以后强制要利用harness engineering的思维去实现和维护项目，参考内容如下https -//zhuanlan.zhihu.com/p/2014...
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

# 以后强制要利用harness engineering的思维去实现和维护项目，参考内容如下https://zhuanlan.zhihu.com/p/2014...

## Metadata

- Stable ID: `codex-user-prompt:0d75cd686a79dbf4`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-11T15:49:09.955Z`
- Semantic hash: `0d75cd686a79dbf4a3602f7e6af3e7db5d7da247e67fabacebc5ecbc01cd0e20`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
以后强制要利用harness engineering的思维去实现和维护项目，参考内容如下https://zhuanlan.zhihu.com/p/2014014859164026634，https://zhuanlan.zhihu.com/p/2016495809307374819

以及github上关于harness engineering的相关工程指南，同时我希望我希望能在agent这边加一句，每次碰到复杂任务强制用多agent协作工作，工作开始时默认阅读几个重要文档（这个要你自行决定和搜索你觉得重要的文档，一般是对agent理解项目路线，清楚任务规划，清楚具体细节，和执行规则）。每次工作完后除了报告也要提供下一步的方案和计划在结束时。要比对自己的项目的严谨度，创新度，技术深度，该有的部分是否完整等，同其他顶会论文比（自行搜索，但不要只搜索仅仅几个），清楚任务什么时候结束，清楚任务路线，一定要记住什么时候可以结束项目和实验，而不是一直下一步（这个就需要你跟其他顶会论文相比较，同时你要找一个顶会级别的reviewer挑刺，直到确实好了，你就可以跟我说已经基本结束项目和实验阶段，可以进行写作了）。新构建这个项目，内容idea只做部分保留，给你大的权限删去已有的工作内容以及模块或者是实验（如果不合理或者不现实），但是架构需要做调整，同时请你记住要多agent协作和计划模式，以后碰到大内容大任务时强制，要降低项目的耦合程度。在不影响质量的情况下（这个你也要自己去查资料网上）。以后记住默认修改好后提交到github，也可分批次commit，根据不同的内容。我也建议你搜寻一下网上关于这种项目类型的一些设计的idea，目前还是太单薄了，你要参考一下其他更能让使用者高兴用起来舒服的一些想法，而不只是我上述说的。我希望你能在科研上过分激进，而非保守，我们需要强制创新，禁止缝合A+B,这种绝对抄袭缝合的内容。


在现有项目的基础上，完整的实现八个baseline，从推荐的baseline里找八个，我记得你当时好像有搜寻比较新的且顶会的项目多达30多个，做到我只需要在服务器上跑，做实验的程度。不用再反复的改代码了。现有的边界就是我暂时不上服务器，暂时不调用api，把能做的工作都先做了，每个模块，除非是因为没有服务器环境，小模型和api。
https://github.com/appleweiping/protein-optimization-feedback-shift.git，

这次prompt我希望看到的结果是，你能够完整的完成除了无小模型无api无服务器之外的所有能做的工作做好，非toy非缝合且顶会级别且按照规则完成的论文项目，agent在未来执行项目能够智能化的继续工作，而不是忘记或者混乱规则，每次执行完要汇报到底完成了什么，做了什么，贡献和结论。定期更新agent的重要文档和删除杂乱的或者对当前项目无关的内容或者垃圾实验结果。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
