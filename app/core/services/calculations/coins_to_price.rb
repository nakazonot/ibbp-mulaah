class Services::Calculations::CoinsToPrice
  include Concerns::Currency

  def initialize(user, coin_amount, use_promocode = false)
    @user          = user
    @coin_amount   = coin_floor(coin_amount)
    @use_promocode = use_promocode
  end

  def call
    promocode_user = search_promocode_user
    bonus          = BonusPreference.get_bonus_total_percent(@user.id, @coin_amount, promocode_user: promocode_user)
    calculations   = {
      coin_amount:       @coin_amount,
      bonus_percent:     bonus,
      coin_amount_bonus: Services::Coin::CalcBonus.new(@coin_amount, bonus).amount_bonus,
      promocode:         promocode_user,
      currencies:        {}
    }

    Parameter.available_currencies.keys.each do |currency|
      calculations[:currencies][currency] = Services::Coin::ToCurrencyConverter.new(
        @coin_amount,
        currency,
        promocode_user
      ).call
    end

    calculations
  end

  private

  def search_promocode_user
    @use_promocode ? PromocodesUser.search_actual_promocode_by_user(@user.id, @coin_amount) : nil
  end
end
