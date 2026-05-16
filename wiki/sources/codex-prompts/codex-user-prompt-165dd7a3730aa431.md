---
title: 这是我跟gpt的对话：只想同步作者更新的话，也建议 fork + clone，但你尽量不要在自己的 fork 里改内容。这样同步最省心。
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

# 这是我跟gpt的对话：只想同步作者更新的话，也建议 fork + clone，但你尽量不要在自己的 fork 里改内容。这样同步最省心。

## Metadata

- Stable ID: `codex-user-prompt:165dd7a3730aa431`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-15T00:46:53.253Z`
- Semantic hash: `165dd7a3730aa431ae6bb30ab4924bc196d7a490dca0a8ba622717f37a2dd1f1`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
这是我跟gpt的对话：只想同步作者更新的话，也建议 fork + clone，但你尽量不要在自己的 fork 里改内容。这样同步最省心。

设置一次：

git clone https://github.com/你的用户名/skills.git
cd skills
git remote add upstream https://github.com/mattpocock/skills.git

以后每次同步作者更新：

git checkout main
git fetch upstream
git merge upstream/main
git push origin main

更“干净”的同步方式是用 rebase：

git checkout main
git fetch upstream
git rebase upstream/main
git push origin main

如果你完全不打算改任何东西，其实可以不 fork，直接 clone 作者仓库：

git clone https://github.com/mattpocock/skills.git
cd skills
git pull

这种方式最简单，但缺点是你没有自己的远程备份，也不能方便地记录自己的版本。

所以结论是：

只看和同步，不改：直接 clone 作者仓库即可
想保留自己的一份，偶尔同步：fork + upstream
想未来可能自定义：fork + upstream + 自己的分支

你的情况“只想同步作者更新”，我会选：直接 clone 作者仓库。最少维护成本。

那我该怎么跟codex说fork+clone这件事
已思考幾秒鐘

你可以直接把下面这段发给 Codex：

我想把这个仓库作为长期同步的上游资源来使用：

https://github.com/mattpocock/skills.git

请帮我完成 fork + clone 的设置：

1. 先确认我是否已经在 GitHub 上 fork 了 mattpocock/skills。
2. 如果还没有 fork，请告诉我需要去 GitHub 页面点击 Fork。
3. 等我 fork 完后，把我的 fork clone 到本地。
4. 给本地仓库添加 upstream remote，指向：
 https://github.com/mattpocock/skills.git
5. 检查 git remote -v，确保：
 - origin 指向我的 fork
 - upstream 指向 mattpocock/skills
6. 给我一个以后同步作者更新的命令。

我的目标是：主要同步作者更新，暂时不改内容。

如果你已经知道自己的 GitHub 用户名，可以更具体一点：

请帮我设置 mattpocock/skills 的 fork + clone。

原仓库是：
https://github.com/mattpocock/skills.git

我的 GitHub 用户名是：你的用户名

请执行或指导我执行：

git clone https://github.com/你的用户名/skills.git
cd skills
git remote add upstream https://github.com/mattpocock/skills.git
git remote -v

然后告诉我以后如何同步 upstream/main 到我的 main，并 push 回 origin/main。
我的目标是只跟随作者更新，不做本地修改。

以后同步时，让 Codex 执行：

git checkout main
git fetch upstream
git merge upstream/main
git push origin main

GitHub 官方文档也是这个思路：fork 后本地 clone，并配置一个 upstream remote 指向原仓库，这样才能把原作者的更新同步到你的 fork。

已思考 2 秒鐘

这个页面设置是对的，直接点右下角 Create fork 就可以。

你现在的选项含义：

Owner：appleweiping，你的个人账号，没问题。
Repository name：skills，可以保持不变。
Description：可以保持默认。
Copy the main branch only：建议保持勾选。你只是想同步作者更新，不需要复制所有分支。

点 Create fork 后，等 GitHub 创建完成。然后把你的 fork 克隆到本地：

git clone https://github.com/appleweiping/skills.git
cd skills
git remote add upstream https://github.com/mattpocock/skills.git
git remote -v

确认看到类似这样就对了：

origin https://github.com/appleweiping/skills.git
upstream https://github.com/mattpocock/skills.git

以后同步作者更新用：

git checkout main
git fetch upstream
git merge upstream/main
git push origin main


然后现在我就是想把他的这个项目放到skill这个大文件夹下面，因为skill这个大文件夹我可能还要移植其他关于skill的别人的文件
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
