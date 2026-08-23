from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path


SCRIPTS_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPTS_DIR))

from wiki_core import (  # noqa: E402
    build_catalog,
    build_evidence_pack,
    load_catalog_if_fresh,
    resolve_public_wiki_path,
)


def _load_context_module():
    path = SCRIPTS_DIR / "wiki-context.py"
    spec = importlib.util.spec_from_file_location("wiki_context_under_test", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


CONTEXT = _load_context_module()


class EvidenceContextPackTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        (self.root / "wiki" / "concepts").mkdir(parents=True)
        (self.root / "wiki" / "sources").mkdir(parents=True)

    def tearDown(self):
        self.tempdir.cleanup()

    def _write(self, relative: str, text: str) -> Path:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text.strip() + "\n", encoding="utf-8")
        return path

    def _seed_pages(self):
        self._write(
            "wiki/concepts/calibration.md",
            """
---
title: Calibration Under Shift
type: concept
tags:
  - recommendation
source_files:
  - papers/calibration.pdf
---
# Calibration Under Shift

This introduction is intentionally generic and should not be the best excerpt.

## Operational Test

Calibration under shift requires measuring coverage on the deployment
distribution, not only on the training split. This is the decisive evidence.

See [[evidence-ledger]].
""",
        )
        self._write(
            "wiki/sources/evidence-ledger.md",
            """
---
title: Evidence Ledger
type: source
---
# Evidence Ledger

The ledger records provenance, experiment identifiers, and confidence labels.
""",
        )
        self._write(
            "wiki/concepts/unrelated.md",
            """
---
title: Unrelated Note
type: concept
---
# Unrelated Note

This page discusses a completely different subject.
""",
        )

    def test_selects_heading_scoped_excerpt_with_provenance_and_budget(self):
        self._seed_pages()
        pack = build_evidence_pack(
            self.root,
            build_catalog(self.root),
            "calibration under shift",
            top=1,
            max_chars=260,
            max_source_chars=260,
        )

        self.assertEqual(pack["returned"], 1)
        self.assertLessEqual(pack["excerpt_chars_used"], 260)
        citation = pack["citations"][0]
        self.assertEqual(citation["citation_id"], "W1")
        self.assertEqual(citation["section"], "Operational Test")
        self.assertIn("deployment", citation["excerpt"])
        self.assertEqual(citation["source_files"], ["papers/calibration.pdf"])

    def test_graph_mode_adds_linked_page_and_explains_seed(self):
        self._seed_pages()
        pack = build_evidence_pack(
            self.root,
            build_catalog(self.root),
            "calibration under shift",
            top=3,
            use_graph=True,
        )

        by_id = {item["id"]: item for item in pack["citations"]}
        self.assertEqual(pack["citations"][0]["via"], "bm25")
        self.assertLessEqual(sum(item["via"] == "graph" for item in pack["citations"]), 1)
        self.assertIn("sources/evidence-ledger", by_id)
        linked = by_id["sources/evidence-ledger"]
        self.assertEqual(linked["via"], "graph")
        self.assertEqual(linked["connected_to"], "concepts/calibration")

    def test_truncated_excerpt_never_exceeds_declared_budget(self):
        self._write(
            "wiki/concepts/long.md",
            """
---
title: Long Evidence
type: concept
---
# Long Evidence

## Findings

""" + ("context before marker " * 40) + "needle-marker " + ("context after marker " * 40),
        )
        pack = build_evidence_pack(
            self.root,
            build_catalog(self.root),
            "needle-marker",
            top=1,
            max_chars=200,
            max_source_chars=120,
        )

        self.assertTrue(pack["citations"][0]["truncated"])
        self.assertLessEqual(len(pack["citations"][0]["excerpt"]), 120)
        self.assertLessEqual(pack["excerpt_chars_used"], 200)

    def test_query_pack_rebuilds_a_stale_catalog_in_memory(self):
        self._seed_pages()
        catalog_path = self.root / "wiki" / "catalog.json"
        catalog_path.write_text(json.dumps(build_catalog(self.root)), encoding="utf-8")
        os.utime(catalog_path, (1, 1))
        self._write(
            "wiki/concepts/live-update.md",
            """
---
title: Live Update
type: concept
---
# Live Update

The never-stale-marker is visible without rewriting catalog.json.
""",
        )

        payload = json.loads(
            CONTEXT.query_pack(
                self.root,
                "never-stale-marker",
                2,
                as_json=True,
            )
        )
        self.assertEqual(payload["catalog"], "in-memory:stale")
        self.assertEqual(payload["citations"][0]["id"], "concepts/live-update")
        self.assertIn("never-stale-marker", CONTEXT.page_pack(self.root, "live-update"))

    def test_corrupt_catalog_falls_back_without_mutating_it(self):
        self._seed_pages()
        catalog_path = self.root / "wiki" / "catalog.json"
        catalog_path.write_text("{not valid json", encoding="utf-8")
        future = time.time() + 60
        os.utime(catalog_path, (future, future))

        payload = json.loads(
            CONTEXT.query_pack(self.root, "calibration under shift", 1, as_json=True)
        )
        self.assertEqual(payload["catalog"], "in-memory:invalid-catalog")
        self.assertEqual(catalog_path.read_text(encoding="utf-8"), "{not valid json")

    def test_catalog_path_escape_is_rebuilt_without_reading_private_file(self):
        self._seed_pages()
        private = self._write("private-marker.md", "must-never-enter-context")
        catalog = build_catalog(self.root)
        catalog["pages"][0]["path"] = private.relative_to(self.root).as_posix()
        catalog["pages"][0]["search_text"] = "must-never-enter-context"
        catalog_path = self.root / "wiki" / "catalog.json"
        catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
        future = time.time() + 60
        os.utime(catalog_path, (future, future))

        payload = json.loads(
            CONTEXT.query_pack(self.root, "must-never-enter-context", 2, as_json=True)
        )
        self.assertEqual(payload["catalog"], "in-memory:invalid-catalog")
        self.assertNotIn(
            "must-never-enter-context",
            " ".join(item["excerpt"] for item in payload["citations"]),
        )
        direct_pack = build_evidence_pack(
            self.root,
            catalog,
            "must-never-enter-context",
            top=1,
        )
        self.assertEqual(direct_pack["returned"], 0)

    def test_markdown_pack_emits_stable_local_citations(self):
        self._seed_pages()
        output = CONTEXT.query_pack(
            self.root,
            "calibration under shift",
            2,
            graph=True,
            max_chars=800,
            max_source_chars=400,
        )
        self.assertIn("# L2 Evidence Pack", output)
        self.assertIn("## [W1] Calibration Under Shift", output)
        self.assertIn("wiki/concepts/calibration.md", output)
        self.assertIn("citation rule", output)

    def test_catalog_build_never_reads_external_markdown_symlink(self):
        self._seed_pages()
        private = self._write("outside-public-wiki.md", "external-symlink-secret-marker")
        link = self.root / "wiki" / "concepts" / "escaped.md"
        try:
            link.symlink_to(private)
        except (OSError, NotImplementedError) as exc:
            self.skipTest(f"symlinks unavailable: {exc}")

        self.assertIsNone(resolve_public_wiki_path(self.root, "wiki/concepts/escaped.md"))
        serialized = json.dumps(build_catalog(self.root), ensure_ascii=False)
        self.assertNotIn("external-symlink-secret-marker", serialized)
        self.assertNotIn("concepts/escaped", serialized)

    def test_future_dated_catalog_cannot_hide_changed_page_content(self):
        self._seed_pages()
        catalog_path = self.root / "wiki" / "catalog.json"
        catalog_path.write_text(json.dumps(build_catalog(self.root)), encoding="utf-8")
        self._write(
            "wiki/concepts/calibration.md",
            """
---
title: Calibration Under Shift
type: concept
---
# Calibration Under Shift

## Live Evidence

digest-detected-live-marker is present after the cached catalog was built.
""",
        )
        future = time.time() + 3600
        os.utime(catalog_path, (future, future))

        payload = json.loads(
            CONTEXT.query_pack(self.root, "digest-detected-live-marker", 1, as_json=True)
        )
        self.assertEqual(payload["catalog"], "in-memory:stale")
        self.assertIn("digest-detected-live-marker", payload["citations"][0]["excerpt"])

    def test_catalog_metadata_tamper_degrades_to_live_catalog(self):
        self._seed_pages()
        catalog = build_catalog(self.root)
        calibration = next(p for p in catalog["pages"] if p["id"] == "concepts/calibration")
        calibration["title"] = "Spoofed Catalog Title"
        calibration["source_files"] = ["C:/Users/admin/private-token.txt"]
        catalog_path = self.root / "wiki" / "catalog.json"
        catalog_path.write_text(json.dumps(catalog), encoding="utf-8")
        future = time.time() + 3600
        os.utime(catalog_path, (future, future))

        loaded, state = load_catalog_if_fresh(self.root)
        self.assertIsNone(loaded)
        self.assertEqual(state, "invalid")
        payload = json.loads(
            CONTEXT.query_pack(self.root, "calibration under shift", 1, as_json=True)
        )
        self.assertEqual(payload["catalog"], "in-memory:invalid-catalog")
        self.assertEqual(payload["citations"][0]["title"], "Calibration Under Shift")
        self.assertEqual(payload["citations"][0]["source_files"], ["papers/calibration.pdf"])

    def test_citation_provenance_is_live_hashed_and_public_safe(self):
        self._write(
            "wiki/sources/provenance.md",
            """
---
title: Provenance Record
type: source
source_files:
  - docs/public-evidence.md
  - D:/Research/private-layout/secret.md
  - ../outside.md
  - wiki-private/account.md
  - https://example.com/evidence?id=token-like-value#fragment
---
# Provenance Record

The provenance-safety-marker is citation evidence.
""",
        )
        catalog = build_catalog(self.root)
        record = catalog["pages"][0]
        record["title"] = "Catalog Spoof"
        record["source_files"] = ["C:/spoofed.txt"]

        citation = build_evidence_pack(
            self.root, catalog, "provenance-safety-marker", top=1
        )["citations"][0]
        self.assertEqual(citation["title"], "Provenance Record")
        self.assertEqual(
            citation["source_files"],
            ["docs/public-evidence.md", "https://example.com/evidence"],
        )
        self.assertEqual(citation["redacted_source_files"], 3)
        self.assertRegex(citation["page_sha256"], r"^[0-9a-f]{64}$")
        self.assertNotIn("Research", json.dumps(citation))
        self.assertNotIn("wiki-private", json.dumps(citation))

    def test_graph_lane_is_seed_balanced_budgeted_and_deterministic(self):
        for seed, links in (
            ("a-seed", ["a-neighbor-one", "a-neighbor-two"]),
            ("b-seed", ["b-neighbor-one", "b-neighbor-two"]),
        ):
            self._write(
                f"wiki/concepts/{seed}.md",
                "---\ntitle: " + seed + "\ntype: concept\n---\n# " + seed
                + "\n\nrare-balanced-query direct evidence.\n\n"
                + " ".join(f"[[{link}]]" for link in links),
            )
            for link in links:
                self._write(
                    f"wiki/sources/{link}.md",
                    f"---\ntitle: {link}\ntype: source\n---\n# {link}\n\n"
                    + ("linked graph evidence " * 30),
                )

        catalog = build_catalog(self.root)
        first = build_evidence_pack(
            self.root,
            catalog,
            "rare-balanced-query",
            top=6,
            max_chars=320,
            max_source_chars=200,
            use_graph=True,
        )
        reversed_catalog = {"meta": catalog["meta"], "pages": list(reversed(catalog["pages"]))}
        second = build_evidence_pack(
            self.root,
            reversed_catalog,
            "rare-balanced-query",
            top=6,
            max_chars=320,
            max_source_chars=200,
            use_graph=True,
        )
        graph_items = [item for item in first["citations"] if item["via"] == "graph"]
        self.assertEqual(
            {item["connected_to"] for item in graph_items},
            {"concepts/a-seed", "concepts/b-seed"},
        )
        self.assertLessEqual(first["excerpt_chars_used"], 320)
        self.assertEqual(len(graph_items), 2)
        self.assertEqual(
            [(item["id"], item["via"], item["connected_to"]) for item in first["citations"]],
            [(item["id"], item["via"], item["connected_to"]) for item in second["citations"]],
        )

    def test_unified_cli_json_errors_are_structured_and_stdout_clean(self):
        command = [
            sys.executable,
            str(SCRIPTS_DIR / "wiki.py"),
            "context",
            "L2",
            "--json",
            "--root",
            str(self.root),
        ]
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 2)
        self.assertEqual(result.stdout, "")
        error = json.loads(result.stderr)
        self.assertFalse(error["ok"])
        self.assertEqual(error["error"]["code"], "invalid_request")

    def test_unified_cli_accepts_documented_root_position(self):
        self._seed_pages()
        command = [
            sys.executable,
            str(SCRIPTS_DIR / "wiki.py"),
            "context",
            "L2",
            "--query",
            "calibration under shift",
            "--json",
            "--root",
            str(self.root),
        ]
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        self.assertEqual(json.loads(result.stdout)["citations"][0]["id"], "concepts/calibration")

    def test_standalone_context_cli_json_error_is_structured(self):
        result = subprocess.run(
            [sys.executable, str(SCRIPTS_DIR / "wiki-context.py"), "query", "--json"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 2)
        self.assertEqual(result.stdout, "")
        self.assertEqual(json.loads(result.stderr)["error"]["code"], "invalid_request")


if __name__ == "__main__":
    unittest.main()
