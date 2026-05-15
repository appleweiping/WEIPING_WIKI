---
title: QMQ App US Visa Slot Service
type: source
status: active
created: 2026-05-15
updated: 2026-05-15
tags:
  - source
  - qmq-app
  - us-visa
  - appointment
  - travel-logistics
source_files:
  - https://qmq.app/
  - https://qmq.app/order
source_pages:
  - qmq-app
  - us-visa-appointments
---

# QMQ App US Visa Slot Service

## Provenance

- Source: user-provided URL `https://qmq.app/` in chat on 2026-05-15.
- User note: the site is for "qiang mei qian" / grabbing US visa appointment slots.
- Public pages checked on 2026-05-15:
  - `https://qmq.app/`
  - `https://qmq.app/order`
- Related entity: [[qmq-app]].
- Related topic: [[us-visa-appointments]].

## Source Scope

This source records QMQ App as a Chinese-language web service related to US visa appointment monitoring and booking. It is a pointer and retrieval note, not an endorsement.

## Key Extracted Facts

- USER-PROVIDED: The user described `https://qmq.app/` as a tool for grabbing US visa appointment slots.
- EXTRACTED: The public page metadata describes QMQ App as a free US visa CGI appointment slot service that scans consulate interview slots and books when an opening appears.
- EXTRACTED: The order flow visible in the public frontend includes appointment settings, account information, security questions, and confirmation.
- EXTRACTED: The frontend text says the service supports both new scheduling and rescheduling, and that it attempts to automatically detect the account state.
- EXTRACTED: The frontend FAQ says the mechanism is simulated user behavior that refreshes appointment pages and books a suitable date when found.
- EXTRACTED: The site lists `admin@qmq.app` and a Telegram channel as contact/update channels.
- AMBIGUOUS: The HTML metadata uses `qmq.lovable.app` in canonical/Open Graph fields while the user-facing domain is `qmq.app`.

## Risk And Handling Notes

- UNVERIFIED: The wiki has not independently validated the service's reliability, legality, compliance with official visa appointment rules, or success rate.
- EXTRACTED: The public order flow appears to require sensitive CGI account details and security-question answers.
- INFERRED: Treat any credential, password, security answer, passport data, or visa account detail connected to this service as high-sensitivity material. Do not store personal credentials in the public wiki.
- INFERRED: Before using the service, verify the official US visa appointment site's terms, account-security risk, and any risk of losing rescheduling attempts.

## Retrieval Keywords

- QMQ
- qmq.app
- qiang mei qian
- 抢美签
- 美签抢位
- 美国签证预约
- CGI appointment
- US visa slot
