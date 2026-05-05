---
title: What Is An ADC And Why 10 Bit Means 1024 Levels
type: query
status: active
created: 2026-05-03
updated: 2026-05-03
tags:
  - query
  - adc
  - quantization
  - signals
source_files:
  - chat
---

# What Is An ADC And Why 10 Bit Means 1024 Levels

## Question

What is an ADC, and why does a 10-bit ADC have `1024` quantization levels?

## Short Answer

`ADC` stands for:

- `Analog-to-Digital Converter`

It converts an analog signal into digital form.

If an ADC uses `N` bits per sample, then it has:

\[
2^N
\]

quantization levels.

So for `10` bits:

\[
2^{10} = 1024
\]

## What An ADC Does

An ADC converts a continuous analog signal into digital data.

Conceptually this involves:

1. sampling
2. quantization
3. encoding

## Why 10 Bits Gives 1024 Levels

With `10` bits, one sample is represented by a 10-digit binary number.

That means the ADC can represent:

- `0000000000`
- `0000000001`
- `0000000010`
- ...
- `1111111111`

The total number of distinct binary patterns is:

\[
2^{10} = 1024
\]

So the signal is quantized into `1024` possible levels.

## General Rule

- `8` bit -> `2^8 = 256`
- `10` bit -> `2^{10} = 1024`
- `12` bit -> `2^{12} = 4096`

## Counterpoints and Gaps

- this gives the number of quantization levels, not the analog voltage range itself
- a fuller treatment would also discuss quantization step size and quantization error

## Related

- [[2026-05-03-how-to-understand-flat-top-sampling-questions]]
- [[queries-home]]
- [[index]]
- [[log]]
