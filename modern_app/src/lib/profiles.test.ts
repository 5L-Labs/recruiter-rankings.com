import { afterAll, beforeEach, describe, expect, it } from 'vitest';
import { insertExperience, insertRecruiter, pool, resetDb } from '@/test/db';
import { getRecruiterProfile } from './profiles';

let recruiterId: number;

beforeEach(async () => {
  process.env.PUBLIC_MIN_REVIEWS = '3';
  await resetDb();
  recruiterId = await insertRecruiter({ name: 'Jane Smith', slug: 'RR-0001' });
  // Noise that must never leak into RR-0001's numbers.
  const other = await insertRecruiter({ name: 'Other', slug: 'RR-0002' });
  for (let i = 0; i < 3; i++) await insertExperience(other, { rating: 1, metrics: { responsiveness: 1 } });
});

afterAll(() => pool.end());

describe('getRecruiterProfile', () => {
  it('returns null for an unknown slug', async () => {
    expect(await getRecruiterProfile('RR-9999')).toBeNull();
  });

  it('hides aggregates below the threshold, even with pending reviews pushing the raw count over it', async () => {
    await insertExperience(recruiterId, { rating: 5, metrics: { responsiveness: 5 } });
    await insertExperience(recruiterId, { rating: 4, metrics: { responsiveness: 4 } });
    await insertExperience(recruiterId, { rating: 1, status: 'pending' });

    const profile = await getRecruiterProfile('RR-0001');
    expect(profile).toMatchObject({
      displayName: 'Recruiter 0001',
      reviewsCount: 2,
      threshold: 3,
      avgRating: null,
      dimensionAverages: null,
    });
    expect(JSON.stringify(profile)).not.toContain('Jane');
  });

  it('shows averages of approved reviews only once the threshold is reached', async () => {
    await insertExperience(recruiterId, { rating: 5, metrics: { responsiveness: 5, role_clarity: 2 } });
    await insertExperience(recruiterId, { rating: 4, metrics: { responsiveness: 4, role_clarity: 3 } });
    await insertExperience(recruiterId, { rating: 2, metrics: { responsiveness: 3 } });
    await insertExperience(recruiterId, { rating: 1, status: 'pending', metrics: { responsiveness: 1 } });
    await insertExperience(recruiterId, { rating: 1, status: 'removed', metrics: { role_clarity: 1 } });

    const profile = await getRecruiterProfile('RR-0001');
    expect(profile?.reviewsCount).toBe(3);
    expect(profile?.avgRating).toBeCloseTo(11 / 3);
    expect(profile?.dimensionAverages).toEqual({ responsiveness: 4, role_clarity: 2.5 });
  });
});
