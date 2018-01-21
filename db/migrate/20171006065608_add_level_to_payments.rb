class AddLevelToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :referral_level, :integer, null: true

    Parameter.find_by_name('user.referral_bonus_percent').update_columns(description: 'Referral program bonus (in %) payable to the referral link publisher. To use multi-level model for your referral program, enter the bonuses for each level separated by commas. Example: 5, 4, 3')
    Parameter.find_by_name('user.referral_user_bonus_percent').update_columns(description: 'Referral program bonus (in %) payable to the referral link follower')

    Payment.where(payment_type: Payment::PAYMENT_TYPE_REFERRAL_BOUNTY).where(referral_level: nil).update_all(referral_level: 1)
  end
end
