"""
wiki-dashboard.py — Agent performance dashboard for Vipin's Knowledgebase.

Reads D:\\devtools\\agent-hub\\state\\metrics.json and produces:
  - Per-agent success/failure/retry rates
  - Task latency distribution
  - Cascade fallback analysis
  - Recent activity timeline
  - HTML dashboard (self-contained, no server needed)

Usage:
    python scripts/wiki-dashboard.py              # print terminal report
    python scripts/wiki-dashboard.py --html       # generate dashboard.html
    python scripts/wiki-dashboard.py --json       # output raw stats as JSON
    python scripts/wiki-dashboard.py --watch      # refresh every 30s
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parent.parent
METRICS_FILE = Path(r"D:\devtools\agent-hub\state\metrics.json")
DASHBOARD_OUT = REPO_ROOT / "wiki-dashboard.html"

AGENT_COLORS = {
    "claude": "#5b8af5",
    "opus": "#a78bfa",
    "codex": "#22d3ee",
    "sonnet": "#4ade80",
    "haiku": "#fbbf24",
    "deepseek": "#f87171",
    "opencode": "#fb923c",
}

AGENT_DISPLAY = {
    "claude": "Opus (Claude)",
    "opus": "Opus",
    "codex": "Codex (GPT-5.5)",
    "sonnet": "Sonnet",
    "haiku": "Haiku",
    "deepseek": "DeepSeek",
    "opencode": "OpenCode",
}

# ── Data loading ───────────────────────────────────────────────────────────────

@dataclass
class Event:
    agent: str
    task_id: str
    event: str          # dispatch | success | fail | retry | quality_gate
    detail: str
    timestamp: datetime


@dataclass
class TaskStats:
    task_id: str
    agents_tried: list[str] = field(default_factory=list)
    final_agent: str = ""
    final_status: str = ""   # success | fail
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    retries: int = 0

    @property
    def duration_seconds(self) -> Optional[float]:
        if self.start_time and self.end_time:
            return (self.end_time - self.start_time).total_seconds()
        return None


@dataclass
class AgentStats:
    agent: str
    dispatches: int = 0
    successes: int = 0
    failures: int = 0
    retries_received: int = 0   # times this agent was tried as fallback
    total_duration: float = 0.0
    durations: list[float] = field(default_factory=list)

    @property
    def success_rate(self) -> float:
        total = self.successes + self.failures
        return self.successes / total if total > 0 else 0.0

    @property
    def avg_duration(self) -> float:
        return sum(self.durations) / len(self.durations) if self.durations else 0.0

    @property
    def p95_duration(self) -> float:
        if not self.durations:
            return 0.0
        s = sorted(self.durations)
        idx = int(len(s) * 0.95)
        return s[min(idx, len(s) - 1)]


def load_events() -> list[Event]:
    if not METRICS_FILE.exists():
        return []
    try:
        raw = json.loads(METRICS_FILE.read_text(encoding="utf-8"))
        events = []
        for e in raw.get("events", []):
            try:
                ts = datetime.fromisoformat(e["timestamp"].replace("Z", "+00:00"))
            except (ValueError, KeyError):
                ts = datetime.now(timezone.utc)
            events.append(Event(
                agent=e.get("agent", "unknown"),
                task_id=e.get("task_id", ""),
                event=e.get("event", ""),
                detail=e.get("detail", ""),
                timestamp=ts,
            ))
        return sorted(events, key=lambda e: e.timestamp)
    except Exception as ex:
        print(f"Warning: could not load metrics: {ex}", file=sys.stderr)
        return []


def compute_stats(events: list[Event]) -> tuple[dict[str, AgentStats], dict[str, TaskStats], list[Event]]:
    agent_stats: dict[str, AgentStats] = {}
    task_stats: dict[str, TaskStats] = {}

    for e in events:
        # Per-agent stats
        if e.agent not in agent_stats:
            agent_stats[e.agent] = AgentStats(agent=e.agent)
        ag = agent_stats[e.agent]

        # Per-task stats
        if e.task_id not in task_stats:
            task_stats[e.task_id] = TaskStats(task_id=e.task_id)
        ts = task_stats[e.task_id]

        if e.event == "dispatch":
            ag.dispatches += 1
            if ts.start_time is None:
                ts.start_time = e.timestamp
            if e.agent not in ts.agents_tried:
                ts.agents_tried.append(e.agent)

        elif e.event == "success":
            ag.successes += 1
            ts.final_agent = e.agent
            ts.final_status = "success"
            ts.end_time = e.timestamp
            if ts.start_time:
                dur = (e.timestamp - ts.start_time).total_seconds()
                ag.durations.append(dur)

        elif e.event == "fail":
            ag.failures += 1
            if ts.final_status != "success":
                ts.final_status = "fail"
                ts.end_time = e.timestamp

        elif e.event == "retry":
            ag.retries_received += 1
            ts.retries += 1
            if e.agent not in ts.agents_tried:
                ts.agents_tried.append(e.agent)

    # Recent events (last 50)
    recent = events[-50:]
    return agent_stats, task_stats, recent


# ── Terminal output ────────────────────────────────────────────────────────────

RESET = "\033[0m"; BOLD = "\033[1m"; DIM = "\033[2m"
GREEN = "\033[32m"; RED = "\033[31m"; YELLOW = "\033[33m"; CYAN = "\033[36m"

def c(*args):
    codes = [a for a in args if isinstance(a, str) and a.startswith("\033")]
    texts = [a for a in args if not (isinstance(a, str) and a.startswith("\033"))]
    return "".join(codes) + str(texts[0] if texts else "") + RESET

def hr(w=80): return c("─" * w, DIM)

def bar(value: float, width: int = 20, color: str = GREEN) -> str:
    filled = int(value * width)
    return c("█" * filled, color) + c("░" * (width - filled), DIM)


def print_dashboard(agent_stats: dict[str, AgentStats],
                    task_stats: dict[str, TaskStats],
                    recent: list[Event]):
    now = datetime.now(timezone.utc)
    total_tasks = len(task_stats)
    successful_tasks = sum(1 for t in task_stats.values() if t.final_status == "success")
    cascade_tasks = sum(1 for t in task_stats.values() if len(t.agents_tried) > 1)

    print(f"\n  {c('⚡ Agent Performance Dashboard', BOLD, CYAN)}")
    print(c(f"  {now.strftime('%Y-%m-%d %H:%M UTC')}  ·  {total_tasks} tasks total", DIM))
    print(hr())

    # Token summary inline
    try:
        import subprocess, sys
        result = subprocess.run(
            [sys.executable, str(Path(__file__).parent / "wiki-tokens.py"), "summary"],
            capture_output=True, text=True, timeout=5,
        )
        if result.returncode == 0 and result.stdout.strip():
            print(f"\n  {c('Token Usage:', BOLD)} {result.stdout.strip()}")
    except Exception:
        pass

    # Summary row
    task_sr = successful_tasks / total_tasks if total_tasks else 0
    print(f"\n  {c('Tasks', BOLD)}: {total_tasks}  "
          f"{c('Success rate', BOLD)}: {c(f'{task_sr:.0%}', GREEN if task_sr > 0.8 else YELLOW)}  "
          f"{c('Cascades', BOLD)}: {cascade_tasks} ({cascade_tasks/total_tasks:.0%})" if total_tasks else "")

    # Per-agent table
    print(f"\n  {c('Per-Agent Statistics', BOLD)}\n")
    print(f"  {'Agent':<18} {'Dispatches':<12} {'Success%':<12} {'Avg dur':<10} {'P95 dur':<10} {'Fallbacks'}")
    print(f"  {'─'*18} {'─'*12} {'─'*12} {'─'*10} {'─'*10} {'─'*10}")

    for agent_id in sorted(agent_stats, key=lambda a: -agent_stats[a].dispatches):
        ag = agent_stats[agent_id]
        name = AGENT_DISPLAY.get(agent_id, agent_id)
        sr = ag.success_rate
        sr_color = GREEN if sr > 0.8 else YELLOW if sr > 0.5 else RED
        avg = f"{ag.avg_duration:.1f}s" if ag.avg_duration else "—"
        p95 = f"{ag.p95_duration:.1f}s" if ag.p95_duration else "—"
        print(f"  {name:<18} {ag.dispatches:<12} "
              f"{c(f'{sr:.0%}', sr_color):<20} {avg:<10} {p95:<10} {ag.retries_received}")

    # Cascade analysis
    if cascade_tasks:
        print(f"\n  {c('Cascade Fallback Patterns', BOLD)}\n")
        patterns: dict[str, int] = defaultdict(int)
        for t in task_stats.values():
            if len(t.agents_tried) > 1:
                pattern = " → ".join(t.agents_tried)
                patterns[pattern] += 1
        for pattern, count in sorted(patterns.items(), key=lambda x: -x[1])[:10]:
            print(f"  {count:>4}×  {pattern}")

    # Recent activity
    print(f"\n  {c('Recent Activity', BOLD)} (last {len(recent)} events)\n")
    for e in recent[-15:]:
        ts_str = e.timestamp.strftime("%H:%M:%S")
        event_color = GREEN if e.event == "success" else RED if e.event == "fail" else DIM
        icon = "✓" if e.event == "success" else "✗" if e.event == "fail" else "↩" if e.event == "retry" else "→"
        agent_name = AGENT_DISPLAY.get(e.agent, e.agent)
        detail = e.detail[:60] + "…" if len(e.detail) > 60 else e.detail
        print(f"  {c(ts_str, DIM)}  {c(icon, event_color)}  {c(agent_name, BOLD):<20}  {c(detail, DIM)}")
    print()


# ── HTML dashboard ─────────────────────────────────────────────────────────────

def generate_html(agent_stats: dict[str, AgentStats],
                  task_stats: dict[str, TaskStats],
                  recent: list[Event]) -> str:
    now = datetime.now(timezone.utc)
    total_tasks = len(task_stats)
    successful_tasks = sum(1 for t in task_stats.values() if t.final_status == "success")
    cascade_tasks = sum(1 for t in task_stats.values() if len(t.agents_tried) > 1)
    task_sr = successful_tasks / total_tasks if total_tasks else 0

    # Build agent rows
    agent_rows = ""
    for agent_id in sorted(agent_stats, key=lambda a: -agent_stats[a].dispatches):
        ag = agent_stats[agent_id]
        name = AGENT_DISPLAY.get(agent_id, agent_id)
        color = AGENT_COLORS.get(agent_id, "#888")
        sr = ag.success_rate
        sr_color = "#4ade80" if sr > 0.8 else "#fbbf24" if sr > 0.5 else "#f87171"
        avg = f"{ag.avg_duration:.1f}s" if ag.avg_duration else "—"
        p95 = f"{ag.p95_duration:.1f}s" if ag.p95_duration else "—"
        bar_w = int(sr * 100)
        agent_rows += f"""
        <tr>
          <td><span class="agent-dot" style="background:{color}"></span>{name}</td>
          <td>{ag.dispatches}</td>
          <td>
            <div class="bar-wrap">
              <div class="bar-fill" style="width:{bar_w}%;background:{sr_color}"></div>
            </div>
            <span style="color:{sr_color}">{sr:.0%}</span>
          </td>
          <td>{avg}</td><td>{p95}</td><td>{ag.retries_received}</td>
        </tr>"""

    # Recent events
    event_rows = ""
    for e in reversed(recent[-30:]):
        ts_str = e.timestamp.strftime("%H:%M:%S")
        icon = "✓" if e.event == "success" else "✗" if e.event == "fail" else "↩" if e.event == "retry" else "→"
        ev_color = "#4ade80" if e.event == "success" else "#f87171" if e.event == "fail" else "#fbbf24"
        agent_name = AGENT_DISPLAY.get(e.agent, e.agent)
        detail = e.detail[:80] + "…" if len(e.detail) > 80 else e.detail
        event_rows += f"""
        <tr>
          <td class="dim">{ts_str}</td>
          <td style="color:{ev_color};font-weight:600">{icon} {e.event}</td>
          <td>{agent_name}</td>
          <td class="dim small">{detail}</td>
        </tr>"""

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Agent Dashboard — Vipin Lab</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:#0b0d12;color:#dde2f0;font-family:'Inter',system-ui,sans-serif;font-size:14px;line-height:1.6;padding:24px}}
h1{{font-size:20px;font-weight:700;color:#5b8af5;margin-bottom:4px}}
.sub{{color:#636d94;font-size:13px;margin-bottom:24px}}
.grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin-bottom:24px}}
.card{{background:#111318;border:1px solid #222736;border-radius:10px;padding:16px}}
.card-val{{font-size:28px;font-weight:700;color:#5b8af5}}
.card-label{{font-size:12px;color:#636d94;margin-top:4px}}
.section{{background:#111318;border:1px solid #222736;border-radius:10px;padding:20px;margin-bottom:16px}}
.section h2{{font-size:14px;font-weight:600;color:#dde2f0;margin-bottom:16px;text-transform:uppercase;letter-spacing:.06em}}
table{{width:100%;border-collapse:collapse}}
th{{text-align:left;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:#636d94;padding:6px 10px;border-bottom:1px solid #222736}}
td{{padding:8px 10px;border-bottom:1px solid #1c2030;font-size:13px}}
tr:last-child td{{border-bottom:none}}
.agent-dot{{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:8px}}
.bar-wrap{{display:inline-block;width:80px;height:6px;background:#1c2030;border-radius:3px;vertical-align:middle;margin-right:8px}}
.bar-fill{{height:100%;border-radius:3px}}
.dim{{color:#636d94}}
.small{{font-size:12px}}
.refresh{{font-size:12px;color:#636d94;margin-top:16px}}
</style>
</head>
<body>
<h1>⚡ Agent Performance Dashboard</h1>
<div class="sub">Vipin Lab · Updated {now.strftime('%Y-%m-%d %H:%M UTC')}</div>

<div class="grid">
  <div class="card"><div class="card-val">{total_tasks}</div><div class="card-label">Total Tasks</div></div>
  <div class="card"><div class="card-val" style="color:{'#4ade80' if task_sr>0.8 else '#fbbf24'}">{task_sr:.0%}</div><div class="card-label">Success Rate</div></div>
  <div class="card"><div class="card-val">{cascade_tasks}</div><div class="card-label">Cascade Fallbacks</div></div>
  <div class="card"><div class="card-val">{len(agent_stats)}</div><div class="card-label">Active Agents</div></div>
</div>

<div class="section">
  <h2>Per-Agent Statistics</h2>
  <table>
    <tr><th>Agent</th><th>Dispatches</th><th>Success Rate</th><th>Avg Duration</th><th>P95 Duration</th><th>Fallbacks</th></tr>
    {agent_rows}
  </table>
</div>

<div class="section">
  <h2>Recent Activity</h2>
  <table>
    <tr><th>Time</th><th>Event</th><th>Agent</th><th>Detail</th></tr>
    {event_rows}
  </table>
</div>

<div class="refresh">Auto-refresh: run <code>python scripts/wiki-dashboard.py --html</code> to update</div>
</body>
</html>"""


