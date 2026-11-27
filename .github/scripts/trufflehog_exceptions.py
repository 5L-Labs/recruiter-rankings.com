#!/usr/bin/env python3
"""Validate time-limited ciphertext exceptions before generating scanner paths."""

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import stat
import sys

APPROVED_FILES = {
    "web/config/credentials.yml.enc": "6d9a83c8ab112dcf018f7bd18d486818e1c2fc0d84e5823360bd6f00e2107650",
    "web/_site/config/credentials.yml.enc": "6d9a83c8ab112dcf018f7bd18d486818e1c2fc0d84e5823360bd6f00e2107650",
}
APPROVED_AT = "2026-11-26T08:46:07Z"
EXPIRES_AT = "2026-12-26T08:46:07Z"
OWNER = "NickJLange"
APPROVER = "user_01M4X9W148S2FSA7520X6PG840"
RATIONALE = "Box detector matches a substring of this Rails encrypted ciphertext, not a demonstrated Box credential."


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("Duplicate metadata key")
        result[key] = value
    return result


def validate_records(data, now):
    if not isinstance(data, dict) or set(data) != {"version", "exceptions"} or type(data["version"]) is not int or data["version"] != 1:
        raise ValueError("Invalid exception metadata")
    records = data["exceptions"]
    if not isinstance(records, list) or len(records) != len(APPROVED_FILES):
        raise ValueError("Expected exactly two exceptions")
    if now.tzinfo is None or now.utcoffset() is None:
        raise ValueError("Timezone-aware current time required")
    approved = dt.datetime.fromisoformat(APPROVED_AT.replace("Z", "+00:00"))
    expires = dt.datetime.fromisoformat(EXPIRES_AT.replace("Z", "+00:00"))
    if not approved <= now < expires:
        raise ValueError("Exception approval is not currently valid")
    seen = set()
    for record in records:
        if not isinstance(record, dict) or set(record) != {"path", "sha256", "owner", "approver", "approved_at", "expires_at", "rationale"}:
            raise ValueError("Invalid exception record")
        path = record["path"]
        if not isinstance(path, str) or path not in APPROVED_FILES or path in seen:
            raise ValueError("Unexpected or duplicate exception path")
        if (record["sha256"] != APPROVED_FILES[path] or record["owner"] != OWNER
                or record["approver"] != APPROVER or record["approved_at"] != APPROVED_AT
                or record["expires_at"] != EXPIRES_AT or record["rationale"] != RATIONALE):
            raise ValueError("Exception metadata differs from approval")
        seen.add(path)
    if seen != set(APPROVED_FILES):
        raise ValueError("Missing approved path")
    return sorted(seen)


def file_digest(root, path):
    # Resolve every component relative to an opened directory, never following symlinks.
    flags = os.O_RDONLY | os.O_CLOEXEC | os.O_NOFOLLOW
    directory = os.open(root, flags | os.O_DIRECTORY)
    try:
        parts = path.split("/")
        for part in parts[:-1]:
            child = os.open(part, flags | os.O_DIRECTORY, dir_fd=directory)
            os.close(directory)
            directory = child
        file = os.open(parts[-1], flags | os.O_NONBLOCK, dir_fd=directory)
        try:
            if not stat.S_ISREG(os.fstat(file).st_mode):
                raise ValueError("Exception target is not a regular file")
            with os.fdopen(file, "rb", closefd=False) as stream:
                return hashlib.file_digest(stream, "sha256").hexdigest()
        finally:
            os.close(file)
    finally:
        os.close(directory)


def exclusion_lines(root, data, now):
    paths = validate_records(data, now)
    for path in paths:
        if file_digest(root, path) != APPROVED_FILES[path]:
            raise ValueError("Exception target does not match approved file digest")
    return "".join(f"^/repo/{re.escape(path)}$\n" for path in paths)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root")
    parser.add_argument("metadata")
    parser.add_argument("output")
    args = parser.parse_args()
    try:
        with open(args.metadata, encoding="utf-8") as stream:
            data = json.load(stream, object_pairs_hook=unique_object)
        lines = exclusion_lines(args.root, data, dt.datetime.now(dt.timezone.utc))
        with open(args.output, "x", encoding="utf-8") as output:
            output.write(lines)
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        print("Ciphertext exception validation failed; scan not started.", file=sys.stderr)
        return 1
    print("Two time-limited ciphertext identities validated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
