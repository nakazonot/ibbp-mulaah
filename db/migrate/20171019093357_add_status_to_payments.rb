class AddStatusToPayments < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE payment_status_type AS ENUM ('pending', 'completed');
    SQL
    add_column :payments, :status, :payment_status_type, null: false, default: 'completed'
  end
end
