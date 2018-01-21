class LoyaltyProgram < ActiveRecord::Base
  acts_as_paranoid

  has_many :loyalty_programs_users
  has_many :users, through: :loyalty_programs_users

  LOYALTY_PROGRAM_FORMAT = /\A[a-zA-Z0-9_-]*\z/u

  validates :contract, presence: true, eth_wallet: true
  validates :name, presence: true, length: {minimum: 3}, format: { with: LOYALTY_PROGRAM_FORMAT }, uniqueness: {case_sensitive: false}
  validates :bonus_percent, presence: true, numericality: { greater_than: 0 }
  validates :min_amount, presence: true, numericality: { greater_than: 0 }
  validates :lifetime_hour, allow_blank: true, numericality: { only_integer: true, greater_than: 0 }

  scope :enabled, -> { where(is_enabled: true) }

end