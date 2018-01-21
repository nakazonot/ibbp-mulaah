class PaymentTransactionIdNull < ActiveRecord::Migration[5.1]
  def change
    change_column_null :payments, :transaction_id, true
  end
end
