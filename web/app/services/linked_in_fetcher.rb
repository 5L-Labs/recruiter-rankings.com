require 'net/http'
require 'uri'

class LinkedInFetcher
  ALLOWED_HOSTS = ["linkedin.com", "www.linkedin.com"].freeze
  DEFAULT_TIMEOUT = 5

  def fetch(url)
    uri = URI.parse(url)
    return nil unless uri.is_a?(URI::HTTPS) || uri.is_a?(URI::HTTP)
    return nil unless ALLOWED_HOSTS.any? { |host| uri.host == host || uri.host&.end_with?(".#{host}") }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    timeout = (ENV['LINKEDIN_FETCH_TIMEOUT'] || DEFAULT_TIMEOUT.to_s).to_i
    http.read_timeout = timeout
    http.open_timeout = timeout

    req = Net::HTTP::Get.new(uri.request_uri)
    req['User-Agent'] = ENV['LINKEDIN_FETCH_UA'].presence || 'RecruiterRankingsBot/0.1'

    res = http.request(req)
    return res.body if res.is_a?(Net::HTTPSuccess)

    nil
  rescue => _e
    nil
  end
end
