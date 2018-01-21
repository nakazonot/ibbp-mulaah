class PaymentAddressSoftDelete < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_addresses, :ipn_url, :string, null: true

    add_column :payment_addresses, :deleted_at, :datetime, null: true
    add_index :payment_addresses, :deleted_at
  end
end
