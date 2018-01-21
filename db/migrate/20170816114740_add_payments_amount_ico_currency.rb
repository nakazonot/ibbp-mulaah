class AddPaymentsAmountIcoCurrency < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :ico_currency_amount, :decimal, precision: 30, scale: 10, null: true
    add_column :payments, :ico_currency, :string, null: true
  end
end
