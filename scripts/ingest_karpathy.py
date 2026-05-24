"""
ingest_karpathy.py — Python replacement for ingest-karpathy-public.ps1

Ingests Karpathy's public work: GitHub repos, blog RSS, YouTube videos.
Uses ingest_github.GitHubIngestor for all heavy lifting.

Usage:
    python scripts/ingest_karpathy.py [--root .] [--dry-run] [--skip-validation]
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from ingest_github import GitHubIngestor, CorpusSource, fetch_rss

REPO_ROOT = Path(__file__).resolve().parent.parent
CORPUS_ID = "karpathy"
WIKI_SECTION = "wiki/sources/karpathy-public"
MANIFEST_PATH = REPO_ROOT / "raw" / "karpathy-public" / "manifest.json"

GITHUB_USERNAME = "karpathy"
BLOG_RSS = "https://karpathy.github.io/feed.xml"
YOUTUBE_RSS = "https://www.youtube.com/feeds/videos.xml?channel_id=UCXUPKJO5MZQN11PqgIvyuvQ"


# ── Category logic (ported from PS1) ──────────────────────────────────────────

def get_category(name: str, desc: str, files: list[str]) -> dict:
    text = f"{name} {desc} {' '.join(files)}".lower()
    if any(k in text for k in ("autoresearch", "agent", "council")):
        return {"Category": "Research automation / agentic science",
                "Tags": ["karpathy", "agents", "research-automation"]}
    if any(k in text for k in ("nanogpt", "mingpt", "gpt", "llm", "llama", "transformer", "chat")):
        return {"Category": "LLM training and inference systems",
                "Tags": ["karpathy", "llm", "training", "inference"]}
    if any(k in text for k in ("token", "bpe", "minbpe")):
        return {"Category": "Tokenization and language modeling",
                "Tags": ["karpathy", "tokenization", "language-modeling"]}
    if any(k in text for k in ("micrograd", "makemore", "zero-to-hero", "backprop", "neural")):
        return {"Category": "Neural network fundamentals",
                "Tags": ["karpathy", "neural-networks", "education"]}
    if any(k in text for k in ("caption", "vision", "image", "convnet", "stable-diffusion")):
        return {"Category": "Vision / multimodal / captioning",
                "Tags": ["karpathy", "vision", "multimodal"]}
    if any(k in text for k in ("arxiv", "paper", "reader", "research")):
        return {"Category": "Research tooling and paper workflows",
                "Tags": ["karpathy", "research-tooling", "papers"]}
    if any(k in text for k in ("javascript", "browser", "convnetjs", "web")):
        return {"Category": "Browser / JavaScript ML experiments",
                "Tags": ["karpathy", "javascript", "browser-ml"]}
    if any(k in text for k in ("course", "lecture", "build", "from-scratch", "101", "zero")):
        return {"Category": "LLM education / from-scratch pedagogy",
                "Tags": ["karpathy", "education", "from-scratch"]}
    return {"Category": "Minimal implementations",
            "Tags": ["karpathy", "minimal-implementation"]}


def get_teaching(category: str, name: str) -> list[str]:
    mapping = {
        "Research automation / agentic science": [
            "How Karpathy frames autonomous research loops, experiment iteration, and AI-assisted discovery.",
            "Useful for designing agent workflows that improve through concrete experiments instead of one-off prompting.",
        ],
        "LLM training and inference systems": [
            "How modern LLM training or inference can be reduced to compact, inspectable systems.",
            "Useful as a reference for building mental models of GPT-style models without hiding behind framework scale.",
        ],
        "Tokenization and language modeling": [
            "How tokenization and sequence modeling mechanics connect to practical LLM behavior.",
            "Useful when debugging prompts, corpora, token budgets, or tokenizer-dependent failures.",
        ],
        "Neural network fundamentals": [
            "How core neural network ideas can be rebuilt from first principles.",
            "Useful for grounding later LLM work in gradients, activations, optimization, and model internals.",
        ],
        "Vision / multimodal / captioning": [
            "How earlier vision and captioning systems connect representation learning with language outputs.",
            "Useful historical context for multimodal LLM research and evaluation.",
        ],
        "Research tooling and paper workflows": [
            "How tooling can compress research reading, search, filtering, and sense-making.",
            "Useful for improving this wiki's own ingest, ranking, and review workflows.",
        ],
        "Browser / JavaScript ML experiments": [
            "How ML ideas can be made interactive and inspectable in the browser.",
            "Useful for teaching interfaces and lightweight demos.",
        ],
        "LLM education / from-scratch pedagogy": [
            "How to teach advanced AI systems by rebuilding the smallest complete version.",
            "Useful as a standard for non-toy educational projects: compact, runnable, and conceptually complete.",
        ],
    }
    return mapping.get(category, [
        "How a complex idea can be compressed into a minimal but working implementation.",
        "Useful as a reference style for serious small systems rather than decorative demos.",
    ])


def get_why_matters(category: str) -> str:
    if "education" in category.lower() or "fundamentals" in category.lower():
        return "This is high-priority for Vipin because it supports durable first-principles understanding instead of shallow API use."
    if "research automation" in category.lower() or "tooling" in category.lower():
        return "This is high-priority for Vipin because it informs agent workflows, paper digestion, wiki maintenance, and autonomous research loops."
    if "llm" in category.lower() or "tokenization" in category.lower():
        return "This is high-priority for Vipin because it connects directly to LLM systems, evaluation, and research implementation judgment."
    return "This matters as part of Karpathy's broader pattern: compress hard technical systems into readable, inspectable, working artifacts."


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Ingest Karpathy public corpus")
    parser.add_argument("--root", default=".", help="Repo root")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--skip-validation", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    ingestor = GitHubIngestor(
        root=root,
        corpus=CORPUS_ID,
        dry_run=args.dry_run,
        skip_validation=args.skip_validation,
    )

    source = CorpusSource(
        kind="github_user",
        url=f"https://github.com/{GITHUB_USERNAME}",
        corpus_id=CORPUS_ID,
        wiki_section=WIKI_SECTION,
        category_fn=get_category,
        teaching_fn=get_teaching,
        why_matters_fn=get_why_matters,
    )

    all_entries = []

    # 1. GitHub repos
    print(f"\n[karpathy] GitHub repos")
    manifest = root / "raw" / "karpathy-public" / "manifest.json"
    entries = ingestor.ingest_github_user(GITHUB_USERNAME, source, manifest)
    all_entries.extend(entries)

    # 2. Blog RSS
    print(f"\n[karpathy] Blog RSS")
    blog_source = CorpusSource(
        kind="rss",
        url=BLOG_RSS,
        corpus_id=CORPUS_ID,
        wiki_section=WIKI_SECTION,
        teaching_fn=lambda cat, name: [
            "How Karpathy frames technical judgment, learning, research, or AI systems in long-form prose.",
            "Useful as a high-signal idea source for research taste, project framing, and agent workflow design.",
        ],
        why_matters_fn=lambda cat: "Karpathy's posts often crystallize reusable heuristics; this wiki should preserve the ideas without relying on chat memory.",
    )
    blog_entries = ingestor.ingest_rss(BLOG_RSS, blog_source, manifest, item_kind="blog")
    all_entries.extend(blog_entries)

    # 3. YouTube RSS
    print(f"\n[karpathy] YouTube RSS")
    yt_source = CorpusSource(
        kind="youtube",
        url=YOUTUBE_RSS,
        corpus_id=CORPUS_ID,
        wiki_section=WIKI_SECTION,
        teaching_fn=lambda cat, name: [
            "How Karpathy explains complex ML systems in accessible, from-scratch video lectures.",
            "Useful as a reference for teaching style, concept sequencing, and minimal-viable explanations.",
        ],
        why_matters_fn=lambda cat: "Karpathy's videos are among the highest-signal ML education resources; preserving their metadata and summaries supports long-term research reference.",
    )
    yt_entries = ingestor.ingest_rss(YOUTUBE_RSS, yt_source, manifest, item_kind="video")
    all_entries.extend(yt_entries)

    # Save manifest
    if not args.dry_run:
        ingestor.save_manifest(all_entries, manifest)
        print(f"\n  Manifest saved: {manifest.relative_to(root)}")

    ingestor.validate()
    ingestor.print_summary()


if __name__ == "__main__":
    main()
