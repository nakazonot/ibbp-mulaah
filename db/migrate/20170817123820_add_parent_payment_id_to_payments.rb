class AddParentPaymentIdToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :parent_payment_id, :integer
    add_foreign_key :payments, :payments, column: :parent_payment_id
    add_index  :payments, :parent_payment_id

    add_column :payments, :referral_user_id, :integer
    add_foreign_key :payments, :users, column: :referral_user_id
    add_index  :payments, :referral_user_id
  end
end
