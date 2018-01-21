FactoryGirl.define do
  factory :bonus_preference

  factory :bonus_preference_current_stage_zero, parent: :bonus_preference do
    min_investment_amount 0
    bonus_percent         10
  end
end