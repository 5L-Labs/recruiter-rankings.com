require "test_helper"

class ReviewsDosTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "Test Corp", region: "Remote")
    @recruiter = Recruiter.create!(name: "Test Recruiter", company: @company, public_slug: "test-recruiter")
    @user = User.create!(role: "candidate", email_hmac: SecureRandom.hex(16))

    # Create 60 approved reviews (exceeding default max of 50)
    # We use insert_all for speed if possible, but Review has callbacks/validations?
    # Review callbacks: create review_metrics if configured?
    # Let's just create them in a loop.
    60.times do |i|
      Review.create!(
        user: @user,
        recruiter: @recruiter,
        company: @company,
        overall_score: 5,
        text: "Review #{i}",
        status: "approved"
      )
    end
  end

  test "reviews index does not clamp per parameter initially" do
    # Request 100 items
    get "/recruiters/test-recruiter/reviews.json", params: { per: 100 }
    assert_response :success

    items = JSON.parse(@response.body)

    # FIXED BEHAVIOR: Returns max 50 (safe)
    # We assert that it returns 50 to confirm the fix
    assert_equal 50, items.length, "Should return 50 items (safe default limit)"
  end
end
