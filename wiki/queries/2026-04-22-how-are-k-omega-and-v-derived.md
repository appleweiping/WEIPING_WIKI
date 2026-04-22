---
title: How Are k Omega And v Derived
type: query
status: active
created: 2026-04-22
updated: 2026-04-22
tags:
  - query
  - optics
  - waves
  - physics
source_files:
  - chat
---

# How Are k Omega And v Derived

## Question

How does the board derive the relations among `k`, `omega`, `lambda`, `T`, `f`, and wave speed `v`?

## Starting Point

A traveling wave can be written as:

```text
y(x,t) = A cos(kx - omega t + phi)
```

Where:

- `k` is the wave number
- `omega` is the angular frequency
- `phi` is the phase constant

The key idea is:

- if the phase changes by `2pi`, the physical wave is unchanged

## Deriving `k = 2pi / lambda`

Compare two points separated by one wavelength `lambda`:

```text
y(x,t) = A cos(kx - omega t + phi)
y(x + lambda, t) = A cos(k(x + lambda) - omega t + phi)
                  = A cos(kx - omega t + phi + k lambda)
```

Because points separated by one wavelength have the same wave value, the phase change must be `2pi`:

```text
k lambda = 2pi
```

So:

```text
k = 2pi / lambda
```

## Deriving `omega = 2pi / T = 2pi f`

Now compare times separated by one period `T`:

```text
y(x, t + T) = A cos(kx - omega(t + T) + phi)
            = A cos(kx - omega t + phi - omega T)
```

After one period, the wave repeats, so the phase change is again `2pi`:

```text
omega T = 2pi
```

Thus:

```text
omega = 2pi / T
```

Since:

```text
f = 1 / T
```

we get:

```text
omega = 2pi f
```

## Deriving `v = omega / k`

A moving crest keeps constant phase:

```text
kx - omega t + phi = constant
```

Rearrange:

```text
kx - omega t = constant
=> x = (omega / k)t + constant
```

So the propagation speed is:

```text
v = omega / k
```

## Recovering `v = f lambda`

Substitute:

```text
omega = 2pi f
k = 2pi / lambda
```

Then:

```text
v = (2pi f) / (2pi / lambda) = f lambda
```

## Final Relations

The board is deriving these standard wave relations:

```text
k = 2pi / lambda
omega = 2pi f
v = omega / k = f lambda
```

## Counterpoints and Gaps

- this derivation is for a standard traveling wave form and does not yet discuss sign conventions such as `kx + omega t`
- it also does not yet distinguish phase velocity from group velocity

## Related

- [[queries-home]]
- [[2026-04-22-what-is-dbm]]
- [[index]]
- [[log]]
