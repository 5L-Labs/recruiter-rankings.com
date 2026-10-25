import Link from 'next/link';
import { TAKEDOWN_REASONS, TAKEDOWN_SLA_DAYS } from '@/lib/takedowns';
import { handleTakedownRequest } from './actions';

const ERROR_MESSAGES: Record<string, string> = {
  invalid_email: 'Please enter a valid email address.',
  invalid_reason: 'Please choose a reason.',
  unknown_recruiter: 'We could not find that profile. Check the profile ID (for example RR-0001).',
};

const inputClass =
  'w-full p-4 border rounded-2xl bg-zinc-50 border-zinc-200 text-gray-900 focus:ring-2 focus:ring-blue-500 outline-none';

export default async function TakedownPage({
  searchParams,
}: {
  searchParams: Promise<{ recruiter?: string; error?: string }>;
}) {
  const { recruiter, error } = await searchParams;
  const errorMessage = error ? ERROR_MESSAGES[error] : undefined;

  return (
    <div className="p-8 max-w-2xl mx-auto w-full min-h-screen">
      <nav className="mb-8">
        <Link href="/" className="text-sm text-blue-600 hover:underline">← Back to Home</Link>
      </nav>

      <div className="mb-10">
        <h1 className="text-4xl font-bold tracking-tight mb-2">Request Content Removal</h1>
        <p className="text-zinc-500">
          If a recruiter profile is inaccurate, defamatory, or violates your privacy, tell us below.
          We aim to respond within {TAKEDOWN_SLA_DAYS} days.
        </p>
      </div>

      {errorMessage && (
        <div role="alert" className="mb-6 p-4 rounded-2xl border border-red-200 bg-red-50 text-red-700 text-sm">
          {errorMessage}
        </div>
      )}

      <form action={handleTakedownRequest} className="space-y-6 bg-white p-8 border rounded-3xl shadow-sm border-zinc-200">
        <div className="space-y-2">
          <label htmlFor="recruiter" className="block text-sm font-semibold text-zinc-700">Profile ID</label>
          <input id="recruiter" name="recruiter" required defaultValue={recruiter} placeholder="e.g. RR-0001" className={inputClass} />
          <p className="text-xs text-zinc-400">The ID at the end of the profile URL, /person/&lt;ID&gt;.</p>
        </div>

        <div className="space-y-2">
          <label htmlFor="requester_email" className="block text-sm font-semibold text-zinc-700">Your email</label>
          <input id="requester_email" name="requester_email" type="email" required maxLength={254} placeholder="email@example.com" className={inputClass} />
        </div>

        <div className="space-y-2">
          <label htmlFor="reason" className="block text-sm font-semibold text-zinc-700">Reason</label>
          <select id="reason" name="reason" required defaultValue="" className={inputClass}>
            <option value="" disabled>Choose a reason</option>
            {Object.entries(TAKEDOWN_REASONS).map(([code, label]) => (
              <option key={code} value={code}>{label}</option>
            ))}
          </select>
        </div>

        <button type="submit" className="w-full py-4 bg-zinc-900 text-white font-bold rounded-2xl hover:bg-zinc-800 transition-all shadow-lg active:scale-95">
          Submit Takedown Request
        </button>
      </form>
    </div>
  );
}
