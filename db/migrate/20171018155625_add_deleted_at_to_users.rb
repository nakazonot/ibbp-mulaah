class AddDeletedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :email
    add_column :users, :deleted_at, :datetime, null: true
    add_index :users, :email, unique: true, where: 'deleted_at IS NULL'
    add_index :users, :deleted_at
  end
end
