class AddLockingToPaymentAddress < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_addresses, :lock_version, :integer, default: 0
  end
end
