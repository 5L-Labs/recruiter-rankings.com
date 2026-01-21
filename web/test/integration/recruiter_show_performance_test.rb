require "test_helper"

class NPlusOneTest < ActionDispatch::IntegrationTest
  setup do
    @company = Company.create!(name: "Globex", region: "US")
    @recruiter = Recruiter.create!(name: "Recruiter One", company: @company, public_slug: "recruiter-one")
    @user = User.create!(role: "candidate", email_hmac: SecureRandom.hex(16))

    # Create reviews
    5.times do |i|
      review = Review.create!(
        user: @user,
        recruiter: @recruiter,
        company: @company,
        overall_score: 5,
        text: "Review #{i}",
        status: "approved"
      )
      ReviewResponse.create!(review: review, user: @user, body: "Response #{i}", visible: true)
    end
  end

  test "recruiter show page avoids N+1 queries" do
    # Warmup
    get "/recruiters/#{@recruiter.public_slug}"

    count = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
      # Count SELECTs, ignore schema queries or transaction control
      if payload[:sql].start_with?("SELECT") && !payload[:name]&.include?("SCHEMA")
         count += 1
      end
    end

    get "/recruiters/#{@recruiter.public_slug}"

    ActiveSupport::Notifications.unsubscribe(subscriber)

    # If N+1 exists:
    # 1. Recruiter
    # 2. Reviews
    # 3. Overall aggregate
    # 4. Dimensions aggregate
    # 5. Loop 5 times: Response check
    # 6. Loop 5 times: Response load (if separated) or merged with check

    # Current behavior likely:
    # 1. Recruiter
    # 2. Reviews
    # 3. Aggregate 1
    # 4. Aggregate 2
    # 5. Responses for Review 1
    # 6. Responses for Review 2
    # ...
    # 9. Responses for Review 5
    # Total ~9 queries.

    # Optimized behavior:
    # 1. Recruiter
    # 2. Reviews
    # 3. Aggregate 1
    # 4. Aggregate 2
    # 5. Responses for all reviews (1 query)
    # Total ~5 queries.

    # So if we have 5 reviews, we expect ~9 queries currently.
    # If we had 10 reviews, it would be ~14.

    # Let's just assert that we have a low number.
    puts "Query count: #{count}"
    assert count <= 6, "Expected <= 6 queries, but got #{count}. Likely N+1 present."
  end
end
