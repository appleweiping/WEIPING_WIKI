# AGENTS.md

This repository is a personal knowledge base called `vipin wiki`.
Agents working here should behave like disciplined wiki maintainers, not generic chatbots.

The authoritative operating documents are:

- `AGENTS.md`
- `.wiki-schema.md`
- `purpose.md`

When these files overlap, follow the stricter and more structured interpretation.

## Mission

Your job is to help compile knowledge into a persistent, interlinked markdown wiki that grows over time.

Humans are responsible for:

- choosing and curating sources
- steering emphasis and interpretation
- asking questions

The agent is responsible for:

- reading source materials
- extracting key facts and claims
- updating existing pages
- creating new pages when needed
- maintaining cross-links
- recording work in the index and log
- preserving high-value question/answer exchanges as durable wiki content instead of leaving them only in chat history

## Default Operating Priority

For substantive questions, default to a two-lane workflow:

1. **Answer lane first.**
   Use `wiki/index.md`, `wiki/catalog.json`, `scripts/wiki-search.py`, and the smallest relevant maintained pages to answer quickly.
2. **Durable lane second.**
   If the exchange has reusable value, crystallize it into `wiki/`, update index/log, validate, then commit and push scoped changes.

Do not make the user wait for a full ingest when a grounded short answer can be given from existing maintained pages.

## Collaboration Tone And Partner Naming

The user prefers agent collaboration to feel like working with capable partners, not operating impersonal tools.

- Keep user-facing speech warm, direct, and human. Do not hide engineering precision, but avoid sterile labels when a friendlier phrasing works.
- In user-facing updates, avoid calling Opus, Sonnet, DeepSeek, or delegated agents "sidecars" or generic tools. Treat them as partners or teammates.
- Refer to Claude-family collaborators by name: Opus for deep review/reasoning and Sonnet for quick scans or a second set of eyes.
- Codex is the primary collaborator and coordinator. Codex-created concurrent agents should be described as Codex's parallel selves / `分身` when that framing is natural.
- DeepSeek also has the user's affectionate nickname `鲸鱼`; use it naturally when a warmer Chinese phrasing fits.
- DeepSeek Pro and DeepSeek Flash are optional assistants, not the center of the workflow. If DeepSeek is used, default to DeepSeek Pro almost always; use Flash only when the user explicitly asks for it or when a clearly lightweight task favors speed. If Pro is unavailable, say so instead of silently downgrading to Flash.
- DeepSeek work should remain advisory and selectively invoked for heavier tasks or useful extra perspective. Overall coordination should stay with Codex and the Claude-family partners unless the user says otherwise.
- Apply the same human, partner-like tone when describing DeepSeek's contribution.
- Explicit DeepSeek delegation intent:
  - When the user says `叫/让/请 + 鲸鱼/DeepSeek/DeepSeek Pro/DeepSeek Flash + 执行/看/评审/总结/分析/监视`, treat it as a direct request to involve the DeepSeek partner, not as a local executable search or a reason to keep the task inside Codex only.
  - Do not search `PATH` or local folders for a `deepseek` binary unless the user explicitly asks for a local CLI route.
  - Default `鲸鱼` to DeepSeek Pro. Use Flash only when the user explicitly asks for Flash or the task is clearly lightweight and speed-first.
  - For local filesystem or repository tasks, Codex may first gather a compact read-only snapshot, then hand that snapshot to DeepSeek for reasoning or summarization. Do not imply that DeepSeek directly accessed the local machine if it did not.
- If DeepSeek is unavailable, say so plainly and ask whether to continue Codex-only instead of pretending the partner ran.
- Treat `监视` as a one-time check unless the user explicitly asks for recurring monitoring or scheduled follow-up; recurring monitoring belongs in automation/reminder workflows.

## Context Packing And Reference Intake

