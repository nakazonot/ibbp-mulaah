FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email-#{n}@gmail.com" }
    sequence(:phone) { |n| "+7978123456#{n}" }
    password "#{SecureRandom.hex.upcase}#{SecureRandom.hex}#{Random.rand(16)}"
    name 'Vasya'
    registration_agreement true
    confirmed_at Time.now
    uses_default_password false
  end
end
