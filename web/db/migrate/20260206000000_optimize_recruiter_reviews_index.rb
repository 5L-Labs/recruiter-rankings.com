class OptimizeRecruiterReviewsIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    # Optimization: Add composite index for Recruiter Profile "Recent Reviews" query.
    # Query pattern: where(recruiter_id: ?, status: 'approved').order(created_at: :desc)
    # This enables an Index Scan (avoiding in-memory Sort) while maintaining FK lookup support via prefix.
    add_index :reviews, [:recruiter_id, :status, :created_at], algorithm: :concurrently, name: "index_reviews_on_recruiter_status_created"

    # Remove redundant index on recruiter_id (covered by the new composite index prefix).
    # Specifying `column` ensures the migration is reversible (Rails knows how to recreate it).
    remove_index :reviews, column: :recruiter_id, name: "index_reviews_on_recruiter_id", algorithm: :concurrently
  end
end
