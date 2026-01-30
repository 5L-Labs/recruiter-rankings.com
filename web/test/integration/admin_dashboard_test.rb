require "test_helper"

class AdminDashboardTest < ActionDispatch::IntegrationTest
  def auth_headers
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("mod", "mod") }
  end

  setup do
    @company = Company.create!(name: "Acme", region: "US")
    @recruiter = Recruiter.create!(name: "Diego Fernández", company: @company, public_slug: "diego-fernandez")
    @user = User.create!(role: "candidate", email_hmac: SecureRandom.hex(16))
    Review.create!(user: @user, recruiter: @recruiter, company: @company, overall_score: 4, text: "Pending", status: "pending")
    Review.create!(user: @user, recruiter: @recruiter, company: @company, overall_score: 2, text: "Flag me", status: "flagged")
    r = Review.create!(user: @user, recruiter: @recruiter, company: @company, overall_score: 5, text: "Approved", status: "approved")
    ReviewResponse.create!(review: r, body: "Hidden reply", visible: false)
    ModerationAction.create!(actor: nil, action: "dummy", subject_type: "Review", subject_id: r.id, notes: "test")
    IdentityChallenge.create!(subject_type: "User", subject_id: @user.id, token_hash: SecureRandom.hex(8), expires_at: 1.day.from_now, verified_at: nil)
  end

  test "dashboard requires auth" do
    get "/admin"
    assert_response :unauthorized
  end

  test "dashboard renders metrics and links with auth" do
    get "/admin", headers: auth_headers
    assert_response :success
    assert_includes @response.body, "Admin Dashboard"
    assert_includes @response.body, "Pending reviews"
    assert_includes @response.body, "Flagged reviews"
    assert_includes @response.body, "Hidden responses"
    assert_includes @response.body, "Recent moderation actions"
  end

  test "dashboard avoids N+1 on moderation actions" do
    # Create 5 moderation actions with distinct actors
    5.times do |i|
      actor = User.create!(role: "moderator", email_hmac: "mod_hmac_#{i}")
      ModerationAction.create!(actor: actor, action: "test:#{i}", subject: @user, notes: "note")
    end

    # 1. Pending count
    # 2. Flagged count
    # 3. Hidden responses count
    # 4. Recent submissions count
    # 5. Verification backlog count
    # 6. Recent actions load
    # Total expected: ~6 queries.
    # N+1 would add 5 queries (one for each actor). Total > 11.

    assert_queries(10) do
      get "/admin", headers: auth_headers
    end
    assert_response :success
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

