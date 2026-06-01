"""
wiki-tokens.py — Agent token usage tracker for Vipin's Knowledgebase.

Records, aggregates, and reports token consumption across all agents.
Integrates with the agent performance dashboard and wiki health page.

Token data sources:
  1. Manual log entries (via `log` command)
  2. Anthropic/OpenAI API response headers (if available)
  3. Optional legacy metrics file supplied explicitly with VIPIN_LEGACY_METRICS_FILE

Storage: D:\\devtools\\agentmemory\\state\\token-usage.json by default.

Usage:
    python scripts/wiki-tokens.py log --agent opus --tokens 12500 --task "paper review"
    python scripts/wiki-tokens.py report                    # terminal report
    python scripts/wiki-tokens.py report --html             # generate HTML section
    python scripts/wiki-tokens.py report --json             # raw JSON
    python scripts/wiki-tokens.py summary                   # one-line summary
    python scripts/wiki-tokens.py reset --confirm           # clear all data
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from collections import defaultdict
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parent.parent
STATE_DIR = Path(os.environ.get("VIPIN_AGENT_TOKEN_STATE_DIR", r"D:\devtools\agentmemory\state"))
TOKEN_FILE = STATE_DIR / "token-usage.json"
LEGACY_METRICS_FILE = os.environ.get("VIPIN_LEGACY_METRICS_FILE")

# Model cost table (USD per 1M tokens, input/output)
MODEL_COSTS: dict[str, tuple[float, float]] = {
    "claude-opus-4-7":    (15.0,  75.0),
    "claude-opus-4":      (15.0,  75.0),
    "claude-sonnet-4-6":  (3.0,   15.0),
    "claude-sonnet-4-5":  (3.0,   15.0),
    "claude-haiku-4-5":   (0.8,   4.0),
    "claude-haiku-3.5":   (0.8,   4.0),
    "gpt-5.5":            (10.0,  30.0),
    "gpt-4o":             (2.5,   10.0),
    "deepseek-chat":      (0.14,  0.28),
    "deepseek-v4":        (0.14,  0.28),
}

AGENT_MODEL_MAP = {
    "claude": "claude-opus-4-7",
    "opus":   "claude-opus-4-7",
    "sonnet": "claude-sonnet-4-6",
    "haiku":  "claude-haiku-4-5",
    "codex":  "gpt-5.5",
    "opencode": "claude-opus-4-7",
    "deepseek": "deepseek-chat",
}

AGENT_DISPLAY = {
    "claude":   "Opus (Claude)",
    "opus":     "Opus",
    "codex":    "Codex (GPT-5.5)",
    "sonnet":   "Sonnet",
    "haiku":    "Haiku",
    "deepseek": "DeepSeek",
    "opencode": "OpenCode",
}

AGENT_COLORS = {
    "claude": "#5b8af5", "opus": "#a78bfa", "codex": "#22d3ee",
    "sonnet": "#4ade80", "haiku": "#fbbf24", "deepseek": "#f87171",
    "opencode": "#fb923c",
}


# ── Data model ─────────────────────────────────────────────────────────────────

@dataclass
class TokenEntry:
    id: str
    agent: str
    model: str
    input_tokens: int
    output_tokens: int
    task: str
    timestamp: str
    session: str = ""
    cost_usd: float = 0.0

    @property
    def total_tokens(self) -> int:
        return self.input_tokens + self.output_tokens


@dataclass
class AgentTokenStats:
    agent: str
    model: str
    total_input: int = 0
    total_output: int = 0
    total_cost_usd: float = 0.0
    entry_count: int = 0
    daily: dict[str, int] = field(default_factory=dict)  # date → total tokens

    @property
    def total_tokens(self) -> int:
        return self.total_input + self.total_output

    @property
    def avg_tokens_per_call(self) -> float:
        return self.total_tokens / self.entry_count if self.entry_count else 0.0


def compute_cost(agent: str, model: str, input_tokens: int, output_tokens: int) -> float:
    m = model or AGENT_MODEL_MAP.get(agent, "")
    costs = MODEL_COSTS.get(m, (0.0, 0.0))
    return (input_tokens * costs[0] + output_tokens * costs[1]) / 1_000_000


# ── Storage ────────────────────────────────────────────────────────────────────

def load_entries() -> list[TokenEntry]:
    if not TOKEN_FILE.exists():
        return []
    try:
        raw = json.loads(TOKEN_FILE.read_text(encoding="utf-8"))
        return [TokenEntry(**e) for e in raw.get("entries", [])]
    except Exception:
        return []


def save_entries(entries: list[TokenEntry]):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    data = {
        "version": "1.0",
        "updated": datetime.now(timezone.utc).isoformat(),
        "total_entries": len(entries),
        "entries": [asdict(e) for e in entries],
    }
    TOKEN_FILE.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def new_id() -> str:
    import hashlib, time
    return hashlib.sha256(str(time.time()).encode()).hexdigest()[:12]


# ── Metrics.json parsing ───────────────────────────────────────────────────────

def parse_metrics_for_tokens() -> list[TokenEntry]:
    """
    Parse an explicitly supplied legacy metrics file for token usage events.

    Agent Hub is retired, so this does not read any default Agent Hub path.
    Set VIPIN_LEGACY_METRICS_FILE to import old metrics for one-off analysis.
    """
    if not LEGACY_METRICS_FILE:
        return []
    metrics_file = Path(LEGACY_METRICS_FILE)
    if not metrics_file.exists():
        print(f"Warning: legacy metrics file not found: {metrics_file}", file=sys.stderr)
        return []
    try:
        raw = json.loads(metrics_file.read_text(encoding="utf-8"))
    except Exception:
        return []

    entries = []
    for e in raw.get("events", []):
        # Look for token usage in detail field
        detail = e.get("detail", "")
        agent = e.get("agent", "unknown")
        ts = e.get("timestamp", datetime.now(timezone.utc).isoformat())

        # Parse token counts from detail if present
        import re
        input_match = re.search(r"input[_\s]tokens?[:\s]+(\d+)", detail, re.IGNORECASE)
        output_match = re.search(r"output[_\s]tokens?[:\s]+(\d+)", detail, re.IGNORECASE)
        total_match = re.search(r"total[_\s]tokens?[:\s]+(\d+)", detail, re.IGNORECASE)

        if input_match or output_match or total_match:
            input_t = int(input_match.group(1)) if input_match else 0
            output_t = int(output_match.group(1)) if output_match else 0
            if total_match and not (input_t or output_t):
                total = int(total_match.group(1))
                input_t = int(total * 0.7)
                output_t = total - input_t

            model = AGENT_MODEL_MAP.get(agent, "")
            cost = compute_cost(agent, model, input_t, output_t)
            entries.append(TokenEntry(
                id=new_id(),
                agent=agent,
                model=model,
                input_tokens=input_t,
                output_tokens=output_t,
                task=e.get("event", ""),
                timestamp=ts,
                cost_usd=cost,
            ))

    return entries


# ── Aggregation ────────────────────────────────────────────────────────────────

def aggregate(entries: list[TokenEntry]) -> dict[str, AgentTokenStats]:
    stats: dict[str, AgentTokenStats] = {}
    for e in entries:
        if e.agent not in stats:
            model = e.model or AGENT_MODEL_MAP.get(e.agent, "")
            stats[e.agent] = AgentTokenStats(agent=e.agent, model=model)
        s = stats[e.agent]
        s.total_input += e.input_tokens
        s.total_output += e.output_tokens
        s.total_cost_usd += e.cost_usd
        s.entry_count += 1
        date = e.timestamp[:10]
        s.daily[date] = s.daily.get(date, 0) + e.total_tokens
    return stats


def total_stats(entries: list[TokenEntry]) -> dict:
    total_input = sum(e.input_tokens for e in entries)
    total_output = sum(e.output_tokens for e in entries)
    total_cost = sum(e.cost_usd for e in entries)
    # Last 7 days
    cutoff = (datetime.now(timezone.utc) - timedelta(days=7)).isoformat()
    recent = [e for e in entries if e.timestamp >= cutoff]
    return {
        "total_input_tokens": total_input,
        "total_output_tokens": total_output,
        "total_tokens": total_input + total_output,
        "total_cost_usd": round(total_cost, 4),
        "total_entries": len(entries),
        "last_7d_tokens": sum(e.total_tokens for e in recent),
        "last_7d_cost_usd": round(sum(e.cost_usd for e in recent), 4),
    }


# ── Terminal output ────────────────────────────────────────────────────────────

RESET = "\033[0m"; BOLD = "\033[1m"; DIM = "\033[2m"
GREEN = "\033[32m"; YELLOW = "\033[33m"; CYAN = "\033[36m"; RED = "\033[31m"

def c(*args):
    codes = [a for a in args if isinstance(a, str) and a.startswith("\033")]
    texts = [a for a in args if not (isinstance(a, str) and a.startswith("\033"))]
    return "".join(codes) + str(texts[0] if texts else "") + RESET

def hr(w=80): return c("─" * w, DIM)

def fmt_tokens(n: int) -> str:
    if n >= 1_000_000:
        return f"{n/1_000_000:.2f}M"
    if n >= 1_000:
        return f"{n/1_000:.1f}K"
    return str(n)

def fmt_cost(usd: float) -> str:
    if usd < 0.01:
        return f"{usd*100:.2f} cents"
    return f"${usd:.4f}"


def print_report(entries: list[TokenEntry], stats: dict[str, AgentTokenStats], totals: dict):
    now = datetime.now(timezone.utc)
    print(f"\n  {c('Token Usage Dashboard', BOLD, CYAN)}")
    print(c(f"  {now.strftime('%Y-%m-%d %H:%M UTC')}  ·  {totals['total_entries']} log entries", DIM))
    print(hr())

    print(f"\n  {c('Total', BOLD)}: {c(fmt_tokens(totals['total_tokens']), CYAN)} tokens  "
          f"{c(fmt_cost(totals['total_cost_usd']), YELLOW)}  "
          f"(last 7d: {c(fmt_tokens(totals['last_7d_tokens']), CYAN)} / "
          f"{c(fmt_cost(totals['last_7d_cost_usd']), YELLOW)})")

    print(f"\n  {c('Per-Agent Breakdown', BOLD)}\n")
    print(f"  {'Agent':<18} {'Total':<10} {'Input':<10} {'Output':<10} {'Cost':<12} {'Calls':<8} {'Avg/call'}")
    print(f"  {'─'*18} {'─'*10} {'─'*10} {'─'*10} {'─'*12} {'─'*8} {'─'*10}")

    for agent_id in sorted(stats, key=lambda a: -stats[a].total_tokens):
        s = stats[agent_id]
        name = AGENT_DISPLAY.get(agent_id, agent_id)
        print(f"  {name:<18} {fmt_tokens(s.total_tokens):<10} "
              f"{fmt_tokens(s.total_input):<10} {fmt_tokens(s.total_output):<10} "
              f"{c(fmt_cost(s.total_cost_usd), YELLOW):<20} {s.entry_count:<8} "
              f"{fmt_tokens(int(s.avg_tokens_per_call))}")

    # Recent entries
    recent = sorted(entries, key=lambda e: e.timestamp, reverse=True)[:10]
    if recent:
        print(f"\n  {c('Recent Entries', BOLD)}\n")
        for e in recent:
            ts = e.timestamp[:16].replace("T", " ")
            name = AGENT_DISPLAY.get(e.agent, e.agent)
            task = e.task[:40] + "…" if len(e.task) > 40 else e.task
            print(f"  {c(ts, DIM)}  {c(name, BOLD):<20}  "
                  f"{c(fmt_tokens(e.total_tokens), CYAN):<10}  "
                  f"{c(fmt_cost(e.cost_usd), YELLOW):<12}  {c(task, DIM)}")
    print()


# ── HTML generation ────────────────────────────────────────────────────────────

def generate_html_section(entries: list[TokenEntry],
                           stats: dict[str, AgentTokenStats],
                           totals: dict) -> str:
    """Generate a self-contained HTML section for embedding in the dashboard."""
    now = datetime.now(timezone.utc)

    agent_rows = ""
    for agent_id in sorted(stats, key=lambda a: -stats[a].total_tokens):
        s = stats[agent_id]
        name = AGENT_DISPLAY.get(agent_id, agent_id)
        color = AGENT_COLORS.get(agent_id, "#888")
        pct = s.total_tokens / max(totals["total_tokens"], 1)
        bar_w = int(pct * 100)
        agent_rows += f"""
        <tr>
          <td><span class="dot" style="background:{color}"></span>{name}</td>
          <td>{fmt_tokens(s.total_tokens)}</td>
          <td>{fmt_tokens(s.total_input)}</td>
          <td>{fmt_tokens(s.total_output)}</td>
          <td style="color:#fbbf24">{fmt_cost(s.total_cost_usd)}</td>
          <td>{s.entry_count}</td>
          <td>
            <div class="bar-wrap">
              <div class="bar-fill" style="width:{bar_w}%;background:{color}"></div>
            </div>
          </td>
        </tr>"""

    recent_rows = ""
    for e in sorted(entries, key=lambda x: x.timestamp, reverse=True)[:15]:
        ts = e.timestamp[:16].replace("T", " ")
        name = AGENT_DISPLAY.get(e.agent, e.agent)
        color = AGENT_COLORS.get(e.agent, "#888")
        task = e.task[:50] + "…" if len(e.task) > 50 else e.task
        recent_rows += f"""
        <tr>
          <td class="dim">{ts}</td>
          <td><span class="dot" style="background:{color}"></span>{name}</td>
          <td>{fmt_tokens(e.total_tokens)}</td>
          <td style="color:#fbbf24">{fmt_cost(e.cost_usd)}</td>
          <td class="dim small">{task}</td>
        </tr>"""

    return f"""<div id="token-dashboard">
