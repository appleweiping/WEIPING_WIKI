param(
    [string]$Root = ".",
    [switch]$DryRun,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$env:VIPIN_WIKI_ROOT = $rootPath
$env:WEEKLY_RESEARCH_DRY_RUN = if ($DryRun) { "1" } else { "0" }

$python = @'
import hashlib
import html
import json
import os
import re
import ssl
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(os.environ["VIPIN_WIKI_ROOT"]).resolve()
DRY_RUN = os.environ.get("WEEKLY_RESEARCH_DRY_RUN") == "1"
NOW = datetime.now(timezone.utc)
TODAY = NOW.date().isoformat()
ISO = NOW.isocalendar()
WEEK_ID = f"{ISO.year}-W{ISO.week:02d}"

RAW_DIR = ROOT / "raw" / "weekly-research-digests"
INBOX_DIR = RAW_DIR / "inbox"
MANIFEST_PATH = RAW_DIR / "manifest.json"
TOPIC_PATH = ROOT / "wiki" / "topics" / "weekly-research-digests.md"
ANALYSIS_PATH = ROOT / "wiki" / "analyses" / f"weekly-research-digest-{WEEK_ID.lower()}.md"
SOURCE_DIR = ROOT / "wiki" / "sources" / "weekly-research-digests"
INDEX_PATH = ROOT / "wiki" / "index.md"
LOG_PATH = ROOT / "wiki" / "log.md"

CATEGORIES = [
    {
        "slug": "ai",
        "label": "AI",
        "queries": ["AI agents planning reasoning", "agentic AI benchmark", "multimodal AI agents"],
        "required_any": ["agent", "artificial intelligence", "multimodal", "reasoning", "planning"],
        "github": "AI agents framework language:Python pushed:>2026-01-01",
        "official": ["https://ai.googleblog.com/", "https://openai.com/news/research/"],
    },
    {
        "slug": "llm",
        "label": "LLM",
        "queries": ["large language models inference reasoning", "LLM alignment evaluation", "long context large language model"],
        "required_any": ["language model", "llm", "transformer", "inference", "alignment"],
        "github": "large language model inference stars:>100 pushed:>2026-01-01",
        "official": ["https://openai.com/research/", "https://www.anthropic.com/research"],
    },
    {
        "slug": "llm4rec",
        "label": "LLM4Rec",
        "queries": ["large language model recommender systems", "generative recommendation large language model", "LLM4Rec sequential recommendation"],
        "required_any": ["recommend", "recommender", "recommendation", "llm4rec", "ranking"],
        "required_all_groups": [
            ["recommend", "recommender", "recommendation", "ranking", "sequential recommendation"],
            ["llm", "language model", "large language model", "generative"]
        ],
        "github": "LLM recommender system stars:>10 pushed:>2025-01-01",
        "official": ["https://paperswithcode.com/task/recommendation-systems"],
    },
    {
        "slug": "ai4eda-analog",
        "label": "AI4EDA analog circuit design",
        "queries": ["analog circuit design machine learning", "LLM analog circuit design", "AI EDA analog circuit sizing", "operational amplifier sizing reinforcement learning"],
        "required_any": ["analog circuit", "circuit design", "circuit sizing", "eda", "electronic design automation", "spice", "op-amp", "operational amplifier", "transistor"],
        "fallback": {
            "kind": "paper",
            "source": "semantic-scholar",
            "source_id": "semantic-scholar:bcfd6404ad1c913b915d1f7731d3bc69564d98e7",
            "title": "AnalogCoder: Analog Circuit Design via Training-Free Code Generation",
            "abstract": "Analog circuit design is a significant task in modern chip technology, focusing on selecting component types, connectivity, and parameters to ensure circuit functionality. This fallback is used when public APIs are rate-limited or fail to return a current domain-qualified AI4EDA item.",
            "url": "https://www.semanticscholar.org/paper/bcfd6404ad1c913b915d1f7731d3bc69564d98e7",
            "published": "2024-05-23",
            "authors": [],
        },
        "github": "analog circuit design machine learning stars:>5 pushed:>2024-01-01",
        "official": ["https://mlcad-workshop.org/", "https://www.dac.com/"],
    },
    {
        "slug": "ai4s-protein",
        "label": "AI4S protein/biology",
        "queries": ["protein design language model", "protein diffusion model", "AI for science protein engineering", "protein engineering generative model"],
        "required_any": ["protein", "enzyme", "amino acid", "biolog", "bio", "molecule", "sequence design"],
        "github": "protein design language model stars:>50 pushed:>2025-01-01",
        "official": ["https://www.nature.com/subjects/protein-design", "https://www.biorxiv.org/"],
    },
]

try:
    import certifi
    SSL_CONTEXT = ssl.create_default_context(cafile=certifi.where())
except Exception:
    SSL_CONTEXT = ssl._create_unverified_context()

def sha(text: str, n: int = 64) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="ignore")).hexdigest()[:n]

