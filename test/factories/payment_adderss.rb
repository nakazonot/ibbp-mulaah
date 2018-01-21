FactoryGirl.define do
  factory :payment_address do
    payment_address SecureRandom.hex(8)
  end

  factory :payment_address_btc, parent: :payment_address do
    currency 'BTC'
  end

  factory :payment_address_xrp, parent: :payment_address do
    currency 'XRP'
    dest_tag 1566580116
  end
end
