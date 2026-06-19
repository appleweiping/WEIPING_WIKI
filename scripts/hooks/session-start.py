#!/usr/bin/env python
"""Session-start helper for WEIPING_WIKI (LLM Wiki v2: event-driven context injection).

Prints an L0 context pack + a quick status summary so a new agent session loads
just enough repository state. Read-only; modifies nothing.

Optional Claude Code hook registration (user-initiated; do NOT auto-install). Add to
the PROJECT .claude/settings.json under hooks.SessionStart, e.g.:

    {"hooks": {"SessionStart": [{"hooks": [{"type": "command",
      "command": "python scripts/hooks/session-start.py"}]}]}}
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WIKI = ROOT / "scripts" / "wiki.py"


def _run(*cmd_args) -> None:
    subprocess.run([sys.executable, str(WIKI), "--root", str(ROOT), *cmd_args], check=False)


def main() -> int:
    print("# WEIPING_WIKI session-start context\n")
    _run("status")
    print("\n---\n")
    _run("context", "L0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
