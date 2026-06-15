"""distill.py — owner prompt-pattern distiller (Feature A). Advisory, human-gated.

Reads the prompts the OWNER actually typed to his coding agents, clusters them into
recurring task-types, and emits an advisory pattern table so agents stop re-deriving
how to do the same kind of work. It NEVER auto-applies behavior and NEVER copies
secret-bearing or verbatim prompt bodies into any durable file.

Sources (most-trusted first):
  1. C:\\Users\\admin\\.claude\\history.jsonl  — line {"display": <verbatim prompt>, "project", "timestamp"}
  2. C:\\Users\\admin\\.claude\\sessions\\*.json — messages[].blocks[].text (role==user); PID stubs skipped

Safety (hard):
  * redact() drops any turn carrying a secret signature, then scrubs paths/digits/tokens.
  * Clustering + the durable output use ONLY normalized leading clauses, never full bodies.
  * Default mode is dry-run (writes .wiki-tmp only). --apply is the only writer of the
    durable, human-curated table, and it MERGES (never clobbers pinned/edited rows).

The owner writes mostly Chinese, so clustering is by a BILINGUAL intent-signal table
(editable below), not whitespace verb+object tokens. Pure stdlib.
"""
from __future__ import annotations

import json
import os
import re
from collections import Counter, defaultdict
from datetime import datetime, timedelta
from pathlib import Path

CLAUDE_HISTORY = Path(os.environ.get("WIKI_CLAUDE_HISTORY", r"C:\Users\admin\.claude\history.jsonl"))
CLAUDE_SESSIONS = Path(os.environ.get("WIKI_CLAUDE_SESSIONS", r"C:\Users\admin\.claude\sessions"))

# ── OWNER-EDITABLE: ordered intent signals (first match wins). Bilingual. ──────────
TASK_SIGNALS = [
    ("audit-cleanup",     ["审计", "整理", "清理", "垃圾", "audit", "cleanup", "clean up", "organize", "tidy"]),
    ("migrate-relocate",  ["迁移", "迁出", "搬", "移到", "挪", " move ", "migrate", "relocate"]),
    ("optimize-upgrade",  ["优化", "改进", "升级", "增强", "optimize", "improve", "upgrade", "refactor", "polish"]),
    ("deploy-publish",    ["部署", "上线", "发布", "deploy", "publish", "vercel", "ship", "release"]),
    ("research-paper",    ["科研", "论文", "实验", "baseline", "sota", "paper", "experiment", "ablation", "rebuttal"]),
    ("frontend-ui",       ["前端", "界面", "网页", "frontend", " ui ", "css", "quartz", "网站", "样式"]),
    ("skill-memory",      ["skill", "memory", "蒸馏", "提示词", "prompt", "distill", "技能", "记忆"]),
    ("review-adversarial",["review", "审查", "对抗", "复核", "审核", "code review", "评审"]),
    ("image-banner",      ["banner", "封面", "配图", "image_gen", "海报", "logo", "图标"]),
    ("summarize",         ["总结", "复盘", "summary", "summarize", "归纳", "梳理"]),
    ("translate",         ["翻译", "translate", "中译", "英译", "translation"]),
    ("debug-fix",         ["报错", "修复", "debug", " fix ", "排查", "失败", "traceback", "崩"]),
    ("test-verify",       ["测试", " test", "单元测试", "验证", "verify", "pytest"]),
    ("git-commit",        ["commit", "push", "提交", "推送", "pull request", " pr "]),
    ("multi-agent",       ["多agent", "并行", "parallel", "workflow", "分身", "对抗讨论", "subagent"]),
    ("research-ideation", ["idea", "想法", "点子", "positioning", "方法设计", "创新", "选题"]),
]

SUGGESTED_SKILL = {
    "audit-cleanup": "workstation-maintenance",
    "skill-memory": "skill-creator",
    "frontend-ui": "frontend-design",
    "research-paper": "aris (research)",
    "review-adversarial": "code-review",
    "image-banner": "imagegen",
    "multi-agent": "superpowers:dispatching-parallel-agents",
}

