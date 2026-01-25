require 'net/http'
require 'uri'

class LinkedInFetcher
  ALLOWED_HOSTS = ["linkedin.com", "www.linkedin.com"].freeze
  DEFAULT_TIMEOUT = 5
  MAX_BODY_SIZE = 2 * 1024 * 1024 # 2 MB Limit

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

    # Range header to be polite, though server might ignore it
    req['Range'] = "bytes=0-#{MAX_BODY_SIZE}"

    # Use block form of request to stream response and limit size
    body = String.new
    begin
      http.request(req) do |response|
        return nil unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPPartialContent)

        response.read_body do |chunk|
          body << chunk
          if body.bytesize > MAX_BODY_SIZE
             # Stop reading if we exceed the limit
             # We can't easily abort the connection cleanly without raising,
             # but returning what we have is usually enough.
             # However, read_body continues until EOF unless we break out.
             # Net::HTTP doesn't support breaking out of read_body easily without closing socket.
             http.finish if http.started?
             break
          end
        end
      end
    rescue IOError, EOFError, Errno::ECONNRESET
      # Connection closed, which is expected if we force finish
    rescue => _e
      return nil
    end

    body
  rescue => _e
    nil
  end
end
