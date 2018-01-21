class AddKycFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :kyc_date, :datetime, null: true
  	add_column :users, :kyc_result, :boolean, default: false

  	Parameter.create(name: 'user.kyc_enabled', value: '0', description: 'Enables KYC (Know Your Customer) compliance check during the token purchase (1=on, 0=off). The check result is added to the user’s profile.')
  end
end
