---
title: How To Ask Teammates For Basestation Interface Info
type: query
status: active
created: 2026-04-27
updated: 2026-04-27
tags:
  - query
  - 5eid0
  - teamwork
  - communication
  - mqtt
source_pages:
  - 2026-04-22-what-do-i-need-from-teammates-for-venus-basestation
  - 2026-04-22-computer-software-ui-role-plan-for-5eid0
---

# How To Ask Teammates For Basestation Interface Info

## Question

How should Vipin ask teammates, in Chinese, for the concrete interface information needed to connect the `venus-basestation` project to the robot side?

## Recommended Chinese Ask

```text
我这边已经把 basestation/UI 的基础部分先做起来了，后面为了和你们机器人端顺利对接，我这边需要先跟你们确认几个接口信息。

你们方便先给我这些吗：
1. MQTT 的 topic 名字怎么定
2. 机器人发出来的消息格式长什么样，最好给我几个 JSON 例子
3. 坐标系怎么定义，比如原点、x/y 方向、单位
4. 两台机器人分别怎么标识
5. 如果同一个物体重复检测，消息会怎么发
6. 有没有 status 类消息，比如 battery、mode 这些

你们现在如果还没完全定下来也没关系，先给我一个暂定版本和几条 sample message 就行，我这边可以先按那个对接，后面再改。
```

## Shorter Version

```text
我这边 basestation/UI 已经先做起来了。为了后面对接机器人端，你们能不能先给我一个暂定的接口版本？

我现在主要需要：
1. MQTT topic
2. 消息格式（最好几个 JSON sample）
3. 坐标系定义
4. robot ID 怎么区分
5. 重复检测怎么处理
6. 有没有 status 信息（比如 battery/mode）

如果还没完全定下来，先给暂定版也可以，我先按这个接。
```

## Why This Framing Works

- it signals that the basestation work is already underway
- it asks for concrete interface data rather than their whole codebase
- it lowers pressure by explicitly allowing a provisional version
- it makes later integration look like a controlled interface update rather than a vague coordination problem

## Counterpoints and Gaps

- if the team is still very early, even a temporary schema may change significantly
- if they do not yet have sample messages, Vipin may need to propose a draft JSON format first

## Related

- [[2026-04-22-what-do-i-need-from-teammates-for-venus-basestation]]
- [[2026-04-22-computer-software-ui-role-plan-for-5eid0]]
- [[queries-home]]
- [[index]]
- [[log]]
