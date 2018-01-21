class AddCreateUserToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :created_by_user_id, :integer, null: true
    add_foreign_key :payments, :users, column: :created_by_user_id
  end
end