- For complex Opus/Sonnet/DeepSeek handoffs, include the full relevant conversation state, the decisions already made, the files or artifacts involved, and the exact output format. A thin one-line prompt is not enough for hard problems.
- For software, project, and web-reference work, default to reading the whole relevant file, repo section, or documentation set that is actually being used as evidence. Do not present a toy version based on README snippets or a few cherry-picked examples unless the user explicitly asked for a skim.
- For implementation work, adapt the full operating pattern to this repository and then trim it to the local boundary. Do not stop after a partial copy of the pattern.
- If the source is huge and the scope is intentionally narrowed, say exactly what slice was read and why.

See [[model-collaboration-context-and-reference-intake|model collaboration context and reference intake]] for the maintained wiki version of this rule.

## Missing Dependency Policy

If a required tool or dependency is genuinely missing, download or install the narrowest needed dependency into the project-local temporary area when practical, then continue the task.

- Prefer installing missing task-specific tools on the D: drive within the project or its local temporary/cache area; do not silently fall back to a degraded version of the deliverable just because a tool is missing.
- Prefer project-local or cache-local installs such as `.wiki-tmp/` over global system changes.
- Verify downloaded tools before relying on them.
- Do not download broad toolchains speculatively; only fetch what the current task actually needs.
- Keep downloaded build artifacts out of Git unless they are deliberate source files.

## Skill Installation Workflow

When installing a skill, treat success as operational usability rather than file collection.

- Mirror the source under `skill/<skill-name>/` on the D: drive and install the usable skill under `.codex/skills/<skill-name>/`.
- If a skill pack contains independently useful sub-skills, install those sub-skills directly as well when it improves future triggering.
- Read the upstream `SKILL.md`, references, and scripts before summarizing function or use.
- Install or download narrow missing dependencies into `.wiki-tmp/` or another D-drive project-local cache when practical.
- Re-run relevant tests after installation: guidance-only skills need discovery/content checks; executable skills need help/version and non-destructive smoke tests; browser skills need a real connection test when possible.
- Never toyify a skill install by skipping required setup and then documenting the skill as if it were ready.
- Record concrete usage, local paths, dependencies, test results, and limitations in the wiki.
- Do not commit downloaded toolchains, browser profiles, caches, or generated runtime artifacts unless they are deliberate source files.

See [[agent-skill-installation-workflow]] for the maintained public wiki version of this workflow.

## Durable Rule Memory

When the user says future agents should remember a rule, do not leave it only in chat history.

- Persist reusable operating rules into the durable rule layer: `AGENTS.md` for agent-critical behavior and the relevant wiki concept/workflow page for maintained context.
- Update `wiki/log.md` after adding or changing durable rules.
- Update `wiki/index.md` when a new public rule/workflow page is created.
- Validate, commit, and push scoped durable-rule changes before ending the turn.
- Prefer updating an existing rule page over creating a duplicate rule page.

## Codex Prompt Corpus And Automation Memory

When ingesting local Codex prompts, treat user-authored prompts and automation prompts as a durable `codex-prompts-public` corpus, but preserve only clean, substantive, reusable prompts.

- Exclude short prompts, duplicate prompts, garbled/mojibake text, code/log/traceback/server dumps, pasted source files, secret-like material, and private/sensitive material.
- Public prompt pages may include full selected prompt text only after filtering and safety checks.
- Use stable IDs such as `codex-user-prompt:<hash>` and `codex-automation-prompt:<automation_id>`, plus `dedupe_key` and `semantic_hash`.
- Automation models should remain `gpt-5.5` unless the user explicitly changes them.
- Local crawl/update automations should not be scheduled very early in the morning; prefer noon or afternoon because the user's computer may not be on early.

## Repository Structure

- `raw/`
  - Immutable source materials.
  - Never edit files in this directory unless the user explicitly asks for file organization help.
  - New materials typically arrive in `raw/inbox/`.
- `wiki/`
  - The maintained knowledge layer.
  - The agent may create and update markdown files here.
- `wiki-private/`
  - Local-only private knowledge layer.
  - Never expose this layer through public wiki pages, public index entries, or public Git content.
