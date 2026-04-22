---
title: What Language For 5EID0 Computer Software UI
type: query
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - query
  - computer-software
  - ui
  - python
  - mqtt
  - course
source_pages:
  - 2026-04-22-5eid0-venus-project-course-materials
  - 2026-04-22-computer-software-ui-role-plan-for-5eid0
---

# What Language For 5EID0 Computer Software UI

## Question

What programming language should Vipin use for the `computer software / UI` role in the 5EID0 Venus project?

## Short Answer

Use `Python` as the default choice.

Best starting stack:

- `Python`
- `paho-mqtt`
- `matplotlib` or `pygame` for map visualization
- optionally `PyQt` if a more polished desktop GUI becomes necessary

## Why Python Is The Best Default

Python is the safest choice because:

- the course manual already provides a Python MQTT example
- MQTT support is straightforward through `paho-mqtt`
- quick iteration matters more than building a perfect production UI
- Python is good for simulation, replay, testing, and plotting
- a working dashboard/map is more valuable than a beautiful but fragile frontend

## Recommended Architecture

```text
MQTT receiver
  -> message parser
  -> map/world-state model
  -> visualization/dashboard
  -> logging/replay/test scripts
```

Keep these parts separated so the UI does not become tangled with message handling.

## Minimum Viable Version

Build this first:

- subscribe to robot MQTT topics
- parse JSON or simple delimited messages
- store robot/object observations in a map state
- display rocks, cliffs, mountains, boundaries, and robot path
- support simulated messages before the robots are ready

## When To Consider A Web UI

A web UI using JavaScript/TypeScript can be attractive if the team wants:

- a nicer looking dashboard
- browser-based display
- easier styling

But it adds complexity:

- MQTT browser setup can be more annoying
- more tooling is required
- integration may take longer

So web UI should be a second-phase option, not the initial default.

## Practical Recommendation

Start with Python.

If there is time after the data pipeline works, improve the visualization.

Do not start with a complicated UI framework before the message format and map model are stable.

## Suggested Team Message

```text
For the base-station software/UI, I suggest we start in Python because the manual already gives Python MQTT examples and it will be fastest for receiving MQTT data, testing with simulated messages, and drawing the map. Once the data format and map logic are stable, we can decide whether to polish the UI further.
```

## Counterpoints and Gaps

- if a teammate is very strong in web development, a web dashboard may become viable
- if the final presentation needs a very polished interface, Python plotting may need extra effort
- the language decision should be revisited once the team fixes the MQTT message format and map requirements

## Related

- [[2026-04-22-5eid0-venus-project-course-materials]]
- [[2026-04-22-computer-software-ui-role-plan-for-5eid0]]
- [[2026-04-22-computer-software-vs-embedded-software-in-5eid0]]
- [[queries-home]]
- [[index]]
- [[log]]
