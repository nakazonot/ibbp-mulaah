FactoryGirl.define do
  factory :exchange_rate

  factory :exchange_rate_btc, parent: :exchange_rate do
    from 'BTC'
    to   'BTC'
    rate 1
  end

  factory :exchange_rate_ltc, parent: :exchange_rate do
    from 'LTC'
    to   'BTC'
    rate 0.0104
  end

  factory :exchange_rate_xrp, parent: :exchange_rate do
    from 'XRP'
    to   'BTC'
    rate 0.000051
  end

  factory :exchange_rate_dash, parent: :exchange_rate do
    from 'DASH'
    to   'BTC'
    rate 0.057479
  end

  factory :exchange_rate_etc, parent: :exchange_rate do
    from 'ETC'
    to   'BTC'
    rate 0.002264
  end

  factory :exchange_rate_eth, parent: :exchange_rate do
    from 'ETH'
    to   'BTC'
    rate 0.06009
  end

  factory :exchange_rate_usd, parent: :exchange_rate do
    from 'USD'
    to   'BTC'
    rate 0.00019
  end
end
