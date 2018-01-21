class AddPaymentsSystem < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :system, :boolean, default: false
  end
end
