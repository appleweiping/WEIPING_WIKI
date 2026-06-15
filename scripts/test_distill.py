"""Tests for the prompt distiller (Feature A).

Run: python scripts/test_distill.py   (stdlib unittest; no network, no real corpus)
"""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import distill  # noqa: E402


class TestRedact(unittest.TestCase):
    def test_drops_secret_turns(self):
        self.assertIsNone(distill.redact("my key is sk-ABCDEFGHIJKLMNOP1234"))
        # split prefix so the file never contains a literal ghp_+token (pre-push secret gate)
        self.assertIsNone(distill.redact("gh" + "p_ABCDEFGHIJKLMNOPQRSTUVWXYZ012345 is the token"))
        self.assertIsNone(distill.redact("email me at foo@example.com please"))
        self.assertIsNone(distill.redact("owner is BensonHalefdo@theplate.com"))
        self.assertIsNone(distill.redact("set password=hunter2 now"))

    def test_scrubs_but_keeps(self):
        out = distill.redact(r"audit D:\Research\foo with id 1234567 and abcdef0123456789abcdef0123456789ab")
        self.assertIsNotNone(out)
        self.assertIn("<path>", out)
        self.assertIn("<n>", out)
        self.assertIn("<token>", out)
        self.assertNotIn("Research", out)


class TestClassify(unittest.TestCase):
    def test_intents_bilingual(self):
        self.assertEqual(distill.classify_intent("帮我审计整理一下d盘垃圾"), "audit-cleanup")
        self.assertEqual(distill.classify_intent("把这个项目迁移到别的文件夹"), "migrate-relocate")
        self.assertEqual(distill.classify_intent("distill prompts into a skill"), "skill-memory")
        self.assertEqual(distill.classify_intent("调整网页css样式"), "frontend-ui")
        self.assertEqual(distill.classify_intent("随便聊聊天气"), "other")

    def test_deterministic(self):
        self.assertEqual(distill.classify_intent("优化前端"), distill.classify_intent("优化前端"))


class TestExtraction(unittest.TestCase):
    def test_history_and_sessions(self):
        with tempfile.TemporaryDirectory() as d:
            d = Path(d)
            hist = d / "history.jsonl"
            hist.write_text(
                json.dumps({"display": "帮我审计整理d盘垃圾文件", "project": "D:\\X",
                            "timestamp": "2026-06-10T00:00:00Z"}, ensure_ascii=False) + "\n"
                + json.dumps({"display": "/clear"}, ensure_ascii=False) + "\n"
                + json.dumps({"display": "hi"}, ensure_ascii=False) + "\n",
                encoding="utf-8")
            sess = d / "sessions"
            sess.mkdir()
            (sess / "pidstub.json").write_text(json.dumps({"pid": 1, "kind": "interactive"}),
                                               encoding="utf-8")
            (sess / "s1.json").write_text(json.dumps({"messages": [
                {"role": "user", "blocks": [
                    {"text": "<system-reminder>noise</system-reminder>"},
                    {"text": "调整网页css样式布局"}]},
                {"role": "assistant", "blocks": [{"text": "ok"}]},
            ]}, ensure_ascii=False), encoding="utf-8")
            distill.CLAUDE_HISTORY = hist
            distill.CLAUDE_SESSIONS = sess
            res = distill.distill(min_count=1, since_days=100000)
            # "/clear" + "hi" dropped from history; system-reminder block dropped from session
            self.assertEqual(res["turns_extracted"], 2)
            keys = {c["pattern_key"] for c in res["clusters"]}
            self.assertIn("audit-cleanup", keys)
            self.assertIn("frontend-ui", keys)
            self.assertEqual(res["sources_read"]["sessions"], 1)  # only one valid user turn


class TestApplyMerge(unittest.TestCase):
    def test_preserves_pinned_and_edited(self):
        result = {"clusters": [{"pattern_key": "audit-cleanup", "count": 5, "first_seen": "a",
                                "last_seen": "b", "top_projects": ["X"],
                                "suggested_skill": "workstation-maintenance", "example_clauses": []}],
                  "turns_extracted": 5, "turns_dropped_redacted": 0, "min_count": 4,
                  "since_days": 180, "sources_read": {}}
        cols = distill._COLS
        prior = ("| " + " | ".join(cols) + " |\n"
                 + "|" + "|".join(["---"] * len(cols)) + "|\n"
                 + "| audit-cleanup | 3 | old | Z | workstation-maintenance | MY EDIT | yes |\n"
                 + "| legacy-pinned | 9 | x | Y | - | keep me | yes |\n")
        md = distill.render_apply(result, prior)
        self.assertIn("MY EDIT", md)         # human-edited canonical preserved on regen
        self.assertIn("legacy-pinned", md)   # pinned-only survivor kept
        self.assertIn("| 5 |", md)           # count refreshed to new value
        self.assertIn("privacy: redacted-clauses-only", md)

    def test_idempotent(self):
        result = {"clusters": [{"pattern_key": "skill-memory", "count": 7, "first_seen": "a",
                                "last_seen": "b", "top_projects": ["X"], "suggested_skill": "",
                                "example_clauses": []}],
                  "turns_extracted": 7, "turns_dropped_redacted": 0, "min_count": 4,
                  "since_days": 180, "sources_read": {}}
        md1 = distill.render_apply(result, "")
        md2 = distill.render_apply(result, md1)
        # same rows both times (ignoring the regenerated `updated:` timestamp line)
        rows1 = [l for l in md1.splitlines() if l.startswith("| skill-memory")]
        rows2 = [l for l in md2.splitlines() if l.startswith("| skill-memory")]
        self.assertEqual(rows1, rows2)
        self.assertEqual(len(rows2), 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
