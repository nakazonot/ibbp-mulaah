FactoryGirl.define do
  factory :ico_stage do
  end

  factory :ico_stage_current, parent: :ico_stage do
    name                     'Current'
    date_start               Time.now - 5.days
    date_end                 Time.now + 5.days
    coin_price               0.01
    min_payment_amount       0.01
    prohibit_make_deposits   false
  end

  factory :ico_stage_future, parent: :ico_stage do
    name                     'Future'
    date_start               Time.now + 5.days
    date_end                 Time.now + 15.days
    coin_price               0.02
    min_payment_amount       0.02
  end

  factory :ico_stage_past, parent: :ico_stage do
    name                     'Past'
    date_start               Time.now - 15.days
    date_end                 Time.now - 5.days
    coin_price               0.01
    min_payment_amount       0.01
  end
end

