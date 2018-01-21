class AddTrackingLabelsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :tracking_labels, :json, null: true
  end
end
