---
title: Venus Team 28 UI/software update uploaded
date: 2026-05-22
tags: [venus, team-28, gitlab, github, ui, communication, mqtt]
---

# Venus Team 28 UI/software update uploaded

- UI module: `D:/Undergraduate_project_netherlands/venus-team-28-user-interface-module`, branch `user-interface-module`, synced to GitLab at `e65064d`.
- Validation: UI tests passed (`28 passed`); headless simulated smoke processed 6 messages.
- Communication module: replaced hardcoded course MQTT password with `VENUS_MQTT_PASSWORD` env var in course publisher/subscriber scripts; pushed GitLab `communication-module` at `8e2abda`.
- GitHub archive: `D:/Undergraduate_project_netherlands/Venus basestation`, remote `https://github.com/appleweiping/venus-basestation.git`, pushed `main` at `edc9e8c` with refreshed Team 28 module snapshots.
- GitLab snapshot heads used for GitHub archive: communication `8e2abda`, algorithm-navigation `fd7a5bc`, embedeed-software `11a4090`, mapping-new `c4f70e6`.
- Public safety: sanitized both communication and mapping-new course MQTT scripts in GitHub archive; final scans found no `qdnaL4Nc` or private-key strings.