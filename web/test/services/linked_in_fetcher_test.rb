require "test_helper"
require "minitest/mock"

class LinkedInFetcherTest < ActiveSupport::TestCase
  test "fetches arbitrary url (reproduction of SSRF) - blocked" do
    fetcher = LinkedInFetcher.new
    url = "http://example.com/sensitive-data"

    # We expect NO request to be made because of the host validation

    result = fetcher.fetch(url)
    assert_nil result
  end

  test "fetches linkedin url - allowed" do
    fetcher = LinkedInFetcher.new
    url = "https://www.linkedin.com/in/someuser"

    http_mock = Minitest::Mock.new
    response_mock = Minitest::Mock.new
    response_mock.expect :is_a?, true, [Net::HTTPSuccess]
    response_mock.expect :body, "linkedin profile"

    http_mock.expect :use_ssl=, nil, [true]
    http_mock.expect :read_timeout=, nil, [5]
    http_mock.expect :open_timeout=, nil, [5]
    http_mock.expect :request, response_mock, [Net::HTTP::Get]

    Net::HTTP.stub :new, http_mock do
      result = fetcher.fetch(url)
      assert_equal "linkedin profile", result
    end
  end
end
