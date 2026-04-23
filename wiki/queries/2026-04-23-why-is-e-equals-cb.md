---
title: Why Is E Equals cB
type: query
status: active
created: 2026-04-23
updated: 2026-04-23
tags:
  - query
  - optics
  - electromagnetism
  - waves
source_files:
  - chat
---

# Why Is E Equals cB

## Question

Why does a vacuum electromagnetic wave satisfy `E = cB`?

## Short Answer

For a plane electromagnetic wave in vacuum,

\[
\vec k \times \vec E = \omega \vec B
\]

and because `E` is perpendicular to `k`, the magnitudes satisfy

\[
kE = \omega B
\]

so

\[
E = \frac{\omega}{k} B
\]

For an electromagnetic wave in vacuum, the phase velocity is

\[
\frac{\omega}{k} = c
\]

therefore

\[
E = cB
\]

More precisely, this is a relation between amplitudes:

\[
E_0 = c B_0
\]

## Main Idea

The electric field and magnetic field are not independent in a vacuum wave.

They must satisfy Maxwell's equations simultaneously, and that forces their amplitudes to be related by the wave speed.

In vacuum the wave speed is the speed of light `c`, so the ratio becomes

\[
\frac{E}{B} = c
\]

## Why The Units Still Make Sense

This does **not** mean the units of `E` and `B` are identical.

Instead, it means their ratio has the value `c`:

\[
\frac{E}{B} = c
\]

So the statement is about the physical relation between their magnitudes inside a vacuum electromagnetic wave.

## Physical Intuition

- a changing electric field produces a magnetic field
- a changing magnetic field produces an electric field
- in a self-propagating vacuum wave, the sizes of `E` and `B` must match the propagation speed
- because the propagation speed is `c`, the relation becomes `E = cB`

## Counterpoints and Gaps

- this relation is specific to electromagnetic waves in vacuum
- in media, the wave speed is generally not `c`, so the corresponding relation changes

## Related

- [[2026-04-22-how-are-k-omega-and-v-derived]]
- [[2026-04-23-what-causes-the-color-of-the-sky]]
- [[queries-home]]
- [[index]]
- [[log]]
