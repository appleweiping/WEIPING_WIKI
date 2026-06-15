"""Tests for the project-hardness engine.

Run: python scripts/hardness/test_hardness.py
(stdlib unittest; no external deps, no network — sync tests use dry-run.)
"""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from hardness import engine
from hardness.analyzer import analyze, blast_radius
from hardness.harden import harden_task
from hardness.memory_sync import is_cross_project_lesson, sync_lessons
from hardness.scanner import classify_file, is_secret_file, scan_project


def _make_fixture(root: Path) -> None:
    (root / "backend" / "engine").mkdir(parents=True)
    (root / "backend" / "providers").mkdir(parents=True)
    (root / "tests").mkdir()
    (root / "backend" / "__init__.py").write_text("", encoding="utf-8")
    (root / "backend" / "api.py").write_text(
        "from backend.engine import core\n"
        "from fastapi import FastAPI\n"
        "app = FastAPI()\n"
        "@app.get('/health')\n"
        "def health():\n    return core.status()\n"
        "@app.post('/query')\n"
        "def query():\n    return core.run()\n",
        encoding="utf-8")
    (root / "backend" / "engine" / "core.py").write_text(
        "from backend.providers import openai_provider\n"
        "class Engine:\n    pass\n"
        "def status():\n    return 'ok'\n"
        "def run():\n    return openai_provider.call()\n",
        encoding="utf-8")
    (root / "backend" / "providers" / "openai_provider.py").write_text(
        "def call():\n    return 1\n", encoding="utf-8")
    (root / "backend" / "models.py").write_text(
        "from pydantic import BaseModel\n"
        "class User(BaseModel):\n    id: int\n    name: str\n",
        encoding="utf-8")
    (root / "tests" / "test_core.py").write_text(
        "from backend.engine import core\n"
        "def test_status():\n    assert core.status() == 'ok'\n",
        encoding="utf-8")
    (root / "requirements.txt").write_text("fastapi\npydantic\n", encoding="utf-8")
    (root / ".env").write_text("SECRET_KEY=should-never-be-read\n", encoding="utf-8")


