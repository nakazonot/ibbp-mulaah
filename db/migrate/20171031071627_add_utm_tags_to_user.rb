class AddUtmTagsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :utm_tags, :json, null: true
  end
end
