---
title: 5EID0 Venus Project Course Materials
type: source
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - source
  - course
  - project
  - embedded-software
  - computer-software
  - tue
source_files:
  - D:/Undergraduate_study_netherlands/EE electrical engineering/5EID0/5EID0_Manual_2025_Q4.pdf
  - D:/Undergraduate_study_netherlands/EE electrical engineering/5EID0/5EID0-kickoff.pdf
  - D:/Undergraduate_study_netherlands/EE electrical engineering/5EID0/Teams.xlsx
---

# 5EID0 Venus Project Course Materials

## Provenance

- origin: local files provided by user
- files:
  - `5EID0_Manual_2025_Q4.pdf`
  - `5EID0-kickoff.pdf`
  - `Teams.xlsx`

## Core Course Structure

- this is a challenge-based project course around a Venus exploration mission
- teams use a fixed robotic base platform and design a larger system around it
- the system must operate autonomously
- the project is not only about technical results, but also about process, system engineering, teamwork, testing, and planning

## Mission Summary

Two robots start next to each other and must:

- explore the terrain autonomously
- avoid cliffs, mountains, and boundaries
- find rock samples
- classify rock sample size and color
- measure temperature near rock samples
- report observations to a satellite-side MQTT server
- support graphical map generation on a connected computer

## Key Course Constraints

- teams are assigned randomly and cannot be changed
- in-person attendance at team meetings is expected
- TAs help mainly with hardware functionality and team dynamics, not with solving the actual technical challenge
- no Ethernet or other cable should be connected to robots during final video/demo operation

## Specializations Mentioned In The Manual

- electronic circuits and interfaces
- algorithms
- communication and networking
- embedded software
- computer software and user interface

## Embedded Software Relevance

The manual defines embedded software as:

- developing `C/C++` code for the Pynq board
- controlling the robot and attached sensors/actuators

This means embedded software is a legitimate and explicit specialization within the course.

## Vipin Role Decision

Vipin has decided to take the `computer software and user interface` role.

This means the most relevant course responsibilities are likely:

- receiving and processing MQTT data from robots
- building the base-station map or dashboard
- visualizing rocks, cliffs, mountains, and explored area
- coordinating data formats with embedded/software teammates

## Deliverables And Grading

- design report: `15%`
- demonstration video: `15%`
- final report: `70%`

Important additional points:

- the final report has a team part plus an individual part
- the individual report can only move the final-report grade downward
- the final-report team part also includes a live functionality demo component

## Team Sheet Note

From `Teams.xlsx`, the user appears in:

- team `28`
- group `D`
- OGO room `Neuron 0.232`
- locker `Traverse 011`
- tutor `Karanović, Jana`

## Counterpoints and Gaps

- the materials identify the course structure well, but do not yet tell whether the user's teammates already agreed on role allocation
- embedded software is a valid specialization, but course deliverables still require broader system understanding and documented contribution

## Related

- [[2026-04-22-what-to-pay-attention-to-in-5eid0-project-course]]
- [[2026-04-22-how-to-position-yourself-for-embedded-software-in-5eid0]]
- [[2026-04-22-computer-software-ui-role-plan-for-5eid0]]
- [[queries-home]]
- [[index]]
- [[log]]
