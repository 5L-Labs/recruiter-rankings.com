require "test_helper"

class ReviewLengthTest < ActiveSupport::TestCase
  # setup do
  #   @user = users(:one)
  #   @recruiter = recruiters(:one)
  # end

  test "review text cannot exceed 5000 characters" do
    # Create objects manually since fixtures are not loading
    user = User.create!(role: "candidate", email_hmac: "test", email_kek_id: "test")
    company = Company.create!(name: "Test Company")
    recruiter = Recruiter.create!(name: "Test Recruiter", company: company, public_slug: "test-recruiter")

    long_text = "a" * 5001
    review = Review.new(
      user: user,
      recruiter: recruiter,
      overall_score: 5,
      text: long_text,
      status: "pending"
    )

    assert_not review.valid?
    assert_includes review.errors[:text], "is too long (maximum is 5000 characters)"
  end
end
