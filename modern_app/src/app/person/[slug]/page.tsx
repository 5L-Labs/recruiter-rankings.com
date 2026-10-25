import { getRecruiterProfile } from '@/lib/profiles';
import { notFound } from 'next/navigation';
import Link from 'next/link';

function formatDimension(dimension: string): string {
  const label = dimension.replace(/_/g, ' ');
  return label.charAt(0).toUpperCase() + label.slice(1);
}

export default async function RecruiterProfilePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const profile = await getRecruiterProfile(slug);
  if (!profile) notFound();

  return (
    <div className="p-8 max-w-4xl mx-auto w-full">
      <nav className="mb-8">
        <Link href="/search" className="text-sm text-blue-600 hover:underline">← Back to search</Link>
      </nav>

      <div className="mb-10 pb-8 border-b border-zinc-200">
        <h1 className="text-4xl font-bold tracking-tight">{profile.displayName}</h1>
        <p className="text-lg text-zinc-600 mt-1">
          {[profile.companyName, profile.region].filter(Boolean).join(' · ') || 'Company not listed'}
        </p>
        <div className="mt-4 flex gap-3">
          {profile.verified && (
            <span className="px-2 py-1 bg-blue-50 text-blue-700 text-xs font-medium rounded-full border border-blue-200">
              ✓ Verified identity
            </span>
          )}
          <span className="px-2 py-1 bg-zinc-100 text-zinc-600 text-xs font-medium rounded-full border border-zinc-200">
            {profile.reviewsCount} approved {profile.reviewsCount === 1 ? 'review' : 'reviews'}
          </span>
        </div>
      </div>

      {profile.avgRating === null || profile.dimensionAverages === null ? (
        <div className="text-center py-12 bg-zinc-50 rounded-xl border-2 border-dashed border-zinc-200">
          <p className="text-zinc-600 font-medium">Not enough reviews to show ratings yet.</p>
          <p className="text-sm text-zinc-500 mt-1">
            To protect reviewers, ratings appear once {profile.threshold} candidates have reviewed this recruiter.
          </p>
        </div>
      ) : (
        <section>
          <div className="mb-8">
            <div className="text-sm text-zinc-500">Overall rating</div>
            <div className="text-5xl font-bold text-zinc-900">
              {profile.avgRating.toFixed(1)}<span className="text-2xl text-zinc-400"> / 5</span>
            </div>
          </div>
          <h2 className="text-xl font-bold mb-4 tracking-tight">By dimension</h2>
          <dl className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {Object.entries(profile.dimensionAverages).map(([dimension, avg]) => (
              <div key={dimension} className="flex justify-between p-4 border border-zinc-200 rounded-xl bg-white">
                <dt className="text-zinc-700">{formatDimension(dimension)}</dt>
                <dd className="font-semibold text-zinc-900">{avg.toFixed(1)}</dd>
              </div>
            ))}
          </dl>
        </section>
      )}

      <p className="mt-12 text-sm text-zinc-500">
        Is this your profile and something is wrong?{' '}
        <Link href={`/takedown?recruiter=${encodeURIComponent(profile.slug)}`} className="text-blue-600 hover:underline">
          Request a takedown
        </Link>
      </p>
    </div>
  );
}
