class Services::Calculations::CoinsForAllDeposits
  include Concerns::Currency

  def initialize(user)
    @user = user
  end

  def call
    result                     = Payment.calc_coins_from_all_balances_by_promocode(@user)
    one_currency               = result[:currencies].keys.size == 1
    bonus_percent              = BonusPreference.get_bonus_total_percent(@user.id, result[:coin_amount], promocode_user: result[:promocode])
    result[:coin_amount_bonus] = Services::Coin::CalcBonus.new(result[:coin_amount], bonus_percent).amount_bonus
    result[:one_currency]      = one_currency || result[:currencies].blank?
    result[:bonus_percent]     = bonus_percent
    if one_currency
      result[:coin_price]      = result[:currencies].first.second
      result[:currency]        = result[:currencies].first.first
    end

    result
  end

end