class Review < ApplicationRecord
  belongs_to :user
  belongs_to :recruiter, optional: true
  belongs_to :company, optional: true
  has_many :review_metrics, dependent: :destroy
  has_many :review_responses, dependent: :destroy
  # Optimization: Scoped association to allow eager loading of only visible responses,
  # preventing N+1 queries when rendering reviews.
  has_many :visible_review_responses, -> { where(visible: true) }, class_name: "ReviewResponse"

  enum :status, {
    pending: "pending",
    approved: "approved",
    removed: "removed",
    flagged: "flagged"
  }

  validates :overall_score, inclusion: { in: 1..5 }
  validates :status, inclusion: { in: statuses.keys }
end

