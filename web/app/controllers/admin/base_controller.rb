module Admin
  class BaseController < ApplicationController
    before_action :require_moderator_auth

    private

    def current_moderator_actor
      User.find_by(role: "moderator")
    end

    def require_moderator_auth
      # Secure default: only allow "mod"/"mod" in development/test
      # In production, require strict ENV setting or fail closed.
      default_cred = (Rails.env.development? || Rails.env.test?) ? "mod" : nil

      expected_user = ENV["DEMO_MOD_USER"].presence || default_cred
      expected_pass = ENV["DEMO_MOD_PASSWORD"].presence || default_cred

      # If no credentials configured in production, deny access by forcing impossible match
      if expected_user.nil? || expected_pass.nil?
        request_http_basic_authentication("Moderation")
        return
      end

      authenticate_or_request_with_http_basic("Moderation") do |u, p|
        ActiveSupport::SecurityUtils.secure_compare(u, expected_user) &&
          ActiveSupport::SecurityUtils.secure_compare(p, expected_pass)
      end
    end
  end
end