# ── Entry point ────────────────────────────────────────────────────────────────

def run_once(args):
    events = load_events()
    if not events:
        print("No metrics data found. Agent Hub may not have run yet.")
        if not getattr(args, "html", False):
            return
    agent_stats, task_stats, recent = compute_stats(events)

    if getattr(args, "json", False):
        out = {
            "generated": datetime.now(timezone.utc).isoformat(),
            "summary": {
                "total_tasks": len(task_stats),
                "successful_tasks": sum(1 for t in task_stats.values() if t.final_status == "success"),
                "cascade_tasks": sum(1 for t in task_stats.values() if len(t.agents_tried) > 1),
            },
            "agents": {
                a: {
                    "dispatches": s.dispatches,
                    "successes": s.successes,
                    "failures": s.failures,
                    "success_rate": round(s.success_rate, 3),
                    "avg_duration_s": round(s.avg_duration, 2),
                    "p95_duration_s": round(s.p95_duration, 2),
                    "retries_received": s.retries_received,
                }
                for a, s in agent_stats.items()
            },
        }
        print(json.dumps(out, indent=2))
        return

    if getattr(args, "html", False):
        html = generate_html(agent_stats, task_stats, recent)
        # Embed token section if available
        try:
            import subprocess, sys as _sys
            result = subprocess.run(
                [_sys.executable, str(Path(__file__).parent / "wiki-tokens.py"),
                 "report", "--html"],
                capture_output=True, text=True, timeout=10, cwd=str(REPO_ROOT),
            )
            token_html_file = REPO_ROOT / "wiki-tokens.html"
            if token_html_file.exists():
                token_section = token_html_file.read_text(encoding="utf-8")
                html = html.replace("</body>", f"{token_section}\n</body>")
        except Exception:
            pass
        DASHBOARD_OUT.write_text(html, encoding="utf-8")
        print(f"Dashboard written: {DASHBOARD_OUT}")
        return

    print_dashboard(agent_stats, task_stats, recent)


def main():
    parser = argparse.ArgumentParser(
        prog="wiki-dashboard",
        description="Agent performance dashboard",
    )
    parser.add_argument("--html", action="store_true", help="Generate HTML dashboard")
    parser.add_argument("--json", action="store_true", help="Output stats as JSON")
    parser.add_argument("--watch", action="store_true", help="Refresh every 30s")
    args = parser.parse_args()

    if args.watch:
        while True:
            os.system("cls" if os.name == "nt" else "clear")
            run_once(args)
            print(f"\n  Refreshing in 30s… (Ctrl+C to stop)")
            try:
                time.sleep(30)
            except KeyboardInterrupt:
                break
    else:
        run_once(args)


if __name__ == "__main__":
    main()
