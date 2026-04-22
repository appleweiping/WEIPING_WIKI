---
title: What Is dBm
type: query
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - query
  - signal
  - electronics
  - communications
source_files:
  - chat
---

# What Is dBm

## Question

What does the formula on the board mean, and how should `dBm` be interpreted?

## Core Definition

`dBm` is a logarithmic power unit referenced to `1 mW`.

Formula:

```text
dBm = 10 log10(P / 1 mW)
```

Where:

- `P` is power
- the reference value is `1 mW`

## Interpretation

- `0 dBm = 1 mW`
- `10 dBm = 10 mW`
- `20 dBm = 100 mW`
- `30 dBm = 1000 mW = 1 W`

And:

- `-10 dBm = 0.1 mW`

## Why `0 dBm = 1 mW`

Because:

```text
P / 1 mW = 1
log10(1) = 0
```

So:

```text
dBm = 10 * 0 = 0
```

## Why `-10 dBm = 0.1 mW`

Starting from:

```text
-10 = 10 log10(P / 1 mW)
```

Then:

```text
-1 = log10(P / 1 mW)
P / 1 mW = 10^-1 = 0.1
P = 0.1 mW
```

## Useful Rules Of Thumb

- every increase of `10 dB` means power multiplies by `10`
- every decrease of `10 dB` means power divides by `10`
- every increase of about `3 dB` means power roughly doubles

## Counterpoints and Gaps

- `dBm` is an absolute power unit because it is referenced to `1 mW`; plain `dB` by itself is only a ratio
- this note explains power scaling only and does not yet cover the difference between `dB`, `dBm`, and `dBW`

## Related

- [[queries-home]]
- [[index]]
- [[log]]
