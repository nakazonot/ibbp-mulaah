class AddIndexToPromocodeUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :promocodes_users, :updated_at
  end
end
