import { query } from '@/lib/db';

export const TAKEDOWN_REASONS = {
  inaccurate: 'Inaccurate information',
  defamatory: 'Defamatory content',
  privacy: 'Privacy violation',
  other: 'Other',
} as const;

export type TakedownReason = keyof typeof TAKEDOWN_REASONS;

// Standard SLA from the published takedown policy (web/app/views/pages/policies.html.erb).
export const TAKEDOWN_SLA_DAYS = 7;

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export type TakedownInput = {
  recruiterSlug: string;
  requesterEmail: string;
  reason: string;
};

export type TakedownResult =
  | { ok: true; id: number }
  | { ok: false; error: 'invalid_email' | 'invalid_reason' | 'unknown_recruiter' };

export async function createTakedownRequest(input: TakedownInput): Promise<TakedownResult> {
  const email = input.requesterEmail.trim();
  if (!EMAIL_PATTERN.test(email) || email.length > 254) return { ok: false, error: 'invalid_email' };
  if (!Object.hasOwn(TAKEDOWN_REASONS, input.reason)) return { ok: false, error: 'invalid_reason' };

  const result = await query(
    `INSERT INTO takedown_requests
       (subject_type, subject_id, requested_by, reason_code, status, sla_due_at, created_at, updated_at)
     SELECT 'Recruiter', r.id, $2, $3, 'pending', now() + make_interval(days => $4), now(), now()
       FROM recruiters r
      WHERE r.public_slug = $1
     RETURNING id`,
    [input.recruiterSlug.trim(), email, input.reason, TAKEDOWN_SLA_DAYS]
  );
  if (result.rowCount === 0) return { ok: false, error: 'unknown_recruiter' };
  return { ok: true, id: Number(result.rows[0].id) };
}
