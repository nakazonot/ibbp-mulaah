FactoryGirl.define do
  factory :buy_tokens_contract do
    uuid SecureRandom.hex
    info { {
      currency: 'BTC',
      coin_amount: 1.0,
      coin_price: 0.01,
      coin_rate: '0.010000',
      ico_currency: 'BTC',
      ico_currency_amount: 0.01,
      ico_currency_rate: '0.010000',
      coin_amount_bonus: 0.0
    } }
  end
end
