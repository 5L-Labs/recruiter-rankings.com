require "test_helper"

class CompaniesEmptyStateTest < ActionDispatch::IntegrationTest
  test "companies index shows empty state when no results found" do
    get "/companies", params: { q: "NonExistentCompanyXYZ" }
    assert_response :success
    assert_select "tr.company-row", count: 0
    assert_select "p", text: /No companies found/
    assert_select "a", text: /Clear filters/
  end
end
