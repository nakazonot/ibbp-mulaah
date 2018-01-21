class TokenTransaction < ApplicationRecord
  acts_as_paranoid

  TRANSACTION_TYPE_BALANCE                  = 'balance'
  TRANSACTION_TYPE_PURCHASE                 = 'purchase'
  TRANSACTION_STATUS_PENDING                = 'pending'
  TRANSACTION_STATUS_COMPLETED              = 'completed'

  belongs_to :user
  belongs_to :payment_address, optional: true
  belongs_to :payment, optional: true

  scope :by_user,                ->(user_id)                { where(user_id: user_id) }
  scope :by_type,                ->(type)                   { where(transaction_type: type) }
  scope :by_payment_system,      ->(p_system)               { where(payment_system: p_system) }
  scope :pending,                ->                         { where(status: TRANSACTION_STATUS_PENDING) }
  scope :completed,              ->                         { where(status: TRANSACTION_STATUS_COMPLETED) }

  def completed?
    self.status == TRANSACTION_STATUS_COMPLETED
  end

  def self.promo_token_balance_by_user(user_id)
    balance = self.where(contract: ENV['PROMO_TOKENS_CONTRACT']).by_type(TRANSACTION_TYPE_BALANCE).by_user(user_id).sum(:amount)
    purchase = self.where(contract: ENV['PROMO_TOKENS_CONTRACT']).by_type(TRANSACTION_TYPE_PURCHASE).by_user(user_id).sum(:amount)
    balance - purchase
  end

  def self.enough_promo_token_balance(user_id)
    TokenTransaction.promo_token_balance_by_user(user_id) >= 1
  end

end