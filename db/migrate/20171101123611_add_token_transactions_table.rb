class AddTokenTransactionsTable < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE token_transaction_type AS ENUM ('balance', 'purchase');
    SQL
    create_table :token_transactions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :payment_address, index: true, foreign_key: true
      t.string     :transaction_id
      t.decimal    :amount, null: false
      t.string     :currency
      t.string     :contract, null: false
      t.column     :status, :payment_status_type, null: false, default: 'completed'
      t.column     :transaction_type, :token_transaction_type, null: false
      t.column     :payment_system, :payment_system_type
      t.references :payment, index: true, foreign_key: true
      t.timestamps
      t.datetime   :deleted_at,   null: true
    end
  end
end
