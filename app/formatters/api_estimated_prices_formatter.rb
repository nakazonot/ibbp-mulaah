class APIEstimatedPricesFormatter
  include Concerns::Currency

  def initialize(params)
    @params = params
  end

  def view_data
    formatted_currencies = {}

    @params[:currencies].keys.each do |currency|
      formatted_currencies[currency] = {
        coin_price:        currency_floor(currency_ceil(@params[:currencies][currency], currency), currency),
        coin_amount:       coin_floor(@params[:coin_amount]),
        coin_amount_bonus: coin_floor(@params[:coin_amount_bonus]),
        coin_amount_total: coin_floor(coin_floor(@params[:coin_amount_bonus]) + coin_floor(@params[:coin_amount])),
        bonus_percent:     percent_floor(@params[:bonus_percent])
      }
    end

    { currencies: formatted_currencies }
  end
end
