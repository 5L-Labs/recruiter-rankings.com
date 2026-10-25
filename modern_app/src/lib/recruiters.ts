import { query } from '@/lib/db';
import { maskedRecruiterName } from '@/lib/privacy';

export interface RecruiterSearchResult {
  slug: string;
  displayName: string;
  companyName: string | null;
  region: string | null;
}

export const MIN_SEARCH_LENGTH = 2;

function escapeLike(value: string): string {
  return value.replace(/[\\%_]/g, (c) => `\\${c}`);
}

export async function searchRecruiters(rawQuery: string): Promise<RecruiterSearchResult[]> {
  const q = rawQuery.trim();
  if (q.length < MIN_SEARCH_LENGTH) return [];

  const result = await query(
    `SELECT r.public_slug, r.region, c.name AS company_name
       FROM recruiters r
       LEFT JOIN companies c ON c.id = r.company_id
      WHERE r.name ILIKE $1 OR c.name ILIKE $1
      ORDER BY r.public_slug
      LIMIT 20`,
    [`%${escapeLike(q)}%`]
  );

  return result.rows.map((row) => ({
    slug: row.public_slug,
    displayName: maskedRecruiterName(row.public_slug),
    companyName: row.company_name,
    region: row.region,
  }));
}
