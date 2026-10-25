# Next.js rewrite: status

Stack: Next.js 16 (App Router), React 19, Tailwind 4, `pg`, Vitest. Schema baseline in
`db/schema.sql`, generated from the Rails schema.

## Working

| Route | Notes |
|---|---|
| `/search` | Name or company search, masked names, LIKE wildcards escaped |
| `/person/[slug]` | Overall and per-dimension averages of approved experiences, hidden below `PUBLIC_MIN_REVIEWS` |
| `/takedown` | Recruiter-profile takedowns into `takedown_requests` with a 7-day SLA |
| `/sitemap.xml` | Uses `CANONICAL_URL` and `/person/:slug` |
| `/recruiters/:slug`, `/recruiters`, `/person` | Permanent redirects matching the Rails URLs |

## Disabled until Clerk sign-in is wired

- `/reviews/new`: must write `interactions` + `experiences` + `review_metrics` for the signed-in user.
- `/claim-identity`: must use `identity_challenges` (hashed token) and envelope-encrypted email.

## Not ported yet

Admin moderation (reviews, responses, identity verifications), companies pages, LinkedIn
verification, subscriptions/Paddle, rate limiting (rack-attack), CSP headers, i18n, about/policies
pages, backups, deployment.
