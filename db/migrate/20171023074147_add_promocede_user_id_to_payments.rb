class AddPromocedeUserIdToPayments < ActiveRecord::Migration[5.1]
  def change
    add_reference :payments, :promocodes_users, index: true, foreign_key: true, null: true

    PromocodesUser.where.not(transaction_id: nil).each do |promocode_user|
      ActiveRecord::Base.transaction do
        Payment.where(id: promocode_user.transaction_id).update_all(promocodes_users_id: promocode_user.id)
        Payment.where(parent_payment_id: promocode_user.transaction_id).where(payment_type: [Payment::PAYMENT_TYPE_PROMOCODE_BONUS, Payment::PAYMENT_TYPE_PROMOCODE_BOUNTY]).update_all(promocodes_users_id: promocode_user.id)
      end
    end

  end
end
