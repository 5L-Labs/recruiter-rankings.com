## 2025-11-21 - SSRF in LinkedInFetcher
**Vulnerability:** Found `LinkedInFetcher` class in `web/app/services/linked_in_fetcher.rb` (CamelCase file) which was used by `ClaimIdentityController` but lacked host validation, allowing SSRF. Another unused class `LinkedinFetcher` in `web/app/services/linkedin_fetcher.rb` (lowercase file) had the correct validation.
**Learning:** Duplicate classes/files with similar names (likely typos or refactoring leftovers) can hide vulnerabilities. One secure implementation was ignored in favor of an insecure one.
**Prevention:** Remove unused code and audit similar filenames. Use strict linting to catch class/filename mismatches.

## 2025-11-22 - Logic Flaw in Identity Verification (Account Takeover)
**Vulnerability:** `ClaimIdentityController#verify` accepted the `linkedin_url` as a user parameter. An attacker could initiate a claim for a victim, place the verification token on their own profile, and verify the claim by supplying their own profile URL to the verification endpoint. This allowed taking over any recruiter account.
**Learning:** Never trust client input for verification parameters that determine the identity source. The source of truth (the URL to check) must be stored securely server-side at the time of initiation (create) and retrieved from the database during verification.
**Prevention:** Store all verification context (URLs, tokens, targets) in the database record (e.g., `IdentityChallenge`) and ignore user parameters that duplicate this state during the verification step.
