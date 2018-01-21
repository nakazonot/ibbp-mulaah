if Rails.env.development?
  User.create!(email: 'admin@example.com', password: 'password',
               password_confirmation: 'password', registration_agreement: true,
               confirmed_at: Time.now)
  ExchangeRate.create!(from: 'USD', to: 'BTC', rate: '4000')
end
