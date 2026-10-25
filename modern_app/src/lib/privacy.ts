import { createHash } from 'node:crypto';

// Same default as the Rails app (ApplicationController#public_min_reviews).
export function publicMinReviews(): number {
  const parsed = Number.parseInt(process.env.PUBLIC_MIN_REVIEWS ?? '', 10);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : 5;
}

// Port of Recruiter#display_name for anonymous viewers: real names are never shown.
export function maskedRecruiterName(publicSlug: string): string {
  if (/^[0-9A-F]{8}$/.test(publicSlug)) return `Recruiter ${publicSlug}`;
  if (publicSlug.startsWith('RR-')) return `Recruiter ${publicSlug.split('-').pop()}`;
  return `Recruiter ${createHash('md5').update(publicSlug).digest('hex').slice(0, 6).toUpperCase()}`;
}
