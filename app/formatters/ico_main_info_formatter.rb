class IcoMainInfoFormatter
  include Concerns::Currency
  include ApplicationHelper

  def initialize(ico_stages, current_stage, params)
    @ico_stages    = ico_stages
    @current_stage = current_stage
    @params        = params
  end

  def view_data
    result = {
      current_stage_id:   @current_stage.id,
      coin_price:         @current_stage.coin_price,
      currency:           @params['coin.rate_currency'],
      date_end_for_timer: @current_stage.date_end
    }
    result[:ico_stages] = []
    @ico_stages.each do |stage|
      result[:ico_stages] << {
        id:                            stage.id,
        name:                          stage.name,
        date_start:                    stage.date_start,
        date_end:                      stage.date_end,
        coin_price:                    stage.coin_price,
        min_payment_amount:            stage.min_payment_amount.to_f,
        min_amount_tokens_to_purchase: stage.min_amount_tokens.to_f,
        bonus_preferences:             stage.bonuses
      }
    end
    result
  end

end