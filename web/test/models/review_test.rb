require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  test "validates length of text" do
    user = User.create!(email_hmac: "test_hmac_#{SecureRandom.hex}", role: "candidate")
    recruiter = Recruiter.create!(name: "Test Recruiter", public_slug: "test-recruiter-#{SecureRandom.hex}")

    long_text = "a" * 5001
    review = Review.new(
      user: user,
      recruiter: recruiter,
      overall_score: 5,
      text: long_text,
      status: "pending"
    )

    assert_not review.valid?, "Review should be invalid if text is too long"
    assert_includes review.errors[:text], "is too long (maximum is 5000 characters)"
  end
end
