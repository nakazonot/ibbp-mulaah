class AddRequestInfoToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :ip, :inet, null: true
    add_column :payments, :country, :string, null: true, index: true
    add_column :payments, :lang, :string, null: true, index: true
  end
end