# ── Privacy ───────────────────────────────────────────────────────────────────────
SECRET_PATTERNS = [re.compile(p) for p in (
    r"sk-[A-Za-z0-9]{16,}", r"gh[ps]_[A-Za-z0-9]{20,}", r"AKIA[0-9A-Z]{16}",
    r"xox[baprs]-", r"-----BEGIN [A-Z ]*PRIVATE KEY-----", r"Bearer [A-Za-z0-9._-]{20,}",
    r"password\s*[:=]", r"BensonHalefdo@theplate\.com",
    r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",
)]
_PATH_RE = re.compile(r"[A-Za-z]:\\[^\s\"'，。]+|(?<![\w])/(?:home|users|mnt|[a-z])/[^\s\"'，。]+", re.I)
_DIGIT_RE = re.compile(r"\d{6,}")
_TOKEN_RE = re.compile(r"\b[A-Za-z0-9+/=_-]{32,}\b")
NOISE_PREFIXES = ("<system-reminder>", "[request interrupted", "this session is being continued",
                  "caveat:", "<command-name>", "<command-message>", "<local-command-stdout>",
                  "<ide_opened_file>", "<user-prompt-submit-hook>")


def redact(text: str) -> str | None:
    """Return scrubbed text, or None if the whole turn must be dropped (secret signature)."""
    for pat in SECRET_PATTERNS:
        if pat.search(text):
            return None
    text = _PATH_RE.sub("<path>", text)
    text = _TOKEN_RE.sub("<token>", text)   # before digits: a long token may contain digit runs
    text = _DIGIT_RE.sub("<n>", text)
    return text


def _clean(s: str) -> str | None:
    s = (s or "").strip()
    if len(s) < 8 or s.startswith("/") or re.fullmatch(r"[\W_]+", s):
        return None
    return s


def _is_noise_block(t: str) -> bool:
    tl = t.strip().lower()
    return any(tl.startswith(p) for p in NOISE_PREFIXES) or "tool_result" in t or "tool_use_id" in t


def _parse_ts(ts) -> datetime | None:
    if ts is None:
        return None
    try:
        if isinstance(ts, (int, float)) or (isinstance(ts, str) and ts.isdigit()):
            v = float(ts)
            if v > 1e12:
                v /= 1000.0
            return datetime.fromtimestamp(v)
        return datetime.fromisoformat(str(ts).replace("Z", "+00:00")).replace(tzinfo=None)
    except (ValueError, OSError, OverflowError):
        return None


def _short_proj(p) -> str:
    if not p:
        return ""
    return str(p).replace("\\", "/").rstrip("/").rsplit("/", 1)[-1]


def _leading_clause(text: str, limit: int = 60) -> str:
    seg = re.split(r"[。！？!?\n.,，；;]", text.strip(), maxsplit=1)[0]
    seg = re.sub(r"\s+", " ", seg).strip()
    return seg[:limit]


def classify_intent(text: str) -> str:
    low = text.lower()
    for name, sigs in TASK_SIGNALS:
        if any(s in low for s in sigs):
            return name
    return "other"


def iter_history(path: Path | None = None):
    path = path or CLAUDE_HISTORY
    if not path.exists():
        return
    try:
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    o = json.loads(line)
                except ValueError:
                    continue
                c = _clean(o.get("display"))
                if c:
                    yield {"text": c, "project": o.get("project"), "ts": o.get("timestamp")}
    except OSError:
        return


def iter_sessions(d: Path | None = None):
    d = d or CLAUDE_SESSIONS
    if not d.exists():
        return
    for fp in sorted(d.glob("*.json")):
        try:
            o = json.loads(fp.read_text(encoding="utf-8"))
        except (OSError, ValueError):
            continue
        msgs = o.get("messages")
        if not isinstance(msgs, list):  # PID stub / lock file
            continue
        for m in msgs:
            if not isinstance(m, dict) or m.get("role") != "user":
                continue
            for b in (m.get("blocks") or []):
                t = b.get("text") if isinstance(b, dict) else None
                if isinstance(t, str) and not _is_noise_block(t):
                    c = _clean(t)
                    if c:
                        yield {"text": c, "project": o.get("project") or o.get("cwd"),
                               "ts": o.get("timestamp")}


