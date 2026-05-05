---
title: How To Understand Quantization And Bit Rate
type: query
status: active
created: 2026-05-05
updated: 2026-05-05
tags:
  - query
  - adc
  - quantization
  - sampling
  - signals
source_files:
  - chat
---

# How To Understand Quantization And Bit Rate

## Question

How should the quantization slide be understood, especially the relations `M = 2^n` and `R = n/T = n f_s`?

## Short Answer

Quantization maps each sampled analog amplitude to one of a finite number of discrete amplitude levels.

If each sample is represented by `n` bits, then the number of possible quantization levels is:

\[
M = 2^n
\]

If the ADC produces `f_s` samples per second, and each sample takes `n` bits, then the bit rate is:

\[
R = n f_s
\]

Equivalently, if `T_s = 1/f_s` is the sampling period:

\[
R = \frac{n}{T_s}
\]

## How To Read The Figure

- The left waveform is a flat-top sampled analog signal: each sampled value is held briefly.
- The horizontal voltage lines are quantization levels.
- Each sampled amplitude is rounded or assigned to the nearest allowed level.
- The binary labels on the right are the digital codes assigned to those levels.
- The red dashed vertical lines indicate sample instants, separated by the sampling period `T_s`.

## Meaning Of The Symbols

- `M`: number of quantization levels
- `n`: number of bits per sample
- `f_s`: sampling frequency, in samples per second
- `T_s`: sampling period, so `T_s = 1/f_s`
- `R`: bit rate, in bits per second
- `T_b`: bit period, so `T_b = 1/R`

## Important Distinction

The `T` in the slide formula `R = n/T` is best read as the sampling period `T_s`, not the bit period.

One sample arrives every `T_s` seconds, and that one sample must be encoded using `n` bits. Therefore:

\[
R = \frac{\text{bits per sample}}{\text{seconds per sample}} = \frac{n}{T_s}
\]

The bit period is instead:

\[
T_b = \frac{1}{R} = \frac{T_s}{n}
\]

## Answer To The Slide Question

If the bitrate goes up while `n` stays the same, the bit period gets shorter.

Claim status: `EXTRACTED` for the formula relationships shown on the slide; `INFERRED` for the notation clarification between `T_s` and `T_b`.

## Example

For a `3`-bit quantizer:

\[
M = 2^3 = 8
\]

If the sampling frequency is `1000 samples/s`, then:

\[
R = 3 \cdot 1000 = 3000 \text{ bits/s}
\]

So each bit lasts:

\[
T_b = \frac{1}{3000} \text{ s}
\]

If the bitrate doubles and `n` stays the same, `T_b` halves.

## Related

- [[2026-05-03-how-to-understand-flat-top-sampling-questions]]
- [[2026-05-03-what-is-an-adc-and-why-10-bit-means-1024-levels]]
- [[queries-home]]
- [[index]]
- [[log]]
