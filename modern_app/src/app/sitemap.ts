import type { MetadataRoute } from 'next';
import { query } from '@/lib/db';

// Rendered per request so the build does not need a database.
export const dynamic = 'force-dynamic';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const base = (process.env.CANONICAL_URL || 'https://recruiter-rankings.com').replace(/\/$/, '');
  const result = await query(
    'SELECT public_slug, updated_at FROM recruiters ORDER BY updated_at DESC LIMIT 1000'
  );

  return [
    { url: base, changeFrequency: 'daily', priority: 1 },
    { url: `${base}/search`, changeFrequency: 'daily', priority: 0.9 },
    { url: `${base}/takedown`, changeFrequency: 'monthly', priority: 0.3 },
    ...result.rows.map((row) => ({
      url: `${base}/person/${encodeURIComponent(row.public_slug)}`,
      lastModified: new Date(row.updated_at),
      changeFrequency: 'monthly' as const,
      priority: 0.7,
    })),
  ];
}
