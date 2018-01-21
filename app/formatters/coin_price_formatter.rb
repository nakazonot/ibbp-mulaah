class CoinPriceFormatter
  include Concerns::Currency

  def initialize(params, api = false)
    @params = params
    @api    = api
  end

  def view_data
    result = {}
    if @api
      result[:coin_amount]       = coin_floor(@params[:coin_amount])
      result[:coin_amount_bonus] = coin_floor(@params[:coin_amount_bonus])
      result[:coin_amount_total] = coin_floor(coin_floor(@params[:coin_amount_bonus]) + coin_floor(@params[:coin_amount]))
      result[:bonus_percent]     = percent_floor(@params[:bonus_percent])
    else
      result[:coin_amount]       = coins_number_format(@params[:coin_amount])
      result[:coin_amount_bonus] = coins_number_format(@params[:coin_amount_bonus])
      result[:coin_amount_total] = coins_number_format(coin_floor(@params[:coin_amount_bonus]) + coin_floor(@params[:coin_amount]))
      result[:bonus_percent]     = percent_number_format(@params[:bonus_percent])
    end
    

    if @params[:promocode].present?
      result[:promocode] = {
        name: @params[:promocode].promocode.code,
        property: @params[:promocode].promocode_property,
        is_promo_token: @params[:promocode].promocode.is_promo_token && Promocode.promo_token_enabled?
      }
    end

    result[:currencies] = {}
    @params[:currencies].keys.each do |currency|
      val = currency_ceil(@params[:currencies][currency], currency)
      result[:currencies][currency] = @api ? currency_floor(val, currency) : currency_number_format(val, currency)
    end
    result
  end
end
