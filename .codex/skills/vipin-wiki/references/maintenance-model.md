# Vipin Wiki Maintenance Model

Use this reference when the task is broad, recurring, or about keeping `vipinknowledge` useful without a fresh prompt.

For focused procedures, prefer the smaller companion references:

- `weekly-maintenance-runbook.md` for the recurring automation run.
- `whole-computer-depth.md` for importance-based scan depth.
- `skill-upgrade-loop.md` for improving this skill.
- `safety-and-automation.md` for commit/push gates and public/private boundaries.

## The Compounding Standard

A change is good only if it makes future retrieval or maintenance easier. Prefer:

- maintained pages over chat-only answers
- refreshed existing pages over duplicate new pages
- public-safe routing metadata over raw private contents
- current live evidence over old memory
- scoped commits over mixed dirty-worktree saves

## Old Content Refresh

Refresh old pages when one of these is true:

- paths, project status, tools, or operating rules changed
- old pages conflict with newer authoritative docs
- a page is too vague to route future agents
- the same topic is fragmented across duplicates
- public/private risk is higher than the page's value
- a root became active and deserves more detail
- a root became inactive and should be summarized or archived

Do not delete useful history just because it is old. Add deprecated/superseded context, retarget links, or consolidate into a stronger page. Actual deletion requires explicit user approval.

## Whole-Computer Project Map Depth

Use the importance tiers in `SKILL.md`.

Detailed entries should include:

- path/root
- purpose/content nature
- current activity status
- source of truth files to read first
- safety boundary
- related wiki pages
- last verified date or evidence source

Brief entries should include:

- bucket
- example paths
- why they are low-detail
- when to inspect deeper

## Evidence Rules

For current-state claims, inspect live files or command output. Good evidence includes:

- `git status`, remotes, README, package metadata, AGENTS/CLAUDE/OPENCODE files
- shallow drive/root inventory
- existing wiki pages and catalog
- validation/lint results
- rendered or runtime checks for UI/site/tooling claims

Weak evidence:

- old markdown memory alone
- chat recollection
- stale folder names
- a README snippet when the relevant behavior lives elsewhere

## Maintenance Cadence

- After major infrastructure or project changes: refresh relevant pages immediately.
- After broad local discovery: update project maps, index, catalog, and log.
- During old-content refresh: run `scripts/wiki-maintenance-audit.ps1` to find stale pages, missing `updated` frontmatter, local-path pages, Agent Hub mentions, and missing counterpoint sections.
- Periodically: scan for stale maps, duplicate project pages, orphan entries, and private/public boundary drift.
- When the user says future agents should remember something: persist it in `AGENTS.md` and a relevant wiki page.

## Completion Checklist

Before calling maintenance done:

- important roots are detailed enough for the next agent to start
- unimportant roots are summarized rather than ignored
- old conflicting content is marked superseded or updated
- index/log/catalog are current
- validation passed
- no private path/material leaked into public pages
- scoped commit/push completed or the reason for not committing is explicit