def clean(text: str) -> str:
    text = html.unescape(text or "")
    text = "".join(ch for ch in text if not (0x1F000 <= ord(ch) <= 0x1FAFF))
    text = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f]", "", text)
    return re.sub(r"\s+", " ", text).strip()

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

def add_index_line(text: str, heading: str, line: str) -> str:
    if line in text:
        return text
    marker = heading + "\n"
    if marker not in text:
        return text.rstrip() + "\n\n" + heading + "\n\n" + line + "\n"
    return text.replace(marker, marker + "\n" + line + "\n", 1)

def fetch_json(url, headers=None, timeout=25):
    req = urllib.request.Request(url, headers=headers or {"User-Agent": "vipin-wiki-weekly-digest/1.0"})
    with urllib.request.urlopen(req, timeout=timeout, context=SSL_CONTEXT) as response:
        return json.loads(response.read().decode("utf-8", errors="replace"))

def fetch_text(url, headers=None, timeout=25):
    req = urllib.request.Request(url, headers=headers or {"User-Agent": "vipin-wiki-weekly-digest/1.0"})
    with urllib.request.urlopen(req, timeout=timeout, context=SSL_CONTEXT) as response:
        return response.read().decode("utf-8", errors="replace")

def arxiv_candidates(category):
    out = []
    ns = {"a": "http://www.w3.org/2005/Atom", "arxiv": "http://arxiv.org/schemas/atom"}
    for query in category["queries"]:
        url = "https://export.arxiv.org/api/query?" + urllib.parse.urlencode({
            "search_query": "all:" + query,
            "start": 0,
            "max_results": 8,
            "sortBy": "submittedDate",
            "sortOrder": "descending",
        })
        try:
            xml = fetch_text(url)
            root = ET.fromstring(xml)
        except Exception as exc:
            out.append({"kind": "error", "source": "arxiv", "query": query, "error": str(exc)})
            continue
        for entry in root.findall("a:entry", ns):
            title = clean(entry.findtext("a:title", default="", namespaces=ns))
            summary = clean(entry.findtext("a:summary", default="", namespaces=ns))
            published = clean(entry.findtext("a:published", default="", namespaces=ns))
            link = ""
            for link_el in entry.findall("a:link", ns):
                if link_el.attrib.get("rel") == "alternate":
                    link = link_el.attrib.get("href", "")
            arxiv_id = link.rstrip("/").split("/")[-1] if link else sha(title, 12)
            authors = [clean(a.findtext("a:name", default="", namespaces=ns)) for a in entry.findall("a:author", ns)][:6]
            out.append({
                "kind": "paper",
                "source": "arxiv",
                "title": title,
                "abstract": summary,
                "url": link,
                "published": published,
                "authors": authors,
                "source_id": f"arxiv:{arxiv_id}",
                "query": query,
            })
        time.sleep(0.35)
    return out

def semantic_scholar_candidates(category):
    out = []
    for query in category["queries"][:2]:
        url = "https://api.semanticscholar.org/graph/v1/paper/search?" + urllib.parse.urlencode({
            "query": query,
            "limit": 8,
            "fields": "title,abstract,year,citationCount,url,authors,externalIds,publicationDate",
        })
        try:
            data = fetch_json(url)
        except Exception as exc:
            out.append({"kind": "error", "source": "semantic-scholar", "query": query, "error": str(exc)})
            continue
        for paper in data.get("data", []) or []:
            title = clean(paper.get("title", ""))
            abstract = clean(paper.get("abstract", ""))
            if not title or not abstract:
                continue
            external = paper.get("externalIds") or {}
            source_id = f"semantic-scholar:{paper.get('paperId') or sha(title, 16)}"
            if external.get("ArXiv"):
                source_id = f"arxiv:{external['ArXiv']}"
            out.append({
                "kind": "paper",
                "source": "semantic-scholar",
                "title": title,
                "abstract": abstract,
                "url": paper.get("url") or "",
                "published": paper.get("publicationDate") or str(paper.get("year") or ""),
                "authors": [a.get("name", "") for a in paper.get("authors", [])[:6]],
                "citation_count": int(paper.get("citationCount") or 0),
                "source_id": source_id,
                "query": query,
            })
        time.sleep(0.35)
    return out

