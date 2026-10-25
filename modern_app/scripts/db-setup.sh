#!/usr/bin/env bash
# Load db/schema.sql into $DATABASE_URL if it has no tables yet; with --seed, also load
# db/seed.sql (which skips itself when data exists). Safe to run repeatedly.
set -euo pipefail

cd "$(dirname "$0")/.."
: "${DATABASE_URL:?DATABASE_URL must be set}"

psql_q() { psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -qAt "$@"; }

if [[ "$(psql_q -c "SELECT to_regclass('public.recruiters') IS NOT NULL")" == "t" ]]; then
  echo "schema already present"
else
  psql_q -f db/schema.sql
  echo "schema loaded"
fi

if [[ "${1:-}" == "--seed" ]]; then
  psql_q -f db/seed.sql
  echo "seed applied"
fi