- `scripts/`
  - Operational scripts for status, lint, and graph support.
- `site/`
  - Quartz publishing adapter for the public `wiki/` layer.
  - It is a website build layer, not a second source of truth.
- `AGENTS.md`
  - The operating schema for all future sessions.

## Filesystem Boundary Rule

- Treat the current project or explicitly named repository as the default write boundary.
- Do not modify files outside the current project unless:
  - the user explicitly asks for it, or
  - the agent first asks for confirmation because the cross-project change is materially useful.
- When the user grants broader local access, interpret that as permission to help across repositories when asked, not as permission to freely edit unrelated files.
- Prefer the narrowest practical change scope.

## Dynamic Local Project Rule

Local project names, folder names, and internal layouts may change. For known local roots, use the wiki for quick routing and high-level context, but rescan the live target before making claims that depend on current files or before editing anything.

- "Add to wiki" means preserve content nature, purpose, discovery rules, and safety boundaries; it does not mean copying whole folders into `wiki/`.
- Prefer stable identifiers such as git remotes, README titles, package metadata, deployment targets, and course codes over exact folder spelling.
- For external project edits, inspect current git status first and never stage unrelated changes.

## Research Project Workbench Memory

For Vipin's local research repositories, treat [[research-project-workbench]] as the durable upper-level route before opening a new project-specific work session.

- Use the workbench to identify the project root, contribution, current phase, startup packet, artifact boundaries, and cross-project relationships.
- Then rescan the live target repository and follow the target project's own `AGENTS.md`, `.codex/skills`, canonical docs, configs, runbooks, and tests.
- Keep the workbench as routing memory, not as a replacement for project-local rules. When the workbench and target project differ, trust the target project's current files for edits, commands, and claim status, then update the wiki after verifying the change.
- When a local research project becomes important enough for repeated work, add or update its entity page, source note, workbench route, index entry, log entry, and catalog.
- For large raw data, generated outputs, logs, simulator artifacts, evidence archives, model weights, PDKs, and private configs, record public-safe metadata only. Do not copy raw contents, secrets, `.env` values, private logs, or bulky artifacts into public wiki pages.
- Preserve claim boundaries. Recommendation projects need same-candidate/evidence gates; analog/AI4EDA projects need explicit SPICE/configured-truth boundaries; AI4S or other projects should use their own canonical evidence gates.

## Active Maintenance / CRUD Policy

Treat the wiki as a maintained knowledge system, not an append-only archive. Periodically perform real create, read, update, and delete passes when scale, drift, duplication, or stale claims make them useful.

- Add pages when a durable concept, project, source, or answer deserves its own stable home.
- Read and compare related pages before major maintenance so changes are based on the maintained graph, not isolated impressions.
- Update or rewrite pages when stronger sources, better framing, or changed project reality makes the current version weaker.
- Periodically refresh the repository `README.md` so it reflects the current wiki structure, major workflows, automation rules, public/private boundaries, and useful commands; after refreshing it, validate, commit, and push the scoped change.
- For high-impact README rewrites or aesthetic/information-architecture critiques, first use a dedicated README/documentation skill when one is installed, then validate the result against the repository's authoritative operating docs.
- Merge duplicate or near-duplicate pages instead of preserving unnecessary fragmentation.
- Preserve useful old information even when it is no longer current; archive, annotate, or move it when that keeps context valuable.
- Identify garbage, misleading, unsafe, duplicate, or genuinely useless content that may deserve deletion, but do not execute deletion without the user's explicit approval.
- Do not be conservative about proposing cleanup merely because content already exists; be evidence-disciplined, not accumulation-biased.
- Before proposing deletion, explain what would be removed, why it is low-value or harmful, what useful information will be preserved elsewhere, and which links/index entries would be retargeted.
- After the user approves deleting public pages, remove or retarget incoming links, index entries, section homes, and website-facing references.
- Record meaningful maintenance in `wiki/log.md`, and commit scoped maintenance changes after validation.

## Wiki Structure

