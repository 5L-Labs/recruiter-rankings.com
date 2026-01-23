require "test_helper"

class RecruiterShowPerformanceTest < ActionDispatch::IntegrationTest
  def setup
    @company = Company.create!(name: "Test Company", region: "Remote")
    @recruiter = Recruiter.create!(
      name: "Test Recruiter",
      company: @company,
      region: "Remote",
      public_slug: "test-recruiter-perf",
      email_hmac: "test_hmac_perf",
      email_ciphertext: "test_cipher",
      email_kek_id: "test_kek"
    )

    # Create approved reviews
    10.times do |i|
      user = User.create!(
        email_hmac: "user_perf_#{i}_hmac",
        role: "candidate"
      )

      review = Review.create!(
        user: user,
        recruiter: @recruiter,
        company: @company,
        overall_score: 5,
        text: "Great recruiter!",
        status: "approved"
      )

      # Add visible response to some reviews
      if i.even?
        review.review_responses.create!(
          body: "Thank you!",
          visible: true
        )
      end
    end
  end

  test "recruiter show page avoids N+1 queries for review responses" do
    get recruiter_path(@recruiter.public_slug)
    assert_response :success

    # With N+1, 10 reviews would trigger 10 extra queries (or 20 if exists? + load)
    # With eager loading, we expect:
    # 1. Recruiter
    # 2. Reviews
    # 3. Aggregates count/avg
    # 4. Dimension averages
    # 5. Review Responses (eager loaded)
    # Total roughly 5-7 queries.

    assert_queries(8) do
      get recruiter_path(@recruiter.public_slug)
    end
  end

  private

  def assert_queries(expected_count, &block)
    counter = QueryCounter.new
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record", counter)
    yield
    ActiveSupport::Notifications.unsubscribe(subscriber)

    assert_operator counter.count, :<=, expected_count, "Expected #{expected_count} queries or fewer, but got #{counter.count}"
  end

  class QueryCounter
    attr_reader :count

    def initialize
      @count = 0
    end

    def call(name, start, finish, id, payload)
      return if payload[:name] == "SCHEMA" || payload[:name] == "CACHE"
      @count += 1
    end
  end
end
