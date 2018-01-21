module PromocodeConcern
  extend ActiveSupport::Concern

  def promocode_property_actual?(property, coin_amount = 0, ico_coin_rate = nil)
    parameters = Parameter.get_all
    ico_coin_rate = ico_coin_rate.present? ? ico_coin_rate : parameters['coin.rate']

    if property[:discount_type] == Promocode::DISCOUNT_TYPE_FIXED_PRICE
      system_rate = parameters['coin.rate']

      return property[:discount_amount].to_f < system_rate
    elsif property[:discount_type] == Promocode::DISCOUNT_TYPE_BONUS
      system_bonus = BonusPreference.get_bonus_by_coin_amount(parameters['bonuses_percent'], coin_amount, ico_coin_rate)

      return true if property[:is_aggregated_discount].to_b
      return property[:discount_amount].to_f > system_bonus
    end

    false
  end
end
