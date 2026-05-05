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

## Chinese Narrative Explanation

### Q1: AAL Is About Authentication Strength

The trap is that the story contains two logins and an OAuth token, so it looks like "more security". But NIST AAL asks what kind of authenticator was used to authenticate the user.

In the scenario, Alice authenticates to J with a password and to U with a password. Those are both memorized secrets, so they are the same factor type. Two different passwords are not automatically two-factor authentication. OAuth also does not change this into AAL2, because OAuth is mainly about letting J access A's resource at U after A authorizes it.

So the most reasonable level is AAL1: Alice has shown control of a single authenticator type.

### Q2: OAuth Token As Delegated Authorization

The story is not asking who Alice is; it asks what permission J gets after Alice authorizes J through OAuth.

U already has a role `R_A` for Alice's course list `CL_A`. The read permission on `CL_A` is assigned to that role. Therefore, if J should be able to read `CL_A`, the cleanest policy change is to add J as a member of `U.R_A`.

This is why `U.R_A <- J` is the right shape: put J into the role that already carries Alice-course-list read permission.

### Q3: Encryption Is Not Freshness

The protocol encrypts Alice's password with J's public key, so an eavesdropper should not learn the password. But the whole encrypted blob is reusable.

If an attacker records:

```text
A -> J: A, E(pkJ, A | J | U | Paj)
```

then later the attacker can send exactly the same message again. J decrypts it and sees the same valid password. Because there is no nonce, timestamp, challenge, or session-specific value, J cannot tell whether the message is fresh.

So the main flaw is replay attack.

### Q4: Hierarchical RBAC Means Add Inherited Permissions

Start from B's assigned roles:

- B has `RWX`.
- B has `RVY`.

Then add each role's direct permission:

- `RWX` gives `Write X`.
- `RVY` gives `View Y`.

Then climb upward in the hierarchy to collect inherited permissions:

- `RWX` is under `RRX`, so it inherits `Read X`.
- `RRX` is under `ROZ`, so it inherits `Open Z`.
- `RVY` is under `ROZ`, so it also inherits `Open Z`.

Take the union:

```text
Open Z, Read X, Write X, View Y
```

### Q5: Avoid The Forbidden Permission

D needs:

```text
Open Z, Read X, Write X, Delete Y
```

D must not get:

```text
View Y
```

`RWX` is useful because it gives `Write X`, and by inheritance also `Read X` and `Open Z`.

The hard part is `Delete Y`. The obvious role `RDY` is dangerous because it sits under `RVY`, so assigning `RDY` also gives `View Y`, which is forbidden.

The best option uses `REX`: nobody among A, B, and C is assigned to `REX` in the table, so changing `REX`'s permission does not change the permissions of existing users. If `REX` is changed from `Execute X` to `Delete Y`, then assigning D both `RWX` and `REX` gives exactly the wanted rights without `View Y`.

### Mental Checklist

Use this checklist for similar questions:

1. For AAL questions, count authenticator factor types, not the number of logins.
2. For OAuth questions, ask "who is being allowed to access which resource?"
3. For protocol questions, distinguish confidentiality from authentication and freshness.
4. For RBAC questions, list assigned roles, direct permissions, inherited permissions, then union.
5. For "add a user without changing existing users" questions, avoid roles that give forbidden inherited permissions and prefer unused roles if the question permits changing their permissions.

## Related

- [[2026-04-22-security-course-self-study-guide]]
- [[queries-home]]
- [[index]]
- [[log]]
