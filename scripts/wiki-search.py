#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import math
import re
import sys
from collections import Counter
from pathlib import Path


TOKEN_RE = re.compile(r"[A-Za-z0-9_+-]+")


def tokenize(text: str) -> list[str]:
    return [token.lower() for token in TOKEN_RE.findall(text)]


def load_catalog(root: Path) -> dict:
    catalog_path = root / "wiki" / "catalog.json"
    if not catalog_path.exists():
        raise SystemExit("wiki/catalog.json not found. Run scripts/wiki-catalog.py first.")
    return json.loads(catalog_path.read_text(encoding="utf-8"))


def score_page(page: dict, query_tokens: list[str], doc_freq: Counter, total_docs: int) -> float:
    fields = {
        "title": tokenize(page.get("title", "")),
        "headings": tokenize(" ".join(page.get("headings", []))),
        "tags": tokenize(" ".join(page.get("tags", []))),
        "preview": tokenize(page.get("body_preview", "")),
        "type": tokenize(page.get("type", "")),
    }
    scores = 0.0
    combined = fields["title"] + fields["headings"] + fields["tags"] + fields["preview"] + fields["type"]
    freqs = Counter(combined)

    for token in query_tokens:
        tf = freqs[token]
        if tf == 0:
            continue
        idf = math.log((1 + total_docs) / (1 + doc_freq[token])) + 1
        boost = 1.0
        if token in fields["title"]:
            boost += 3.0
        if token in fields["headings"]:
            boost += 1.5
        if token in fields["tags"]:
            boost += 1.0
        if token in fields["type"]:
            boost += 0.8
        scores += tf * idf * boost

    if len(query_tokens) == 1 and page.get("id", "").lower() == query_tokens[0]:
        scores += 6.0
    return scores


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    parser = argparse.ArgumentParser()
    parser.add_argument("query")
    parser.add_argument("--root", default=".")
    parser.add_argument("--top", type=int, default=8)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    catalog = load_catalog(root)
    pages = catalog.get("pages", [])
    query_tokens = tokenize(args.query)
    if not query_tokens:
        raise SystemExit("Query produced no usable tokens.")

    doc_freq: Counter[str] = Counter()
    for page in pages:
        page_tokens = set(tokenize(page.get("title", "")) + tokenize(" ".join(page.get("headings", []))) + tokenize(" ".join(page.get("tags", []))) + tokenize(page.get("body_preview", "")) + tokenize(page.get("type", "")))
        for token in page_tokens:
            doc_freq[token] += 1

    results = []
    for page in pages:
        score = score_page(page, query_tokens, doc_freq, len(pages))
        if score <= 0:
            continue
        results.append({
            "score": round(score, 4),
            "id": page["id"],
            "title": page["title"],
            "type": page["type"],
            "path": page["path"],
            "preview": page["body_preview"],
        })

    results.sort(key=lambda item: (-item["score"], item["title"].lower()))
    results = results[: args.top]

    if args.json:
        print(json.dumps({"query": args.query, "results": results}, ensure_ascii=False, indent=2))
        return

    print(f"# Search Results: {args.query}")
    print("")
    if not results:
        print("- No matches")
        return

    for item in results:
        print(f"- {item['title']} ({item['type']}, score={item['score']})")
        print(f"  path: {item['path']}")
        print(f"  preview: {item['preview']}")


if __name__ == "__main__":
    main()
