class ApiWrappers::AnyPayCoins
  include HTTParty
  include Concerns::Log::Logger

  attr_reader :enabled

  base_uri ENV['ANY_PAY_COINS_TEST_MODE'].to_i == 1 ? 'http://api-demo.anypaycoins.com' : 'https://api.anypaycoins.com'

  ADDRESSES_PATH        = "/v1/addresses"
  ADDRESSES_LIST_PATH   = "/v1/addresses/list"
  CLIENT_CURRENCY_PATH  = "/v1/client/currency"
  CURRENCY_ALL_PATH     = "/v1/currency/all"

  ADDRESSES_MAX_LIMIT = 100

  def initialize
    @enabled = ENV['ANY_PAY_COINS_API_KEY'].present?
    @api_key = ENV['ANY_PAY_COINS_API_KEY']
  end

  def enabled_for_deposit?
    @enabled && ENV['ANY_PAY_COINS_DISABLE_DEPOSITS'].to_i == 0
  end

  def get_addresses_max_limit
    ADDRESSES_MAX_LIMIT
  end

  def get_addresses(currency, limit = 10)
    params = {
      query:   {currency: currency.downcase, limit: limit},
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get(ADDRESSES_PATH, params).parsed_response
    return response['Result'] if response['Status'] == 'ok'
    log_params_error(params.merge(action: __method__.to_s), response)
    nil
  end

  def get_addresses_list(currency = nil, page = 1)
    params = {
      query:   {currency: currency, page: page},
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get(ADDRESSES_LIST_PATH, params).parsed_response
    return response['Result'] if response['Status'] == 'ok'
    log_params_error(params.merge(action: __method__.to_s), response)
    nil
  end

  def get_rates
    params = {
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get(CURRENCY_ALL_PATH, params).parsed_response
    if response['Status'] == 'ok'
      result = {}
      response['Result'].each do |currency, value|
        from = currency.split('_')[0].upcase
        to   = currency.split('_')[1].upcase
        next unless to == 'BTC'
        result[from] = { from: from, rate: value.to_f, payment_system: ::PaymentSystemType::ANY_PAY_COINS }
      end
      result['BTC'] = { from: 'BTC', rate: 1, payment_system: ::PaymentSystemType::ANY_PAY_COINS }
      return result
    end
    log_params_error(params.merge(action: __method__.to_s), response)
    nil
  end

  def free_address_pool
    ENV['ANY_PAY_COINS_FREE_ADDRESS_POOL'].to_i
  end

  def get_available_currencies
    params = {
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get(CLIENT_CURRENCY_PATH, params).parsed_response
    if response['Status'] == 'ok'
      available_currencies = {}
      response['Result'].each do |row|
        available_currencies[row['Currency'].upcase] = {
          name: row['Description'],
          payment_system: ::PaymentSystemType::ANY_PAY_COINS
        }
      end
      return available_currencies
    end
    log_params_error(params.merge(action: __method__.to_s), response)
    nil
  end

  def add_tokens(currency, limit)
    free_addresses = get_addresses(currency, limit)
    return nil if free_addresses.nil?
    result = []
    free_addresses.each do |address|
      result << { address: address['Address'] }
    end
    result
  end

  def check_api_key
    params = {
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get(CLIENT_CURRENCY_PATH, params).parsed_response
    return { error: true, message: response['Result'] } if response['Status'] == 'error'
    { error: false }
  end

  def check_contract(contract)
    params = {
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get("/v1/contracts/#{contract}", params).parsed_response
    return { error: true, message: response['Result'] } if response['Status'] == 'error'
    { error: false }
  end

  def get_contract_balance(ai, ax)
    params = {
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get("/v1/contracts/#{ai}/balance/#{ax}", params).parsed_response
    return response['Result'] if response['Status'] == 'ok'
    log_params_error(params.merge(action: __method__.to_s, contract: ai, address: ax), response)
    nil
  end

  def contract_transfer(ai, address, amount)
    params = {
      body:   {'Address': address, 'Amount': amount},
      headers: {'Authorization' => @api_key}
    }
    response = self.class.post("/v1/contracts/#{ai}/transfer", params).parsed_response
    return response['Result'] if response['Status'] == 'ok'
    log_params_error(params.merge(action: __method__.to_s, contract: ai), response)
    nil
  end

  def get_eth_tx_info(tx)
    params = {
      body:    {tx: tx },
      headers: {'Authorization' => @api_key}
    }
    response = self.class.get("/v1/tx/eth/#{tx}", params).parsed_response
    return response['Result'] if response['Status'] == 'ok'
    log_params_error(params.merge(action: __method__.to_s), response)
    nil
  end
end