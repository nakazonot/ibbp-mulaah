class AddRegistrationIpCountry < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :sign_up_ip, :inet, null: true
    add_column :users, :sign_up_country, :string, null: true
  end
end
