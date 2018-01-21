class CoinPriceForAllBalancesFormatter
  include Concerns::Currency

  def initialize(params, api = false)
    @params = params
    @api    = api
  end

  def view_data
    result = {}
    if @api
      result[:coin_amount]       = coin_floor(@params[:coin_amount])
      result[:coin_price]        = currency_floor(@params[:coin_price], @params[:currency])
      result[:coin_amount_bonus] = coin_floor(@params[:coin_amount_bonus])
      result[:bonus_percent]     = percent_floor(@params[:bonus_percent])
    else
      result[:coin_amount]       = coins_number_format(@params[:coin_amount])
      result[:coin_price]        = currency_number_format(@params[:coin_price], @params[:currency])
      result[:coin_amount_bonus] = coins_number_format(@params[:coin_amount_bonus])
      result[:bonus_percent]     = percent_number_format(@params[:bonus_percent])
    end
    result[:one_currency]      = @params[:one_currency]
    result[:currency]          = @params[:currency]

    if @params[:promocode].present?
      result[:promocode] = {
        name: @params[:promocode].promocode.code, 
        property: @params[:promocode].promocode_property, 
        is_promo_token: @params[:promocode].promocode.is_promo_token 
      }
    end

    if !@params[:one_currency] && @params[:currencies].present?
      result[:balances] = balances
    end
    result[:error] = @params[:error] if @params[:error].present?
    result
  end

  private

  def balances
    res = {}
    @params[:currencies].keys.each do |currency|
      if @api
        res[currency] = currency_floor(@params[:currencies][currency], currency)
      else
        res[currency] = currency_number_format(@params[:currencies][currency], currency)
      end
    end
    res
  end

end