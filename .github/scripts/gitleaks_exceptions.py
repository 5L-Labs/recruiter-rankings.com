#!/usr/bin/env python3
"""Generate the narrowly approved, time-limited Gitleaks configuration."""

import argparse
import datetime as dt
import json
import re
import sys

import trufflehog_exceptions as ciphertext


# NickJLange (user_01M4X9W148S2FSA7520X6PG840) approved the two digest
# constants because they are ciphertext identities, not demonstrated keys.
APPROVED_AT = dt.datetime(2026, 11, 26, 19, 3, 39, tzinfo=dt.timezone.utc)
EXPIRES_AT = dt.datetime(2026, 12, 26, 8, 46, 7, tzinfo=dt.timezone.utc)


def configuration(root, records, now):
    if now.tzinfo is None or now.utcoffset() is None or not APPROVED_AT <= now < EXPIRES_AT:
        raise ValueError("Digest exception approval is not currently valid")
    ciphertext.exclusion_lines(root, records, now)
    lines = [re.escape(f'    "{path}": "{digest}",')
             for path, digest in ciphertext.APPROVED_FILES.items()]
    # Gitleaks 8.28 includes the preceding newline in most finding lines.
    regexes = ",\n".join(f"  '''^\\n?{line}$'''" for line in lines)
    return f"""[extend]
useDefault = true

[[rules]]
id = "generic-api-key"

[[rules.allowlists]]
description = "Approved ciphertext digest constants; expires 2026-12-26T08:46:07Z"
condition = "AND"
paths = ['''^(?:/scan/)?\\.github/scripts/trufflehog_exceptions\\.py$''']
regexTarget = "line"
regexes = [
{regexes}
]
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("root")
    parser.add_argument("metadata")
    parser.add_argument("output")
    args = parser.parse_args()
    try:
        with open(args.metadata, encoding="utf-8") as stream:
            records = json.load(stream, object_pairs_hook=ciphertext.unique_object)
        config = configuration(args.root, records, dt.datetime.now(dt.timezone.utc))
        with open(args.output, "x", encoding="utf-8") as output:
            output.write(config)
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        print("Digest exception validation failed; scan not started.", file=sys.stderr)
        return 1
    print("Two time-limited digest identities validated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
