import pool from '@/lib/db';

if (!/_test(\?|$)/.test(process.env.DATABASE_URL ?? '')) {
  throw new Error('Tests truncate tables; DATABASE_URL must point at a *_test database.');
}

export async function resetDb() {
  await pool.query(
    `TRUNCATE takedown_requests, review_metrics, experiences, interactions, recruiters, companies, users
     RESTART IDENTITY CASCADE`
  );
}

export async function insertCompany(name: string): Promise<number> {
  const r = await pool.query(
    `INSERT INTO companies (name, created_at, updated_at) VALUES ($1, now(), now()) RETURNING id`,
    [name]
  );
  return Number(r.rows[0].id);
}

export async function insertRecruiter(
  attrs: { name: string; slug: string; companyId?: number; region?: string }
): Promise<number> {
  const r = await pool.query(
    `INSERT INTO recruiters (name, public_slug, company_id, region, created_at, updated_at)
     VALUES ($1, $2, $3, $4, now(), now()) RETURNING id`,
    [attrs.name, attrs.slug, attrs.companyId ?? null, attrs.region ?? null]
  );
  return Number(r.rows[0].id);
}

let userCounter = 0;

export async function insertExperience(
  recruiterId: number,
  attrs: { rating: number; status?: string; metrics?: Record<string, number> }
): Promise<void> {
  userCounter += 1;
  const user = await pool.query(
    `INSERT INTO users (email_hmac, created_at, updated_at) VALUES ($1, now(), now()) RETURNING id`,
    [`test-hmac-${process.pid}-${userCounter}`]
  );
  const interaction = await pool.query(
    `INSERT INTO interactions (recruiter_id, target_id, occurred_at, created_at, updated_at)
     VALUES ($1, $2, now(), now(), now()) RETURNING id`,
    [recruiterId, user.rows[0].id]
  );
  const experience = await pool.query(
    `INSERT INTO experiences (interaction_id, rating, status, created_at, updated_at)
     VALUES ($1, $2, $3, now(), now()) RETURNING id`,
    [interaction.rows[0].id, attrs.rating, attrs.status ?? 'approved']
  );
  for (const [dimension, score] of Object.entries(attrs.metrics ?? {})) {
    await pool.query(
      `INSERT INTO review_metrics (experience_id, dimension, score, created_at, updated_at)
       VALUES ($1, $2, $3, now(), now())`,
      [experience.rows[0].id, dimension, score]
    );
  }
}

export { pool };
