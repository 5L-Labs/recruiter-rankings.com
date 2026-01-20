require "test_helper"

class RecruiterShowPerformanceTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "Perf Corp", region: "US")
    @recruiter = Recruiter.create!(name: "Perf Recruiter", company: @company, public_slug: "perf-recruiter", region: "US")
    @user = User.create!(role: "candidate", email_hmac: SecureRandom.hex(16))

    10.times do |i|
      review = Review.create!(
        user: @user,
        recruiter: @recruiter,
        company: @company,
        overall_score: 5,
        text: "Review #{i}",
        status: "approved"
      )
      ReviewResponse.create!(
        review: review,
        user: @user,
        body: "Response #{i}",
        visible: true
      )
    end
  end

  test "avoids n+1 queries on recruiter show page" do
    # Warmup to load schema etc
    get "/recruiters/#{@recruiter.public_slug}"

    count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
      count += 1 unless payload[:name] == "SCHEMA" || payload[:name] == "TRANSACTION"
    end

    get "/recruiters/#{@recruiter.public_slug}"

    ActiveSupport::Notifications.unsubscribe(subscriber)

    # Without fix:
    # 1. Recruiter load
    # 2. Reviews load
    # 3. Overall aggregate
    # 4. Dimensions aggregate
    # 5-24. For each of 10 reviews: check exists? (1) + load (1) = 20 queries (or 10 if just exists check fails)
    # Total > 10.

    # With fix:
    # 1. Recruiter load
    # 2. Reviews load (with responses)
    # 3. Overall aggregate
    # 4. Dimensions aggregate
    # Total ~4-5 queries.

    puts "Query count: #{count}"
    assert_operator count, :<, 10, "Too many queries! N+1 detected. Count: #{count}"
  end
end
