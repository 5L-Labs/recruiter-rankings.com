require "test_helper"

class ReviewResponseLengthTest < ActiveSupport::TestCase
  test "review response body cannot exceed 5000 characters" do
    # Setup
    user = User.create!(role: "candidate", email_hmac: "resp-test-1", email_kek_id: "test")
    company = Company.create!(name: "Test Company Resp")
    recruiter = Recruiter.create!(name: "Test Recruiter Resp", company: company, public_slug: "test-recruiter-resp")
    review = Review.create!(
      user: user,
      recruiter: recruiter,
      overall_score: 5,
      text: "Valid text",
      status: "approved"
    )

    long_body = "a" * 5001
    response = ReviewResponse.new(
      review: review,
      user: user,
      body: long_body
    )

    assert_not response.valid?
    assert_includes response.errors[:body], "is too long (maximum is 5000 characters)"
  end

  test "review response body with 5000 characters is valid" do
    user = User.create!(role: "candidate", email_hmac: "resp-test-2", email_kek_id: "test")
    company = Company.create!(name: "Test Company Resp 2")
    recruiter = Recruiter.create!(name: "Test Recruiter Resp 2", company: company, public_slug: "test-recruiter-resp-2")
    review = Review.create!(
      user: user,
      recruiter: recruiter,
      overall_score: 5,
      text: "Valid text",
      status: "approved"
    )

    body_at_limit = "a" * 5000
    response = ReviewResponse.new(
      review: review,
      user: user,
      body: body_at_limit
    )

    assert response.valid?
  end
end
