import { afterAll, beforeEach, describe, expect, it } from 'vitest';
import { insertCompany, insertRecruiter, pool, resetDb } from '@/test/db';
import { searchRecruiters } from './recruiters';

beforeEach(async () => {
  await resetDb();
  const acme = await insertCompany('Acme Talent');
  await insertRecruiter({ name: 'Jane Smith', slug: 'RR-0001', companyId: acme, region: 'EU' });
  await insertRecruiter({ name: 'Bob 100% Real', slug: 'RR-0002' });
});

afterAll(() => pool.end());

describe('searchRecruiters', () => {
  it('matches recruiter names and returns masked names with slugs', async () => {
    expect(await searchRecruiters('jane')).toEqual([
      { slug: 'RR-0001', displayName: 'Recruiter 0001', companyName: 'Acme Talent', region: 'EU' },
    ]);
  });

  it('never returns the real name', async () => {
    const results = await searchRecruiters('Smith');
    expect(JSON.stringify(results)).not.toContain('Smith');
  });

  it('matches company names', async () => {
    expect((await searchRecruiters('acme')).map((r) => r.slug)).toEqual(['RR-0001']);
  });

  it('returns nothing for queries shorter than 2 characters', async () => {
    expect(await searchRecruiters(' j ')).toEqual([]);
  });

  it('treats LIKE wildcards literally', async () => {
    expect((await searchRecruiters('%%')).map((r) => r.slug)).toEqual([]);
    expect((await searchRecruiters('100%')).map((r) => r.slug)).toEqual(['RR-0002']);
  });
});
