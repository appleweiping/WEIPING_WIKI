---
title: How To Convert This Spectrum To Time Domain
type: query
status: active
created: 2026-05-03
updated: 2026-05-03
tags:
  - query
  - signals
  - sampling
  - frequency-domain
  - time-domain
source_files:
  - chat
---

# How To Convert This Spectrum To Time Domain

## Question

Given a spectrum with:

- amplitude `+1` at `f = -100 Hz`
- amplitude `-3` at `f = 0 Hz`
- amplitude `+1` at `f = +100 Hz`

what is the corresponding signal in the time domain?

## Short Answer

\[
x(t) = -3 + 2\cos(2\pi 100 t)
\]

## Why

### 1. The `f = 0` component

The line at `0 Hz` is a DC component, so it gives a constant term:

\[
-3
\]

### 2. The symmetric lines at `\pm 100 Hz`

Equal spectral lines at `+f_0` and `-f_0` correspond to a real cosine term.

In general,

\[
A\cos(2\pi f_0 t)
\quad \leftrightarrow \quad
\frac{A}{2}\delta(f-f_0)+\frac{A}{2}\delta(f+f_0)
\]

Here each side has amplitude `1`, so:

\[
\frac{A}{2}=1
\Rightarrow A=2
\]

and the oscillating part is:

\[
2\cos(2\pi 100 t)
\]

### 3. Combine both parts

Therefore:

\[
x(t) = -3 + 2\cos(2\pi 100 t)
\]

## Time-Domain Interpretation

This is a cosine wave with:

- mean value `-3`
- amplitude `2`
- frequency `100 Hz`

So it oscillates between:

\[
-3 + 2 = -1
\]

and

\[
-3 - 2 = -5
\]

## Counterpoints and Gaps

- this interpretation assumes the shown spectral values are real-valued line amplitudes with zero extra phase information
- if additional phase information were present, the time-domain expression would need an added phase shift

## Related

- [[2026-04-22-how-are-k-omega-and-v-derived]]
- [[queries-home]]
- [[index]]
- [[log]]
