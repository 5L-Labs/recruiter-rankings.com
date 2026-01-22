## 2025-10-26 - Scoped Associations for N+1 Prevention
**Learning:** Iterating over scoped associations (e.g., `review.responses.visible`) in a view triggers N+1 queries even if the parent association is eager loaded, because the scope forces a new query.
**Action:** Define a specific association for the scope (e.g., `has_many :visible_responses, -> { visible }`) and eager load that association instead.
