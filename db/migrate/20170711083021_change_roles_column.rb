class ChangeRolesColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :roles_mask
    add_column :users, :role, :string
  end
end
