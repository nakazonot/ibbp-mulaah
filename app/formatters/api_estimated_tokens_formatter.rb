class APIEstimatedTokensFormatter
  include Concerns::Currency

  def initialize(currencies)
    @currencies = currencies
  end

  def view_data
    formatted_currencies = {}

    @currencies.keys.each do |currency|
      formatted_currencies[currency] = {
        coin_price:        currency_floor(currency_ceil(@currencies[currency][:coin_price], currency), currency),
        coin_amount:       coin_floor(@currencies[currency][:coin_amount]),
        coin_amount_bonus: coin_floor(@currencies[currency][:coin_bonus]),
        coin_amount_total: coin_floor(coin_floor(@currencies[currency][:coin_amount]) + coin_floor(@currencies[currency][:coin_bonus])),
        bonus_percent:     percent_floor(@currencies[currency][:bonus_percent])
      }
    end

    { currencies: formatted_currencies }
  end
end
