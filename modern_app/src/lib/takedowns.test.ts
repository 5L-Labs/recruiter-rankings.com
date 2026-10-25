import { afterAll, beforeEach, describe, expect, it } from 'vitest';
import { insertRecruiter, pool, resetDb } from '@/test/db';
import { createTakedownRequest } from './takedowns';

let recruiterId: number;

beforeEach(async () => {
  await resetDb();
  await insertRecruiter({ name: 'Decoy', slug: 'RR-0001' });
  recruiterId = await insertRecruiter({ name: 'Jane Smith', slug: 'RR-0002' });
});

afterAll(() => pool.end());

const valid = { recruiterSlug: 'RR-0002', requesterEmail: ' jane@example.com ', reason: 'privacy' };

describe('createTakedownRequest', () => {
  it('stores a pending request against the recruiter with a 7-day SLA', async () => {
    const result = await createTakedownRequest(valid);
    expect(result.ok).toBe(true);

    const { rows } = await pool.query(
      `SELECT subject_type, subject_id, requested_by, reason_code, status,
              EXTRACT(EPOCH FROM (sla_due_at - created_at)) / 86400 AS sla_days
         FROM takedown_requests`
    );
    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject({
      subject_type: 'Recruiter',
      subject_id: String(recruiterId),
      requested_by: 'jane@example.com',
      reason_code: 'privacy',
      status: 'pending',
    });
    expect(Number(rows[0].sla_days)).toBeCloseTo(7, 3);
  });

  it.each([
    [{ ...valid, recruiterSlug: 'RR-9999' }, 'unknown_recruiter'],
    [{ ...valid, reason: 'because' }, 'invalid_reason'],
    [{ ...valid, reason: 'toString' }, 'invalid_reason'],
    [{ ...valid, requesterEmail: 'not-an-email' }, 'invalid_email'],
  ])('rejects %j with %s and stores nothing', async (input, error) => {
    expect(await createTakedownRequest(input)).toEqual({ ok: false, error });
    const { rows } = await pool.query('SELECT count(*)::int AS n FROM takedown_requests');
    expect(rows[0].n).toBe(0);
  });
});
