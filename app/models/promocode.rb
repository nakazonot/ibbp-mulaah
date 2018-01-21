class Promocode < ActiveRecord::Base
  include PromocodeConcern

  acts_as_paranoid

  has_many :promocodes_users
  has_many :users, through: :promocodes_users
  belongs_to :owner, class_name: 'User', optional: true

  DISCOUNT_TYPE_FIXED_PRICE = 'fixed_price'
  DISCOUNT_TYPE_BONUS       = 'bonus'

  PROMOCODE_FORMAT = /\A[a-zA-Z0-9_-]*\z/u

  scope :by_code,     ->(pc) { where('lower(code) = ?', pc.downcase) }
  scope :promo_token, ->     { where(is_promo_token: true) }

  validates :discount_type, presence: true, inclusion: { in: [ DISCOUNT_TYPE_FIXED_PRICE, DISCOUNT_TYPE_BONUS ] }
  validates :code, presence: true, length: {minimum: 3}, format: { with: PROMOCODE_FORMAT }, uniqueness: {case_sensitive: false}
  validates :discount_amount, presence: true, numericality: { greater_than: 0 }, ico_currency_format: true, if: ->(obj) { obj.discount_type == DISCOUNT_TYPE_FIXED_PRICE }
  validates :discount_amount, presence: true, numericality: { greater_than_or_equal: 0 }, percent_format: true, if: ->(obj) { obj.discount_type == DISCOUNT_TYPE_BONUS }
  validates :num_total, allow_blank: true, numericality: { only_integer: true, greater_than: 0 }
  validates_datetime :expires_at, allow_blank: true, after: Time.current
  validates :owner_bonus, presence: true, numericality: { greater_than: 0 }, if: ->(obj) { obj.owner_id.present? }
  validates :is_promo_token, promo_token_unique: true

  after_save :promocode_valid?

  def self.discount_types
    {
      DISCOUNT_TYPE_FIXED_PRICE => 'Fixed Price',
      DISCOUNT_TYPE_BONUS       => 'Bonus'
    }
  end

  def self.search_promo_token
    promo_token_first  = self.promo_token.first
    return promo_token_first if promo_token_first.present? && promo_token_first.actual? && promo_token_first.promocode_valid?
    nil
  end

  def promocode_valid?
    valid = (expires_at.blank? || expires_at > Time.current) && (num_total.blank? || num_total > num_used) && deleted_at.nil?
    self.update_column(:is_valid, valid)
    valid
  end

  def property
    { discount_type: discount_type, discount_amount: discount_amount, is_aggregated_discount: is_aggregated_discount, is_onetime: is_onetime}
  end

  def actual?
    promocode_property_actual?(property)
  end

  def can_duplicate?
    !is_onetime? && actual? && promocode_valid?
  end

  def is_promo_token?
    is_promo_token
  end

  def self.promo_token_enabled?
    ENV['PROMO_TOKENS_ENABLE'].to_i == 1
  end
end
