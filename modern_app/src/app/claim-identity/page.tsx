import Link from 'next/link';

// Disabled until Clerk sign-in is wired: claims must go through identity_challenges with a
// hashed token and an encrypted email, tied to the signed-in user.
export default function ClaimIdentityPage() {
  return (
    <div className="p-8 max-w-2xl mx-auto w-full min-h-screen">
      <nav className="mb-8">
        <Link href="/" className="text-sm text-blue-600 hover:underline">← Back to Home</Link>
      </nav>
      <h1 className="text-4xl font-bold tracking-tight mb-4">Claim Your Profile</h1>
      <div className="p-6 bg-zinc-50 rounded-2xl border border-zinc-200 text-zinc-600">
        Claiming a profile needs a signed-in account, which isn&apos;t available in the new site yet.
      </div>
    </div>
  );
}
