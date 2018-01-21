class PromocodesUser < ActiveRecord::Base
  include PromocodeConcern

  belongs_to :promocode, -> { with_deleted }
  belongs_to :user

  scope :by_user,      ->(u_id) { where(user_id: u_id) }
  scope :by_promocode, ->(p_id) { where(promocode_id: p_id) }
  scope :not_used,     ->       { where(used_at: nil) }

  def self.search_actual_promocode_by_user(user_id, coin_amount = 0, ico_coin_rate = nil)
    is_promo_token = Promocode.promo_token_enabled? && TokenTransaction.enough_promo_token_balance(user_id) ? nil : false
    promocode = search_actual_promocodes_by_user(user_id, coin_amount, ico_coin_rate, is_promo_token).first
    if promocode.blank? && is_promo_token.nil?
      init_assign_promo_token_to_user(user_id)
      promocode = search_actual_promocodes_by_user(user_id, coin_amount, ico_coin_rate, true).first
    end
    promocode
  end

  def self.search_actual_promocodes_by_user(user_id, coin_amount = 0, ico_coin_rate = nil, is_promo_token = nil)
    promocodes_users = PromocodesUser.by_user(user_id).not_used
      .joins(:promocode)
      .where('promocodes.is_valid' => true)
      .where('promocodes.deleted_at' => nil)
    promocodes_users = promocodes_users.where('promocodes.is_promo_token' => is_promo_token) unless is_promo_token.nil?
    promocodes_users = promocodes_users.order(updated_at: :desc)

    result = []
    promocodes_users.each do |promocode_user|
      result << promocode_user if promocode_user.promocode.promocode_valid? && promocode_user.property_actual?(coin_amount, ico_coin_rate)
    end

    result
  end

  def bonus_from_promocode
    return nil unless self.promocode_property['discount_type'] == Promocode::DISCOUNT_TYPE_BONUS
    { bonus: self.promocode_property['discount_amount'].to_f, is_aggregated_discount: self.promocode_property['is_aggregated_discount'] }
  end

  def fixed_price_from_promocode
    return nil unless self.promocode_property['discount_type'] == Promocode::DISCOUNT_TYPE_FIXED_PRICE
    self.promocode_property['discount_amount'].to_f
  end

  def property_actual?(coin_amount, ico_coin_rate = nil)
    promocode_property_actual?(promocode_property.symbolize_keys, coin_amount, ico_coin_rate)
  end

  private

  def self.init_assign_promo_token_to_user(user_id)
    promo_token = Promocode.promo_token.first
    return if promo_token.blank? || self.by_user(user_id).by_promocode(promo_token.id).not_used.present? || !promo_token.actual? || !promo_token.promocode_valid?
    Services::Promocode::AddToUser.new(User.find(user_id), promo_token.code).call
  end

end