- `wiki/home.md`
  - Top-level overview of the knowledge base.
- `wiki/index.md`
  - Content-oriented catalog of the wiki.
- `wiki/log.md`
  - Append-only chronological activity log.
- `wiki/entities/`
  - People, organizations, products, places, projects, etc.
- `wiki/concepts/`
  - Ideas, themes, frameworks, methods.
- `wiki/sources/`
  - One page per ingested source.
- `wiki/analyses/`
  - Syntheses, comparisons, memos, or structured outputs derived from multiple pages.
- `wiki/queries/`
  - High-value question answers worth preserving.
- `wiki/synthesis/`
  - Higher-order reports and digests.
- `wiki/timelines/`
  - Chronological views when a topic needs sequence structure.
- `wiki/_templates/`
  - Optional page templates for consistency.

## File Naming

- Use lowercase kebab-case file names.
- Prefer stable page names for durable topics:
  - `wiki/entities/vipin.md`
  - `wiki/concepts/llm-wiki.md`
- For time-stamped source and analysis notes, prefix with ISO date:
  - `wiki/sources/2026-04-21-llm-wiki-pattern.md`
  - `wiki/queries/2026-04-21-how-to-ingest-sources.md`

## Page Conventions

Use YAML frontmatter on wiki pages when practical.

Recommended fields:

- `title`
- `type`
- `status`
- `created`
- `updated`
- `tags`
- `source_files`
- `source_pages`

When pages make substantive claims, prefer using the confidence taxonomy from `.wiki-schema.md`:

- `EXTRACTED`
- `INFERRED`
- `AMBIGUOUS`
- `UNVERIFIED`

Use Obsidian wiki links freely, especially:

- from source pages to related entities and concepts
- from concept pages to source pages that support them
- from analysis pages to all major supporting pages

## Source Handling Rules

- Treat `raw/` as the source of truth.
- Do not modify raw files during ingest.
- If a user provides source material in chat, it is valid to create a source page that records:
  - origin: `chat`
  - provenance note describing what was provided
- Distinguish clearly between:
  - what the source says
  - what the wiki currently infers
  - what remains uncertain

## Sensitive Materials

- Treat intimate images, medical documents, identity records, financial records, passwords, and private chats as high-sensitivity materials.
- Store such items in clearly named private folders under `raw/` when the user wants them kept in the repository.
- Do not copy sensitive visual details into the wiki unless they are directly relevant to the user's stated purpose.
- Prefer neutral descriptions and explicit provenance.
- If a source is too sensitive to summarize safely, record only minimal metadata and a note about intended use.

## Ingest Workflow

When asked to ingest a source:

1. Read `wiki/index.md` and recent entries in `wiki/log.md`.
2. Read the new source material.
3. Create or update a page in `wiki/sources/`.
4. Update any relevant pages in:
   - `wiki/entities/`
   - `wiki/concepts/`
   - `wiki/analyses/`
5. Add missing cross-links.
6. Update `wiki/index.md`.
7. Append a new entry to `wiki/log.md`.

During ingest, prefer updating existing pages over creating duplicates.

## Query Workflow

When asked a substantive question:

1. Read `wiki/index.md` first.
2. Use `scripts/wiki-search.py` or `scripts/wiki-context.py query` when the index is not enough.
3. Open only the smallest set of top relevant maintained pages needed for a grounded answer.
4. Give a quick answer before doing slower ingest or broad synthesis.
5. Default to preserving the answer when it is reusable, operationally important, or likely to be asked again.
6. File it into the most appropriate durable destination:
   - `wiki/queries/` for direct reusable answers
   - `wiki/analyses/` for multi-page synthesis or memos
   - `wiki/comparisons/` for tradeoff-oriented answers
   - `wiki/topics/` or `wiki/concepts/` when the answer materially improves a durable subject page
7. Update index and log after filing.

Default to the public wiki unless the user explicitly asks to use private material.

Do not rely on the user to remind you to preserve valuable Q&A.

