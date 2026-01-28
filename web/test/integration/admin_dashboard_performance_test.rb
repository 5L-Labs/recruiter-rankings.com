require "test_helper"

class AdminDashboardPerformanceTest < ActionDispatch::IntegrationTest
  def auth_headers
    { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("mod", "mod") }
  end

  def assert_query_count(expected_count, &block)
    queries = []
    callback = ->(name, start, finish, id, payload) {
      # Ignore schema queries and transaction control
      unless payload[:name] == "SCHEMA" || payload[:sql].match?(/TRANSACTION/) || payload[:sql].match?(/SAVEPOINT/)
        queries << payload[:sql]
      end
    }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &block)
    assert_equal expected_count, queries.count, "Expected #{expected_count} queries, but got #{queries.count}. Queries:\n#{queries.join("\n")}"
  end

  setup do
    @actor = User.create!(role: "moderator", email_hmac: SecureRandom.hex(16))
    @subject = User.create!(role: "candidate", email_hmac: SecureRandom.hex(16))

    # Create 5 actions with actors
    5.times do |i|
      ModerationAction.create!(actor: @actor, action: "test_action_#{i}", subject: @subject, notes: "test note")
    end
  end

  test "dashboard query count" do
    # Expected queries without eager loading:
    # 1. Review pending count
    # 2. Review flagged count
    # 3. ReviewResponse hidden count
    # 4. Review recent count
    # 5. IdentityChallenge backlog count
    # 6. Fetch ModerationAction (limit 20)
    # 7. Fetch actors (1 query)
    # Total = 7

    assert_query_count(7) do
      get "/admin", headers: auth_headers
      assert_response :success
    end
  end
end
