class User < ApplicationRecord
  has_many :reviews
  has_many :profile_claims
  has_many :review_responses
  has_many :identity_challenges, as: :subject, dependent: :destroy

  validates :email_hmac, presence: true, uniqueness: true
  validates :role, presence: true
end