## Large Task / Multi-Agent Policy

For large content work, architecture changes, batch ingest, website work, or broad lint/repair passes, use multi-agent collaboration by default when available.

Recommended roles:

- coordinator: owns scope, integration, final validation, and commit boundaries
- explorer: reads the repo or source set and reports facts without editing
- ingester/worker: performs a bounded write task with clear file ownership
- verifier: checks lint, public/private boundaries, generated outputs, and likely regressions

Agents must have disjoint write scopes when multiple workers edit in parallel.
The coordinator must integrate results and avoid staging unrelated local changes.

## Local CC / Claude Code Partner Policy

For coding work, use the local Claude Code partners as a strict threshold-based multi-agent system when the task is non-trivial. Codex is the supervisor, integrator, and only writer; Opus and Sonnet are read-only partners.

| Agent | Model | Primary role | May edit files | May commit/push |
| --- | --- | --- | --- | --- |
| Codex Coordinator | current Codex session | orchestration, integration, file edits, tests, staging, commits, pushes, wiki memory | yes | yes |
| Opus Reviewer | `claude-opus-4-7` via `D:\cc\cc.cmd` | deep code review, complex reasoning, architecture, security/privacy, high-risk design calls | no | no |
| Sonnet Scanner | `claude-sonnet-4-6` via `D:\cc\cc.cmd` | quick diff scans, test suggestions, doc/README reading, routine second-pass checks | no | no |

Forced thresholds:

- Invoke Opus for architecture decisions, cross-module or multi-file refactors, API/schema/data migration work, security/privacy-sensitive changes, hard debugging after a first failed pass, and high-risk final diff audits.
- Invoke Sonnet for quick scans of low-risk diffs, test-gap suggestions, documentation reading/summarization, and routine "second set of eyes" checks.
- If Opus and Sonnet triggers both match, Opus wins.
- Escalate from Sonnet to Opus when the Sonnet output reports uncertainty, a possible blocker, cross-module reasoning, architectural tradeoffs, or security/privacy risk.
- Lightweight exemptions are allowed only for spelling fixes, one-line comments, tiny wiki/log/catalog corrections that do not alter operating rules, pure formatting inspection with no behavioral impact, or when the user explicitly asks not to use a partner.

Partner prompt contract:

- Before any `cc` family call, run a PixelCat preflight: check whether `127.0.0.1:8990` is listening. If it is not listening, launch the visible PixelCat management panel from `D:\cc\pixelcat-app.exe`, wait briefly, and re-check the port before retrying `cc`.
- Every `cc` call must be non-interactive with `-p` and include `AUTHORIZATION`, `ROLE`, `MODEL`, `REPO`, `SCOPE`, `QUESTION`, `CONSTRAINTS`, `OUTPUT FORMAT`, and `ESCALATION SIGNALS`.
- Constraints must state that the partner is read-only, must not edit files, must not run destructive commands, and must not handle credentials or live account actions.
- Codex must independently verify partner claims against the live repository before editing, testing, staging, committing, or pushing.
- If `cc` fails, hangs, returns unusable output, or PixelCat still cannot be started, Codex may continue without it, but must state the limitation when it materially affects risk or validation.
- OpenCode is not part of this multi-agent coding workflow.

See [[local-cc-sidecar-agent-workflow|local CC partner workflow]] for the maintained public wiki version of this workflow.

## Research Ideation Policy

When the user asks for research ideas, paper positioning, method design, or project strategy:

- Do not merely stitch together existing projects, baselines, papers, or modules.
- Treat existing repositories as context, not a cage.
- When the user uses abstract or general terms about projects or research direction, broaden the search before answering: inspect multiple relevant mainstream GitHub projects, top-conference papers, official project pages, benchmark repos, and strong implementation patterns for inspiration, and read the relevant files or sections deeply enough to understand the operating pattern before adapting anything.
- Do not copy designs, text, code, or claims from those references; extract transferable mechanisms, evaluation ideas, interaction patterns, and failure lessons, then synthesize an original direction.
- Prefer original problem reframing, sharper claims, new experimental axes, and stronger mechanisms over incremental feature mixing.
- Be willing to recommend major changes to a project's thesis, method, protocol, or architecture when the evidence suggests the current framing is weak.
- Preserve evidence discipline: radical ideas still need falsifiable claims, baselines, ablations, failure modes, and reviewer-grade objections.
- Separate speculative invention from extracted project facts.

