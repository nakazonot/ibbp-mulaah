class IcoStage < ApplicationRecord
  include Concerns::Currency

  has_many :bonus_preferences, dependent: :delete_all
  belongs_to :buy_token_promocode, optional: true, class_name: 'Promocode', foreign_key: 'buy_token_promocode_id'

  validates :name, presence: true
  validates :date_start, presence: true
  validates :date_end, presence: true
  validates :coin_price, presence: true, numericality: { greater_than: 0 }, ico_currency_format: true
  validates :min_payment_amount, allow_blank: true, numericality: { greater_than_or_equal_to: 0 }, ico_currency_format: true
  validates_datetime :date_end, after: :date_start
  validates :tokens_limit, allow_blank: true, numericality: { only_integer: true, greater_than: 0 }

  scope :before, -> (stage) { where('date_start <= ? AND id <> ?', stage.date_start, stage.id) }

  def self.ico_dates_valid?
    return false if self.count == 0
    stages = self.all.order(:date_start)
    stages.each do |stage|
      prev = stage.prev_stage
      return false if prev.present? && stage.date_start != prev.date_end
    end
    true
  end

  def prev_stage
    IcoStage.before(self).order(date_start: :desc).first
  end

  def self.stage_by_date(d)
    self.where('date_start <= ? AND date_end > ?', d, d).first
  end

  def min_amount_tokens
    self.coin_price > 0 ? coin_round(self.min_payment_amount.to_f / self.coin_price.to_f) : 0
  end

  def self.ico_enabled?
    self.ico_dates_valid? && self.stage_by_date(Time.current).present?
  end

  def bonuses
    self.bonus_preferences.order(:min_investment_amount).select(:id, :min_investment_amount, :bonus_percent).map{ |r| r.attributes.symbolize_keys }
  end

  def tokens_limit_reached?
    return false if self.tokens_limit.blank?
    Payment.date_ranges(self.date_start, self.date_end).total_amount_tokens >= self.tokens_limit
  end
end