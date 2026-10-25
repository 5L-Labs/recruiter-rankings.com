import { afterEach, describe, expect, it } from 'vitest';
import { maskedRecruiterName, publicMinReviews } from './privacy';

describe('maskedRecruiterName', () => {
  it('shows 8-char hex slugs as-is', () => {
    expect(maskedRecruiterName('0A1B2C3D')).toBe('Recruiter 0A1B2C3D');
  });

  it('uses the last segment of RR- slugs', () => {
    expect(maskedRecruiterName('RR-ABC123')).toBe('Recruiter ABC123');
  });

  it('hashes legacy slugs so the name-derived slug is not revealed', () => {
    // `printf jane-doe | md5sum` = 6362aa2270b3...
    expect(maskedRecruiterName('jane-doe')).toBe('Recruiter 6362AA');
  });

  it('does not treat lowercase hex as the 8-char format', () => {
    expect(maskedRecruiterName('0a1b2c3d')).not.toBe('Recruiter 0a1b2c3d');
  });
});

describe('publicMinReviews', () => {
  const original = process.env.PUBLIC_MIN_REVIEWS;
  afterEach(() => {
    process.env.PUBLIC_MIN_REVIEWS = original;
  });

  it('defaults to 5 like the Rails app', () => {
    delete process.env.PUBLIC_MIN_REVIEWS;
    expect(publicMinReviews()).toBe(5);
  });

  it('reads the env var', () => {
    process.env.PUBLIC_MIN_REVIEWS = '3';
    expect(publicMinReviews()).toBe(3);
  });

  it.each(['0', '-2', 'abc', ''])('falls back to 5 for invalid value %j', (value) => {
    process.env.PUBLIC_MIN_REVIEWS = value;
    expect(publicMinReviews()).toBe(5);
  });
});
