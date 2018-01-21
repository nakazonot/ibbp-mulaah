class AddPaymentAdderessesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_addresses do |t|
      t.string      :payment_address,        null: false
      t.string      :currency,               null: false
      t.references  :user, index: true, foreign_key: true, null: true
      t.string      :pubkey,                 null: true
      t.string      :dest_tag,               null: true
      t.timestamps
    end

    add_index  :payment_addresses, [:payment_address], unique: true
    add_index  :payment_addresses, [:user_id, :currency], unique: true, where: 'user_id IS NOT NULL'
  end
end
