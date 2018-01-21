class AddReferralIdToIcoCoins < ActiveRecord::Migration[5.1]
  def change
    add_column :user_ico_coins, :referral_user_id, :integer, null: true
    add_foreign_key :user_ico_coins, :users, column: :referral_user_id
    add_index  :user_ico_coins, :referral_user_id

    add_index  :users, :referral_id

    UserIcoCoin.where(create_type: UserIcoCoin::CREATE_TYPE_REFERRAL).find_each(batch_size: 200) do |coin|
      coin.update(referral_user_id: coin.payment.user_id)
    end
  end
end
