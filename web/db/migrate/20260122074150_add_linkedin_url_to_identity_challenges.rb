class AddLinkedinUrlToIdentityChallenges < ActiveRecord::Migration[8.1]
  def change
    add_column :identity_challenges, :linkedin_url, :string
  end
end
