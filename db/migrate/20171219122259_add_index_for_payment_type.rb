class AddIndexForPaymentType < ActiveRecord::Migration[5.1]
  def change
  	add_index :payments, :payment_type
  end
end
