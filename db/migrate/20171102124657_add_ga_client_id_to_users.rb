class AddGaClientIdToUsers < ActiveRecord::Migration[5.1]
  def change
  	remove_column :users, :utm_tags
  	add_column :users, :ga_client_id, :string, null: true 
  end
end
