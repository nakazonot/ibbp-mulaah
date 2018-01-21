class ReferralsBountyBalanceFormatter
  include Concerns::Currency
  include ApplicationHelper

  def initialize(users)
    @users = users
  end

  def view_data
    result = {}
    @users.each do |user|
      result[user.email]                               = { bounty_amount: 0 } if result[user.email].blank?
      result[user.email][:email]                       = user.email
      result[user.email][:id]                          = user.id
      result[user.email][:currencies]                  = {} if result[user.email][:currencies].blank?
      if user.currency.present?
        amount                                         = currency_floor(user.bounty_amount.to_f, user.currency)
        result[user.email][:bounty_amount]            += amount
        result[user.email][:currencies][user.currency] = amount
      end
      result[user.email][:created_at]                  = user.created_at
      result[user.email][:referral_level]              = user.referral_level
      result[user.email][:confirmed_at]                = user.confirmed_at
    end
    result.values
  end
end