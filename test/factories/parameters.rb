FactoryGirl.define do
  factory :parameter do
  end
  factory :parameter_coin_tiker, parent: :parameter do
    name 'coin.tiker'
    value 'CAT'
  end
  factory :parameter_available_currencies, parent: :parameter do
    name 'available_currencies'
    value "{'BTC': 'Bitcoin','LTC': 'Litecoin','XRP': 'Ripple','DASH': 'Dash','ETC': 'Ether Classic','ETH': 'Ether'}"
  end
  factory :parameter_user_referral_bonus_percent, parent: :parameter do
    name 'user.referral_bonus_percent'
    value '10'
  end
  factory :parameter_coin_investments_volume, parent: :parameter do
    name 'coin.investments_volume'
    value '100000000'
  end
  factory :parameter_coin_rate_currency, parent: :parameter do
    name 'coin.rate_currency'
    value 'BTC'
  end
  factory :parameter_coin_precision, parent: :parameter do
    name 'coin.precision'
    value '2'
  end
  factory :parameter_coin_currency_precision, parent: :parameter do
    name 'coin.currency_precision'
    value '4'
  end

end