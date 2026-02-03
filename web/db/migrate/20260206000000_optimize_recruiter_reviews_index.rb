class OptimizeRecruiterReviewsIndex < ActiveRecord::Migration[8.1]
  def change
    # Add composite index that covers filtering and sorting for Recruiter#show reviews
    add_index :reviews, [:recruiter_id, :status, :created_at], name: "index_reviews_on_recruiter_status_created_at"

    # Remove the single column index which is now a prefix of the new index
    remove_index :reviews, column: :recruiter_id, name: "index_reviews_on_recruiter_id"
  end
end
