import { query } from '@/lib/db';
import { maskedRecruiterName, publicMinReviews } from '@/lib/privacy';

export interface RecruiterProfile {
  slug: string;
  displayName: string;
  companyName: string | null;
  region: string | null;
  verified: boolean;
  reviewsCount: number;
  threshold: number;
  // Aggregates are null until reviewsCount reaches the k-anonymity threshold.
  avgRating: number | null;
  dimensionAverages: Record<string, number> | null;
}

export async function getRecruiterProfile(slug: string): Promise<RecruiterProfile | null> {
  const recruiterResult = await query(
    `SELECT r.id, r.public_slug, r.region, r.verified_at, c.name AS company_name
       FROM recruiters r
       LEFT JOIN companies c ON c.id = r.company_id
      WHERE r.public_slug = $1`,
    [slug]
  );
  const recruiter = recruiterResult.rows[0];
  if (!recruiter) return null;

  const threshold = publicMinReviews();
  const aggregate = await query(
    `SELECT COUNT(*)::int AS count, AVG(e.rating)::float AS avg
       FROM experiences e
       JOIN interactions i ON i.id = e.interaction_id
      WHERE i.recruiter_id = $1 AND e.status = 'approved'`,
    [recruiter.id]
  );
  const reviewsCount: number = aggregate.rows[0].count;
  const isPublic = reviewsCount >= threshold;

  let dimensionAverages: Record<string, number> | null = null;
  if (isPublic) {
    const dims = await query(
      `SELECT m.dimension, AVG(m.score)::float AS avg
         FROM review_metrics m
         JOIN experiences e ON e.id = m.experience_id
         JOIN interactions i ON i.id = e.interaction_id
        WHERE i.recruiter_id = $1 AND e.status = 'approved'
        GROUP BY m.dimension
        ORDER BY m.dimension`,
      [recruiter.id]
    );
    dimensionAverages = Object.fromEntries(dims.rows.map((row) => [row.dimension, row.avg]));
  }

  return {
    slug: recruiter.public_slug,
    displayName: maskedRecruiterName(recruiter.public_slug),
    companyName: recruiter.company_name,
    region: recruiter.region,
    verified: recruiter.verified_at !== null,
    reviewsCount,
    threshold,
    avgRating: isPublic ? aggregate.rows[0].avg : null,
    dimensionAverages,
  };
}
