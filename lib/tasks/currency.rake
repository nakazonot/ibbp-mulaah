namespace :currency do
  desc "Update CoinPayments currency rate"
  task update_currency_rate: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Started task currency:update_currency_rate"
    begin
      ExchangeRate.sync_currencies
      rates = ExchangeRate.by_currency(Parameter.available_currencies.keys).map { |rate| "From #{rate.from} to #{rate.to} - #{BigDecimal.new(rate.rate.to_s)}\n" }
      puts "Rates:\n#{rates.join}"
      puts "#{Time.current.to_formatted_s(:db)} INFO: Finished task currency:update_currency_rate"
    rescue EOFError, ApiWrappers::CoinPaymentsError
      puts "Payment service currently unavailable. Please try again."
    end
  end

  desc "Sync available currencies in CoinPayment System"
  task sync_available_currencies: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Started task currency:sync_available_currencies"
    begin
      Parameter.sync_available_currencies
      available_currencies = Parameter.available_currencies.map { |key, value| "#{key}: #{value['name']}, #{value['payment_system']}\n" }
      puts "Available Currencies:\n#{available_currencies.join}"
      puts "#{Time.current.to_formatted_s(:db)} INFO: Finished task currency:sync_available_currencies"
    rescue EOFError, ApiWrappers::CoinPaymentsError
      puts "Payment service currently unavailable. Please try again."
    end
  end

  desc "Pregenerate payment addresses for Deposits"
  task get_free_payment_addresses: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Started task currency:get_free_payment_addresses"
    begin
      result = Services::PaymentAddress::FreePaymentAddressGenerator.new(nil, nil, true).call
      result.each do |currency, value|
        puts "#{currency} - #{value} addresses generated"
      end
      puts "#{Time.current.to_formatted_s(:db)} INFO: Finished task currency:get_free_payment_addresses"
    rescue EOFError
      puts "Payment service currently unavailable. Please try again."
    end
  end

  desc "Pregenerate payment addresses for Promo Tokens"
  task get_free_promo_token_addresses: :environment do
    puts "#{Time.current.to_formatted_s(:db)} INFO: Started task currency:get_free_promo_token_addresses"

    result = Services::PaymentAddress::FreePromoTokenAddressGenerator.new.call
    puts "#{result[:currency]} - #{result[:value]} addresses generated"
    puts "#{Time.current.to_formatted_s(:db)} INFO: Finished task currency:get_free_promo_token_addresses"
  end
end
