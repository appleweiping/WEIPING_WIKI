---
title: Why Pe Is Not Proportional To Input SNR
type: query
status: active
created: 2026-05-05
updated: 2026-05-05
tags:
  - query
  - signals
  - snr
  - probability-of-error
  - pcm
source_files:
  - chat
---

# Why Pe Is Not Proportional To Input SNR

## Question

Why does the slide seem to say `P_e` is proportional to `(S/N)_in`?

## Short Answer

Strictly, `P_e` should not be directly proportional to `(S/N)_in`.

If `(S/N)_in` means input signal-to-noise ratio, then higher input SNR normally makes the probability of error smaller:

\[
(S/N)_{in} \uparrow \quad \Rightarrow \quad P_e \downarrow
\]

So the slide's last line is likely shorthand for "`P_e` depends on `(S/N)_in`", or it is missing an inverse/decreasing relationship.

Claim status: `INFERRED`, based on the slide context and the standard meaning of signal-to-noise ratio.

## Why Higher SNR Lowers Error Probability

Digital detection usually works by comparing a received signal value to a decision threshold.

An error happens when noise pushes the received value to the wrong side of that threshold.

- stronger signal -> received levels are farther apart
- weaker noise -> less random pushing
- larger SNR -> less overlap between the possible received levels
- less overlap -> lower probability of choosing the wrong code

That is why `P_e` is usually a decreasing function of SNR.

## More Accurate Relationship

For many digital communication systems, `P_e` is not a simple linear proportion. It is more like:

\[
P_e = Q(\sqrt{k \cdot SNR})
\]

or approximately decreases exponentially at high SNR:

\[
P_e \approx e^{-k \cdot SNR}
\]

The exact formula depends on the modulation and detection method, but the direction is the same:

\[
SNR \uparrow \Rightarrow P_e \downarrow
\]

## How This Connects To The Slide Formula

The slide gives:

\[
\left(\frac{S}{N}\right)_{out}
=
\frac{M^2}{1 + 4P_e(M^2 - 1)}
\]

Here:

- `M` is the number of quantization levels
- `P_e` is the probability of a transmission/decision error
- higher `P_e` makes the denominator larger
- therefore higher `P_e` makes output SNR worse

If:

\[
P_e = 0
\]

then:

\[
\left(\frac{S}{N}\right)_{out} = M^2
\]

This is the best case shown by the formula.

## Practical Exam Interpretation

Read the last line as:

\[
P_e \text{ is controlled by } (S/N)_{in}
\]

not as:

\[
P_e \propto (S/N)_{in}
\]

A safer statement is:

\[
P_e \propto \frac{1}{(S/N)_{in}}
\]

as a rough intuition, or more accurately:

\[
P_e = f((S/N)_{in})
\]

where `f` is a decreasing function.

## Related

- [[2026-05-05-how-to-understand-quantization-and-bit-rate]]
- [[2026-05-03-what-is-an-adc-and-why-10-bit-means-1024-levels]]
- [[queries-home]]
- [[index]]
- [[log]]
