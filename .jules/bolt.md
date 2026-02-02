## 2025-10-26 - Scoped Associations for N+1 Prevention
**Learning:** Iterating over scoped associations (e.g., `review.responses.visible`) in a view triggers N+1 queries even if the parent association is eager loaded, because the scope forces a new query.
**Action:** Define a specific association for the scope (e.g., `has_many :visible_responses, -> { visible }`) and eager load that association instead.
## 2026-01-23 - Filtered Association N+1
**Learning:** Iterating over filtered associations (e.g., `review.responses.visible`) in views causes N+1 queries because standard eager loading (`includes(:responses)`) loads *all* responses, but the scope triggers a new query.
**Action:** Define scoped associations (e.g., `has_many :visible_responses, -> { visible }`) and eager load *that* association to ensure filters are applied in the eager load query.

## 2026-01-26 - Admin Review N+1
**Learning:** The admin review list iterates over `review.review_responses` for each review, causing N+1 queries if not eager loaded.
**Action:** Always verify associated data usage in views (especially admin dashboards) and add `.includes(:association)` to the controller query.
## 2026-01-23 - Index Only Scan for Aggregation
**Learning:** For aggregation queries like `Review.where(status: "approved").group(:recruiter_id).select(..., AVG(overall_score))`, a composite index including the filtered column, the grouping column, AND the aggregated column (e.g., `[:status, :recruiter_id, :overall_score]`) enables an Index Only Scan, avoiding expensive heap fetches for every row in the group.
**Action:** Always include aggregated columns in the index when optimizing `GROUP BY` queries on large tables to achieve Index Only Scans.

## 2026-02-06 - Migration Reversibility
**Learning:** Using `remove_index` inside a `change` method requires passing the `column` option (e.g., `remove_index :table, column: :col, name: "idx"`) so Rails can recreate the index during rollback. Providing only the name breaks reversibility.
**Action:** Always include `column` or use `up/down` methods when removing indexes.
