import copy
import contextlib
import datetime as dt
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import trufflehog_exceptions as guard


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / ".github/scripts/trufflehog_exceptions.py"
METADATA = ROOT / ".github/trufflehog-exceptions.json"
VALID_TIME = dt.datetime(2026, 11, 26, 8, 46, 7, tzinfo=dt.timezone.utc)


class ExceptionGuardTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo"
        self.root.mkdir()
        self.metadata = Path(self.temp.name) / "records.json"
        self.output = Path(self.temp.name) / "exclusions"
        self.data = json.loads(METADATA.read_text())
        for path in guard.APPROVED_FILES:
            target = self.root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / path, target)
        self.write_metadata()

    def write_metadata(self):
        self.metadata.write_text(json.dumps(self.data))

    def run_guard(self):
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(self.root), str(self.metadata), str(self.output)],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False,
        ).returncode

    def assert_rejected(self):
        self.assertNotEqual(self.run_guard(), 0)
        self.assertFalse(self.output.exists())

    def test_exact_approved_files_generate_only_anchored_exclusions(self):
        self.assertEqual(self.run_guard(), 0)
        self.assertEqual(self.output.read_text().splitlines(), [
            r"^/repo/web/_site/config/credentials\.yml\.enc$",
            r"^/repo/web/config/credentials\.yml\.enc$",
        ])

    def test_changed_missing_and_renamed_files_fail(self):
        path = self.root / "web/config/credentials.yml.enc"
        original = path.read_bytes()
        for case in ("changed", "missing", "renamed"):
            with self.subTest(case=case):
                if case == "changed":
                    path.write_bytes(original + b"x")
                elif case == "missing":
                    path.unlink()
                else:
                    path.rename(path.with_suffix(".other"))
                self.assert_rejected()
                path.write_bytes(original)

    def test_file_and_parent_symlinks_fail(self):
        path = self.root / "web/config/credentials.yml.enc"
        other = self.root / "web/_site/config/credentials.yml.enc"
        path.unlink()
        path.symlink_to(other)
        self.assert_rejected()
        path.unlink()
        shutil.copyfile(other, path)
        config = path.parent
        config.rename(config.with_name("saved-config"))
        config.symlink_to(config.with_name("saved-config"), target_is_directory=True)
        self.assert_rejected()

    def test_invalid_or_unexpected_records_fail(self):
        changes = [
            lambda data: data["exceptions"].pop(),
            lambda data: data["exceptions"].append(copy.deepcopy(data["exceptions"][0])),
            lambda data: data["exceptions"].__setitem__(1, copy.deepcopy(data["exceptions"][0])),
            lambda data: data["exceptions"][0].update(path="web/other.enc"),
            lambda data: data["exceptions"][0].update(sha256="0" * 64),
            lambda data: data["exceptions"][0].update(expires_at="2027-12-26T08:46:07Z"),
            lambda data: data["exceptions"][0].pop("expires_at"),
            lambda data: data["exceptions"][0].pop("owner"),
            lambda data: data["exceptions"][0].update(owner="other"),
            lambda data: data["exceptions"][0].update(rationale=""),
            lambda data: data.update(version=True),
        ]
        for change in changes:
            with self.subTest(change=change):
                self.data = json.loads(METADATA.read_text())
                change(self.data)
                self.write_metadata()
                self.assert_rejected()
        self.metadata.write_text('{"version":1,"version":1,"exceptions":[]}')
        self.assert_rejected()
        self.metadata.write_text('{')
        self.assert_rejected()
        self.metadata.unlink()
        self.assert_rejected()

    def test_approval_time_window_is_closed_at_expiry(self):
        records = json.loads(METADATA.read_text())
        self.assertEqual(len(guard.validate_records(records, VALID_TIME)), 2)
        for time in (VALID_TIME - dt.timedelta(seconds=1),
                     dt.datetime(2026, 12, 26, 8, 46, 7, tzinfo=dt.timezone.utc)):
            with self.subTest(time=time), self.assertRaises(ValueError):
                guard.validate_records(records, time)

    def test_expiry_stops_cli_without_exclusions(self):
        class ExpiredDateTime(dt.datetime):
            @classmethod
            def now(cls, tz=None):
                return cls(2026, 12, 26, 8, 46, 7, tzinfo=tz)

        args = [str(SCRIPT), str(self.root), str(self.metadata), str(self.output)]
        with patch.object(guard.dt, "datetime", ExpiredDateTime), patch.object(sys, "argv", args), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(guard.main(), 1)
        self.assertFalse(self.output.exists())


if __name__ == "__main__":
    unittest.main()
