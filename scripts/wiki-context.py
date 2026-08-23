#!/usr/bin/env python
from __future__ import annotations

import argparse
import json
import sys

from wiki_core import (
    build_catalog,
    build_evidence_pack,
    load_catalog_if_fresh,
    read_text,
    recent_log_headings,
    resolve_public_wiki_path,
    resolve_page,
    resolve_root,
)


_JSON_ERROR_MODE = False


def _emit_json_error(code: str, message: str) -> None:
    print(
        json.dumps(
            {"ok": False, "error": {"code": code, "message": str(message)}},
            ensure_ascii=False,
        ),
        file=sys.stderr,
    )


class _ContextArgumentParser(argparse.ArgumentParser):
    def error(self, message):
        if _JSON_ERROR_MODE:
            _emit_json_error("usage_error", message)
            raise SystemExit(2)
        super().error(message)


def l0_pack(root) -> str:
    parts = [
        "# L0 Context Pack",
        "",
        "## Reader Context",
        read_text(root / "reader-context.md").strip(),
        "",
        "## Purpose",
        read_text(root / "purpose.md").strip(),
        "",
        "## Overview",
        read_text(root / "wiki" / "overview.md").strip(),
        "",
        "## Recent Log Headings",
    ]
    parts.extend(f"- {line}" for line in recent_log_headings(root / "wiki" / "log.md"))
    return "\n".join(parts).strip() + "\n"


def l1_pack(root) -> str:
    return read_text(root / "wiki" / "index.md")


def _fresh_catalog(root) -> tuple[dict, str]:
    """Use catalog.json when current, otherwise rebuild read-only in memory."""
    catalog, state = load_catalog_if_fresh(root)
    if catalog is not None:
        return catalog, "catalog.json:fresh"
    label = "invalid-catalog" if state == "invalid" else state
    return build_catalog(root), f"in-memory:{label}"


def _format_evidence_pack(pack: dict) -> str:
    lines = [f"# L2 Evidence Pack: {pack['query']}", ""]
    lines.extend(
        [
            f"- retrieval: {pack['retrieval']}",
            f"- catalog: {pack['catalog']}",
            f"- citations: {pack['returned']} / {pack['requested_top']}",
            f"- excerpt budget: {pack['excerpt_chars_used']} / {pack['excerpt_char_budget']} characters",
            "- citation rule: cite local evidence as `[W1]`, `[W2]`, etc.; paths below are authoritative.",
            "",
        ]
    )
    for item in pack["citations"]:
        lines.append(f"## [{item['citation_id']}] {item['title']}")
        lines.append(f"- id: {item['id']}")
        lines.append(f"- type: {item['type']}")
        lines.append(f"- path: {item['path']}")
        lines.append(f"- page sha256: {item['page_sha256']}")
        lines.append(f"- retrieval: {item['via']} (score {item['score']})")
        if item.get("connected_to"):
            lines.append(f"- graph seed: {item['connected_to']}")
        if item.get("source_pages"):
            lines.append(f"- source pages: {', '.join(item['source_pages'])}")
        if item.get("source_files"):
            lines.append(f"- source files: {', '.join(item['source_files'])}")
        redacted = item.get("redacted_source_pages", 0) + item.get("redacted_source_files", 0)
        if redacted:
            lines.append(f"- local/private provenance omitted: {redacted}")
        section = item.get("section") or "Relevant excerpt"
        suffix = " (trimmed)" if item.get("truncated") else ""
        lines.append(f"- excerpt section: {section}{suffix}")
        lines.append("")
        lines.extend(f"> {line}" if line else ">" for line in item["excerpt"].splitlines())
        lines.append("")
    return "\n".join(lines).strip() + "\n"


def query_pack(
    root,
    query: str,
    top: int,
    graph: bool = False,
    max_chars: int = 12000,
    max_source_chars: int = 2400,
    as_json: bool = False,
) -> str:
    catalog, catalog_state = _fresh_catalog(root)
    pack = build_evidence_pack(
        root,
        catalog,
        query,
        top=top,
        max_chars=max_chars,
        max_source_chars=max_source_chars,
        use_graph=graph,
    )
    pack["catalog"] = catalog_state
    if as_json:
        return json.dumps(pack, ensure_ascii=False, indent=2) + "\n"
    return _format_evidence_pack(pack)


def page_pack(root, page_id: str) -> str:
    catalog, _catalog_state = _fresh_catalog(root)
    page = resolve_page(catalog, page_id)
    if not page:
        raise SystemExit(f"Page not found or ambiguous in catalog: {page_id}")
    page_path = resolve_public_wiki_path(root, page.get("path"))
    if page_path is None:
        raise SystemExit(f"Page path is outside the public wiki: {page_id}")
    return read_text(page_path)


def main(argv: list[str] | None = None) -> None:
    global _JSON_ERROR_MODE
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    raw_args = list(sys.argv[1:] if argv is None else argv)
    _JSON_ERROR_MODE = "--json" in raw_args
    parser = _ContextArgumentParser()
    parser.add_argument("mode", choices=["l0", "l1", "query", "page"])
    parser.add_argument("value", nargs="?")
    parser.add_argument("--root", default=".")
    parser.add_argument("--top", type=int, default=6)
    parser.add_argument("--graph", action="store_true", help="Include 1-hop wiki-link expansion")
    parser.add_argument("--max-chars", type=int, default=12000, help="Total excerpt character budget")
    parser.add_argument("--max-source-chars", type=int, default=2400, help="Per-page excerpt limit")
    parser.add_argument("--json", action="store_true", help="Structured output (query mode only)")
    args = parser.parse_args(raw_args)

    try:
        root = resolve_root(args.root)

        if args.mode == "l0":
            if args.json:
                raise SystemExit("--json is supported only for query mode")
            print(l0_pack(root), end="")
        elif args.mode == "l1":
            if args.json:
                raise SystemExit("--json is supported only for query mode")
            print(l1_pack(root), end="")
        elif args.mode == "query":
            if not args.value:
                raise SystemExit("query mode requires a search string")
            if args.top < 1:
                raise SystemExit("--top must be at least 1")
            if args.max_chars < 200:
                raise SystemExit("--max-chars must be at least 200")
            if args.max_source_chars < 80:
                raise SystemExit("--max-source-chars must be at least 80")
            print(
                query_pack(
                    root,
                    args.value,
                    args.top,
                    graph=args.graph,
                    max_chars=args.max_chars,
                    max_source_chars=args.max_source_chars,
                    as_json=args.json,
                ),
                end="",
            )
        elif args.mode == "page":
            if args.json:
                raise SystemExit("--json is supported only for query mode")
            if not args.value:
                raise SystemExit("page mode requires a page id")
            print(page_pack(root, args.value), end="")
    except SystemExit as exc:
        if _JSON_ERROR_MODE and isinstance(exc.code, str):
            _emit_json_error("invalid_request", exc.code)
            raise SystemExit(2) from None
        raise
    except Exception as exc:
        if _JSON_ERROR_MODE:
            _emit_json_error("runtime_error", str(exc))
            raise SystemExit(1) from None
        raise


if __name__ == "__main__":
    main()
