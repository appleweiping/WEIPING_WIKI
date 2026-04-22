---
title: What Do I Need From Teammates For Venus Basestation
type: query
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - query
  - 5eid0
  - teamwork
  - mqtt
  - interface
source_pages:
  - 2026-04-22-computer-software-ui-role-plan-for-5eid0
  - 2026-04-22-what-language-for-5eid0-computer-software-ui
---

# What Do I Need From Teammates For Venus Basestation

## Question

What exactly does Vipin need from teammates in order to build the `venus-basestation` project effectively?

## Short Answer

The most important thing is not their whole codebase.

What Vipin needs is the interface contract.

## Required Inputs From Teammates

### 1. MQTT topic names

Need to know:

- which topic each robot publishes to
- whether there are separate topics per robot or one combined topic
- whether there are any status/debug topics

### 2. Message format

Need an agreed payload structure, ideally JSON.

At minimum:

- `robot_id`
- `event_type`
- `x`
- `y`
- `timestamp`

For rock detections:

- `color`
- `size`
- `temperature`
- optional `confidence`

### 3. Coordinate system

Need the team to agree on:

- origin location
- unit (`m`, `cm`, grid cells, etc.)
- axis directions
- how orientation is represented if needed

Without this, the map will be inconsistent even if the UI code works.

### 4. Event definitions

Need a stable meaning for each event type:

- `robot_position`
- `rock`
- `cliff`
- `boundary`
- `mountain`
- `status`

Otherwise the UI may display the wrong thing.

### 5. Robot identifiers

Need to know how the two robots are distinguished:

- `robot_1` / `robot_2`
- or another stable naming scheme

### 6. Update frequency and behavior

Need clarity on:

- how often position messages are sent
- whether robots resend old observations
- how duplicate observations should be treated
- whether partial observations can be updated later

### 7. A few sample messages early

This is one of the most useful things teammates can give.

Even before their full system works, ask for:

- 5 to 10 example MQTT messages
- one example per event type
- one example of each robot

That is enough to let the base-station software move forward.

## What You Do Not Need Immediately

You do not need:

- their full embedded code
- full hardware access
- a fully working robot

You can already build:

- the parser
- the map state model
- the dashboard
- replay scripts
- test cases

as long as the interface is agreed.

## Best Message To Send To Teammates

```text
For the base-station software, the most important thing I need early is our interface contract: MQTT topics, message format, robot IDs, coordinate system, and a few sample messages. I don't need the full robot code yet. If we agree on that part early, I can already build and test the map/dashboard in parallel.
```

## Counterpoints and Gaps

- if teammates do not yet know their exact message format, the UI work can still start with a provisional schema, but rework risk increases
- if localization is weak on the robot side, the basestation map may need to represent uncertainty or approximate positions

## Related

- [[2026-04-22-computer-software-ui-role-plan-for-5eid0]]
- [[2026-04-22-what-language-for-5eid0-computer-software-ui]]
- [[queries-home]]
- [[index]]
- [[log]]
