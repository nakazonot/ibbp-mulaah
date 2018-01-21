class AddPaymentSystemToExchangeRate < ActiveRecord::Migration[5.1]
  def change
    add_column :exchange_rates, :payment_system, :payment_system_type, null: true
  end
end
