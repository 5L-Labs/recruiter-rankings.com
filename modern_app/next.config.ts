import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Amp orb portals proxy the dev server from *.onamp.dev; extra hosts via env.
  allowedDevOrigins: [
    "*.onamp.dev",
    ...(process.env.ALLOWED_DEV_ORIGINS?.split(",").filter(Boolean) ?? []),
  ],
  // Legacy Rails URLs: /recruiters/:slug already 301s to /person/:slug in production.
  async redirects() {
    return [
      { source: "/recruiters/:slug", destination: "/person/:slug", permanent: true },
      { source: "/recruiters", destination: "/search", permanent: true },
      { source: "/person", destination: "/search", permanent: true },
    ];
  },
};

export default nextConfig;
