require "test_helper"

class VerifyIdentityJobTest < ActiveJob::TestCase
  setup do
    @user = User.create!(role: 'candidate', email_hmac: 'test_hmac_job')
    @challenge = IdentityChallenge.create!(
      subject_type: 'User',
      subject_id: @user.id,
      token_hash: 'test_hash_job',
      expires_at: 1.hour.from_now
    )
    @token = "RR-VERIFY-#{@challenge.token_hash}"
    @url = "https://linkedin.com/in/test"
  end

  test "successfully verifies identity" do
    # Mock LinkedIn fetcher response
    fetcher_mock = Minitest::Mock.new
    fetcher_mock.expect :fetch, "<html><body>Some content... #{@token} ...</body></html>", [@url]

    LinkedInFetcher.stub :new, fetcher_mock do
      perform_enqueued_jobs do
        VerifyIdentityJob.perform_now(@challenge.id, @url)
      end
    end

    @challenge.reload
    assert_not_nil @challenge.verified_at
    assert_nil @challenge.last_verification_error
    fetcher_mock.verify
  end

  test "fails verification when token missing" do
    fetcher_mock = Minitest::Mock.new
    fetcher_mock.expect :fetch, "<html><body>No token here</body></html>", [@url]

    LinkedInFetcher.stub :new, fetcher_mock do
      perform_enqueued_jobs do
        VerifyIdentityJob.perform_now(@challenge.id, @url)
      end
    end

    @challenge.reload
    assert_nil @challenge.verified_at
    assert_not_nil @challenge.last_verification_error
    assert_match(/Token not found/, @challenge.last_verification_error)
    fetcher_mock.verify
  end

  test "handles errors gracefully" do
    # Stub fetch to raise an error
    LinkedInFetcher.stub :new, -> { raise "Network Error" } do
      # Depending on how the job handles initialization vs method call, we might need to mock the instance method.
      # The job does `fetcher = LinkedInFetcher.new`.
      # So we need LinkedInFetcher.new to return an object that raises on fetch.
    end

    error_fetcher = Object.new
    def error_fetcher.fetch(_)
      raise "Network Error"
    end

    LinkedInFetcher.stub :new, error_fetcher do
      perform_enqueued_jobs do
        VerifyIdentityJob.perform_now(@challenge.id, @url)
      end
    end

    @challenge.reload
    assert_nil @challenge.verified_at
    assert_not_nil @challenge.last_verification_error
    assert_match(/Verification failed/, @challenge.last_verification_error)
  end
end
