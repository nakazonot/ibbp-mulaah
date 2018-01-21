class DropUniqueIndexPaymentAddresses < ActiveRecord::Migration[5.1]
  def change
    remove_index  :payment_addresses, [:payment_address]
    add_index  :payment_addresses, [:payment_address, :dest_tag]
  end
end
