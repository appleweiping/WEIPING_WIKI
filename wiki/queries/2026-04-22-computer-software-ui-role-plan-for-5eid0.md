---
title: Computer Software UI Role Plan For 5EID0
type: query
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - query
  - computer-software
  - ui
  - course
  - project
source_pages:
  - 2026-04-22-5eid0-venus-project-course-materials
  - 2026-04-22-computer-software-vs-embedded-software-in-5eid0
---

# Computer Software UI Role Plan For 5EID0

## Decision

Vipin decided to take the `computer software and user interface` role for the 5EID0 Venus project.

## Why This Role Can Be Good

This role is valuable because the course mission explicitly requires a computer-side system that:

- receives robot messages
- uses the MQTT server data
- develops or updates a graphical map
- visualizes rocks, cliffs, mountains, and explored terrain

This makes the role highly visible in:

- the final demo
- the demonstration video
- screenshots in the final report
- the system-level explanation

## What To Own

Vipin should try to own these parts clearly:

- base-station software
- MQTT data receiver
- data format agreement with robot-side members
- map state model
- graphical visualization
- UI/dashboard
- screenshots and demo scenes for the report/video

## Most Important Interface

The biggest dependency is the interface with robot-side software.

The team should agree early on:

- MQTT topics
- message format
- coordinate representation
- object types
- rock sample fields
- event timestamps or sequence numbers
- how uncertain or partial robot observations are represented

Example message fields:

```text
robot_id
event_type
x
y
object_type
color
size
temperature
confidence
timestamp
```

## How To Make The Role Look Strong

Do not frame the role as "just UI".

Frame it as:

- base-station software
- data integration
- real-time mapping
- system visualization
- testable software component

This sounds more engineering-oriented and better matches the course grading.

## Suggested Message To Teammates

```text
I’ll take the computer software / UI role. I can focus on the base-station program, receiving MQTT data from the robots, defining the data format together with the robot-side team, and building the map/visualization for the demo. I think this can make our final demo and report much clearer, as long as we agree early on the message format and coordinates.
```

## Testing Plan Ideas

Vipin can test this component even before the robots are ready by using simulated MQTT messages.

Useful tests:

- receive a rock-sample message and display it on the map
- receive cliff/boundary/mountain events and update the map
- handle multiple robots
- handle repeated or conflicting observations
- replay a scripted exploration path
- verify that screenshots match the reported system behavior

## Report Evidence To Collect

For the final report and individual reflection, collect:

- UI screenshots over time
- data-flow diagram
- MQTT topic/message specification
- map state model
- test cases and expected outcomes
- notes on integration issues with robot-side software

## Counterpoints and Gaps

- this role is more visible but may be perceived as less hardware-deep unless it includes real data integration and testing
- it depends on robot-side members sending usable MQTT data
- coordinate mapping and uncertainty can become difficult if the robots do not track position consistently

## Related

- [[2026-04-22-5eid0-venus-project-course-materials]]
- [[2026-04-22-computer-software-vs-embedded-software-in-5eid0]]
- [[2026-04-22-what-to-pay-attention-to-in-5eid0-project-course]]
- [[queries-home]]
- [[index]]
- [[log]]
