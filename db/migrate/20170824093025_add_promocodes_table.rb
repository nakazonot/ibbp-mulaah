class AddPromocodesTable < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      CREATE TYPE promocodes_discount_type AS ENUM ('fixed_price', 'bonus');
    SQL

    create_table :promocodes do |t|
      t.string  :code, null: false
      t.datetime :expires_at, null: true
      t.integer :num_total, null: true
      t.integer :num_used, null: false, default: 0
      t.column :discount_type, :promocodes_discount_type, null: false
      t.float :discount_amount, null: false
      t.boolean :is_aggregated_discount, null: false, default: false
      t.string :comment, null: true
      t.boolean :is_valid, null: false, default: true
      t.timestamps null: false
      t.datetime :deleted_at, null: true
    end

    add_index :promocodes, :code, unique: true, where: "deleted_at IS NULL"

    create_table :promocodes_users do |t|
      t.references :promocode, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
      t.datetime :used_at, null: true
      t.integer :transaction_id, null: true
      t.json :promocode_property, null: false
    end

    add_foreign_key :promocodes_users, :payments, column: :transaction_id
  end
end