<style>
#token-dashboard{{background:#111318;border:1px solid #222736;border-radius:10px;padding:20px;margin-bottom:16px;font-family:'Inter',system-ui,sans-serif;font-size:14px;color:#dde2f0}}
#token-dashboard h2{{font-size:14px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:#dde2f0;margin-bottom:16px}}
#token-dashboard .summary-grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:10px;margin-bottom:20px}}
#token-dashboard .stat-card{{background:#0b0d12;border:1px solid #222736;border-radius:8px;padding:12px}}
#token-dashboard .stat-val{{font-size:22px;font-weight:700;color:#5b8af5}}
#token-dashboard .stat-label{{font-size:11px;color:#636d94;margin-top:2px}}
#token-dashboard table{{width:100%;border-collapse:collapse}}
#token-dashboard th{{text-align:left;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:#636d94;padding:6px 8px;border-bottom:1px solid #222736}}
#token-dashboard td{{padding:7px 8px;border-bottom:1px solid #1c2030;font-size:13px}}
#token-dashboard tr:last-child td{{border-bottom:none}}
#token-dashboard .dot{{display:inline-block;width:7px;height:7px;border-radius:50%;margin-right:6px}}
#token-dashboard .bar-wrap{{display:inline-block;width:60px;height:5px;background:#1c2030;border-radius:3px;vertical-align:middle}}
#token-dashboard .bar-fill{{height:100%;border-radius:3px}}
#token-dashboard .dim{{color:#636d94}}
#token-dashboard .small{{font-size:12px}}
#token-dashboard .updated{{font-size:11px;color:#636d94;margin-top:12px}}
</style>

