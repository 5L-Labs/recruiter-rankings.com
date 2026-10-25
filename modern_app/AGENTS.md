<!-- BEGIN:nextjs-agent-rules -->
# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` before writing any code. Heed deprecation notices.
<!-- END:nextjs-agent-rules -->

# modern_app (Next.js rewrite)

Replaces the Rails + Jekyll app in `web/` and `site/`. See `HANDOFF.md` for status and what is not ported yet.

## Commands (run from `modern_app/`)

```bash
npm run lint && npm run typecheck   # static checks
npm test                            # Vitest against Postgres (TEST_DATABASE_URL, default rr_test)
npm run build                       # production build; needs no database
npm run db:setup -- --seed          # load db/schema.sql + db/seed.sql into $DATABASE_URL if empty
```

In an Amp orb, `.agents/setup` installs Postgres 15, creates `rr_dev` (seeded) and `rr_test`, and
writes `.env.local`. `amp orb services ensure` starts the dev server with a portal.

## Data rules

- No ORM: plain `pg` queries in `src/lib/`, each covered by a test in `src/lib/*.test.ts` that runs
  against the real schema.
- `db/schema.sql` is generated from the Rails schema, which still owns production migrations. When
  `web/db/schema.rb` changes, regenerate it with `rails db:schema:load` then
  `pg_dump --schema-only --no-owner --no-privileges` (see the file header).
- Never show `recruiters.name` to anonymous viewers; use `maskedRecruiterName`.
- Ratings stay hidden until a recruiter has `PUBLIC_MIN_REVIEWS` (default 5) approved experiences.
  Only `experiences.status = 'approved'` counts.
- Never trust user identity from form fields. Write paths that need a user wait for Clerk.
- `redirect()` throws to navigate; never call it inside `try/catch`.
