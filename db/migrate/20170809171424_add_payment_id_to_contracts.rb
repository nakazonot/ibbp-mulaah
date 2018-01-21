class AddPaymentIdToContracts < ActiveRecord::Migration[5.1]
  def change
    add_column :buy_tokens_contracts, :payment_id, :integer
    add_foreign_key :buy_tokens_contracts, :payments, column: :payment_id
  end
end
