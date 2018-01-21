class AddUserAgreement < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :agreement, :boolean, default: false
  end
end