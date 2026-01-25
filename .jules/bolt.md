## 2026-01-23 - Filtered Association N+1
**Learning:** Iterating over filtered associations (e.g., `review.responses.visible`) in views causes N+1 queries because standard eager loading (`includes(:responses)`) loads *all* responses, but the scope triggers a new query.
**Action:** Define scoped associations (e.g., `has_many :visible_responses, -> { visible }`) and eager load *that* association to ensure filters are applied in the eager load query.
