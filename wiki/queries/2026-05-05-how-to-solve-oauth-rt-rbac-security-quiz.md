---
title: How To Solve OAuth RT RBAC Security Quiz
type: query
status: active
created: 2026-05-05
updated: 2026-05-05
tags:
  - query
  - security
  - oauth
  - rbac
  - rt
  - authentication
source_pages:
  - 2026-04-22-security-course-self-study-guide
source_files:
  - chat screenshots
  - https://pages.nist.gov/800-63-4/sp800-63b.html
  - https://www.rfc-editor.org/rfc/rfc6749
---

# How To Solve OAuth RT RBAC Security Quiz

## Question

How should Vipin reason through a five-question security quiz covering NIST authenticator assurance levels, OAuth authorization, RT rules, replay attacks, and hierarchical RBAC?

## Study Note

If the quiz is a graded individual component, use this page as a reasoning aid rather than as a submission script.

## Q1: NIST AAL In The OAuth Scenario

Most appropriate choice:

```text
Some confidence (AAL1) as control over a single type of credential is shown.
```

Reasoning:

- `EXTRACTED`: Alice logs in to J with a username/password.
- `EXTRACTED`: Alice also logs in to U with a username/password.
- `INFERRED`: Even if the two passwords are different, they are still the same authenticator type: memorized secrets.
- `INFERRED`: OAuth access to the course list is authorization/delegation, not automatically high-assurance authentication of Alice to J.
- `INFERRED`: This does not become AAL2 merely because two passwords or an OAuth token appear in the scenario.

## Q2: RT Rule For OAuth Delegation

Most appropriate choice:

```text
U.R_A <- J
```

Reasoning:

- `EXTRACTED`: U keeps one role `R_x` for each course-list resource `CL_x`.
- `EXTRACTED`: Read permission on `CL_A` is assigned to `U.R_A`.
- `INFERRED`: When A authorizes J to access A's course list, J should become a member of the role that already has read permission on `CL_A`.
- Therefore U should add J to `U.R_A`.

## Q3: Authentication Protocol With Encrypted Password

Most appropriate choice:

```text
No, as an attacker could record and later replay the message.
```

Reasoning:

- `EXTRACTED`: The message contains `E(pkJ, A | J | U | Paj)`.
- `INFERRED`: Encrypting the password to J protects it from passive reading, assuming the public key and encryption are correct.
- `INFERRED`: The protocol has no nonce, timestamp, challenge, or session freshness value.
- Therefore a recorded valid login message can be replayed later.

## Q4: Permissions Of User B In Hierarchical RBAC

Most appropriate choice:

```text
Read and Write file X, View file Y and Open file Z, as these are the permissions, including inherited ones, of his roles.
```

Reasoning:

- `EXTRACTED`: B is assigned roles `RWX` and `RVY`.
- `EXTRACTED`: Direct permissions are `RWX = Write X` and `RVY = View Y`.
- `INFERRED`: From the quiz's hierarchy, `RWX` inherits from `RRX` and `ROZ`, so it also gets `Read X` and `Open Z`.
- `INFERRED`: `RVY` inherits from `ROZ`, so it also gets `Open Z`.
- Union for B: `Read X`, `Write X`, `View Y`, `Open Z`.

## Q5: Add D With Open Z, Read/Write X, Delete But Not View Y

Most appropriate choice:

```text
Change the permission of REX to `Delete Y` and give D roles REX and RWX.
```

Reasoning:

- Needed rights: `Open Z`, `Read X`, `Write X`, `Delete Y`.
- Forbidden right: `View Y`.
- `RWX` gives `Write X`, and through inheritance also `Read X` and `Open Z`.
- `RDY` would give `Delete Y`, but it also inherits `View Y`, so assigning `RDY` is not acceptable.
- `REX` has no current user in the shown assignment table, so changing `REX` from `Execute X` to `Delete Y` does not change permissions of existing users A, B, or C.
- Giving D `REX + RWX` gives the desired set without `View Y`.

## General Rules To Remember

- AAL is about the authenticator factors used for authentication, not just how many services appear in the story.
- OAuth access tokens represent delegated authorization to access a resource.
- In RT notation, `U.R_A <- J` means J becomes a member of U's role `R_A`.
- Encryption alone does not guarantee freshness; replay protection needs a nonce, timestamp, or challenge-response structure.
- In hierarchical RBAC, first list direct roles, then add inherited permissions, then take the union.

## Related

- [[2026-04-22-security-course-self-study-guide]]
- [[queries-home]]
- [[index]]
- [[log]]
