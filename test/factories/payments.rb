FactoryGirl.define do
  factory :payment do
    user
  end

  factory :payment_balance, parent: :payment do
    sequence(:transaction_id) { |n| "transaction_id_#{n}" }
    payment_type Payment::PAYMENT_TYPE_BALANCE
  end

  factory :payment_balance_btc, parent: :payment do
    currency_origin   'BTC'
    currency_buyer    'BTC'
    amount_origin     20
    amount_buyer      20
  end

  factory :payment_balance_eth, parent: :payment do
    currency_origin   'ETH'
    currency_buyer    'ETH'
    amount_origin     200
    amount_buyer      200
  end

  factory :payment_balance_usd, parent: :payment do
    currency_origin   'USD'
    currency_buyer    'USD'
    amount_origin     1000
    amount_buyer      1000
  end

  factory :payment_purchase_tokens, parent: :payment do
    sequence(:transaction_id) { |n| "transaction_id_#{n}" }
    payment_type Payment::PAYMENT_TYPE_PURCHASE
    currency_origin   'BTC'
    currency_buyer    'BTC'
    ico_currency_amount 0.5100000000
    ico_currency 'USD'
    iso_coin_amount 1.0000000000
    amount_origin   0.0001000000
    amount_buyer    0.0001000000
  end

  factory :payment_referral_bounty, parent: :payment do
    sequence(:transaction_id) { |n| "transaction_id_#{n}" }
    payment_type Payment::PAYMENT_TYPE_REFERRAL_BOUNTY
    currency_origin   'BTC'
    currency_buyer    'BTC'
    ico_currency_amount 0.5100000000
    ico_currency 'USD'
    iso_coin_amount 2.0000000000
    amount_origin   0.0001000000
    amount_buyer    0.0001000000
  end

  factory :payment_referral_bounty_balance, parent: :payment do
    sequence(:transaction_id) { |n| "transaction_id_#{n}" }
    payment_type Payment::PAYMENT_TYPE_REFERRAL_BOUNTY_BALANCE
    currency_origin   'BTC'
    currency_buyer    'BTC'
    ico_currency_amount 0.5100000000
    ico_currency 'USD'
    iso_coin_amount 2.0000000000
    amount_origin   0.0001000000
    amount_buyer    0.0001000000
  end
end

