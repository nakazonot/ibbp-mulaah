class CoinPriceForTotalFormatter
  include Concerns::Currency

  def initialize(currencies)
    @currencies = currencies
  end

  def view_data
    result = {}
    @currencies.keys.each do |currency|
      result[currency] = {
        coin_amount:   coins_number_format(@currencies[currency][:coin_amount]),
        coin_bonus:    coins_number_format(@currencies[currency][:coin_bonus]),
        coin_total:    coins_number_format(coin_floor(@currencies[currency][:coin_amount]) + coin_floor(@currencies[currency][:coin_bonus])),
        bonus_percent: percent_number_format(@currencies[currency][:bonus_percent])
      }
    end
    result
  end

end