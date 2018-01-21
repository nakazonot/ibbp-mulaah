class InvoicedAddStatusAndPayment < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE invoice_status_type
      AS ENUM ('created', 'paid');
    SQL

    add_column :invoices, :status, :string, default: 'created', null: false
    add_column :invoices, :payment_id, :integer, null: true
    add_foreign_key :invoices, :payments, column: :payment_id
    add_index  :invoices, [:payment_id]
  end
end
