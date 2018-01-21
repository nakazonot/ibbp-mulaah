class AddPromocodeOwner < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE "payment_type" ADD VALUE 'promocode_bounty';
    SQL

    add_column :promocodes, :owner_id, :integer, null: true
    add_column :promocodes, :owner_bonus, :float, null: true

    add_foreign_key :promocodes, :users, column: :owner_id
  end
end
