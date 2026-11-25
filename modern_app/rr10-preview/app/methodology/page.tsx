import Link from 'next/link';
import { canonical } from '../origin';

export const metadata = { title: 'Methodology · Synthetic Preview', alternates: { canonical: canonical('/methodology') } };

export default function Methodology() {
  return <main className="profile"><Link className="back" href="/">← &nbsp; Back to directory</Link><section className="summary"><div className="eyebrow muted">SYNTHETIC PREVIEW</div><h1>Methodology</h1><p>All firms, people and feedback in this preview are fictional. This is a read-only experiment, not a source of real ratings.</p><h2>Privacy thresholds</h2><p>Overall scores appear only when at least five distinct contributors have approved feedback for that target. Each category independently requires at least five distinct approved contributors who supplied that category.</p><p>Removed or pending feedback does not contribute. Individual reviews and contributor identities are not published.</p></section></main>;
}
