class AddBtcWallet < ActiveRecord::Migration[5.1]
  def change
  	Parameter.create(name: 'system.btc_wallet_enabled', value: '0', description: 'Adds the BTC wallet to the system (1 - enabled, 0 - disabled)')

  	add_column :users, :btc_wallet, :string, null: true
  end
end
