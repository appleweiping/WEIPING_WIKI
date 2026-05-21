#!/usr/bin/env python3
"""Rebuild memory/INDEX.md from YAML frontmatter of all memory files."""
import os, re, sys
from pathlib import Path

MEMORY_DIR = Path(r"D:\research\Vipin's Knowledgebase\memory")
INDEX_FILE = MEMORY_DIR / "INDEX.md"
SKIP = {"INDEX.md", "README.md"}
CATEGORIES = ["decisions", "facts", "preferences", "lessons", "workflows", "sessions"]

def parse_frontmatter(path):
    text = path.read_text(encoding="utf-8")
    m = re.match(r"^---\s*\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return None
    fm = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            key, val = line.split(":", 1)
            fm[key.strip()] = val.strip().strip('"').strip("'")
    return fm

def build_index():
    lines = ["# Memory Index\n", f"Auto-maintained index of all shared agent memories.\n"]
    for cat in CATEGORIES:
        cat_dir = MEMORY_DIR / cat
        if not cat_dir.exists():
            continue
        files = sorted(cat_dir.glob("*.md"))
        lines.append(f"\n## {cat.capitalize()}\n")
        if not files:
            lines.append("(empty)\n")
            continue
        lines.append("| File | Title | Tags | Updated |")
        lines.append("|------|-------|------|---------|")
        for f in files:
            fm = parse_frontmatter(f)
            if not fm:
                continue
            title = fm.get("title", f.stem)
            tags = fm.get("tags", "").strip("[]")
            updated = fm.get("updated", "unknown")[:10]
            rel = f"{cat}/{f.name}"
            lines.append(f"| [{f.name}]({rel}) | {title} | {tags} | {updated} |")
        lines.append("")
    INDEX_FILE.write_text("\n".join(lines), encoding="utf-8")
    print(f"Rebuilt {INDEX_FILE} ({sum(1 for c in CATEGORIES for _ in (MEMORY_DIR/c).glob('*.md') if (MEMORY_DIR/c).exists())} files indexed)")

if __name__ == "__main__":
    build_index()
