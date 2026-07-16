from __future__ import annotations

import sys
import unittest
from datetime import date, datetime, timezone
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parents[1]
FIXTURES_DIR = Path(__file__).resolve().parent / "fixtures"
RUNTIME_ROOT = FIXTURES_DIR / "runtime"
sys.path.insert(0, str(SCRIPT_DIR))

from memory_tools import audit_memory, create_ad_hoc_note  # noqa: E402


class AuditMemoryTests(unittest.TestCase):
    def test_default_snapshot_threshold_is_30_days(self) -> None:
        report = audit_memory(
            FIXTURES_DIR / "snapshots" / "MEMORY.md",
            today=date(2026, 7, 16),
        )
        stale_findings = [
            item
            for item in report["findings"]
            if item["kind"] == "stale-snapshot-candidate"
        ]
        self.assertEqual(1, len(stale_findings))
        self.assertIn("older than 30 days", stale_findings[0]["detail"])

    def test_valid_fixture_uses_scoped_headings_and_inherited_revalidation(self) -> None:
        report = audit_memory(
            FIXTURES_DIR / "valid" / "MEMORY.md",
            stale_after_days=5000,
        )
        kinds = {item["kind"] for item in report["findings"]}
        self.assertNotIn("duplicate-heading", kinds)
        self.assertNotIn("possible-current-state-without-revalidation", kinds)
        self.assertNotIn("missing-rollout-summary", kinds)

    def test_issue_fixture_reports_structural_and_safety_findings(self) -> None:
        report = audit_memory(
            FIXTURES_DIR / "issues" / "MEMORY.md",
            stale_after_days=5000,
        )
        kinds = {item["kind"] for item in report["findings"]}
        self.assertTrue(
            {
                "possible-secret",
                "possible-current-state-without-revalidation",
                "duplicate-heading",
                "duplicate-bullet",
                "missing-rollout-summary",
                "duplicate-rollout-reference",
                "snapshot-without-date",
            }.issubset(kinds)
        )


class AdHocNoteTests(unittest.TestCase):
    def test_dry_run_does_not_write_and_apply_writes_only_note(self) -> None:
        generated_memory = RUNTIME_ROOT / "MEMORY.md"
        created_at = datetime(2026, 7, 16, 8, 0, 0, tzinfo=timezone.utc)
        expected_note = (
            RUNTIME_ROOT
            / "extensions"
            / "ad_hoc"
            / "notes"
            / "20260716-080000-consolidate-duplicate-entries.md"
        )
        if expected_note.exists():
            expected_note.unlink()
        try:
            preview = create_ad_hoc_note(
                RUNTIME_ROOT,
                action="rewrite",
                subject="Consolidate duplicate entries",
                details="Replace duplicated bullets with one evidence-backed conclusion.",
                evidence=("MEMORY.md lines 10-12",),
                apply=False,
                created_at=created_at,
            )
            self.assertFalse(Path(preview["path"]).exists())
            self.assertEqual("generated state\n", generated_memory.read_text(encoding="utf-8"))

            applied = create_ad_hoc_note(
                RUNTIME_ROOT,
                action="rewrite",
                subject="Consolidate duplicate entries",
                details="Replace duplicated bullets with one evidence-backed conclusion.",
                evidence=("MEMORY.md lines 10-12",),
                apply=True,
                created_at=created_at,
            )
            self.assertTrue(Path(applied["path"]).is_file())
            self.assertEqual("generated state\n", generated_memory.read_text(encoding="utf-8"))

            with self.assertRaises(FileExistsError):
                create_ad_hoc_note(
                    RUNTIME_ROOT,
                    action="rewrite",
                    subject="Consolidate duplicate entries",
                    details="Replace duplicated bullets with one evidence-backed conclusion.",
                    apply=True,
                    created_at=created_at,
                )
        finally:
            if expected_note.exists():
                expected_note.unlink()

    def test_note_rejects_unredacted_secret(self) -> None:
        with self.assertRaises(ValueError):
            create_ad_hoc_note(
                RUNTIME_ROOT,
                action="add",
                subject="Credential lesson",
                details="API_KEY=real-value-must-not-be-stored",
            )


if __name__ == "__main__":
    unittest.main()
