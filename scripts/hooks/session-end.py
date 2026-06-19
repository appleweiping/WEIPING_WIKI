#!/usr/bin/env python
"""Session-end helper for WEIPING_WIKI (LLM Wiki v2: crystallize-on-session-end).

Inspects the current git working tree and suggests crystallize candidates when
wiki/ content changed this session. Read-only and advisory: it only SUGGESTS,
never writes pages, commits, or runs crystallize automatically.

Optional Claude Code hook registration (user-initiated; do NOT auto-install). Add to
the PROJECT .claude/settings.json under hooks.Stop or hooks.SessionEnd, e.g.:

    {"hooks": {"Stop": [{"hooks": [{"type": "command",
      "command": "python scripts/hooks/session-end.py"}]}]}}
"""
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def _changed_files() -> list[str]:
    result = subprocess.run(
        ["git", "-C", str(ROOT), "status", "--porcelain"],
        capture_output=True, text=True, check=False,
    )
    files = []
    for line in result.stdout.splitlines():
        if line.strip():
            files.append(line[3:].strip())
    return files


def main() -> int:
    changed = _changed_files()
    wiki_changed = [f for f in changed if f.startswith("wiki/") and f.endswith(".md")]
    print("# WEIPING_WIKI session-end crystallize check\n")
    if not wiki_changed:
        print("- No wiki/ markdown changes this session; nothing to crystallize.")
        return 0
    print("- Consider preserving reusable outcomes with:")
    print('    python scripts/wiki.py crystallize --title "<title>" --type query --from-file <notes>')
    print(f"- Changed wiki/ pages this session ({len(wiki_changed)}):")
    for path in wiki_changed[:20]:
        print(f"  - {path}")
    if len(wiki_changed) > 20:
        print(f"  ... and {len(wiki_changed) - 20} more")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
