import Link from 'next/link';
import HistoryRefresh from './history-refresh';
import './style.css';
import './narrow.css';
export const metadata = { title: 'Recruiter Rankings · Synthetic Preview', robots: { index: false, follow: false } };
export default function Layout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body><HistoryRefresh/><div className="notice">SYNTHETIC PREVIEW <span>All people, firms and feedback are fictional.</span></div><header className="header"><Link href="/" className="brand"><span className="mark">R<span>R</span></span><span>recruiter<span className="brand-light">rankings</span></span></Link><span className="header-tag">READ-ONLY EXPLORATION</span></header>{children}<footer><span>Recruiter Rankings <b>·</b> Synthetic preview</span><Link href="/methodology">Methodology</Link><span>No real reviews. No sign-in. No submissions.</span></footer></body></html>;
}
