class VerifyIdentityJob < ApplicationJob
  queue_as :default

  def perform(challenge_id, _linkedin_url = nil)
    challenge = IdentityChallenge.find_by(id: challenge_id)
    return unless challenge

    # Security: Always use the stored URL from the challenge to ensure
    # we verify the same URL that we update the user with.
    target_url = challenge.linkedin_url

    # Don't re-verify if already verified
    return if challenge.verified_at.present?

    # Check expiration
    if challenge.expires_at.past?
      challenge.update!(last_verification_error: 'Token expired')
      return
    end

    token = "RR-VERIFY-#{challenge.token_hash}"
    fetcher = LinkedInFetcher.new

    begin
      body = fetcher.fetch(target_url)

      if body&.include?(token)
        challenge.transaction do
          challenge.update!(verified_at: Time.current, last_verification_error: nil)

          # Propagate verification to subject
          case challenge.subject_type
          when 'Recruiter'
            recruiter = Recruiter.find(challenge.subject_id)
            recruiter.update!(verified_at: Time.current)
          when 'User'
            # Update the user's LinkedIn URL now that ownership is verified
            user = User.find(challenge.subject_id)
            user.update!(linked_in_url: challenge.linkedin_url)
          end
        end
      else
        challenge.update!(last_verification_error: 'Token not found on the page. Make sure it is visible and saved.')
      end
    rescue => e
      challenge.update!(last_verification_error: "Verification failed: #{e.message}")
    end
  end
end
