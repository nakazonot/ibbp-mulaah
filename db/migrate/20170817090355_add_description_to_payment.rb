class AddDescriptionToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :description, :text, null: true
  end
end