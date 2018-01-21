class ChangeNullColumnPayments < ActiveRecord::Migration[5.1]
  def change
    change_column_null :payments, :currency_origin, true
    change_column_null :payments, :currency_buyer, true
    change_column_null :payments, :amount_origin, true
    change_column_null :payments, :amount_buyer, true
  end
end