class TestScanner(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        _make_fixture(self.root)
        self.model = analyze(scan_project(str(self.root)))

    def tearDown(self):
        self.tmp.cleanup()

    def test_modules_detected(self):
        names = {m.name for m in self.model.modules}
        self.assertIn("backend/engine", names)
        self.assertIn("backend/providers", names)

    def test_routes_extracted(self):
        paths = {(r.method, r.path) for r in self.model.routes}
        self.assertIn(("GET", "/health"), paths)
        self.assertIn(("POST", "/query"), paths)

    def test_entities_extracted(self):
        self.assertIn("User", {e.name for e in self.model.entities})

    def test_framework_detected(self):
        self.assertIn("FastAPI", self.model.frameworks)

    def test_secret_never_read(self):
        # .env must be flagged as a block constraint, never read
        env_constraints = [c for c in self.model.constraints if c.scope == ".env"]
        self.assertTrue(env_constraints)
        self.assertEqual(env_constraints[0].severity, "block")

    def test_internal_dependency_resolved(self):
        eng = next(m for m in self.model.modules if m.name == "backend/engine")
        self.assertIn("backend/providers", eng.depends_on)

    def test_blast_radius(self):
        br = blast_radius(self.model, "backend/providers")
        # engine depends on providers; api depends on engine
        self.assertGreaterEqual(br["impacted_total"], 1)


class TestSecretClassifier(unittest.TestCase):
    def test_is_secret(self):
        self.assertTrue(is_secret_file(".env"))
        self.assertTrue(is_secret_file("config/server.key"))
        self.assertFalse(is_secret_file(".env.example"))
        self.assertFalse(is_secret_file("main.py"))

    def test_classify(self):
        self.assertEqual(classify_file("tests/test_x.py", ".py"), "test")
        self.assertEqual(classify_file("schema.sql", ".sql"), "schema")
        self.assertEqual(classify_file("README.md", ".md"), "docs")


class TestHarden(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        _make_fixture(self.root)
        self.model = analyze(scan_project(str(self.root)))

    def tearDown(self):
        self.tmp.cleanup()

    def test_harden_produces_spec(self):
        spec = harden_task(self.model, "add retry to the provider call", task_id="t1")
        self.assertEqual(spec["id"], "t1")
        self.assertTrue(spec["acceptance_criteria"])
        self.assertTrue(spec["test_commands"])
        self.assertTrue(any("pytest" in c for c in spec["test_commands"]))


class TestMemoryBoundary(unittest.TestCase):
    def test_lesson_vs_fact_guard(self):
        self.assertTrue(is_cross_project_lesson(
            "Always flush SSE events or the client buffers the whole stream"))
        self.assertFalse(is_cross_project_lesson(
            "backend/engine/core.py line 42 calls run()"))

    def test_sync_rejects_facts_dry_run(self):
        report = sync_lessons(
            ["Prefer pinned dependency versions for reproducibility",
             "src/app.py imports the config module"],
            project="fixture", dry_run=True)
        self.assertEqual(len(report["accepted"]), 1)
        self.assertEqual(len(report["rejected_as_project_facts"]), 1)
        self.assertEqual(report["synced"], 0)


class TestEndToEnd(unittest.TestCase):
    def test_scan_writes_agent_dir(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            _make_fixture(root)
            result = engine.scan(str(root))
            agent_dir = Path(result["agent_dir"])
            for art in ("architecture.md", "glossary.md", "constraints.md",
                        "decisions.md", "entities.json", "causal-graph.json", "index.json"):
                self.assertTrue((agent_dir / art).exists(), f"missing {art}")
            graph = json.loads((agent_dir / "causal-graph.json").read_text(encoding="utf-8"))
            self.assertTrue(graph["nodes"])
            self.assertTrue(graph["edges"])
            # Non-git dir: tracked files must NOT be touched (no root .gitignore created)
            self.assertFalse((root / ".gitignore").exists())

    def test_git_repo_uses_local_exclude(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            _make_fixture(root)
            (root / ".git" / "info").mkdir(parents=True)
            engine.scan(str(root))
            # .agent/ ignored via LOCAL exclude, not the tracked .gitignore
            exclude = (root / ".git" / "info" / "exclude").read_text(encoding="utf-8")
            self.assertIn(".agent", exclude)
            self.assertFalse((root / ".gitignore").exists())


class TestDiscover(unittest.TestCase):
    def test_discover_dedups_and_excludes(self):
        from hardness import discover
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            # a real project
            (root / "proj_a").mkdir()
            (root / "proj_a" / "requirements.txt").write_text("flask\n", encoding="utf-8")
            # an excluded archive
            (root / "proj_b_backup").mkdir()
            (root / "proj_b_backup" / "package.json").write_text("{}", encoding="utf-8")
            # a third-party upstream by name
            (root / "agentmemory").mkdir()
            (root / "agentmemory" / "package.json").write_text("{}", encoding="utf-8")
            # a non-project dir
            (root / "just_files").mkdir()
            (root / "just_files" / "notes.txt").write_text("x", encoding="utf-8")
            found = {p.name for p in discover.discover(roots=[str(root)])}
            self.assertIn("proj_a", found)
            self.assertNotIn("proj_b_backup", found)
            self.assertNotIn("agentmemory", found)
            self.assertNotIn("just_files", found)


class TestAuto(unittest.TestCase):
    def test_decisions_new_skip_change(self):
        from hardness import auto
        from hardness.auto import _write_state, fingerprint, decide
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            _make_fixture(root)
            # 1) 全新项目 (没有 .agent) -> "new"
            self.assertEqual(decide(root)[0], "new")
            # hardening + 建基线
            engine.scan(str(root))
            _write_state(root / ".agent", fingerprint(root))
            # 2) 没变化 -> "skip"
            self.assertEqual(decide(root)[0], "skip")
            # 3) 大改动 (新增超过阈值的代码文件) -> 触发重扫
            pkg = root / "newpkg"
            pkg.mkdir()
            for i in range(20):
                (pkg / f"mod{i}.py").write_text(f"def f{i}():\n    return {i}\n", encoding="utf-8")
            self.assertIn(decide(root, threshold=15)[0],
                          ("content-change", "content-change-nogit", "git-change"))


class TestDiskAudit(unittest.TestCase):
    """Feature B: canonical disk-audit ledger writer (advisory, NEVER safe-delete)."""

    def _export(self, inputs, audit_dir, overrides=None):
        from hardness import audit
        if overrides is not None:
            (audit_dir / "overrides.json").write_text(
                json.dumps({"overrides": overrides}), encoding="utf-8")
        path = audit.export_audit(inputs, audit_dir=audit_dir)
        return json.loads(Path(path).read_text(encoding="utf-8"))

    def test_keep_default_for_git(self):
        with tempfile.TemporaryDirectory() as d:
            ad = Path(d) / "audit"; ad.mkdir()
            data = self._export([
                {"name": "Proj", "root": str(Path(d) / "proj"),
                 "fp": {"git_head": "a1b2c3d4e5f6", "code_file_count": 100},
                 "state": {"hardened_at": "2026-06-12 13:17:00"}, "decision": "skip"},
            ], ad)
            rec = data["projects"][0]
            self.assertEqual(rec["verdict"], "keep")
            self.assertTrue(rec["is_git"])
            self.assertEqual(rec["git_head"], "a1b2c3d4")

    def test_quarantine_requires_all_signals(self):
        import os, time
        with tempfile.TemporaryDirectory() as d:
            ad = Path(d) / "audit"; ad.mkdir()
            scratch = Path(d) / "old-backup"; scratch.mkdir()
            old = time.time() - 200 * 86400
            os.utime(scratch, (old, old))
            data = self._export([
                {"name": "old-backup", "root": str(scratch),
                 "fp": {"git_head": None, "code_file_count": 0},
                 "state": None, "decision": "content-change-nogit"},
            ], ad)
            self.assertEqual(data["projects"][0]["verdict"], "quarantine")

    def test_recent_scratch_stays_keep(self):
        with tempfile.TemporaryDirectory() as d:
            ad = Path(d) / "audit"; ad.mkdir()
            scratch = Path(d) / "tmp-thing"; scratch.mkdir()  # recent mtime
            data = self._export([
                {"name": "tmp-thing", "root": str(scratch),
                 "fp": {"git_head": None, "code_file_count": 0},
                 "state": None, "decision": "content-change-nogit"},
            ], ad)
            self.assertEqual(data["projects"][0]["verdict"], "keep")

    def test_incomplete_scan_forces_keep(self):
        with tempfile.TemporaryDirectory() as d:
            ad = Path(d) / "audit"; ad.mkdir()
            data = self._export([
                {"name": "Broken", "root": str(Path(d) / "broken"),
                 "fp": None, "state": None, "decision": "error"},
            ], ad)
            rec = data["projects"][0]
            self.assertEqual(rec["verdict"], "keep")
            self.assertFalse(rec["scan_complete"])

    def test_never_safe_delete(self):
        import os, time
        with tempfile.TemporaryDirectory() as d:
            ad = Path(d) / "audit"; ad.mkdir()
            scratch = Path(d) / "old-tmp"; scratch.mkdir()
            old = time.time() - 400 * 86400
            os.utime(scratch, (old, old))
            inputs = [
                {"name": "git", "root": str(Path(d)),
                 "fp": {"git_head": "deadbeef", "code_file_count": 5}, "state": None, "decision": "skip"},
                {"name": "old-tmp", "root": str(scratch),
                 "fp": {"git_head": None, "code_file_count": 0}, "state": None, "decision": "content-change-nogit"},
                {"name": "err", "root": "X", "fp": None, "state": None, "decision": "error"},
            ]
            data = self._export(inputs, ad)
            for rec in data["projects"]:
                self.assertIn(rec["verdict"], ("keep", "quarantine"))

    def test_override_wins(self):
        import os, time
        with tempfile.TemporaryDirectory() as d:
            ad = Path(d) / "audit"; ad.mkdir()
            scratch = Path(d) / "old-backup"; scratch.mkdir()
            old = time.time() - 200 * 86400
            os.utime(scratch, (old, old))
            root_norm = str(scratch).replace("\\", "/").rstrip("/")
            data = self._export([
                {"name": "old-backup", "root": str(scratch),
                 "fp": {"git_head": None, "code_file_count": 0},
                 "state": None, "decision": "content-change-nogit"},
            ], ad, overrides={root_norm: {"verdict": "keep", "reason": "owner pinned"}})
            rec = data["projects"][0]
            self.assertEqual(rec["verdict"], "keep")
            self.assertEqual(rec["decided_by"], "override")


if __name__ == "__main__":
    unittest.main(verbosity=2)
