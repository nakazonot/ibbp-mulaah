class AddOauthToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :uses_default_password,          :boolean,  default: false
    add_column :users, :is_oauth_sign_up,               :boolean,  default: false
    add_column :users, :oauth_email_confirmed_at,       :datetime
    add_column :users, :oauth_email_confirmation_token, :string
  end
end
