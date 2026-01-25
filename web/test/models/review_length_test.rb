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

  test "review text with exactly 5000 characters is valid" do
    user = User.create!(role: "candidate", email_hmac: "test2", email_kek_id: "test2")
    company = Company.create!(name: "Test Company 2")
    recruiter = Recruiter.create!(name: "Test Recruiter 2", company: company, public_slug: "test-recruiter-2")

    text_at_limit = "a" * 5000
    review = Review.new(
      user: user,
      recruiter: recruiter,
      overall_score: 5,
      text: text_at_limit,
      status: "pending"
    )

    assert review.valid?
    assert_empty review.errors[:text]
  end

  test "review text with less than 5000 characters is valid" do
    user = User.create!(role: "candidate", email_hmac: "test3", email_kek_id: "test3")
    company = Company.create!(name: "Test Company 3")
    recruiter = Recruiter.create!(name: "Test Recruiter 3", company: company, public_slug: "test-recruiter-3")

    text_below_limit = "a" * 4999
    review = Review.new(
      user: user,
      recruiter: recruiter,
      overall_score: 5,
      text: text_below_limit,
      status: "pending"
    )

    assert review.valid?
    assert_empty review.errors[:text]
  end
end
