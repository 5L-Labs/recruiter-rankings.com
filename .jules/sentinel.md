## 2025-11-21 - SSRF in LinkedInFetcher
**Vulnerability:** Found `LinkedInFetcher` class in `web/app/services/linked_in_fetcher.rb` (CamelCase file) which was used by `ClaimIdentityController` but lacked host validation, allowing SSRF. Another unused class `LinkedinFetcher` in `web/app/services/linkedin_fetcher.rb` (lowercase file) had the correct validation.
**Learning:** Duplicate classes/files with similar names (likely typos or refactoring leftovers) can hide vulnerabilities. One secure implementation was ignored in favor of an insecure one.
**Prevention:** Remove unused code and audit similar filenames. Use strict linting to catch class/filename mismatches.

## 2025-01-21 - Missing Global CSRF Protection
**Vulnerability:** `ApplicationController` did not have `protect_from_forgery`, leaving controllers inheriting from it (like `Admin::ResponsesController`) vulnerable to CSRF unless they explicitly opted in.
**Learning:** Even if critical controllers protect themselves, gaps in base classes create "secure by default" failures. New controllers added by developers assuming global protection would be vulnerable.
**Prevention:** Always enforce `protect_from_forgery` in `ApplicationController` or `ActionController::Base` configuration.
