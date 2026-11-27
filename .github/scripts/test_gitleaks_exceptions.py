import datetime as dt
import hashlib
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

    def test_scanner_limits_exceptions_to_approved_lines_and_path(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "scan"
            target = root / ".github/scripts/trufflehog_exceptions.py"
            target.parent.mkdir(parents=True)
            config = Path(directory) / "gitleaks.toml"
            config.write_text(guard.configuration(ROOT, self.records, guard.APPROVED_AT))
            lines = [f'    "{record["path"]}": "{record["sha256"]}",' for record in self.records["exceptions"]]
            approved = "\n".join(lines) + "\n"

            def scan(expected, configured=True, history=False):
                command = ["docker", "run", "--rm", "--network", "none",
                           "-v", f"{root}:/scan:ro", "-v", f"{config}:/config/gitleaks.toml:ro",
                           "zricethezav/gitleaks:v8.28.0", "detect", "--source=/scan",
                           "--redact", "--no-color", "--verbose", "--exit-code=42"]
                if not history:
                    command.append("--no-git")
                if configured:
                    command.append("--config=/config/gitleaks.toml")
                result = subprocess.run(command, capture_output=True, text=True, check=False)
                findings = (result.stdout + result.stderr).count("RuleID:")
                self.assertEqual((result.returncode, findings), (42 if expected else 0, expected))

            target.write_text(approved)
            scan(2, configured=False)
            scan(0)
            changed = hashlib.sha256(b"harmless changed digest fixture").hexdigest()
            target.write_text(approved.replace(self.records["exceptions"][0]["sha256"], changed, 1))
            scan(1)
            target.write_text(approved.replace(lines[0], lines[0] + " # changed", 1))
            scan(1)
            token = "ghp_" + "a1B2c3D4e5F6g7H8i9J0k1L2m3N4o5P6q7R8"
            target.write_text(approved + f'api_key = "{token}"\n')
            scan(1)
            target.write_text(approved)
            other = root / "other.py"
            other.write_text(approved)
            scan(2)
            other.write_text(f'api_key = "{token}"\n')
            scan(1)
            other.unlink()

            def git(*args):
                subprocess.run(["git", "-C", str(root), *args], capture_output=True, check=True)

            git("init", "-q")
            git("add", ".")
            git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                "-c", "commit.gpgsign=false", "commit", "-qm", "approved lines")
            scan(0, history=True)
            target.write_text(approved + f'api_key = "{token}"\n')
            git("add", ".")
            git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                "-c", "commit.gpgsign=false", "commit", "-qm", "synthetic finding")
            target.write_text(approved)
            git("add", ".")
            git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                "-c", "commit.gpgsign=false", "commit", "-qm", "remove synthetic finding")
            scan(1, history=True)


if __name__ == "__main__":
    unittest.main()
