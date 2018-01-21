class UserIcoCoin < ApplicationRecord
  belongs_to :payment

  CREATE_TYPE_PAYMENT  = 'payment'
  CREATE_TYPE_REFERRAL = 'referral'

  scope :by_user,           ->(user_id) { where(user_id: user_id) }
  scope :referral_coin_sum, ->(user_id) { by_user(user_id).where(create_type: CREATE_TYPE_REFERRAL).sum(:coin_amount) }
end
