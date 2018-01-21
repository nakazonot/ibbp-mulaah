class AddPaymentSystemField < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE payment_system_type AS ENUM ('invoiced', 'coin_payments', 'any_pay_coins');
    SQL
    add_column :payments, :payment_system, :payment_system_type, null: true
    add_column :payment_addresses, :payment_system, :payment_system_type, null: true

    remove_index :payment_addresses, column: [:user_id, :currency]
  end
end
