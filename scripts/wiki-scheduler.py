"""
wiki-scheduler.py — Automated ingest scheduler for Vipin's Knowledgebase.

Runs corpus ingest jobs on configurable schedules, tracks last-run times,
handles failures with retry/backoff, and logs everything to memory.

Usage:
    python scripts/wiki-scheduler.py run              # run all due jobs now
    python scripts/wiki-scheduler.py run --job karpathy  # run one job
    python scripts/wiki-scheduler.py status           # show schedule + last runs
    python scripts/wiki-scheduler.py daemon           # run continuously (blocking)
    python scripts/wiki-scheduler.py install          # install Windows Task Scheduler entry
    python scripts/wiki-scheduler.py list             # list all jobs with next-run times

Design:
    - Each job has a schedule (cron-style interval), a script to run, and retry config.
    - State is persisted to .scheduler-state.json in the repo root.
    - On failure, jobs are retried with exponential backoff (max 3 attempts).
    - After each successful run, wiki catalog is rebuilt and lint is checked.
    - All runs are logged to memory/sessions/ as session files.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from dataclasses import asdict, dataclass, field
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Optional

REPO_ROOT = Path(__file__).resolve().parent.parent
STATE_FILE = REPO_ROOT / ".scheduler-state.json"
SCRIPTS_DIR = REPO_ROOT / "scripts"
MEMORY_SESSIONS = REPO_ROOT / "memory" / "sessions"

# ── Job definitions ────────────────────────────────────────────────────────────

@dataclass
class JobDef:
    id: str
    name: str
    script: str                    # path relative to SCRIPTS_DIR, or "python:module"
    interval_hours: float          # how often to run
    priority: int = 5              # 1=highest, 10=lowest
    max_retries: int = 2
    timeout_seconds: int = 600
    enabled: bool = True
    description: str = ""
    tags: list[str] = field(default_factory=list)


JOBS: list[JobDef] = [
    JobDef(
        id="karpathy",
        name="Karpathy Public Corpus",
        script="ingest-karpathy-public.ps1",
        interval_hours=168,        # weekly
        priority=2,
        description="GitHub repos, blog RSS, YouTube — Karpathy public work",
        tags=["ingest", "karpathy", "weekly"],
    ),
    JobDef(
        id="lidang",
        name="Lidang Public Corpus",
        script="ingest-lidang-public.ps1",
        interval_hours=168,
        priority=2,
        description="YouTube RSS, X profile, mirror probes — 立党 public work",
        tags=["ingest", "lidang", "weekly"],
    ),
    JobDef(
        id="shunyu-yao",
        name="Shunyu Yao Public Corpus",
        script="ingest-shunyu-yao-public.ps1",
        interval_hours=336,        # bi-weekly
        priority=3,
        description="Two public corpora (alfredyao, ysymyth)",
        tags=["ingest", "shunyu-yao", "biweekly"],
    ),
    JobDef(
        id="frontend-frameworks",
        name="Frontend Frameworks",
        script="ingest-frontend-frameworks-public.ps1",
        interval_hours=336,
        priority=4,
        description="GitHub framework repos — React, Vue, Svelte, etc.",
        tags=["ingest", "frontend", "biweekly"],
    ),
    JobDef(
        id="openai-cookbook",
        name="OpenAI Cookbook",
        script="ingest-openai-cookbook.ps1",
        interval_hours=168,
        priority=3,
        description="Official OpenAI cookbook mirror",
        tags=["ingest", "openai", "weekly"],
    ),
    JobDef(
        id="codex-prompts",
        name="Codex Prompts Corpus",
        script="ingest-codex-prompts-public.ps1",
        interval_hours=336,
        priority=4,
        description="Codex automation prompt corpus",
        tags=["ingest", "codex", "biweekly"],
    ),
    JobDef(
        id="weekly-digest",
        name="Weekly Research Digest",
        script="ingest-weekly-research-digest.ps1",
        interval_hours=168,
        priority=1,
        description="Curated research picks — highest priority weekly job",
        tags=["ingest", "research", "weekly"],
    ),
    JobDef(
        id="catalog-rebuild",
        name="Catalog Rebuild",
        script="python:wiki_catalog",
        interval_hours=24,
        priority=1,
        timeout_seconds=120,
        description="Rebuild wiki/catalog.json and run lint gates",
        tags=["maintenance", "catalog", "daily"],
    ),
    JobDef(
        id="memory-index",
        name="Memory Index Rebuild",
        script="python:memory_index",
        interval_hours=24,
        priority=1,
        timeout_seconds=60,
        description="Rebuild memory/INDEX.md from frontmatter",
        tags=["maintenance", "memory", "daily"],
    ),
    JobDef(
        id="token-report",
        name="Token Usage Report",
        script="python:token_report",
        interval_hours=24,
        priority=1,
        timeout_seconds=30,
        description="Generate token usage HTML section and update dashboard",
        tags=["maintenance", "tokens", "daily"],
    ),
    JobDef(
        id="graphify",
        name="Knowledge Graph Update",
        script="python:graphify",
        interval_hours=72,          # every 3 days
        priority=3,
        timeout_seconds=1800,
        description="Incremental graphify extraction on changed files",
        tags=["maintenance", "graph", "triweekly"],
    ),
]

JOBS_BY_ID = {j.id: j for j in JOBS}


# ── State persistence ──────────────────────────────────────────────────────────

@dataclass
class JobRun:
    job_id: str
    started_at: str
    finished_at: str = ""
    status: str = "running"        # running | success | failed | skipped
    exit_code: int = 0
    attempt: int = 1
    error: str = ""
    duration_seconds: float = 0.0


@dataclass
class JobState:
    job_id: str
    last_success: str = ""         # ISO timestamp of last successful run
    last_attempt: str = ""
    consecutive_failures: int = 0
    next_run: str = ""             # ISO timestamp of next scheduled run
    runs: list[dict] = field(default_factory=list)  # last 10 runs


def load_state() -> dict[str, JobState]:
    if not STATE_FILE.exists():
        return {}
    try:
        raw = json.loads(STATE_FILE.read_text(encoding="utf-8"))
        return {k: JobState(**v) for k, v in raw.items()}
    except Exception:
        return {}


def save_state(state: dict[str, JobState]):
    data = {k: asdict(v) for k, v in state.items()}
    STATE_FILE.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def now_utc() -> datetime:
    return datetime.now(timezone.utc)


def iso(dt: datetime) -> str:
    return dt.isoformat()


def parse_iso(s: str) -> Optional[datetime]:
    if not s:
        return None
    try:
        return datetime.fromisoformat(s)
    except ValueError:
        return None


# ── Scheduling logic ───────────────────────────────────────────────────────────

def is_due(job: JobDef, state: dict[str, JobState]) -> bool:
    """Return True if this job should run now."""
    if not job.enabled:
        return False
    js = state.get(job.id)
    if js is None:
        return True  # never run
    # Exponential backoff on consecutive failures
    if js.consecutive_failures > 0:
        backoff_hours = min(2 ** js.consecutive_failures, 48)
        last = parse_iso(js.last_attempt)
        if last and (now_utc() - last) < timedelta(hours=backoff_hours):
            return False
    last_success = parse_iso(js.last_success)
    if last_success is None:
        return True
    return (now_utc() - last_success) >= timedelta(hours=job.interval_hours)


def due_jobs(state: dict[str, JobState]) -> list[JobDef]:
    """Return jobs that are due, sorted by priority."""
    return sorted(
        [j for j in JOBS if is_due(j, state)],
        key=lambda j: j.priority,
    )


def next_run_time(job: JobDef, state: dict[str, JobState]) -> Optional[datetime]:
    js = state.get(job.id)
    if js is None:
        return now_utc()
    last_success = parse_iso(js.last_success)
    if last_success is None:
        return now_utc()
    return last_success + timedelta(hours=job.interval_hours)


# ── Job execution ──────────────────────────────────────────────────────────────

def run_job(job: JobDef, dry_run: bool = False) -> JobRun:
    """Execute a single job. Returns a JobRun record."""
    started = now_utc()
    run = JobRun(
        job_id=job.id,
        started_at=iso(started),
        attempt=1,
    )

    if dry_run:
        print(f"  [DRY RUN] Would run: {job.script}")
        run.status = "skipped"
        run.finished_at = iso(now_utc())
        return run

    print(f"  Running: {job.name} ({job.script})")

    try:
        if job.script.startswith("python:"):
            result = _run_python_job(job)
        else:
            result = _run_powershell_job(job)

        run.exit_code = result.returncode
        run.status = "success" if result.returncode == 0 else "failed"
        if result.returncode != 0:
            run.error = (result.stderr or "")[-500:]
    except subprocess.TimeoutExpired:
        run.status = "failed"
        run.error = f"Timeout after {job.timeout_seconds}s"
    except Exception as e:
        run.status = "failed"
        run.error = str(e)

    run.finished_at = iso(now_utc())
    run.duration_seconds = (now_utc() - started).total_seconds()
    return run


def _run_powershell_job(job: JobDef) -> subprocess.CompletedProcess:
    script_path = SCRIPTS_DIR / job.script
    if not script_path.exists():
        raise FileNotFoundError(f"Script not found: {script_path}")
    cmd = ["powershell", "-NonInteractive", "-ExecutionPolicy", "Bypass",
           "-File", str(script_path), "-Root", str(REPO_ROOT)]
    return subprocess.run(
        cmd, capture_output=True, text=True,
        timeout=job.timeout_seconds, cwd=str(REPO_ROOT),
    )


def _run_python_job(job: JobDef) -> subprocess.CompletedProcess:
    module = job.script.split(":", 1)[1]
    if module == "wiki_catalog":
        cmd = [sys.executable, str(SCRIPTS_DIR / "wiki.py"), "catalog"]
    elif module == "memory_index":
        cmd = [sys.executable, str(SCRIPTS_DIR / "rebuild-memory-index.py")]
    elif module == "graphify":
        cmd = [sys.executable, str(SCRIPTS_DIR / "graphify-extract.py"), "--update"]
    elif module == "token_report":
        cmd = [sys.executable, str(SCRIPTS_DIR / "wiki-tokens.py"), "report", "--html"]
    else:
        raise ValueError(f"Unknown python job module: {module}")
    return subprocess.run(
        cmd, capture_output=True, text=True,
        timeout=job.timeout_seconds, cwd=str(REPO_ROOT),
    )


# ── State update ───────────────────────────────────────────────────────────────

def update_state(state: dict[str, JobState], run: JobRun):
    js = state.setdefault(run.job_id, JobState(job_id=run.job_id))
    js.last_attempt = run.started_at
    js.runs = ([asdict(run)] + js.runs)[:10]  # keep last 10

    if run.status == "success":
        js.last_success = run.started_at
        js.consecutive_failures = 0
        job = JOBS_BY_ID.get(run.job_id)
        if job:
            js.next_run = iso(now_utc() + timedelta(hours=job.interval_hours))
    else:
        js.consecutive_failures += 1


# ── Session logging ────────────────────────────────────────────────────────────

def write_session_log(runs: list[JobRun]):
    """Write a session file to memory/sessions/ after a scheduler run."""
    if not runs:
        return
    MEMORY_SESSIONS.mkdir(parents=True, exist_ok=True)
    date_str = now_utc().strftime("%Y-%m-%d")
    slug = f"{date_str}_scheduler-run"
    path = MEMORY_SESSIONS / f"{slug}.md"

    success = [r for r in runs if r.status == "success"]
    failed = [r for r in runs if r.status == "failed"]

    lines = [
        "---",
        f'title: "Scheduler Run {date_str}"',
        "type: session",
        f"created: {now_utc().strftime('%Y-%m-%dT%H:%M:%SZ')}",
        f"updated: {now_utc().strftime('%Y-%m-%dT%H:%M:%SZ')}",
        "tags: [scheduler, ingest, maintenance]",
        "---",
        "",
        f"## Scheduler Run — {date_str}",
        "",
        f"- **Jobs run**: {len(runs)}",
        f"- **Succeeded**: {len(success)}",
        f"- **Failed**: {len(failed)}",
        "",
        "## Results",
        "",
    ]
    for r in runs:
        icon = "✓" if r.status == "success" else "✗" if r.status == "failed" else "○"
        job = JOBS_BY_ID.get(r.job_id)
        name = job.name if job else r.job_id
        dur = f"{r.duration_seconds:.1f}s" if r.duration_seconds else "—"
        lines.append(f"- {icon} **{name}** ({r.job_id}) — {r.status} in {dur}")
        if r.error:
            lines.append(f"  - Error: {r.error[:200]}")

    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"  Session log: {path.relative_to(REPO_ROOT)}")


# ── CLI commands ───────────────────────────────────────────────────────────────

def cmd_run(args):
    state = load_state()
    dry_run = getattr(args, "dry_run", False)

    if args.job:
        job = JOBS_BY_ID.get(args.job)
        if not job:
            print(f"Unknown job: {args.job}. Use 'list' to see available jobs.")
            sys.exit(1)
        jobs_to_run = [job]
    else:
        jobs_to_run = due_jobs(state)

    if not jobs_to_run:
        print("No jobs due. Use --force to run anyway, or specify --job <id>.")
        return

    print(f"Running {len(jobs_to_run)} job(s):")
    runs = []
    for job in jobs_to_run:
        print(f"\n[{job.priority}] {job.name}")
        run = run_job(job, dry_run=dry_run)
        update_state(state, run)
        save_state(state)
        icon = "✓" if run.status == "success" else "✗"
        print(f"  {icon} {run.status} ({run.duration_seconds:.1f}s)")
        if run.error:
            print(f"  Error: {run.error[:200]}")
        runs.append(run)

    write_session_log(runs)
    failed = [r for r in runs if r.status == "failed"]
    if failed:
        print(f"\n{len(failed)} job(s) failed.")
        sys.exit(1)
    print(f"\nAll {len(runs)} job(s) completed successfully.")


def cmd_status(args):
    state = load_state()
    now = now_utc()

    print(f"\n{'Job':<28} {'Last Success':<22} {'Next Run':<22} {'Failures':<10} {'Status'}")
    print("─" * 100)
    for job in sorted(JOBS, key=lambda j: j.priority):
        if not job.enabled:
            continue
        js = state.get(job.id)
        last_ok = js.last_success[:16] if js and js.last_success else "never"
        nxt = next_run_time(job, state)
        nxt_str = nxt.strftime("%Y-%m-%d %H:%M") if nxt else "now"
        overdue = " ⚠ OVERDUE" if nxt and nxt < now else ""
        failures = js.consecutive_failures if js else 0
        fail_str = f"{failures}x" if failures else "—"
        due_str = "DUE" if is_due(job, state) else "ok"
        print(f"  {job.name:<26} {last_ok:<22} {nxt_str:<22} {fail_str:<10} {due_str}{overdue}")
    print()


def cmd_list(args):
    state = load_state()
    print(f"\n{'ID':<22} {'Interval':<12} {'Priority':<10} {'Description'}")
    print("─" * 90)
    for job in sorted(JOBS, key=lambda j: j.priority):
        interval = f"{job.interval_hours:.0f}h"
        print(f"  {job.id:<22} {interval:<12} {job.priority:<10} {job.description}")
    print()


def cmd_daemon(args):
    """Run continuously, checking for due jobs every 15 minutes."""
    print("Starting scheduler daemon. Press Ctrl+C to stop.")
    print(f"Checking every 15 minutes. State: {STATE_FILE}")
    while True:
        try:
            state = load_state()
            due = due_jobs(state)
            if due:
                print(f"\n[{now_utc().strftime('%H:%M')}] {len(due)} job(s) due:")
                runs = []
                for job in due:
                    print(f"  Running: {job.name}")
                    run = run_job(job)
                    update_state(state, run)
                    save_state(state)
                    icon = "✓" if run.status == "success" else "✗"
                    print(f"  {icon} {run.status} ({run.duration_seconds:.1f}s)")
                    runs.append(run)
                write_session_log(runs)
            else:
                print(f"[{now_utc().strftime('%H:%M')}] No jobs due.", end="\r")
            time.sleep(900)  # 15 minutes
        except KeyboardInterrupt:
            print("\nDaemon stopped.")
            break


def cmd_install(args):
    """Install a Windows Task Scheduler entry to run daily."""
    script = Path(__file__).resolve()
    task_name = "VipinWikiScheduler"
    cmd = (
        f'schtasks /Create /TN "{task_name}" /TR '
        f'"python \\"{script}\\" run" '
        f'/SC DAILY /ST 06:00 /F /RL HIGHEST'
    )
    print(f"Installing Task Scheduler entry: {task_name}")
    print(f"Command: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode == 0:
        print("✓ Task Scheduler entry installed. Runs daily at 06:00.")
    else:
        print(f"✗ Failed: {result.stderr}")
        sys.exit(1)


# ── Entry point ────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        prog="wiki-scheduler",
        description="Automated ingest scheduler for Vipin's Knowledgebase",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_run = sub.add_parser("run", help="Run due jobs (or a specific job)")
    p_run.add_argument("--job", help="Run a specific job by ID")
    p_run.add_argument("--dry-run", action="store_true", help="Show what would run without executing")
    p_run.add_argument("--force", action="store_true", help="Run all jobs regardless of schedule")
    p_run.set_defaults(func=cmd_run)

    p_status = sub.add_parser("status", help="Show schedule and last-run status")
    p_status.set_defaults(func=cmd_status)

    p_list = sub.add_parser("list", help="List all jobs with intervals")
    p_list.set_defaults(func=cmd_list)

    p_daemon = sub.add_parser("daemon", help="Run continuously (blocking)")
    p_daemon.set_defaults(func=cmd_daemon)

    p_install = sub.add_parser("install", help="Install Windows Task Scheduler entry")
    p_install.set_defaults(func=cmd_install)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
