class MigrateDataFromUserIcoCoinsToPayment < ActiveRecord::Migration[5.1]
  def change
    UserIcoCoin.where(create_type: UserIcoCoin::CREATE_TYPE_REFERRAL).find_each(batch_size: 200) do |uic|
      Payment.create(
        user_id: uic.user_id,
        payment_type: Payment::PAYMENT_TYPE_REFERRAL_BOUNTY,
        referral_user_id: uic.referral_user_id,
        iso_coin_amount: uic.coin_amount,
        parent_payment_id: uic.payment_id,
        created_at: uic.created_at,
        updated_at: uic.updated_at
      )
    end
  end
end
