class AddNameColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :middle_name, :string
    add_column :users, :last_name,   :string
  end
end
