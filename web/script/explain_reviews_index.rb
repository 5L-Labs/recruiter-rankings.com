# Verification script for index optimization on RecruitersController#index
# Usage: bin/rails runner script/explain_reviews_index.rb

puts "--- Explaining RecruitersController#index Aggregation Query ---"

# The query used in RecruitersController#index to aggregate review stats
query = Review.where(status: "approved")
  .group(:recruiter_id)
  .select(:recruiter_id, "COUNT(*) AS reviews_count", "AVG(overall_score) AS avg_overall")

puts "Query: #{query.to_sql}"
puts "\nExecution Plan:"

begin
  # Run EXPLAIN (ANALYZE if possible, but regular EXPLAIN is safer for potential write queries or unsupported adapters)
  # Here it's a SELECT so it's safe.
  explanation = ActiveRecord::Base.connection.explain(query.to_sql)
  puts explanation
rescue => e
  puts "Error running explain: #{e.message}"
end

puts "\n--- Expected Result with Index ---"
puts "Scan type: Index Only Scan using index_reviews_on_status_recruiter_overall"
