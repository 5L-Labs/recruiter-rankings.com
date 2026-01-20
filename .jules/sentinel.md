## 2025-11-21 - SSRF in LinkedInFetcher
**Vulnerability:** Found `LinkedInFetcher` class in `web/app/services/linked_in_fetcher.rb` (CamelCase file) which was used by `ClaimIdentityController` but lacked host validation, allowing SSRF. Another unused class `LinkedinFetcher` in `web/app/services/linkedin_fetcher.rb` (lowercase file) had the correct validation.
**Learning:** Duplicate classes/files with similar names (likely typos or refactoring leftovers) can hide vulnerabilities. One secure implementation was ignored in favor of an insecure one.
**Prevention:** Remove unused code and audit similar filenames. Use strict linting to catch class/filename mismatches.

## 2025-11-21 - Memory Discrepancy on Input Validation
**Vulnerability:** The Review model was documented in memory as having a 5000 character limit on `text`, but the codebase lacked this validation.
**Learning:** Security documentation or assumptions can drift from the actual code state. Always verify security controls in the source.
**Prevention:** Use automated tests (like the one added) to enforce security invariants rather than relying on documentation.

## 2025-11-21 - Logic Flaw in ClaimIdentityController
**Vulnerability:** The `verify` action in `ClaimIdentityController` verifies a Recruiter profile based on *any* provided LinkedIn URL containing the token, without ensuring that the provided LinkedIn URL belongs to the Recruiter entity.
**Learning:** Verification flows that accept user-provided identity claims (URL) at the *verification* step, without linking them to the *request* step or the entity, are prone to bypass.
**Prevention:** Bind the verification target (e.g. LinkedIn URL) to the entity or the challenge at creation time, and only verify against that bound target.
