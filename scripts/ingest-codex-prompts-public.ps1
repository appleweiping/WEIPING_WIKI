param(
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$SkipValidation,
    [int]$SinceDays = 0
)

$ErrorActionPreference = "Stop"
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }

$env:VIPIN_WIKI_ROOT = $rootPath
$env:CODEX_PROMPT_HOME = $codexHome
$env:CODEX_PROMPT_DRY_RUN = if ($DryRun) { "1" } else { "0" }
$env:CODEX_PROMPT_SKIP_VALIDATION = if ($SkipValidation) { "1" } else { "0" }
$env:CODEX_PROMPT_SINCE_DAYS = [string]$SinceDays

$python = @'
import hashlib
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone, timedelta
from pathlib import Path

try:
    import tomllib
except Exception:
    tomllib = None

ROOT = Path(os.environ["VIPIN_WIKI_ROOT"]).resolve()
CODEX_HOME = Path(os.environ["CODEX_PROMPT_HOME"]).resolve()
DRY_RUN = os.environ.get("CODEX_PROMPT_DRY_RUN") == "1"
SKIP_VALIDATION = os.environ.get("CODEX_PROMPT_SKIP_VALIDATION") == "1"
SINCE_DAYS = int(os.environ.get("CODEX_PROMPT_SINCE_DAYS") or "0")
NOW = datetime.now(timezone.utc)
TODAY = NOW.date().isoformat()

RAW_DIR = ROOT / "raw" / "codex-prompts-public"
INBOX_DIR = RAW_DIR / "inbox"
WIKI_SOURCE_DIR = ROOT / "wiki" / "sources" / "codex-prompts"
TOPIC_PATH = ROOT / "wiki" / "topics" / "codex-prompt-corpus.md"
TAXONOMY_PATH = ROOT / "wiki" / "analyses" / "codex-prompt-taxonomy.md"
MANIFEST_PATH = RAW_DIR / "manifest.json"
INDEX_PATH = ROOT / "wiki" / "index.md"
LOG_PATH = ROOT / "wiki" / "log.md"

MIN_CHARS = 160
MAX_PROMPT_CHARS = 24000

CATEGORY_RULES = [
    ("automation", ["automation", "定时", "cron", "schedule", "weekly", "daily", "run the", "commit", "push"]),
    ("wiki-ingest", ["wiki", "ingest", "manifest", "raw/", "catalog", "lint", "语料", "收录"]),
    ("research-workflow", ["research", "paper", "experiment", "baseline", "reviewer", "reproducible", "顶会", "论文"]),
    ("coding-agent-workflow", ["implement", "repo", "tests", "pytest", "github", "gitlab", "agent", "codex"]),
    ("project-strategy", ["plan", "roadmap", "strategy", "scope", "项目", "框架", "方案"]),
    ("personal-rules", ["记住", "preference", "rule", "以后", "不要", "必须", "喜欢"]),
    ("prompt-engineering-pattern", ["prompt", "instructions", "system", "role", "workflow", "persona"]),
]

SECRET_PATTERNS = [
    re.compile(r"sk-[A-Za-z0-9_-]{20,}"),
    re.compile(r"gh[pousr]_[A-Za-z0-9_]{20,}"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"(?i)(password|passwd|secret|api[_-]?key|token)\s*[:=]\s*[\"']?[A-Za-z0-9_./+=-]{8,}"),
    re.compile(r"(?im)^\s*[^@\s]+@[\w.-]+(?:'s)?\s+password:\s*$"),
]

SENSITIVE_PATTERNS = [
    re.compile(r"(?i)\bstudent\s*id\b"),
    re.compile(r"(?i)\bdate\s+of\s+birth\b|\bDOB\b"),
    re.compile(r"(?i)\baddress\b"),
    re.compile(r"(?i)\bphone\s*(number)?\b"),
    re.compile(r"(?i)\bemail\s+address\b"),
    re.compile(r"(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"),
]

MOJIBAKE_MARKERS = [
    chr(code) for code in [
        0x951B, 0x9428, 0x6D63, 0x9418, 0x9368, 0x7023, 0x9207, 0x6DC7,
        0x6793, 0x9414, 0x95B8, 0x7F01, 0x9853, 0x9854, 0x6D51, 0x6D63,
        0x6D63, 0x95BA, 0x9355, 0x9208, 0x6D63, 0x5A34, 0x6D93, 0x7039,
    ]
]

