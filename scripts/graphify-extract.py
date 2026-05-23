"""Run graphify extraction on the knowledgebase.

Usage:
    python scripts/graphify-extract.py              # full extraction
    python scripts/graphify-extract.py --update     # incremental (changed files only)
"""
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

def main():
    args = ["python", "-m", "graphify", "extract", str(REPO_ROOT),
            "--backend", "deepseek", "--no-cluster"]
    if "--update" in sys.argv:
        args.append("--incremental")
    print(f"[graphify] Running: {' '.join(args)}")
    result = subprocess.run(args, cwd=str(REPO_ROOT))
    sys.exit(result.returncode)

if __name__ == "__main__":
    main()
