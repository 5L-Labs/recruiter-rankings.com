require "test_helper"

class ClaimIdentitySecurityTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = User.create!(role: 'candidate', email_hmac: 'test_hmac', linked_in_url: 'https://linkedin.com/in/original')
    @new_linkedin_url = "https://linkedin.com/in/attacker"
  end

  test "create does not update linked_in_url immediately" do
    # Patch controller to return our specific user, bypassing HMAC lookup
    ClaimIdentityController.class_eval do
      alias_method :original_find_or_create_user, :find_or_create_user
      def find_or_create_user(email)
        User.find_by(email_hmac: 'test_hmac')
      end
    end

    begin
      post claim_identity_url, params: {
        claim: {
          subject_type: 'user',
          email: 'test@example.com',
          linkedin_url: @new_linkedin_url
        }
      }
    ensure
      ClaimIdentityController.class_eval do
        alias_method :find_or_create_user, :original_find_or_create_user
        remove_method :original_find_or_create_user
      end
    end

    @user.reload
    assert_equal 'https://linkedin.com/in/original', @user.linked_in_url, "User linked_in_url should not be updated on create"
  end

  test "verify updates linked_in_url upon success" do
    challenge = IdentityChallenge.create!(
      subject: @user,
      token_hash: 'fixedhash',
      linkedin_url: @new_linkedin_url,
      expires_at: 1.hour.from_now
    )

    # Patch LinkedInFetcher to simulate finding the token
    LinkedInFetcher.class_eval do
      alias_method :original_fetch, :fetch
      def fetch(url)
        "<html><body>Here is the token: RR-VERIFY-fixedhash</body></html>"
      end
    end

    begin
      VerifyIdentityJob.perform_now(challenge.id, @new_linkedin_url)
    ensure
      LinkedInFetcher.class_eval do
        alias_method :fetch, :original_fetch
        remove_method :original_fetch
      end
    end

    @user.reload
    assert_equal @new_linkedin_url, @user.linked_in_url, "User linked_in_url should be updated after verification"
  end
end
