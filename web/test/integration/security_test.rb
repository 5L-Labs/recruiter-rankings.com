require "test_helper"

class SecurityTest < ActionDispatch::IntegrationTest
  test "admin responses controller requires CSRF token" do
    # Enable CSRF protection for this test
    ActionController::Base.allow_forgery_protection = true

    # Create a user to be the moderator
    user = User.create!(role: "moderator", email_kek_id: "test", email_hmac: "test")

    # Create a review
    review = Review.create!(
      user: user,
      recruiter: Recruiter.first,
      company: Company.first,
      overall_score: 5,
      text: "test",
      status: "pending"
    )

    # Basic Auth headers
    auth_headers = {
      "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("mod", "mod")
    }

    # Attempt to create a response WITHOUT a CSRF token
    begin
      post admin_review_responses_path(review),
           params: { review_response: { body: "reply" } },
           headers: auth_headers

      # If we reach here, check the response code
      if response.status == 422
        # This IS the CSRF failure!
        # In Rails 8 / integration tests, sometimes exception is caught and rendered as 422.
        # So getting 422 here is actually SUCCESS for our security test (it blocked the request).
        assert_response :unprocessable_entity
      else
        flunk "CSRF protection failed: Request succeeded with #{response.status}"
      end

    rescue ActionController::InvalidAuthenticityToken
      # This is also what we expect!
      assert true
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end
end
