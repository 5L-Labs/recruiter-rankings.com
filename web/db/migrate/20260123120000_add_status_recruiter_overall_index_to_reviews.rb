class AddStatusRecruiterOverallIndexToReviews < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    # Optimized index for RecruitersController#index aggregation query:
    # Review.where(status: "approved").group(:recruiter_id).select(..., AVG(overall_score))
    # This index allows an Index Only Scan, avoiding heap fetches for the aggregation.
    add_index :reviews, [:status, :recruiter_id, :overall_score], algorithm: :concurrently, name: "index_reviews_on_status_recruiter_overall"
  end
end
