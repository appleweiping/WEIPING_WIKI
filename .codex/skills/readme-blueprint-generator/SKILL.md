---
name: readme-blueprint-generator
description: Create, rewrite, or critique high-quality project README.md files. Use when the user asks to improve README aesthetics, information architecture, onboarding quality, public GitHub presentation, maintainer quick-start docs, repository documentation polish, or a top-tier README rewrite. Also use when README changes must reflect AGENTS.md, project purpose, workflows, validation, installation, testing, contribution, security, or automation rules.
---

# README Blueprint Generator

Generate or rewrite `README.md` as the public front door to a repository. The output should feel intentionally designed: clear first impression, strong hierarchy, concrete quick start, and no filler.

## Workflow

1. Inspect the current README and the project's authoritative docs before rewriting.
   - Prefer `AGENTS.md`, `.wiki-schema.md`, `purpose.md`, `CONTRIBUTING.md`, `WORKFLOWS.md`, package metadata, docs indexes, and existing automation scripts when present.
   - If `.github/copilot/` or `.github/copilot-instructions.md` exists, read the smallest relevant files for architecture, stack, tests, workflow, and standards.
2. Decide the README's audience and job.
   - Public reader: what is this, why should they care, where do they go next?
   - Maintainer or future agent: how do they start, verify, maintain, and avoid dangerous mistakes?
3. Build a narrative outline before editing.
   - Start with a crisp identity sentence.
   - Put the most important navigation and quick-start material above long reference sections.
   - Use tables only when they reduce cognitive load.
   - Link to deeper docs instead of duplicating them.
4. Rewrite for polish.
   - Prefer specific verbs and nouns.
   - Remove generic "comprehensive", "powerful", "easy-to-use" language unless backed by concrete behavior.
   - Keep sections visually varied: short paragraphs, compact tables, short command blocks, and scannable bullets.
   - Avoid overlong catalogs in README; point to maintained indexes.
5. Validate the README as an artifact.
   - Check that commands are plausible for the repo.
   - Check that public/private boundaries are respected.
   - Check that the README does not claim unverified features or live status.
   - Run the repository's documentation, lint, catalog, or diff hygiene commands when available.

## Recommended Structure

Use this only as a starting shape; adapt to the repo.

- Title and one-sentence positioning.
- Short "why it exists" paragraph.
- Entry map or "start here" table.
- Quick start or common commands.
- Architecture or repository map.
- Core workflows.
- Quality gates and verification.
- Contribution or maintenance contract.
- Security/public-private boundaries when relevant.
- Links to deeper docs.

## Quality Bar

A strong README:

- gives a first-time reader an accurate mental model in under one minute;
- helps a future maintainer perform the next correct action without reading every file;
- separates stable project truth from generated outputs, caches, and private material;
- shows real commands, validation, and maintenance expectations;
- has enough visual rhythm to be pleasant on GitHub without becoming decorative.

## Avoid

- Turning the README into a full wiki index.
- Listing every file or every command.
- Repeating complete operating docs that already live elsewhere.
- Hiding important safety or validation rules below a wall of prose.
- Adding badges, diagrams, or slogans that are not supported by the repository.
