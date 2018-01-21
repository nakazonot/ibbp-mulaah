class ApiWrappers::CoinPayments
  include Concerns::Log::Logger

  attr_reader :enabled

  ADDRESSES_MAX_LIMIT = 1

  def initialize
    @enabled = ENV['COIN_PAYMENTS_MERCHANT_ID'].present? && 
      ENV['COIN_PAYMENTS_PUBLIC_API_KEY'].present? && 
      ENV['COIN_PAYMENTS_PRIVATE_API_KEY'].present?
  end

  def enabled_for_deposit?
    @enabled
  end

  def create_transaction(options)
    result = Coinpayments.create_transaction(options[:amount], options[:currency_original], options[:currency_buyer], { 
      ipn_url: Rails.application.routes.url_helpers.payment_notifications_url,
      custom:  options[:custom].to_json
    })

    return result if result.kind_of?(Hash) && result[:address].present?
    log_params_error(options, result)
    nil
  end

  def get_rates
    result = {}
    cp_rates = Coinpayments.rates
    raise ApiWrappers::CoinPaymentsError.new('Can not get currency rates') if cp_rates.nil?
    cp_rates.each do |currency_symbol, value|
      result[currency_symbol] = { from: currency_symbol, rate: value[:rate_btc].to_f, payment_system: ::PaymentSystemType::COIN_PAYMENTS }
    end
    result
  end

  def free_address_pool
    ENV['COIN_PAYMENTS_FREE_ADDRESS_POOL'].to_i
  end

  def get_available_currencies
    available_currencies = Coinpayments.rates(accepted: 1)
    raise ApiWrappers::CoinPaymentsError.new('Can not get available currencies') if available_currencies.nil?
    available_currencies = available_currencies.delete_if { |_k, v| v["accepted"] == 0 }
    result = {}
    available_currencies.each do |currency_symbol, value|
      result[currency_symbol] = { name: value[:name], payment_system: ::PaymentSystemType::COIN_PAYMENTS }
    end
    result
  end

  def get_callback_address(currency)
    result = Coinpayments.get_callback_address(currency, { ipn_url: Rails.application.routes.url_helpers.payment_notifications_url })
    if result.kind_of?(Hash) && result[:address].present?
      result[:ipn_url] = Rails.application.routes.url_helpers.payment_notifications_url
      return result
    end
    log_params_error({currency: currency}, result)
    nil
  end

  def add_tokens(currency, limit = ADDRESSES_MAX_LIMIT)
    free_address = get_callback_address(currency)
    return nil if free_address.nil?
    [free_address]
  end

  def get_addresses_max_limit
    ADDRESSES_MAX_LIMIT
  end
end