# RR-6 defensive checks

The PR-only workflow `.github/workflows/rr6-defensive.yml` runs lint and both TypeScript projects, the existing database tests, `npm audit` against the npm lockfile at moderate severity or above, and a redacted Gitleaks working-tree scan. Its PostgreSQL service and data are disposable. The workflow does not deploy or use production credentials. It is not an audit of git history, infrastructure, production, or external services. A PR can modify this workflow and its tests, so independent review and branch protection remain necessary; this change does not configure either.

Run the source and regression checks from `modern_app` after provisioning a disposable `rr_test` database and loading the schema with `DATABASE_URL=postgres://postgres:postgres@localhost:5432/rr_test npm run db:setup`:

```sh
npm ci --no-audit --no-fund
npm run lint
npm run typecheck
npx tsc -p rr10-preview/tsconfig.json --noEmit
TEST_DATABASE_URL=postgres://postgres:postgres@localhost:5432/rr_test npm test
npm audit --audit-level=moderate
```

The advisory check sends dependency metadata to the configured npm registry; an unavailable registry is a failure, not a clean result. The secret job uses the Gitleaks container and checks a fabricated fixture before scanning; it neither verifies credentials nor scans history. Output must remain redacted. Scanner image and PostgreSQL image tags are versioned but not digest-pinned. The named synthetic preview and caller-supplied roles are not production privacy or authentication guarantees.

The lockfile resolves `typescript-eslint` 8.73.0 within `eslint-config-next`'s declared range: registry metadata advertised 8.74.0, but its parser tarball returned 404 during clean installation. This is a resolution choice, not an advisory exception; future lockfile updates should recheck availability and advisories.

No exceptions are proposed or granted. A future proposal must identify each finding, an accountable owner, a specific expiry date, and the rationale, and must be reviewed and approved separately; no silent allowlisting is permitted. This document does not approve exceptions or establish branch protection.
