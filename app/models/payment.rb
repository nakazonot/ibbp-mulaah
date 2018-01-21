class Payment < ApplicationRecord
  include Concerns::Currency
  acts_as_paranoid

  PAYMENT_TYPE_BALANCE                  = 'balance'
  PAYMENT_TYPE_PURCHASE                 = 'purchase'
  PAYMENT_TYPE_PAYMENT                  = 'payment'
  PAYMENT_TYPE_BUY_TOKEN_BONUS          = 'buy_token_bonus'
  PAYMENT_TYPE_PROMOCODE_BONUS          = 'promocode_bonus'
  PAYMENT_TYPE_PROMOCODE_BOUNTY         = 'promocode_bounty'
  PAYMENT_TYPE_REFERRAL_BOUNTY          = 'referral_bounty'
  PAYMENT_TYPE_REFERRAL_USER            = 'referral_user'
  PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE  = 'referral_bounty_balance'
  PAYMENT_TYPE_REFERRAL_BONUS_BALANCE   = 'referral_bonus_balance'
  PAYMENT_TYPE_REFUND                   = 'refund'
  PAYMENT_TYPE_REFUND_TOKENS            = 'refund_tokens'
  PAYMENT_TYPE_TRANSFER_TOKENS          = 'transfer_tokens'
  PAYMENT_TYPE_LOYALTY_BONUS            = 'loyalty_bonus'

  PAYMENT_STATUS_PENDING                = 'pending'
  PAYMENT_STATUS_COMPLETED              = 'completed'

  PAYMENT_TYPES_TOKENS = [
    PAYMENT_TYPE_PURCHASE, 
    PAYMENT_TYPE_PAYMENT, 
    PAYMENT_TYPE_BUY_TOKEN_BONUS, 
    PAYMENT_TYPE_PROMOCODE_BONUS, 
    PAYMENT_TYPE_REFERRAL_USER, 
    PAYMENT_TYPE_REFERRAL_BOUNTY, 
    PAYMENT_TYPE_PROMOCODE_BOUNTY,
    PAYMENT_TYPE_LOYALTY_BONUS
  ]
  PAYMENT_TYPES_TOKENS_WITHOUT_REFERRAL = [
    PAYMENT_TYPE_PURCHASE, 
    PAYMENT_TYPE_PAYMENT, 
    PAYMENT_TYPE_BUY_TOKEN_BONUS, 
    PAYMENT_TYPE_PROMOCODE_BONUS,
    PAYMENT_TYPE_LOYALTY_BONUS
  ]
  PAYMENT_TYPES_TOKENS_REFERRAL = [
    PAYMENT_TYPE_REFERRAL_USER, 
    PAYMENT_TYPE_REFERRAL_BOUNTY, 
    PAYMENT_TYPE_PROMOCODE_BOUNTY
  ]
  PAYMENT_TYPES_CAN_BE_CREATED_BY_USER = [
    PAYMENT_TYPE_BALANCE, 
    PAYMENT_TYPE_PURCHASE, 
    PAYMENT_TYPE_REFUND, 
    PAYMENT_TYPE_REFUND_TOKENS,
    PAYMENT_TYPE_TRANSFER_TOKENS
  ]
  PAYMENT_TYPES_REFUND_TOKENS = [
    PAYMENT_TYPE_REFUND_TOKENS,
    PAYMENT_TYPE_TRANSFER_TOKENS
  ]

  belongs_to :user, -> { with_deleted }
  belongs_to :created_by_user, class_name: 'User', foreign_key: 'created_by_user_id', optional: true
  belongs_to :parent_payment, class_name: 'Payment', foreign_key: 'parent_payment_id', optional: true
  belongs_to :promocodes_user, class_name: 'PromocodesUser', foreign_key: 'promocodes_users_id', optional: true

  has_many :child_payments, class_name: 'Payment', foreign_key: 'parent_payment_id'

  has_one :loyalty_programs_user
  has_one :buy_tokens_contract
  has_one :invoice

  scope :by_user,                        ->(user_id)                { where(user_id: user_id) }
  scope :not_system,                     ->                         { where(system: false) }
  scope :amount_sum_by_currency,         ->                         { completed.group(:currency_buyer).sum(:amount_buyer) }
  scope :by_type,                        ->(type)                   { where(payment_type: type) }
  scope :by_currency_sum,                ->(currency)               { completed.where(currency_buyer: currency).sum(:amount_buyer) }
  scope :by_parent_ids,                  ->(ids)                    { where(parent_payment_id: ids) }
  scope :total_amount_tokens,            ->                         { tokens_by_types(PAYMENT_TYPES_TOKENS, PAYMENT_TYPE_REFUND_TOKENS) }
  scope :user_total_amount_tokens,       ->                         { tokens_by_types(PAYMENT_TYPES_TOKENS, PAYMENT_TYPES_REFUND_TOKENS) }
  scope :countries,                      ->                         { where('country IS NOT NULL').distinct.pluck(:country) }
  scope :languages,                      ->                         { where('lang IS NOT NULL').distinct.pluck(:lang) }
  scope :date_ranges,                    ->(starting_at, ending_at) { from_datetime(starting_at).to_datetime(ending_at) }
  scope :by_payment_system,              ->(p_system)               { where(payment_system: p_system) }
  scope :pending,                        ->                         { where(status: PAYMENT_STATUS_PENDING) }
  scope :completed,                      ->                         { where(status: PAYMENT_STATUS_COMPLETED) }
  scope :from_datetime, ->(starting_at) do
    where('payments.created_at >= ?', starting_at) if starting_at.present?
  end
  scope :to_datetime, ->(ending_at) do
    where('payments.created_at < ?', ending_at) if ending_at.present?
  end
  scope :tokens_by_types, ->(add_types, subtract_types = []) do
    add_types      = [ add_types ]      unless add_types.kind_of?(Array)
    subtract_types = [ subtract_types ] unless subtract_types.kind_of?(Array)

    where(payment_type: add_types + subtract_types).sum(query_for_iso_coin_amount(add_types, subtract_types))
  end

  def self.query_for_iso_coin_amount(add_types, subtract_types = [])    
    sanitize_sql_array(["CASE
        WHEN payment_type IN (:add_types) THEN payments.iso_coin_amount
        WHEN payment_type IN (:subtract_types) THEN -payments.iso_coin_amount
        ELSE 0
      END", [add_types: add_types, subtract_types: subtract_types]].flatten)
  end

  def completed?
    self.status == PAYMENT_STATUS_COMPLETED
  end

  def self.payment_types
    [
      ['Balance', Payment::PAYMENT_TYPE_BALANCE],
      ['Purchase', Payment::PAYMENT_TYPE_PURCHASE],
      ['Payment', Payment::PAYMENT_TYPE_PAYMENT],
      ['Buy Token Bonus', Payment::PAYMENT_TYPE_BUY_TOKEN_BONUS],
      ['Promocode Bonus', Payment::PAYMENT_TYPE_PROMOCODE_BONUS],
      ['Promocode Bounty', Payment::PAYMENT_TYPE_PROMOCODE_BOUNTY],
      ['Referral Bounty', Payment::PAYMENT_TYPE_REFERRAL_BOUNTY],
      ['Referral User', Payment::PAYMENT_TYPE_REFERRAL_USER],
      ['Referral Balance Bounty', Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE],
      ['Referral Balance Bonus', Payment::PAYMENT_TYPE_REFERRAL_BONUS_BALANCE],
      ['Refund', Payment::PAYMENT_TYPE_REFUND],
      ['Refund Tokens', Payment::PAYMENT_TYPE_REFUND_TOKENS],
      ['Tokens Transfer', Payment::PAYMENT_TYPE_TRANSFER_TOKENS],
      ['Loyalty Program Bonus', Payment::PAYMENT_TYPE_LOYALTY_BONUS],
    ]
  end

  def self.scope_by_type(type, scope)
    return scope.where(payment_type: [PAYMENT_TYPE_REFERRAL_BOUNTY, PAYMENT_TYPE_REFERRAL_USER, PAYMENT_TYPE_REFERRAL_BONUS_BALANCE, PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE]) if type == 'referral'
    return scope.where(payment_type: [PAYMENT_TYPE_PROMOCODE_BONUS, PAYMENT_TYPE_PROMOCODE_BOUNTY]) if type == 'promocode'
    scope.where(payment_type: type)
  end

  def self.user_totals(user_id)
    coin_count          = self.by_user(user_id).tokens_by_types(PAYMENT_TYPES_TOKENS_WITHOUT_REFERRAL)
    referral_coin_count = self.by_user(user_id).tokens_by_types(PAYMENT_TYPES_TOKENS_REFERRAL)
    refund_coin_count   = self.by_user(user_id).tokens_by_types(PAYMENT_TYPES_REFUND_TOKENS)

    if coin_count >= refund_coin_count
      coin_count -= refund_coin_count
    else
      referral_coin_count -= refund_coin_count - coin_count
      coin_count = 0
    end
    {
      coin_count: coin_count,
      referral_coin_count: referral_coin_count
    }
  end

  def self.amount_optional_currency_by_payment_type(payment_type, starting_at = nil, ending_at = nil)
    parameters  = Parameter.get_all
    total       = 0

    payments_amount(payment_type, true, starting_at, ending_at).each do |currency_symbol, amount|
      total += amount * ExchangeRate.get_rate(currency_symbol, parameters['coin.rate_currency'])
    end

    total
  end

  def self.total_amount_optional_currency_on_balance(starting_at = nil, ending_at = nil)
    balances = amount_optional_currency_by_payment_type([ PAYMENT_TYPE_BALANCE, PAYMENT_TYPE_REFERRAL_BONUS_BALANCE, PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE ], starting_at, ending_at)
    spending = amount_optional_currency_by_payment_type([ PAYMENT_TYPE_PURCHASE, PAYMENT_TYPE_REFUND], starting_at, ending_at)

    balances - spending
  end

  def self.balances_by_user(user)
    balance_payments  = Payment.by_user(user.id).by_type([ PAYMENT_TYPE_BALANCE, PAYMENT_TYPE_REFERRAL_BONUS_BALANCE, PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE ]).amount_sum_by_currency
    purchase_payments = Payment.by_user(user.id).by_type([ PAYMENT_TYPE_PURCHASE, PAYMENT_TYPE_REFUND ]).amount_sum_by_currency
    balance_payments.each do |currency_symbol, amount|
      balance_payments[currency_symbol] -= purchase_payments[currency_symbol].present? ? purchase_payments[currency_symbol] : 0
    end
    result = {}
    balance_payments.each do |currency, amount|
      result[currency] = currency_floor(amount, currency) if currency_present?(amount, currency)
    end
    result.sort.to_h
  end

  def self.balances_by_user_currency(user, currency)
    balance_payments  = Payment.by_user(user.id).by_type([ PAYMENT_TYPE_BALANCE, PAYMENT_TYPE_REFERRAL_BONUS_BALANCE, PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE ]).by_currency_sum(currency)
    purchase_payments = Payment.by_user(user.id).by_type([ PAYMENT_TYPE_PURCHASE, PAYMENT_TYPE_REFUND] ).by_currency_sum(currency)
    balance_payments -= purchase_payments.present? ? purchase_payments : 0
    balance_payments
  end

  def self.balances(starting_at = nil, ending_at = nil)
    parameters        = Parameter.get_all
    balances          = payments_amount(PAYMENT_TYPE_BALANCE, false, starting_at, ending_at)
    refunds           = payments_amount(PAYMENT_TYPE_REFUND, false, starting_at, ending_at)
    referral_balances = payments_amount([ PAYMENT_TYPE_REFERRAL_BONUS_BALANCE, PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE ], false, starting_at, ending_at)

    currencies = {}
    balances.each do |currency, amount|
      currencies[currency] = { balance: amount, referral_balance: 0 }
      currencies[currency][:balance] -= refunds[currency] if refunds[currency].present?
    end
    referral_balances.each do |currency, amount|
      currencies[currency] = { balance: 0 } if currencies[currency].blank?
      currencies[currency][:referral_balance] = referral_balances[currency] if referral_balances[currency].present?
    end

    {
      amount_of_purchased_tokens: amount_of_purchased_tokens(starting_at, ending_at),
      amount_of_referral_tokens: amount_of_referral_tokens(starting_at, ending_at),
      amount_of_bonus_tokens: amount_of_bonus_tokens(starting_at, ending_at),
      amount_of_refund_tokens: amount_of_refund_tokens(starting_at, ending_at),
      amount_of_transfer_tokens: amount_of_transfer_tokens(starting_at, ending_at),
      total_amount_tokens_on_balance: parameters['coin.rate'] > 0 ? total_amount_optional_currency_on_balance(starting_at, ending_at) / parameters['coin.rate'] : 0,
      currencies: currencies
    }
  end

  def self.by_type_with_range(payments_type, with_system = false, starting_at = nil, ending_at = nil)
    query = by_type(payments_type)
    query = query.not_system unless with_system
    query = query.date_ranges(starting_at, ending_at)

    query
  end

  def self.payments_amount(payments_type, with_system = false, starting_at = nil, ending_at = nil)
    by_type_with_range(payments_type, with_system, starting_at, ending_at).amount_sum_by_currency
  end

  def self.tokens_amount(payments_type, with_system = false, starting_at = nil, ending_at = nil)
    by_type_with_range(payments_type, with_system, starting_at, ending_at).sum(:iso_coin_amount)
  end

  def self.amount_of_purchased_tokens(starting_at = nil, ending_at = nil)
    tokens_amount(
      [PAYMENT_TYPE_PAYMENT, PAYMENT_TYPE_PURCHASE],
      false,
      starting_at,
      ending_at
    )
  end

  def self.amount_of_referral_tokens(starting_at, ending_at)
    tokens_amount(
      [PAYMENT_TYPE_REFERRAL_BOUNTY, PAYMENT_TYPE_REFERRAL_USER, PAYMENT_TYPE_PROMOCODE_BOUNTY],
      false,
      starting_at,
      ending_at
    )
  end

  def self.amount_of_bonus_tokens(starting_at, ending_at)
    tokens_amount(
      [PAYMENT_TYPE_BUY_TOKEN_BONUS, PAYMENT_TYPE_PROMOCODE_BONUS],
      false,
      starting_at,
      ending_at
    )
  end

  def self.amount_of_refund_tokens(starting_at, ending_at)
    tokens_amount(
      [PAYMENT_TYPE_REFUND_TOKENS],
      false,
      starting_at,
      ending_at
    )
  end

  def self.amount_of_transfer_tokens(starting_at, ending_at)
    tokens_amount(
      [PAYMENT_TYPE_TRANSFER_TOKENS],
      false,
      starting_at,
      ending_at
    )
  end

  def self.convert_balances_by_user(user, currency, promocode_user = nil)
    balances   = balances_by_user(user)
    currencies = {}
    coins      = 0
    balances.each do |currency_symbol, amount|
      coin                        = coin_floor(Services::Coin::ToCoinConverter.new(amount, currency_symbol, promocode_user).call)
      currencies[currency_symbol] = currency_ceil(Services::Coin::ToCurrencyConverter.new(coin, currency_symbol, promocode_user).call, currency_symbol) if coin > 0
      coins                      += coin
    end
    {
      coins: coins,
      currencies: currencies
    }
  end

  def self.calc_coins_from_all_balances(user, promocode_user = nil)
    currency    = Parameter.get_all['coin.rate_currency']
    result      = Payment.convert_balances_by_user(user, currency, promocode_user)

    {
      currency:    currency,
      coin_amount: result[:coins],
      coin_price:  currency_ceil(Services::Coin::ToCurrencyConverter.new(result[:coins], currency, promocode_user).call, currency),
      currencies:  result[:currencies]
    }
  end

  def self.calc_coins_from_all_balances_by_promocode(user)
    coins_without_promocode = self.calc_coins_from_all_balances(user)
    promocode_user          = PromocodesUser.search_actual_promocode_by_user(user.id, coins_without_promocode[:coin_amount])
    result                  = self.calc_coins_from_all_balances(user, promocode_user)
    result[:promocode]      = promocode_user

    result
  end

  def self.calc_total_ico_currency_amount(starting_at: nil, ending_at: nil)
    Rails.cache.fetch(:payments_ico_investments, expires_in: 10.minutes) do
      Payment.not_system.date_ranges(starting_at, ending_at).by_type(PAYMENT_TYPE_PURCHASE).sum(:ico_currency_amount)
    end
  end

  def payment_address
    return nil unless [PAYMENT_TYPE_BALANCE, PAYMENT_TYPE_PAYMENT].include?(payment_type)
    return nil if system || created_by_user_id.present?
    PaymentAddress.by_user(user_id).by_payment_system(payment_system).by_address_type(PaymentAddressType::DEPOSIT).by_currency(currency_buyer).first&.payment_address
  end

  def self.purchase_amount_in_system_currency(starting_at = nil, ending_at = nil)
    by_type_with_range([PAYMENT_TYPE_PURCHASE, PAYMENT_TYPE_PAYMENT], false, starting_at, ending_at)
      .not_system
      .sum(:ico_currency_amount)
  end

  def self.cached_total_amount_tokens
    Rails.cache.fetch(:payments_ico_tokens, expires_in: 10.minutes) { self.total_amount_tokens }
  end
end