HARNESS_PREFIXES = (
    "# AGENTS.md instructions",
    "<environment_context>",
    "<permissions instructions>",
    "<skills_instructions>",
    "<plugins_instructions>",
    "<collaboration_mode>",
)

def sha(text: str, n: int = 64) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="ignore")).hexdigest()[:n]

def normalize_text(text: str) -> str:
    text = text.replace("\ufeff", "")
    text = re.sub(r"\r\n?", "\n", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{4,}", "\n\n\n", text)
    return text.strip()

def semantic_normalize(text: str) -> str:
    text = normalize_text(text).lower()
    text = re.sub(r"\d{4}-\d{2}-\d{2}[t ][0-9:.\-+z]+", "<date>", text)
    text = re.sub(r"\b[0-9a-f]{24,}\b", "<hash>", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def strip_harness_texts(parts):
    kept = []
    for part in parts:
        text = part if isinstance(part, str) else part.get("text", "")
        if not text:
            continue
        stripped = text.lstrip()
        if any(stripped.startswith(prefix) for prefix in HARNESS_PREFIXES):
            continue
        text = re.sub(r"(?s)<environment_context>.*?</environment_context>", "", text)
        if text.strip():
            kept.append(text.strip())
    return normalize_text("\n\n".join(kept))

def has_cjk(text: str) -> bool:
    return any(0x4E00 <= ord(c) <= 0x9FFF for c in text)

def useful_char_ratio(text: str) -> float:
    visible = [c for c in text if not c.isspace()]
    if not visible:
        return 0.0
    useful = 0
    for c in visible:
        o = ord(c)
        if c.isalnum() or 0x4E00 <= o <= 0x9FFF or 0x3040 <= o <= 0x30FF:
            useful += 1
    return useful / len(visible)

def mojibake_marker_ratio(text: str) -> float:
    if not text:
        return 0.0
    if has_cjk(text):
        return 0.0
    hits = sum(text.count(marker) for marker in MOJIBAKE_MARKERS)
    return hits / max(len(text), 1)

def code_like_ratio(text: str) -> float:
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines:
        return 0.0
    code_like = 0
    for line in lines:
        if re.match(r"^(import |from |def |class |function |const |let |var |if \(|for \(|while \(|try:|except |Traceback|File \")", line):
            code_like += 1
        elif re.match(r"^(\{|\}|\[|\]|</?[A-Za-z][^>]*>|[A-Za-z0-9_./\\-]+:\d+:)", line):
            code_like += 1
        elif line.endswith(";") or line.count("{") + line.count("}") + line.count("=>") >= 2:
            code_like += 1
        elif re.match(r"^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}", line):
            code_like += 1
    return code_like / len(lines)

def has_secret(text: str) -> bool:
    return any(pattern.search(text) for pattern in SECRET_PATTERNS)

def has_sensitive_personal_data(text: str) -> bool:
    hits = sum(1 for pattern in SENSITIVE_PATTERNS if pattern.search(text))
    return hits >= 1 and any(anchor in text.lower() for anchor in ["student", "date of birth", "address", "phone", "email"])

def looks_like_terminal_paste(text: str) -> bool:
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines:
        return False
    prompt_lines = sum(1 for line in lines if re.search(r"(^|\s)(PS\s+[A-Z]:\\[^>]*>|(?:\([^)]+\)\s*)?[\w.-]+@[\w.-]+:[^$#>]*[\$#])", line))
    command_lines = sum(1 for line in lines if re.match(r"^(cd |scp |tar |python |find |grep |sha256sum |mkdir |Get-Item|Select-Object|[A-Z_]+\\?=)", line))
    error_lines = sum(1 for line in lines if re.search(r"(No such file or directory|CategoryInfo|FullyQualifiedErrorId|Traceback|Exception|Error opening archive|Get-Item\s*:|scp\.exe:|tar\.exe:)", line, re.IGNORECASE))
    path_heavy = sum(1 for line in lines if len(re.findall(r"([A-Za-z]:\\|~/|/[\w.-]+/|outputs/|\.tar\.gz|\.jsonl|\.csv|\.pt|\.npy)", line)) >= 2)
    terminal_score = prompt_lines * 3 + command_lines + error_lines * 2 + path_heavy
    return terminal_score >= 5 or (prompt_lines >= 2 and (command_lines + error_lines + path_heavy) >= 2)

def rejection_reason(text: str) -> str | None:
    if not text or len(text) < MIN_CHARS:
        return "too_short"
    if text.startswith("# AGENTS.md instructions") or text.startswith("<environment_context>"):
        return "harness_context"
    if "\ufffd" in text and text.count("\ufffd") / max(len(text), 1) > 0.002:
        return "replacement_character_noise"
    if mojibake_marker_ratio(text) > 0.003 or sum(1 for marker in MOJIBAKE_MARKERS if marker in text) >= 3:
        return "mojibake_or_encoding_noise"
    useful = useful_char_ratio(text)
    code_ratio = code_like_ratio(text)
    if useful < 0.52:
        return "high_symbol_or_gibberish_ratio"
    if looks_like_terminal_paste(text):
        return "terminal_or_server_paste"
    if re.search(r"(?im)^\[[^\]]*(official|baseline|proex|promax|elmrec)[^\]]*\]\s+epoch=\d+.*train_loss=", text):
        return "training_log_paste"
    if code_ratio > 0.58:
        return "mostly_code_or_logs"
    if has_secret(text):
        return "secret_like"
    if has_sensitive_personal_data(text):
        return "sensitive_personal_data"
    if re.search(r"(raw/private|wiki-private|auth\.json|id_rsa|medical record|passport)", text, re.IGNORECASE):
        return "private_or_sensitive_boundary"
    return None

def categorize(text: str) -> str:
    lower = text.lower()
    scores = {}
    for category, keywords in CATEGORY_RULES:
        scores[category] = sum(1 for keyword in keywords if keyword.lower() in lower)
    best, score = max(scores.items(), key=lambda kv: kv[1])
    return best if score else "general-high-quality-prompt"

def title_from_text(text: str, fallback: str) -> str:
    first = re.sub(r"^[#\s>*-]+", "", text.strip().splitlines()[0] if text.strip().splitlines() else fallback)
    first = re.sub(r"\s+", " ", first).strip()
    if len(first) > 80:
        first = first[:77].rstrip() + "..."
    return first or fallback

def slug_for(entry) -> str:
    return entry["stable_id"].replace(":", "-").replace("/", "-").replace("_", "-").lower()

def markdown_escape_code(text: str) -> str:
    fence = "```"
    if "```" in text:
        fence = "````"
    return f"{fence}text\n{text}\n{fence}"

def write_if_changed(path: Path, text: str) -> bool:
    text = text.replace("\r\n", "\n").rstrip() + "\n"
    if path.exists():
        old = path.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n")
        if old == text:
            return False
    if not DRY_RUN:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8", newline="\n")
    return True

def read_existing_manifest():
    if not MANIFEST_PATH.exists():
        return {}, None
    try:
        data = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        return {entry.get("stable_id"): entry for entry in data.get("entries", []) if entry.get("stable_id")}, data
    except Exception:
        return {}, None

def extract_session_prompts():
    candidates = []
    files = []
    for base in [CODEX_HOME / "sessions", CODEX_HOME / "archived_sessions"]:
        if base.exists():
            files.extend(base.rglob("*.jsonl"))
    cutoff = NOW - timedelta(days=SINCE_DAYS) if SINCE_DAYS > 0 else None
    for path in sorted(files):
        if cutoff and datetime.fromtimestamp(path.stat().st_mtime, timezone.utc) < cutoff:
            continue
        session_id = None
        for line_number, line in enumerate(path.read_text(encoding="utf-8", errors="replace").splitlines(), start=1):
            try:
                obj = json.loads(line)
            except Exception:
                continue
            payload = obj.get("payload") or {}
            if obj.get("type") == "session_meta":
                session_id = payload.get("id") or session_id
                continue
            if obj.get("type") != "response_item":
                continue
            if payload.get("type") != "message" or payload.get("role") != "user":
                continue
            parts = []
            for item in payload.get("content") or []:
                if isinstance(item, dict) and item.get("type") == "input_text":
                    parts.append(item.get("text", ""))
                elif isinstance(item, str):
                    parts.append(item)
            text = strip_harness_texts(parts)
            if not text:
                continue
            timestamp = obj.get("timestamp") or payload.get("timestamp")
            candidates.append({
                "source_kind": "codex-session-user",
                "source_path": str(path),
                "source_line": line_number,
                "session_id": session_id or path.stem,
                "timestamp": timestamp or datetime.fromtimestamp(path.stat().st_mtime, timezone.utc).isoformat(),
                "text": text,
            })
    return candidates

def parse_toml_prompt(path: Path):
    raw = path.read_text(encoding="utf-8", errors="replace")
    if tomllib is not None:
        try:
            data = tomllib.loads(raw)
            return data.get("prompt"), data
        except Exception:
            pass
    match = re.search(r'(?ms)^prompt\s*=\s*"((?:\\.|[^"\\])*)"', raw)
    if not match:
        return None, {}
    try:
        return bytes(match.group(1), "utf-8").decode("unicode_escape"), {}
    except Exception:
        return match.group(1), {}

def extract_automation_prompts():
    candidates = []
    automation_root = CODEX_HOME / "automations"
    if not automation_root.exists():
        return candidates
    for toml_path in sorted(automation_root.glob("*/automation.toml")):
        prompt, data = parse_toml_prompt(toml_path)
        if not prompt:
            continue
        automation_id = data.get("id") if isinstance(data, dict) else toml_path.parent.name
        candidates.append({
            "source_kind": "codex-automation",
            "source_path": str(toml_path),
            "automation_id": automation_id or toml_path.parent.name,
            "timestamp": datetime.fromtimestamp(toml_path.stat().st_mtime, timezone.utc).isoformat(),
            "text": normalize_text(prompt),
        })
    return candidates

old_by_id, old_manifest = read_existing_manifest()
selected = []
rejected = []
seen_semantic = set()
for candidate in extract_session_prompts() + extract_automation_prompts():
    text = candidate["text"]
    normalized = semantic_normalize(text)
    semantic_hash = sha(normalized)
    reason = rejection_reason(text)
    if semantic_hash in seen_semantic:
        reason = reason or "duplicate_semantic_hash"
    if reason:
        rejected.append({
            "source_kind": candidate.get("source_kind"),
            "source_path": candidate.get("source_path"),
            "timestamp": candidate.get("timestamp"),
            "reason": reason,
            "semantic_hash": semantic_hash,
            "length": len(text),
            "preview": "",
        })
        continue
    seen_semantic.add(semantic_hash)
    if candidate["source_kind"] == "codex-automation":
        stable_id = f"codex-automation-prompt:{candidate.get('automation_id')}"
    else:
        stable_id = f"codex-user-prompt:{semantic_hash[:16]}"
    category = categorize(text)
    selected.append({
        "stable_id": stable_id,
        "dedupe_key": semantic_hash,
        "semantic_hash": semantic_hash,
        "source_kind": candidate.get("source_kind"),
        "source_path": candidate.get("source_path"),
        "source_line": candidate.get("source_line"),
        "session_id": candidate.get("session_id"),
        "automation_id": candidate.get("automation_id"),
        "timestamp": candidate.get("timestamp"),
        "category": category,
        "title": title_from_text(text, stable_id),
        "length": len(text),
        "public_handling": "public-fulltext-selected-redact-secrets",
        "text": text[:MAX_PROMPT_CHARS],
        "truncated": len(text) > MAX_PROMPT_CHARS,
    })

selected = sorted(selected, key=lambda e: (e.get("category") or "", e.get("timestamp") or "", e["stable_id"]))
entries_for_manifest = []
for entry in selected:
    public_entry = {k: v for k, v in entry.items() if k != "text"}
    public_entry["wiki_path"] = f"wiki/sources/codex-prompts/{slug_for(entry)}.md"
    entries_for_manifest.append(public_entry)

new_hash = sha(json.dumps(entries_for_manifest, ensure_ascii=False, sort_keys=True))
old_hash = (old_manifest or {}).get("semantic_hash")
has_semantic_change = new_hash != old_hash

changed_paths = []
for entry in selected:
    path = WIKI_SOURCE_DIR / f"{slug_for(entry)}.md"
    body = f"""---
title: {entry['title'].replace(':', ' -')}
type: source
status: active
created: {TODAY}
updated: {TODAY}
tags:
  - source
  - codex-prompts
  - {entry['category']}
source_pages:
  - codex-prompt-corpus
---

# {entry['title']}

## Metadata

- Stable ID: `{entry['stable_id']}`
- Source kind: `{entry['source_kind']}`
- Category: `{entry['category']}`
- Timestamp: `{entry.get('timestamp') or 'unknown'}`
- Semantic hash: `{entry['semantic_hash']}`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

{markdown_escape_code(entry['text'])}

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
"""
    if write_if_changed(path, body):
        changed_paths.append(str(path.relative_to(ROOT)))

by_category = defaultdict(list)
for entry in selected:
    by_category[entry["category"]].append(entry)

def index_lines_for_entries(entries):
    lines = []
    for entry in entries:
        lines.append(f"- [[sources/codex-prompts/{slug_for(entry)}|{entry['title']}]] - `{entry['stable_id']}`")
    return lines

topic_lines = [
    "---",
    "title: Codex Prompt Corpus",
    "type: topic",
    "status: active",
    f"created: {TODAY}",
    f"updated: {TODAY}",
    "tags:",
    "  - topic",
    "  - codex-prompts",
    "---",
    "",
    "# Codex Prompt Corpus",
    "",
    "## Summary",
    "",
    "This corpus preserves high-quality user-authored Codex prompts and automation prompts as reusable prompt engineering material.",
    "",
    "## Selection Rules",
    "",
    "- EXTRACTED: Include user prompts and automation prompts that are substantive, clean, reusable, and not mostly code/log output.",
    "- EXTRACTED: Exclude short prompts, duplicates, mojibake/noise, pasted stack traces, server logs, source-code dumps, and secret-like/private material.",
    "- EXTRACTED: Public pages may include full selected prompt text, but only after safety filtering.",
    "",
    "## Current Counts",
    "",
    f"- Selected prompts: `{len(selected)}`",
    f"- Rejected candidates: `{len(rejected)}`",
    f"- Manifest: `raw/codex-prompts-public/manifest.json`",
    "",
    "## Categories",
    "",
]
for category in sorted(by_category):
    topic_lines += [f"### {category}", ""]
    topic_lines.extend(index_lines_for_entries(by_category[category]))
    topic_lines.append("")
topic_lines += [
    "## Sources",
    "",
    "- EXTRACTED: Raw manifest and capture metadata are stored under `raw/codex-prompts-public/`.",
    "- EXTRACTED: Source material comes from local Codex session JSONL files and local Codex automation TOML files.",
    "",
    "## Counterpoints and Gaps",
    "",
    "- AMBIGUOUS: Local session encodings can be messy; future runs should continue filtering mojibake, terminal paste, and sensitive personal data aggressively.",
    "- INFERRED: Full-text prompt preservation is useful only for selected reusable prompts; rejected candidates should remain raw audit metadata, not public pages.",
    "",
    "## Related",
    "",
    "- [[codex-prompt-taxonomy]]",
    "- [[index]]",
    "- [[log]]",
]
if write_if_changed(TOPIC_PATH, "\n".join(topic_lines)):
    changed_paths.append(str(TOPIC_PATH.relative_to(ROOT)))

taxonomy_lines = [
    "---",
    "title: Codex Prompt Taxonomy",
    "type: analysis",
    "status: active",
    f"created: {TODAY}",
    f"updated: {TODAY}",
    "tags:",
    "  - analysis",
    "  - codex-prompts",
    "source_pages:",
    "  - codex-prompt-corpus",
    "---",
    "",
    "# Codex Prompt Taxonomy",
    "",
    "## Category Map",
    "",
    "| Category | Count | What It Captures |",
    "| --- | ---: | --- |",
]
descriptions = {
    "automation": "Long-running scheduled tasks, commit rules, validation gates, and scoped update behavior.",
    "wiki-ingest": "Source capture, manifest design, stable IDs, semantic hashes, and wiki maintenance rules.",
    "research-workflow": "Research direction, experiments, baselines, reviewer gates, and non-toy project standards.",
    "coding-agent-workflow": "Repository implementation tasks, testing, Git hygiene, and agent execution constraints.",
    "project-strategy": "Planning, roadmaps, architecture choices, and project framing.",
    "personal-rules": "User preferences and durable operating rules future agents should remember.",
    "prompt-engineering-pattern": "Reusable prompt structures, role design, and instruction scaffolds.",
    "general-high-quality-prompt": "Selected prompts that pass quality filters but do not fit a narrower bucket.",
}
for category in sorted(by_category):
    taxonomy_lines.append(f"| {category} | {len(by_category[category])} | {descriptions.get(category, 'Selected high-quality prompt material.')} |")
taxonomy_lines += [
    "",
    "## Reusable Patterns",
    "",
    "- EXTRACTED: Strong prompts usually define role, source boundaries, filtering rules, validation commands, commit policy, and explicit non-goals.",
    "- EXTRACTED: Automation prompts should specify scoped staging paths and no-noisy-commit behavior.",
    "- INFERRED: The highest-value prompts are those that encode judgment, acceptance criteria, and future-agent memory rather than one-off commands.",
    "",
    "## Noise Boundaries",
    "",
    "- Do not preserve short chat fragments, copied code blobs, traceback/log dumps, garbled text, secrets, or private material as public prompt pages.",
    "- Keep rejected candidate metadata in raw manifest/inbox for audit without creating public full-text pages.",
    "",
    "## Sources",
    "",
    "- EXTRACTED: Counts and categories come from `raw/codex-prompts-public/manifest.json`.",
    "- EXTRACTED: The selected prompt pages link back to [[codex-prompt-corpus]].",
    "",
    "## Counterpoints and Gaps",
    "",
    "- AMBIGUOUS: Prompt quality is partly judgment-based; future runs should prefer false negatives over public exposure of noisy or sensitive prompts.",
    "- INFERRED: This taxonomy should stay compact even as the underlying prompt pages grow.",
    "",
    "## Related",
    "",
    "- [[codex-prompt-corpus]]",
]
if write_if_changed(TAXONOMY_PATH, "\n".join(taxonomy_lines)):
    changed_paths.append(str(TAXONOMY_PATH.relative_to(ROOT)))

manifest = {
    "generated_at": NOW.isoformat(),
    "corpus": "codex-prompts-public",
    "semantic_hash": new_hash,
    "entry_count": len(entries_for_manifest),
    "rejected_count": len(rejected),
    "filters": {
        "min_chars": MIN_CHARS,
        "scope": "user prompts and automation prompts",
        "excluded": ["short", "duplicate", "mostly_code_or_logs", "gibberish", "secret_like", "private_or_sensitive"],
    },
    "entries": entries_for_manifest,
}
if write_if_changed(MANIFEST_PATH, json.dumps(manifest, ensure_ascii=False, indent=2)):
    changed_paths.append(str(MANIFEST_PATH.relative_to(ROOT)))

capture = {
    "generated_at": NOW.isoformat(),
    "selected": selected,
    "rejected": rejected[:1000],
}
capture_path = INBOX_DIR / f"{TODAY}-capture.json"
if has_semantic_change and write_if_changed(capture_path, json.dumps(capture, ensure_ascii=False, indent=2)):
    changed_paths.append(str(capture_path.relative_to(ROOT)))

def ensure_index_link():
    if not INDEX_PATH.exists():
        return False
    text = INDEX_PATH.read_text(encoding="utf-8", errors="replace")
    addition = "\n### Codex Prompt Corpus\n\n- [[codex-prompt-corpus]] - High-quality selected local Codex prompts and automation prompts for reuse.\n- [[codex-prompt-taxonomy]] - Category map and filtering rules for the Codex prompt corpus.\n"
    addition += "\n#### Codex Prompt Sources\n\n"
    addition += "\n".join(index_lines_for_entries(selected))
    addition += "\n"
    if "[[codex-prompt-corpus]]" in text:
        if "#### Codex Prompt Sources" in text:
            return False
        return write_if_changed(INDEX_PATH, text.rstrip() + "\n" + "\n#### Codex Prompt Sources\n\n" + "\n".join(index_lines_for_entries(selected)))
    return write_if_changed(INDEX_PATH, text.rstrip() + "\n" + addition)

if ensure_index_link():
    changed_paths.append("wiki/index.md")

if has_semantic_change:
    log_entry = f"""
## [{datetime.now().strftime('%Y-%m-%d %H:%M')}] ingest | codex prompt corpus

- Pages created or updated:
  - [[codex-prompt-corpus]]
  - [[codex-prompt-taxonomy]]
  - [[index]]
- Sources used:
  - Local Codex session JSONL files
  - Local Codex automation TOML files
- Notes:
  - Selected `{len(selected)}` high-quality user/automation prompts and rejected `{len(rejected)}` noisy or unsafe candidates.
  - Preserved full selected prompt text only after filtering out short, garbled, code/log-like, duplicate, and secret-like material.
"""
    old_log = LOG_PATH.read_text(encoding="utf-8", errors="replace") if LOG_PATH.exists() else ""
    if write_if_changed(LOG_PATH, old_log.rstrip() + "\n" + log_entry):
        changed_paths.append("wiki/log.md")

print(json.dumps({
    "dry_run": DRY_RUN,
    "codex_home": str(CODEX_HOME),
    "selected": len(selected),
    "rejected": len(rejected),
    "semantic_changed": has_semantic_change,
    "changed_paths": changed_paths,
    "manifest": str(MANIFEST_PATH.relative_to(ROOT)),
}, ensure_ascii=False, indent=2))
'@

$python | python -
if (-not $DryRun -and -not $SkipValidation) {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath "scripts/wiki-catalog.ps1") -Root $rootPath
    & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath "scripts/wiki-lint.ps1") -Root $rootPath
}
