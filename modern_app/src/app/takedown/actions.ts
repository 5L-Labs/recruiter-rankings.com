'use server';

import { createTakedownRequest } from '@/lib/takedowns';
import { redirect } from 'next/navigation';

export async function handleTakedownRequest(formData: FormData) {
  const recruiterSlug = String(formData.get('recruiter') ?? '');
  const result = await createTakedownRequest({
    recruiterSlug,
    requesterEmail: String(formData.get('requester_email') ?? ''),
    reason: String(formData.get('reason') ?? ''),
  });

  // redirect() throws to navigate, so it must stay outside any try/catch.
  if (!result.ok) {
    redirect(`/takedown?recruiter=${encodeURIComponent(recruiterSlug)}&error=${result.error}`);
  }
  redirect('/takedown/success');
}
