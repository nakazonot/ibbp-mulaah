class AddPaymentsType < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE payment_type AS ENUM ('balance', 'purchase', 'payment');
    SQL
    add_column :payments, :payment_type, :payment_type, null: false, default: "balance"
    change_column_null :payments, :iso_coin_amount_origin, true
    change_column_null :payments, :iso_coin_amount, true

    Payment.unscoped.update_all(payment_type: 'payment')
  end
end
