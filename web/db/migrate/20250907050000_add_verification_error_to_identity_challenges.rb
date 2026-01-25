class AddVerificationErrorToIdentityChallenges < ActiveRecord::Migration[8.0]
  def change
    add_column :identity_challenges, :last_verification_error, :text
  end
end
