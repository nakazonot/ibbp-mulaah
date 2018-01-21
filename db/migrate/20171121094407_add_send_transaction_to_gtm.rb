class AddSendTransactionToGtm < ActiveRecord::Migration[5.1]
  def change
  	add_column :buy_tokens_contracts, :send_transaction_to_gtm, :boolean, default: false
  end
end