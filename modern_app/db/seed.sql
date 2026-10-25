-- Synthetic development data. Never run against production.
-- Idempotent: does nothing if any recruiter already exists.
-- Recruiters RR-0001..RR-0008 get 3..10 approved experiences, so with the default
-- PUBLIC_MIN_REVIEWS=5 some profiles show aggregates and some stay hidden.

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM recruiters) THEN
    RAISE NOTICE 'seed skipped: recruiters already present';
    RETURN;
  END IF;

  PERFORM setseed(0.42);

  INSERT INTO companies (name, region, size_bucket, created_at, updated_at)
  SELECT name, region, size_bucket, now(), now()
  FROM (VALUES
    ('Acme Talent', 'US-West', '1000+'),
    ('Northwind Search', 'US-East', '200-999'),
    ('Globex Staffing', 'EU', '50-199'),
    ('Initech Recruiting', 'US-Central', '1000+')
  ) AS c(name, region, size_bucket);

  INSERT INTO users (email_hmac, role, created_at, updated_at)
  SELECT md5('seed-candidate-' || g), 'candidate', now(), now()
  FROM generate_series(1, 12) AS g;

  INSERT INTO recruiters (name, public_slug, region, company_id, created_at, updated_at)
  SELECT
    'Seed Recruiter ' || g,
    'RR-' || lpad(g::text, 4, '0'),
    (ARRAY['US-West', 'US-East', 'EU', 'US-Central'])[1 + (g % 4)],
    (SELECT id FROM companies ORDER BY id OFFSET (g % 4) LIMIT 1),
    now(), now()
  FROM generate_series(1, 8) AS g;

  -- One interaction per (recruiter, candidate) pair; recruiter n gets n + 2 of them.
  INSERT INTO interactions (recruiter_id, target_id, occurred_at, status, created_at, updated_at)
  SELECT r.id, u.id, now() - (u.n * interval '20 days'), 'completed', now(), now()
  FROM (SELECT id, row_number() OVER (ORDER BY id) AS n FROM recruiters) r
  JOIN (SELECT id, row_number() OVER (ORDER BY id) AS n FROM users) u ON u.n <= r.n + 2;

  INSERT INTO experiences (interaction_id, rating, body, status, would_recommend, created_at, updated_at)
  SELECT i.id, 1 + floor(random() * 5)::int, 'Synthetic experience for interaction ' || i.id,
         'approved', random() > 0.4, now(), now()
  FROM interactions i;

  -- A pending experience on every recruiter must never count toward public aggregates.
  INSERT INTO interactions (recruiter_id, target_id, occurred_at, status, created_at, updated_at)
  SELECT r.id, (SELECT max(id) FROM users), now(), 'completed', now(), now()
  FROM recruiters r;
  INSERT INTO experiences (interaction_id, rating, body, status, created_at, updated_at)
  SELECT i.id, 1, 'Pending synthetic experience', 'pending', now(), now()
  FROM interactions i
  WHERE NOT EXISTS (SELECT 1 FROM experiences e WHERE e.interaction_id = i.id);

  INSERT INTO review_metrics (experience_id, dimension, score, created_at, updated_at)
  SELECT e.id, d, 1 + floor(random() * 5)::int, now(), now()
  FROM experiences e
  CROSS JOIN unnest(ARRAY['responsiveness', 'role_clarity', 'candidate_understanding',
    'fairness_inclusivity', 'timeline_management', 'feedback_quality',
    'professionalism_respect', 'job_match_quality']) AS d;
END
$$;