<h2>🔢 Token Usage</h2>

<div class="summary-grid">
  <div class="stat-card"><div class="stat-val">{fmt_tokens(totals['total_tokens'])}</div><div class="stat-label">Total Tokens</div></div>
  <div class="stat-card"><div class="stat-val" style="color:#fbbf24">{fmt_cost(totals['total_cost_usd'])}</div><div class="stat-label">Total Cost</div></div>
  <div class="stat-card"><div class="stat-val">{fmt_tokens(totals['last_7d_tokens'])}</div><div class="stat-label">Last 7 Days</div></div>
  <div class="stat-card"><div class="stat-val" style="color:#fbbf24">{fmt_cost(totals['last_7d_cost_usd'])}</div><div class="stat-label">7-Day Cost</div></div>
</div>

<table>
  <tr><th>Agent</th><th>Total</th><th>Input</th><th>Output</th><th>Cost</th><th>Calls</th><th>Share</th></tr>
  {agent_rows}
</table>

<br>
<h2>Recent Entries</h2>
<table>
  <tr><th>Time</th><th>Agent</th><th>Tokens</th><th>Cost</th><th>Task</th></tr>
  {recent_rows}
</table>

<div class="updated">Updated {now.strftime('%Y-%m-%d %H:%M UTC')} · <code>python scripts/wiki-tokens.py report --html</code></div>
</div>"""


# ── Commands ───────────────────────────────────────────────────────────────────

def cmd_log(args):
    entries = load_entries()
    model = args.model or AGENT_MODEL_MAP.get(args.agent, "")
    input_t = args.input_tokens or int(args.tokens * 0.7)
    output_t = args.output_tokens or (args.tokens - input_t)
    cost = compute_cost(args.agent, model, input_t, output_t)

    entry = TokenEntry(
        id=new_id(),
        agent=args.agent,
        model=model,
        input_tokens=input_t,
        output_tokens=output_t,
        task=args.task or "",
        timestamp=datetime.now(timezone.utc).isoformat(),
        session=args.session or "",
        cost_usd=cost,
    )
    entries.append(entry)
    save_entries(entries)
    name = AGENT_DISPLAY.get(args.agent, args.agent)
    print(f"Logged: {name}  {fmt_tokens(entry.total_tokens)} tokens  {fmt_cost(cost)}")


def cmd_report(args):
    entries = load_entries()
    # Optional one-off import from an explicitly supplied legacy metrics file.
    metrics_entries = parse_metrics_for_tokens()
    # Merge (avoid duplicates by id)
    existing_ids = {e.id for e in entries}
    for me in metrics_entries:
        if me.id not in existing_ids:
            entries.append(me)

    stats = aggregate(entries)
    totals = total_stats(entries)

    if getattr(args, "json", False):
        out = {
            "generated": datetime.now(timezone.utc).isoformat(),
            "totals": totals,
            "agents": {
                a: {
                    "total_tokens": s.total_tokens,
                    "input_tokens": s.total_input,
                    "output_tokens": s.total_output,
                    "cost_usd": round(s.total_cost_usd, 6),
                    "entry_count": s.entry_count,
                    "avg_tokens_per_call": round(s.avg_tokens_per_call, 0),
                }
                for a, s in stats.items()
            },
        }
        print(json.dumps(out, indent=2))
        return

    if getattr(args, "html", False):
        html = generate_html_section(entries, stats, totals)
        out_path = REPO_ROOT / "wiki-tokens.html"
        out_path.write_text(html, encoding="utf-8")
        print(f"Token dashboard section written: {out_path}")
        return

    print_report(entries, stats, totals)


def cmd_summary(args):
    entries = load_entries()
    totals = total_stats(entries)
    print(f"Tokens: {fmt_tokens(totals['total_tokens'])}  "
          f"Cost: {fmt_cost(totals['total_cost_usd'])}  "
          f"7d: {fmt_tokens(totals['last_7d_tokens'])} / {fmt_cost(totals['last_7d_cost_usd'])}")


def cmd_reset(args):
    if not getattr(args, "confirm", False):
        print("Add --confirm to reset all token data.")
        return
    save_entries([])
    print("Token usage data cleared.")


# ── Entry point ────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        prog="wiki-tokens",
        description="Agent token usage tracker",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("log", help="Log a token usage entry")
    p.add_argument("--agent", required=True, choices=list(AGENT_MODEL_MAP.keys()))
    p.add_argument("--tokens", type=int, default=0, help="Total tokens (if not split)")
    p.add_argument("--input-tokens", type=int, default=0)
    p.add_argument("--output-tokens", type=int, default=0)
    p.add_argument("--model", default="", help="Override model ID")
    p.add_argument("--task", default="", help="Task description")
    p.add_argument("--session", default="", help="Session ID")
    p.set_defaults(func=cmd_log)

    p = sub.add_parser("report", help="Show token usage report")
    p.add_argument("--html", action="store_true", help="Generate HTML section")
    p.add_argument("--json", action="store_true", help="Output as JSON")
    p.set_defaults(func=cmd_report)

    p = sub.add_parser("summary", help="One-line summary")
    p.set_defaults(func=cmd_summary)

    p = sub.add_parser("reset", help="Clear all token data")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_reset)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
