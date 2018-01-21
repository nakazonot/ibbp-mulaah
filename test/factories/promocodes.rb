FactoryGirl.define do
  factory :promocode do
    code SecureRandom.hex(8)
    discount_type Promocode::DISCOUNT_TYPE_FIXED_PRICE
    discount_amount 0.001
  end
end
