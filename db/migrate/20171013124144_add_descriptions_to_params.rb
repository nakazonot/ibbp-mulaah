class AddDescriptionsToParams < ActiveRecord::Migration[5.1]
  def change
    Parameter.find_by_name('user.referral_bonus_percent').update_columns(description: 'Referral program bonus (in %) charged to the referral link publisher to replenish balance or buy tokens. To use multi-level model for your referral program, enter the bonuses for each level separated by commas. Example: 5, 4, 3')
    Parameter.find_by_name('user.referral_user_bonus_percent').update_columns(description: 'Referral program bonus (in %) charged to referral link follower to replenish balance or buy tokens.')
    Parameter.find_by_name('user.referral_bonus_type').update_columns(description: 'The type of referral bonus system. Could be tokens/balance. Defines the type of bonus that would be charged to referral link followers.')

    Payment.where(payment_type: Payment::PAYMENT_TYPE_REFERRAL_BOUNTY).where(referral_level: nil).update_all(referral_level: 1)
  end
end
