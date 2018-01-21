class BonusPreference < ApplicationRecord
  belongs_to :ico_stage, optional: true

  validates :min_investment_amount, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :min_investment_amount, scope: :ico_stage_id
  validates :bonus_percent, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, percent_format: true

  def self.get_bonus_preference(user_id, coin_amount: 0, promocode_user: nil, ico_coin_rate: nil)
    user                  = User.find_by(id: user_id)
    parameters            = Parameter.get_all
    loyalty_program_user  = Services::LoyaltyProgram::ChoiceForUser.new(user).call

    if ico_coin_rate.blank?
      promocode_coin_rate = promocode_user.present? ? promocode_user.fixed_price_from_promocode : nil
      ico_coin_rate           = promocode_coin_rate.present? ? promocode_coin_rate : parameters['coin.rate']
    end

    bonus_percent         = get_bonus_by_coin_amount(parameters['bonuses_percent'], coin_amount, ico_coin_rate)
    bonus_promocode       = promocode_user.nil? ? nil : promocode_user.bonus_from_promocode
    bonus_loyalty_program = loyalty_program_user.present? ? loyalty_program_user.loyalty_program.bonus_percent : 0
    currency              = parameters['coin.rate_currency']

    result = {
      bonus_percent: bonus_percent,
      bonus_promocode: 0,
      bonus_refferal_user_percent: bonus_referral_user(user),
      bonus_loyalty_program: bonus_loyalty_program,
      max_investment_amount: nil,
      currency: currency
    }

    if bonus_promocode.present?
      result[:bonus_percent] = 0 unless bonus_promocode[:is_aggregated_discount]
      result[:bonus_promocode] = bonus_promocode[:bonus]
    end

    result[:bonus_total_percent] = result[:bonus_percent] + result[:bonus_promocode] + 
      result[:bonus_refferal_user_percent] + result[:bonus_loyalty_program]
    result
  end

  def self.get_bonus_total_percent(user_id, coin_amount, promocode_user: nil, ico_coin_rate: nil)
    get_bonus_preference(user_id, coin_amount: coin_amount, promocode_user: promocode_user, ico_coin_rate: ico_coin_rate)[:bonus_total_percent]
  end

  def self.get_bonus_by_coin_amount(bonuses, coin_amount, ico_coin_rate)
    coin_price = ico_currency_ceil(coin_amount.to_f * ico_coin_rate.to_f)
    bonus = 0
    bonuses.each do |row|
      bonus = row[:bonus_percent] if coin_price >= row[:min_investment_amount]
    end
    bonus
  end

  private

  def self.bonus_referral_user(user)
    if User.new.ability.can?(:referral_system, :tokens) && user&.referral_id.present?
      return UserParameter.get_user_parameter(user, 'user.referral_user_bonus_percent')
    end
    0.0
  end
end