def github_candidates(category):
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    headers = {
        "User-Agent": "vipin-wiki-weekly-digest/1.0",
        "Accept": "application/vnd.github+json",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    url = "https://api.github.com/search/repositories?" + urllib.parse.urlencode({
        "q": category["github"],
        "sort": "stars",
        "order": "desc",
        "per_page": 5,
    })
    out = []
    try:
        data = fetch_json(url, headers=headers)
    except Exception as exc:
        return [{"kind": "error", "source": "github", "query": category["github"], "error": str(exc)}]
    for repo in data.get("items", []) or []:
        full = repo.get("full_name") or ""
        desc = clean(repo.get("description") or "")
        out.append({
            "kind": "repository",
            "source": "github",
            "title": full,
            "abstract": desc,
            "url": repo.get("html_url") or "",
            "published": repo.get("pushed_at") or repo.get("updated_at") or "",
            "authors": [repo.get("owner", {}).get("login", "")],
            "stars": int(repo.get("stargazers_count") or 0),
            "source_id": f"github:{full}",
            "query": category["github"],
            "language": repo.get("language"),
            "topics": repo.get("topics") or [],
        })
    return out

def fallback_candidate(category):
    fallback = category.get("fallback")
    if not fallback:
        return None
    item = dict(fallback)
    item["fallback"] = True
    return item

def load_old_ids():
    if not MANIFEST_PATH.exists():
        return set(), {}
    try:
        data = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
        return {e.get("stable_id") for e in data.get("entries", [])}, data
    except Exception:
        return set(), {}

def relevance_score(item, category):
    text = f"{item.get('title','')} {item.get('abstract','')}".lower()
    required = category.get("required_any") or []
    if required and not any(term.lower() in text for term in required):
        return -999
    for group in category.get("required_all_groups") or []:
        if not any(term.lower() in text for term in group):
            return -999
    query_terms = set()
    for query in category["queries"]:
        query_terms.update(re.findall(r"[a-zA-Z0-9]+", query.lower()))
    hit = sum(1 for term in query_terms if len(term) > 2 and term in text)
    signal = 0
    if item.get("source") == "arxiv":
        signal += 20
    if item.get("source") == "semantic-scholar":
        signal += 15 + min(int(item.get("citation_count") or 0), 100) / 5
    if item.get("source") == "github":
        signal += 10 + min(int(item.get("stars") or 0), 5000) / 100
    if "survey" in text or "benchmark" in text or "dataset" in text:
        signal += 4
    if any(word in text for word in ["agent", "reasoning", "protein", "recommend", "circuit", "analog", "language model"]):
        signal += 4
    return round(signal + hit * 2 + min(len(item.get("abstract", "")) / 120, 10), 2)

def plain_summary(item, category):
    abstract = item.get("abstract") or ""
    first_sentence = re.split(r"(?<=[.!?])\s+", abstract)[0] if abstract else ""
    if len(first_sentence) > 260:
        first_sentence = first_sentence[:257].rstrip() + "..."
    if not first_sentence:
        first_sentence = "Repository or source metadata suggests an active project related to this track."
    return first_sentence

def why_it_matters(item, category):
    label = category["label"]
    if category["slug"] == "llm4rec":
        return "Useful for grounding recommendation research in current LLM/recommender evidence rather than toy baselines."
    if category["slug"] == "ai4eda-analog":
        return "Useful for analog-design automation ideas, circuit constraints, and non-toy AI4EDA evaluation thinking."
    if category["slug"] == "ai4s-protein":
        return "Useful for protein/design workflows where generative models need wet-lab-aware constraints and validation."
    if category["slug"] == "llm":
        return "Useful for updating LLM reasoning, evaluation, inference, or alignment assumptions used by agents."
    return f"Useful for keeping the broader {label} map current and finding transferable agent mechanisms."

def agent_reuse(item, category):
    if item.get("kind") == "repository":
        return "Inspect repo structure, README tasks, evaluation scripts, and issue/release patterns before borrowing mechanisms."
    return "Extract problem framing, method components, evaluation axes, limitations, and candidate baselines; do not copy prose."

old_ids, old_manifest = load_old_ids()
all_evidence = {}
picked = []
errors = []
for category in CATEGORIES:
    candidates = []
    for fn in (arxiv_candidates, semantic_scholar_candidates, github_candidates):
        batch = fn(category)
        errors.extend([x | {"category": category["slug"]} for x in batch if x.get("kind") == "error"])
        candidates.extend([x for x in batch if x.get("kind") != "error" and x.get("title")])
    scored = []
    seen = set()
    for item in candidates:
        stable = f"weekly-research:{category['slug']}:{sha(item.get('source_id') or item.get('title',''), 20)}"
        if stable in seen:
            continue
        seen.add(stable)
        item["stable_id"] = stable
        item["category"] = category["slug"]
        item["category_label"] = category["label"]
        item["signal_score"] = relevance_score(item, category)
        if item["signal_score"] < 0:
            continue
        item["semantic_hash"] = sha(json.dumps({
            "title": item.get("title"),
            "abstract": item.get("abstract"),
            "url": item.get("url"),
            "published": item.get("published"),
        }, ensure_ascii=False, sort_keys=True))
        item["plain_core"] = plain_summary(item, category)
        item["why_it_matters"] = why_it_matters(item, category)
        item["agent_reuse"] = agent_reuse(item, category)
        scored.append(item)
    scored.sort(key=lambda x: x.get("signal_score", 0), reverse=True)
    if not scored:
        fallback = fallback_candidate(category)
        if fallback:
            fallback["stable_id"] = f"weekly-research:{category['slug']}:{sha(fallback.get('source_id') or fallback.get('title',''), 20)}"
            fallback["category"] = category["slug"]
            fallback["category_label"] = category["label"]
            fallback["signal_score"] = 25
            fallback["semantic_hash"] = sha(json.dumps({
                "title": fallback.get("title"),
                "abstract": fallback.get("abstract"),
                "url": fallback.get("url"),
                "published": fallback.get("published"),
            }, ensure_ascii=False, sort_keys=True))
            fallback["plain_core"] = plain_summary(fallback, category)
            fallback["why_it_matters"] = why_it_matters(fallback, category)
            fallback["agent_reuse"] = agent_reuse(fallback, category) + " This is a fallback pick because live sources did not return a domain-qualified fresh item."
            scored.append(fallback)
    all_evidence[category["slug"]] = scored[:20]
    selected = scored[0] if scored else None
    if selected:
        picked.append(selected)

manifest_entries = []
for item in picked:
    manifest_entries.append({k: item.get(k) for k in [
        "stable_id", "category", "category_label", "source", "kind", "source_id", "title", "url",
        "published", "semantic_hash", "signal_score", "plain_core", "why_it_matters", "agent_reuse"
    ]})

manifest_hash = sha(json.dumps(manifest_entries, ensure_ascii=False, sort_keys=True))
old_hash = (old_manifest or {}).get("latest_digest_hash")
semantic_changed = manifest_hash != old_hash
changed = []

for item in picked:
    page = SOURCE_DIR / f"{WEEK_ID.lower()}-{item['category']}.md"
    text = f"""---
title: {WEEK_ID} {item['category_label']} Research Pick
type: source
status: active
created: {TODAY}
updated: {TODAY}
tags:
  - source
  - weekly-research
  - {item['category']}
source_pages:
  - weekly-research-digests
---

# {WEEK_ID} {item['category_label']} Research Pick

## Pick

- Title: [{item['title']}]({item.get('url') or ''})
- Source: `{item.get('source')}` / `{item.get('kind')}`
- Published or updated: `{item.get('published') or 'unknown'}`
- Signal score: `{item.get('signal_score')}`
- Stable ID: `{item['stable_id']}`
- Semantic hash: `{item['semantic_hash']}`

## Abstract Or Source Summary

{item.get('abstract') or item.get('plain_core')}

## Short Core Idea

{item['plain_core']}

## Why It Matters

{item['why_it_matters']}

## Agent Reuse Notes

{item['agent_reuse']}

## Related

- [[weekly-research-digests]]
- [[weekly-research-digest-{WEEK_ID.lower()}]]
"""
    if write_if_changed(page, text):
        changed.append(str(page.relative_to(ROOT)))

rows = []
for item in picked:
    rows.append(f"| {item['category_label']} | [{item['title']}]({item.get('url') or ''}) | {item.get('source')} | {item.get('published') or 'unknown'} | {item.get('signal_score')} | {item['plain_core']} |")

chart_lines = ["```mermaid", "xychart-beta", f'  title "{WEEK_ID} Research Pick Signal Scores"', '  x-axis ["AI", "LLM", "LLM4Rec", "AI4EDA", "AI4S"]', "  y-axis \"score\" 0 --> 100", "  bar [" + ", ".join(str(min(round(float(i.get("signal_score", 0)), 2), 100)) for i in picked) + "]", "```"]

analysis = f"""---
title: Weekly Research Digest {WEEK_ID}
type: analysis
status: active
created: {TODAY}
updated: {TODAY}
tags:
  - analysis
  - weekly-research
  - research-digest
source_pages:
  - weekly-research-digests
---

# Weekly Research Digest {WEEK_ID}

## Summary

This digest captures one high-signal weekly item for each track: AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.

## Picks

| Track | Pick | Source | Date | Score | Short Core |
| --- | --- | --- | --- | ---: | --- |
{chr(10).join(rows)}

## Signal Chart

{chr(10).join(chart_lines)}

## Agent Memory

"""
for item in picked:
    analysis += f"- **{item['category_label']}**: {item['agent_reuse']}\n"
analysis += "\n## Sources\n\n- EXTRACTED: Abstracts and metadata come from arXiv, Semantic Scholar, GitHub, and configured fallback public links where available.\n- EXTRACTED: Raw evidence and API errors are stored under `raw/weekly-research-digests/`.\n\n## Counterpoints and Gaps\n\n- AMBIGUOUS: API rate limits and search ranking can bias weekly picks toward repos or older fallback papers.\n- INFERRED: Treat each pick as an inspiration lead for agent recall, not as a final survey or citation-quality literature review.\n\n## Evidence Notes\n\n- EXTRACTED: Abstracts and metadata come from public scholarly/project APIs where available.\n- INFERRED: Signal scores combine source quality, topical match, recency/update signal, citations/stars when available, and reusable idea density.\n- Do not treat this digest as exhaustive literature review; use it as a weekly inspiration and routing layer.\n\n## Related\n\n- [[weekly-research-digests]]\n"
if write_if_changed(ANALYSIS_PATH, analysis):
    changed.append(str(ANALYSIS_PATH.relative_to(ROOT)))

topic = f"""---
title: Weekly Research Digests
type: topic
status: active
created: {TODAY}
updated: {TODAY}
tags:
  - topic
  - weekly-research
source_pages:
  - weekly-research-digest-{WEEK_ID.lower()}
---

# Weekly Research Digests

## Purpose

Weekly research digests preserve current, high-signal inspiration across five tracks: AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.

## Current Digest

- [[weekly-research-digest-{WEEK_ID.lower()}]] - {WEEK_ID} weekly picks.

## Current Source Pages

{chr(10).join(f"- [[sources/weekly-research-digests/{WEEK_ID.lower()}-{item['category']}|{item['category_label']} pick]] - {item['title']}" for item in picked)}

## Operating Rules

- EXTRACTED: Each weekly run should pick one item per track, with abstract/source summary, plain-language core idea, link, signal score, and agent reuse note.
- EXTRACTED: Sources should include papers, GitHub projects, and official/public research surfaces where available.
- EXTRACTED: Automations should run in the afternoon rather than early morning and use `gpt-5.5`.
- INFERRED: This corpus is for inspiration and agent recall, not final exhaustive literature review.

## Sources

- EXTRACTED: Weekly evidence manifests live under `raw/weekly-research-digests/`.
- EXTRACTED: Current source pages summarize public paper/project metadata and link to canonical public URLs.

## Counterpoints and Gaps

- AMBIGUOUS: Freshness and popularity signals can favor active GitHub repos over slower-moving papers.
- INFERRED: Future runs should keep the five-track balance even when one track has weak live evidence.

## Related

- [[index]]
- [[log]]
"""
if write_if_changed(TOPIC_PATH, topic):
    changed.append(str(TOPIC_PATH.relative_to(ROOT)))

old_entries = (old_manifest or {}).get("entries", [])
combined = {e.get("stable_id"): e for e in old_entries if e.get("stable_id")}
for e in manifest_entries:
    combined[e["stable_id"]] = e
manifest = {
    "generated_at": NOW.isoformat(),
    "corpus": "weekly-research-digests",
    "latest_week": WEEK_ID,
    "latest_digest_hash": manifest_hash,
    "entry_count": len(combined),
    "latest_entries": manifest_entries,
    "errors": errors[:50],
    "entries": sorted(combined.values(), key=lambda x: (x.get("category", ""), x.get("published", ""), x.get("stable_id", ""))),
}
if write_if_changed(MANIFEST_PATH, json.dumps(manifest, ensure_ascii=False, indent=2)):
    changed.append(str(MANIFEST_PATH.relative_to(ROOT)))

capture_path = INBOX_DIR / f"{WEEK_ID.lower()}-evidence.json"
capture = {"generated_at": NOW.isoformat(), "week": WEEK_ID, "picked": picked, "evidence": all_evidence, "errors": errors}
if write_if_changed(capture_path, json.dumps(capture, ensure_ascii=False, indent=2)):
    changed.append(str(capture_path.relative_to(ROOT)))

if INDEX_PATH.exists():
    index_text = INDEX_PATH.read_text(encoding="utf-8", errors="replace")
    if "[[weekly-research-digests]]" not in index_text:
        addition = "\n### Weekly Research Digests\n\n- [[weekly-research-digests]] - Weekly AI/LLM/LLM4Rec/AI4EDA/AI4S inspiration picks.\n"
        if write_if_changed(INDEX_PATH, index_text.rstrip() + "\n" + addition):
            changed.append("wiki/index.md")
    else:
        new_index = index_text
        new_index = add_index_line(new_index, "## Topics", "- [[weekly-research-digests]] - Weekly AI/LLM/LLM4Rec/AI4EDA/AI4S inspiration picks.")
        new_index = add_index_line(new_index, "## Analyses", f"- [[weekly-research-digest-{WEEK_ID.lower()}]] - {WEEK_ID} weekly AI, LLM, LLM4Rec, AI4EDA, and AI4S inspiration digest.")
        for item in picked:
            new_index = add_index_line(new_index, "## Sources", f"- [[sources/weekly-research-digests/{WEEK_ID.lower()}-{item['category']}]] - {WEEK_ID} {item['category_label']} research pick.")
        if write_if_changed(INDEX_PATH, new_index):
            changed.append("wiki/index.md")

if semantic_changed:
    old_log = LOG_PATH.read_text(encoding="utf-8", errors="replace") if LOG_PATH.exists() else ""
    log = f"""
## [{datetime.now().strftime('%Y-%m-%d %H:%M')}] ingest | weekly research inspiration digest

- Pages created or updated:
  - [[weekly-research-digests]]
  - [[weekly-research-digest-{WEEK_ID.lower()}]]
  - [[index]]
- Sources used:
  - arXiv API
  - Semantic Scholar API
  - GitHub repository search API
- Notes:
  - Captured one high-signal item each for AI, LLM, LLM4Rec, AI4EDA analog circuit design, and AI4S protein/biology.
  - Stored abstracts/source summaries, links, plain-language core ideas, signal scores, and agent reuse notes.
"""
    if write_if_changed(LOG_PATH, old_log.rstrip() + "\n" + log):
        changed.append("wiki/log.md")

print(json.dumps({
    "dry_run": DRY_RUN,
    "week": WEEK_ID,
    "picked": len(picked),
    "semantic_changed": semantic_changed,
    "errors": len(errors),
    "changed_paths": changed,
    "manifest": str(MANIFEST_PATH.relative_to(ROOT)),
}, ensure_ascii=False, indent=2))
'@

$python | python -
if (-not $DryRun -and -not $SkipValidation) {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath "scripts/wiki-catalog.ps1") -Root $rootPath
    & powershell -ExecutionPolicy Bypass -File (Join-Path $rootPath "scripts/wiki-lint.ps1") -Root $rootPath
}
