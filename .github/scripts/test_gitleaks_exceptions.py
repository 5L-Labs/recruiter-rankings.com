import datetime as dt
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import gitleaks_exceptions as guard


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / ".github/scripts/gitleaks_exceptions.py"
METADATA = ROOT / ".github/trufflehog-exceptions.json"


class GitleaksExceptionTest(unittest.TestCase):
    def setUp(self):
        self.records = json.loads(METADATA.read_text())

    def test_approval_window_includes_start_and_excludes_expiry(self):
        for now in (guard.APPROVED_AT, guard.EXPIRES_AT - dt.timedelta(microseconds=1)):
            with self.subTest(now=now):
                self.assertIn('id = "generic-api-key"', guard.configuration(ROOT, self.records, now))
        for now in (guard.APPROVED_AT - dt.timedelta(microseconds=1), guard.EXPIRES_AT,
                    guard.APPROVED_AT.replace(tzinfo=None)):
            with self.subTest(now=now), self.assertRaises(ValueError):
                guard.configuration(ROOT, self.records, now)

    def test_changed_approval_and_missing_ciphertext_fail(self):
        self.records["exceptions"][0]["owner"] = "other"
        with self.assertRaises(ValueError):
            guard.configuration(ROOT, self.records, guard.APPROVED_AT)
        self.records = json.loads(METADATA.read_text())
        with tempfile.TemporaryDirectory() as root, self.assertRaises(OSError):
            guard.configuration(root, self.records, guard.APPROVED_AT)

    def test_cli_rejects_existing_output_and_invalid_metadata(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "config"
            output.write_text("unchanged")
            result = subprocess.run([sys.executable, str(SCRIPT), str(ROOT), str(METADATA), str(output)],
                                    capture_output=True, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(output.read_text(), "unchanged")
            output.unlink()
            invalid = Path(directory) / "invalid.json"
            invalid.write_text('{"version": 1, "version": 1, "exceptions": []}')
            result = subprocess.run([sys.executable, str(SCRIPT), str(ROOT), str(invalid), str(output)],
                                    capture_output=True, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(output.exists())

    def test_expired_cli_leaves_no_configuration(self):
        class ExpiredDateTime(dt.datetime):
            @classmethod
            def now(cls, tz=None):
                return cls(2026, 12, 26, 8, 46, 7, tzinfo=tz)

        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "config"
            args = [str(SCRIPT), str(ROOT), str(METADATA), str(output)]
            with patch.object(guard.dt, "datetime", ExpiredDateTime), patch.object(sys, "argv", args):
                self.assertEqual(guard.main(), 1)
            self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
