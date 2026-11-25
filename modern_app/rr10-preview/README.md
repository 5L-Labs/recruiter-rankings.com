# RR-10 synthetic preview

This separate, read-only Next application is an experiment, not a release. It uses fictional fixtures and the RR-8 aggregate interface. It has no sign-in or public mutation routes. Do not connect it to real data. The existing application and its routes are not served by this preview.

## Clean disposable setup

Start from `NickJLange/recruiter-rankings.com` revision `ce14dafa3664a797015f10528117317939dcb4a2`, apply the complete candidate patch, and install dependencies with `npm ci` in `modern_app`. Provision a disposable local PostgreSQL instance and create an empty `rr10_preview` database. The examples below assume a local PostgreSQL user `postgres` with password `postgres`; use only disposable credentials and data.

From the repository root:

```sh
export DATABASE_URL=postgres://postgres:postgres@localhost:5432/rr10_preview
# Use the exact preview portal origin at build and server startup; omit its trailing slash.
export RR10_PREVIEW_ORIGIN=https://YOUR-PORTAL-ORIGIN
npm --prefix modern_app run db:setup
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f modern_app/rr8/schema.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f modern_app/rr10-preview/fixtures.sql
cd modern_app
NEXT_TELEMETRY_DISABLED=1 ./node_modules/.bin/next build rr10-preview
```

In an Amp orb, start a supervised preview from the repository root, using the absolute checkout path for `--cwd`:

```sh
amp orb service start rr10-preview --command 'DATABASE_URL=postgres://postgres:postgres@localhost:5432/rr10_preview RR10_PREVIEW_ORIGIN=https://YOUR-PORTAL-ORIGIN NEXT_TELEMETRY_DISABLED=1 ./node_modules/.bin/next start rr10-preview --hostname 0.0.0.0 --port "$PORT"' --cwd "$PWD/modern_app" --port 31581 --portal
```

Use the exact portal URL printed by that command as `RR10_PREVIEW_ORIGIN`; if it was not known at build time, rebuild and restart with that value. The fallback is specific to the original experiment portal, not a production domain. To exercise the HTTP threshold sequence against this disposable database:

```sh
DATABASE_URL=postgres://postgres:postgres@localhost:5432/rr10_preview PREVIEW_URL='https://YOUR-PORTAL-URL/' NODE_USE_SYSTEM_CA=1 node modern_app/rr10-preview/verify.mjs
```

The verifier directly changes two synthetic fixture rows through SQL, not the moderator application interface. It leaves those rows removed, and leaves other rated and unrated listings available. Never point it at any non-disposable database. The portal is network-accessible: use fictional data only. Browser inspection and the RR-8 test suite provide additional checks; this verifier alone does not establish a production privacy or security guarantee. Authentication, real data, restore/deletion guarantees, operational controls and the rest of RR-10 remain out of scope.

For a callable-interface lifecycle check which creates and removes separate synthetic targets and users, run `DATABASE_URL=postgres://postgres:postgres@localhost:5432/rr10_preview PREVIEW_URL='https://YOUR-PORTAL-URL/' NODE_USE_SYSTEM_CA=1 node modern_app/rr10-preview/lifecycle-check.mjs`. Its actor roles are test inputs, not authenticated identities. The directory supports name search only; joined filters are not implemented. History navigation deliberately reloads to avoid Next's stale back/forward page payload; an already-open page is not automatically updated when moderation occurs.