def distill(min_count: int = 4, since_days: int = 180) -> dict:
    cutoff = datetime.now() - timedelta(days=since_days)
    sources, extracted, dropped = {}, 0, 0
    clusters: dict[str, dict] = defaultdict(
        lambda: {"count": 0, "projects": Counter(), "first": None, "last": None, "examples": []})
    for name, it in (("history.jsonl", iter_history()), ("sessions", iter_sessions())):
        n = 0
        for turn in (it or ()):
            n += 1
            ts = _parse_ts(turn.get("ts"))
            if ts and ts < cutoff:
                continue
            red = redact(turn["text"])
            if red is None:
                dropped += 1
                continue
            extracted += 1
            key = classify_intent(red)
            c = clusters[key]
            c["count"] += 1
            if turn.get("project"):
                c["projects"][_short_proj(turn["project"])] += 1
            raw = turn.get("ts")
            if raw is not None:
                s = str(raw)
                if c["first"] is None or s < str(c["first"]):
                    c["first"] = raw
                if c["last"] is None or s > str(c["last"]):
                    c["last"] = raw
            if len(c["examples"]) < 3:
                c["examples"].append(_leading_clause(red))
        sources[name] = n
    out = []
    for key, c in clusters.items():
        if c["count"] < min_count:
            continue
        out.append({
            "pattern_key": key, "count": c["count"],
            "first_seen": c["first"], "last_seen": c["last"],
            "top_projects": [p for p, _ in c["projects"].most_common(3)],
            "suggested_skill": SUGGESTED_SKILL.get(key, ""),
            "example_clauses": c["examples"],
        })
    out.sort(key=lambda x: -x["count"])
    return {"sources_read": sources, "turns_extracted": extracted,
            "turns_dropped_redacted": dropped, "min_count": min_count,
            "since_days": since_days, "clusters": out}


# ── Output ─────────────────────────────────────────────────────────────────────────
_COLS = ["pattern_key", "count", "last_seen", "top_projects", "suggested_skill",
         "canonical_prompt", "pinned"]


def _parse_existing_table(md: str) -> dict[str, dict]:
    """Parse prior rows so --apply preserves human-edited canonical_prompt / pinned."""
    rows: dict[str, dict] = {}
    for line in md.splitlines():
        if not line.strip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < len(_COLS) or cells[0] in ("pattern_key", "---") or set(cells[0]) <= {"-", " ", ":"}:
            continue
        row = dict(zip(_COLS, cells))
        if row["pattern_key"] and row["pattern_key"] != "pattern_key":
            rows[row["pattern_key"]] = row
    return rows


def render_apply(result: dict, prior_md: str = "") -> str:
    prior = _parse_existing_table(prior_md)
    by_key = {c["pattern_key"]: c for c in result["clusters"]}
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    lines = [
        "---",
        "title: Distilled task patterns (owner prompt corpus)",
        "type: preference",
        "privacy: redacted-clauses-only",
        f"updated: {now}",
        "tags: [prompt-pattern, distilled, advisory]",
        "---",
        "",
        "<!-- Generated by `python scripts/wiki.py distill --apply`. ADVISORY + human-curated.",
        "     No verbatim prompt bodies, no secrets. Edit `canonical_prompt`; set `pinned` = yes to",
        "     keep a row across regenerations. Agents: skim for a matching pattern; NEVER auto-apply. -->",
        "",
        "| " + " | ".join(_COLS) + " |",
        "|" + "|".join(["---"] * len(_COLS)) + "|",
    ]
    keys = list(by_key) + [k for k in prior if k not in by_key]  # new first, then pinned-only survivors
    for key in keys:
        old = prior.get(key, {})
        new = by_key.get(key)
        pinned = old.get("pinned", "") or ""
        if new is None:
            if pinned.lower() not in ("yes", "true", "1"):
                continue  # drop stale rows unless human-pinned
            row = old
        else:
            row = {
                "pattern_key": key,
                "count": str(new["count"]),
                "last_seen": str(new.get("last_seen") or old.get("last_seen", "")),
                "top_projects": ", ".join(new["top_projects"]) or old.get("top_projects", ""),
                "suggested_skill": new["suggested_skill"] or old.get("suggested_skill", ""),
                # preserve human edits
                "canonical_prompt": old.get("canonical_prompt", "") or "",
                "pinned": pinned,
            }
        lines.append("| " + " | ".join(str(row.get(c, "")) for c in _COLS) + " |")
    lines += ["", f"_Corpus: {result['turns_extracted']} owner turns "
              f"({result['turns_dropped_redacted']} dropped by redaction); "
              f"sources {result['sources_read']}; min_count={result['min_count']}._", ""]
    return "\n".join(lines)