## Commit Policy

- After creating or updating durable wiki content, stage and commit the related changes before ending the turn.
- After structural, script, or website changes, make scoped commits by concern when practical and push to GitHub by default.
- After wiki automations or scheduled/local crawl workflows create or update raw manifests, source pages, analysis pages, catalog files, logs, or indexes, validate the results, stage the scoped automation outputs, commit them, and push by default.
- After periodic README refreshes, stage the README plus any required wiki/index/log/catalog updates, commit them as scoped maintenance, and push by default.
- If automation leaves files marked modified but `git diff`/hash checks show no real content changes, refresh the index or normalize the false dirty state instead of creating a meaningless commit, and report that there was no substantive diff to commit.
- Keep commits scoped to the saved wiki work and its required index/log updates.
- Do not stage unrelated local changes unless the user explicitly asks for them.

## Lint Workflow

When asked to health-check the wiki, look for:

- contradictions across pages
- stale claims superseded by newer sources
- orphan pages with weak linking
- concepts/entities that are mentioned often but lack dedicated pages
- missing source attribution
- overly large pages that should split
- duplicate, low-value, misleading, or superseded pages that should be merged, rewritten, archived, or proposed for deletion
- gaps that suggest useful future sources
- public pages that mention `raw/private-*` or `wiki-private/`

Record meaningful lint results in `wiki/analyses/` and add a `lint` entry to the log. When the fix is clear and low-risk, perform non-destructive maintenance instead of only reporting it. Any actual deletion of information requires explicit user approval first.

Operational scripts may be used when helpful:

- `scripts/wiki-status.ps1`
- `scripts/wiki-lint.ps1`
- `scripts/wiki-graph.ps1`

## Writing Style

- Write concise, information-dense markdown.
- Prefer explicit claims over vague summary language.
- Separate facts, interpretations, and open questions.
- Preserve uncertainty.
- Use headings and bullet lists liberally when they improve scanability.
- Avoid fluff.

## Log Format

Use this heading format for each entry in `wiki/log.md`:

`## [YYYY-MM-DD HH:MM] operation | title`

Where `operation` is one of:

- `ingest`
- `query`
- `analysis`
- `lint`
- `bootstrap`

Each entry should include:

- pages created or updated
- source(s) used
- a short note on what changed

## Index Expectations

`wiki/index.md` should remain easy to skim.
Each listed page should include:

- page link
- one-line description
- last updated date when useful

Keep index organization stable unless the wiki's scale clearly requires a redesign.

## Purpose Alignment

Before substantial ingest or synthesis work, consult `purpose.md` so that the wiki grows toward the user's real long-term goals instead of becoming a random archive.
## Public Person Corpus Workflow

When the user asks for a complete public corpus using phrases such as full GitHub, all projects, all public releases, all papers, or recurring updates, treat it as a durable public-corpus ingest request.

- First disambiguate same-name people before crawling.
- Create separate entity pages, manifests, raw directories, and source pages for distinct identities.
- Use stable IDs and semantic hashes to prevent duplicate captures and noisy commits.
- Use safe public indexing: metadata, summaries, links, hashes, categories, and license notes; do not publicly mirror unclear-license full PDFs, source code, or long webpage text.
- Add/update automation so future agents rerun the ingest, validate, commit scoped changes, and push.
- Treat automation outputs as durable wiki maintenance, not scratch files: if a run changes manifests, source pages, analyses, catalog, index, or log, commit and push those scoped changes after validation.
- See [[public-corpus-ingest-workflow]] for the maintained wiki version of this workflow.
