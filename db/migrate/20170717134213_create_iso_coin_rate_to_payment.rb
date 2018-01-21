class CreateIsoCoinRateToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :iso_coin_rate, :float
    add_column :payments, :amount_buyer_usd, :decimal, precision: 30, scale: 10
  end
end
