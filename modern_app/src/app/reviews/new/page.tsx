import Link from 'next/link';

// Disabled until Clerk sign-in is wired: a review must belong to an authenticated user
// (reviews.user_id / interactions.target_id), never to an ID taken from the form.
export default function NewReviewPage() {
  return (
    <div className="p-8 max-w-2xl mx-auto w-full min-h-screen">
      <nav className="mb-8">
        <Link href="/" className="text-sm text-blue-600 hover:underline">← Back to Home</Link>
      </nav>
      <h1 className="text-4xl font-bold tracking-tight mb-4">Share Your Experience</h1>
      <div className="p-6 bg-zinc-50 rounded-2xl border border-zinc-200 text-zinc-600">
        Submitting reviews needs a signed-in account, which isn&apos;t available in the new site yet.
      </div>
    </div>
  );
}
