class CreateUsersOauthProviders < ActiveRecord::Migration[5.1]
  def change
    create_table :users_oauth_providers do |t|
      t.references :user, index: true, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps null: false
    end

    add_index :users_oauth_providers, [:provider, :uid]
  end
end
