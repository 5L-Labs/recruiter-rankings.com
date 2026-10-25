import Link from 'next/link';
import { TAKEDOWN_SLA_DAYS } from '@/lib/takedowns';

export default function TakedownSuccessPage() {
  return (
    <div className="p-8 max-w-2xl mx-auto min-h-screen flex flex-col justify-center items-center text-center">
      <h1 className="text-4xl font-bold tracking-tight mb-4 text-zinc-900">Request received</h1>
      <p className="text-zinc-600 mb-8 max-w-md">
        A moderator will review your request within {TAKEDOWN_SLA_DAYS} days and contact you at the email you provided.
      </p>
      <Link href="/" className="px-6 py-3 bg-blue-600 text-white font-bold rounded-2xl hover:bg-blue-700 transition-all">
        Back to Home
      </Link>
    </div>
  );
}
