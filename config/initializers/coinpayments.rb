Coinpayments.configure do |config|
  config.merchant_id     = ENV['COIN_PAYMENTS_MERCHANT_ID']
  config.public_api_key  = ENV['COIN_PAYMENTS_PUBLIC_API_KEY']
  config.private_api_key = ENV['COIN_PAYMENTS_PRIVATE_API_KEY']
end