## 2026-01-20 - [Efficient Eager Loading of Scoped Associations]
**Learning:** To avoid N+1 queries when iterating over a filtered subset of an association (e.g., `review.review_responses.visible`), standard `includes(:review_responses)` is insufficient if the view still calls the scope (which hits DB).
**Action:** Define a specific scoped association (e.g., `has_many :visible_review_responses, -> { where(visible: true) }`) and eager load that instead. Use the scoped association in the view.
