import { MIN_SEARCH_LENGTH, searchRecruiters } from '@/lib/recruiters';
import Link from 'next/link';

export default async function SearchPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const query = (q ?? '').trim();
  const recruiters = await searchRecruiters(query);

  return (
    <div className="p-8 max-w-4xl mx-auto w-full min-h-screen">
      <nav className="mb-8">
        <Link href="/" className="text-sm text-blue-600 hover:underline">← Back to Home</Link>
      </nav>

      <div className="mb-12">
        <h1 className="text-4xl font-bold tracking-tight mb-2">Find a Recruiter</h1>
        <p className="text-zinc-500">Search by recruiter name or company.</p>
      </div>

      <form action="/search" method="GET" className="mb-12 flex gap-3">
        <input
          name="q"
          type="search"
          defaultValue={query}
          aria-label="Search recruiters"
          placeholder="Search by name or company..."
          className="flex-1 p-4 pl-5 border rounded-2xl bg-white text-gray-900 shadow-sm focus:ring-2 focus:ring-blue-500 outline-none transition-all border-zinc-200"
        />
        <button type="submit" className="px-8 py-4 bg-blue-600 text-white font-semibold rounded-2xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-100 active:scale-95">
          Search
        </button>
      </form>

      {query.length < MIN_SEARCH_LENGTH ? (
        <div className="text-center py-20 bg-zinc-50 rounded-3xl border-2 border-dashed border-zinc-200">
          <p className="text-zinc-400">Enter at least {MIN_SEARCH_LENGTH} characters to search.</p>
        </div>
      ) : recruiters.length === 0 ? (
        <div className="text-center py-20 bg-zinc-50 rounded-3xl border-2 border-dashed border-zinc-200">
          <p className="text-zinc-500 mb-2">No results found for &ldquo;{query}&rdquo;.</p>
          <p className="text-sm text-zinc-400">Try different keywords or check the spelling.</p>
        </div>
      ) : (
        <ul className="grid gap-4">
          {recruiters.map((r) => (
            <li key={r.slug}>
              <Link
                href={`/person/${encodeURIComponent(r.slug)}`}
                className="p-5 border rounded-2xl hover:border-blue-300 hover:bg-blue-50/30 transition-all group shadow-sm bg-white flex justify-between items-center"
              >
                <div>
                  <div className="font-bold text-lg group-hover:text-blue-700 transition-colors">{r.displayName}</div>
                  <div className="text-sm text-zinc-500">
                    {[r.companyName, r.region].filter(Boolean).join(' · ')}
                  </div>
                </div>
                <div className="text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity font-medium text-sm">
                  View Profile →
                </div>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
