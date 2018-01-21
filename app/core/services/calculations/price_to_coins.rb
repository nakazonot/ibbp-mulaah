class Services::Calculations::PriceToCoins
  def initialize(user, coin_price)
    @user       = user
    @coin_price = coin_price
  end

  def call
    result = {}

    Parameter.available_currencies.keys.each do |currency_code|
      coin_amount   = Services::Coin::ToCoinConverter.new(currency_floor(@coin_price, currency_code), currency_code).call
      bonus_percent = BonusPreference.get_bonus_total_percent(@user.id, coin_amount)

      result[currency_code] = {
        coin_price:    @coin_price,
        coin_amount:   coin_amount,
        coin_bonus:    Services::Coin::CalcBonus.new(coin_floor(coin_amount), bonus_percent).amount_bonus,
        bonus_percent: bonus_percent
      }
    end

    result
  end
end
