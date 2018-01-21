class Services::SystemInfo::ValidateParams

  ERROR_TYPE_ERROR   = "error"
  ERROR_TYPE_WARNING = "warning"

  def initialize
    @errors = {
      env:           {},
      ico_params:    {},
      ico_stages:    {},
      free_adresses: {},
      systems:       {}
    }
  end

  def call
    check_env
    check_ico_params
    check_ico_stages

    check_pdfkit
    @errors
  end

  private

  def check_env
    # General settings
    check_param_env 'ROUTES_HOST', :string
    check_param_env 'ASSET_HOST', :string
    check_param_env 'DEVISE_SECRET', :string
    check_param_env 'TIMEZONE', :string
    check_param_env 'SECRET_KEY_BASE', :string
    check_param_env 'DEVISE_SECRET', :string
    check_param_env 'TIMEZONE', :string
    check_param_env 'SECRET_KEY_BASE', :string
    check_param_env 'LOG_TO_FILE', :boolean
    check_param_env 'HTTPS_MODE', :boolean
    check_param_env 'SKIP_USER_CONFIRMATION', :boolean
    check_jwt_secret

    # Redis cache settings
    check_param_env 'REDIS_URL', :string


    # Auth settings
    check_param_env 'DEVISE_SECRET', :string
    check_param_env 'DEVISE_MAXIMUM_ATTEMPTS', :integer, greater_than_or_equal_to: 1
    check_param_env 'DEVISE_UNLOCK_IN', :integer, greater_than_or_equal_to: 1
    check_param_env 'DEVISE_PASSWORD_LENGTH', :integer, greater_than_or_equal_to: 6
    check_param_env 'DEVISE_RESET_PASSWORD_WITHIN', :integer, greater_than_or_equal_to: 1

    # Database settings
    if ENV['DATABASE_URL'].present?
      check_param_env 'DATABASE_URL', :string
    else
      check_param_env 'DB_HOST', :string
      check_param_env 'DB_USERNAME', :string
      check_param_env 'DB_PASSWORD', :string
      check_param_env 'DB_NAME_PROD', :string
    end
    check_db_connection

    if ENV['COIN_PAYMENTS_MERCHANT_ID'].blank? && ENV['COIN_PAYMENTS_PUBLIC_API_KEY'].blank? && ENV['COIN_PAYMENTS_PRIVATE_API_KEY'].blank? && ENV['ANY_PAY_COINS_API_KEY'].blank?
      @errors[:env]['Payment System'] = [ { message: 'At least one of available payment system should be configured. Please provide API key for system you want to use.', error_type: ERROR_TYPE_ERROR } ]
    end

    # CoinPayments Settings
    if ENV['COIN_PAYMENTS_MERCHANT_ID'].present? || ENV['COIN_PAYMENTS_PUBLIC_API_KEY'].present? || ENV['COIN_PAYMENTS_PRIVATE_API_KEY'].present?
      check_param_env 'COIN_PAYMENTS_MERCHANT_ID', :string
      check_param_env 'COIN_PAYMENTS_PUBLIC_API_KEY', :string
      check_param_env 'COIN_PAYMENTS_PRIVATE_API_KEY', :string
      check_param_env 'COIN_PAYMENTS_IPN_SECRET', :string
      check_param_env 'COIN_PAYMENTS_FREE_ADDRESS_POOL', :integer, greater_than_or_equal_to: 0
      check_coin_payment
    end

    # AnyPayCoins Settings
    if ENV['ANY_PAY_COINS_API_KEY'].present?
      check_param_env 'ANY_PAY_COINS_API_KEY', :string
      check_param_env 'ANY_PAY_COINS_CLIENT_ID', :string
      check_param_env 'ANY_PAY_COINS_TEST_MODE', :boolean
      check_param_env 'ANY_PAY_COINS_IPN_SECRET', :string
      check_param_env 'ANY_PAY_COINS_FREE_ADDRESS_POOL', :integer
      check_param_env 'ANY_PAY_COINS_DISABLE_DEPOSITS', :boolean
      check_any_pay_coins
      check_any_pay_coins_mode
    end

    # Promo Tokens Settings
    if ENV['PROMO_TOKENS_ENABLE'].to_i == 1
      check_param_env 'ANY_PAY_COINS_API_KEY', :string
      check_param_env 'PROMO_TOKENS_CONTRACT', :string
      check_param_env 'PROMO_TOKENS_ADDRESS_POOL', :integer, greater_than_or_equal_to: 0
      check_promo_tokens_contract
    end

    # SMTP settings
    if ENV['SENDGRID_API_KEY'].present?
      check_param_env 'SENDGRID_API_KEY', :string
    elsif ENV['POSTAL_HOST'].present?
      check_param_env 'POSTAL_HOST', :string
      check_param_env 'POSTAL_SERVER_KEY', :string
    else
      check_param_env 'SMTP_ADDRESS', :string
      check_param_env 'SMTP_DOMAIN', :string
      check_param_env 'SMTP_USER_NAME', :string
      check_param_env 'SMTP_PASSWORD', :string
      check_param_env 'SMTP_PORT', :integer
    end

    if ENV['LOG_DNA_API_KEY'].present?
      check_param_env 'LOG_DNA_API_KEY', :string
      check_param_env 'LOG_DNA_APP_NAME', :string
    end

    if ENV['ROLLBAR_ACCESS_TOKEN'].present?
      check_param_env 'ROLLBAR_ACCESS_TOKEN', :string
    end

    # Invoiced settings https://invoiced.com
    if ENV['INVOICED_API_KEY'].present?
      check_param_env 'INVOICED_API_KEY', :string
      check_param_env 'INVOICED_TEST_MODE', :string
      check_param_env 'INVOICED_PAYMENT_TERMS', :string
      check_param_env 'INVOICED_INVOICE_DESCRIPTION', :string
      check_param_env 'INVOICED_TEST_MODE', :boolean
      check_invoiced
      check_invoiced_mode
    else
      @errors[:env]['Invoiced API'] = [ { message: 'The Invoiced service is not enabled. Please add Invoiced API Key in the config.', error_type: ERROR_TYPE_WARNING } ]
    end

    if ENV['GOOGLE_ANALYTICS'].present?
      check_param_env 'GOOGLE_ANALYTICS', :string
      check_ga_cross_domains
    end

    # Two-factor authorization settings
    check_param_env 'TWO_FACTOR_ENCRYPTION_KEY', :string
  end

  def check_ico_params
    begin
      @ico_params = Parameter.order(:name).pluck(:name, :value).to_h

      # coin settings
      check_param_ico 'coin.investments_volume', :float, greater_than_or_equal_to: 0, optional: true
      check_param_ico 'coin.ico_tokens_volume', :float, greater_than_or_equal_to: 0, optional: true
      check_param_ico 'coin.name', :string
      check_param_ico 'coin.rate_currency', :string
      check_param_ico 'coin.tiker', :string
      check_param_ico 'coin.precision', :integer, greater_than_or_equal_to: 0
      check_param_ico 'coin.currency_precision', :integer, greater_than_or_equal_to: 0
      check_param_ico 'coin.usd_precision', :integer, greater_than_or_equal_to: 0

      # user settings
      check_referral_bonus_type
      check_param_ico 'user.referral_bonus_percent', :float, greater_than_or_equal_to: 0, optional: true
      check_param_ico 'referral.enabled', :boolean, optional: true
      check_referral_user_bonus_percent
      check_user_show_identification

      # system settings
      check_param_ico 'system.skip_eth_wallet_input', :boolean, optional: true
      check_param_ico 'system.btc_wallet_enabled', :boolean, optional: true
      check_param_ico 'system.skip_totals_block_date_to', :string, optional: true
      check_param_ico 'system.buy_tokens_agreement_enabled', :boolean, optional: true
      check_param_ico 'system.auto_convert_balance_to_tokens', :boolean, optional: true

      # sign up settings
      check_param_ico 'sign_up.require_user_name_input', :boolean, optional: true

      # invoiced settings
      check_param_ico 'invoiced.min_amount_for_transfer', :float, optional: true, greater_than_or_equal_to: 0
      check_param_ico 'invoiced.max_amount_for_transfer', :float, optional: true, greater_than_or_equal_to: 0

      # links
      check_param_ico 'links.new_window', :boolean
      check_param_ico 'links.license_agreement', :string, warning: true
      check_param_ico 'links.support_email', :string, warning: true
      check_param_ico 'links.ico_site', :string, warning: true

      check_available_currencies
      check_exchange_rates
      check_social_share if @ico_params['referral.social_share_buttons'].present?

    rescue => e
      @errors[:ico_params]['ICO params'] = [ { message: "No access to the database", error_type: ERROR_TYPE_ERROR } ]
    end
  end

  def check_param(group, name, param, param_type, optional: false, greater_than_or_equal_to: nil, warning: false)
    @errors[group][name] = []
    if optional
      return if param.blank?
    else
      if param.nil?
        @errors[group][name] << { message: "Parameter not found", error_type: warning ? ERROR_TYPE_WARNING : ERROR_TYPE_ERROR }
      else
        @errors[group][name] << { message: "Parameter must not be empty", error_type: warning ? ERROR_TYPE_WARNING : ERROR_TYPE_ERROR } if param.blank?
      end
    end

    if param_type != :string
      error = check_param_type(param, param_type)
      @errors[group][name] << { message: error, error_type: warning ? ERROR_TYPE_WARNING : ERROR_TYPE_ERROR } if error.present?
    end

    if greater_than_or_equal_to.present?
      error = check_greater_than_or_equal_to(param, greater_than_or_equal_to)
      @errors[group][name] << { message: error, error_type: warning ? ERROR_TYPE_WARNING : ERROR_TYPE_ERROR } if error.present?
    end
  end

  def check_param_env(name, param_type, optional: false, greater_than_or_equal_to: nil, warning: false)
    check_param(:env, name, ENV[name], param_type, optional: optional, greater_than_or_equal_to: greater_than_or_equal_to, warning: warning)
  end

  def check_param_ico(name, param_type, optional: false, greater_than_or_equal_to: nil, warning: false)
    params = @ico_params.has_key?(name) ? @ico_params[name] : ""
    check_param(:ico_params, name, @ico_params[name], param_type, optional: optional, greater_than_or_equal_to: greater_than_or_equal_to, warning: warning)
  end

  def check_param_type(param, param_type)
    return check_param_type_boolean(param) if param_type == :boolean
    return check_param_type_integer(param) if param_type == :integer
    return check_param_type_float(param) if param_type == :float
    nil
  end

  def check_greater_than_or_equal_to(param, greater_than_or_equal_to)
    return "parameter must be greater than or equal to #{greater_than_or_equal_to}" unless param.to_f >= greater_than_or_equal_to
  end

  def check_param_type_boolean(param)
    return "parameter must be boolean" unless ['0', '1'].include?(param.to_s)
    nil
  end

  def check_param_type_integer(param)
    return "parameter must be integer" unless (Integer(param) != nil rescue false)
    nil
  end

  def check_param_type_float(param)
    return "parameter must be float" unless (Float(param) != nil rescue false)
    nil
  end

  def check_referral_bonus_type
    @errors[:ico_params]['user.referral_bonus_type'] = []
    @errors[:ico_params]['user.referral_bonus_type'] << { message: 'The parameter must be one of the list: (tokens, balance)', error_type: ERROR_TYPE_ERROR } unless ['tokens', 'balance'].include?(@ico_params['user.referral_bonus_type'])
  end

  def check_free_addresses
    res = {}
    Parameter.available_currencies.keys.each do |currency|
      res[currency] = PaymentAddress.by_currency(currency).not_user.count
    end
    res
  end

  def check_ico_stages
    begin
      stages = IcoStage.all
      stages.each do |stage|
        prev_stage = stage.prev_stage
        @errors[:ico_stages][stage.name] = []
        @errors[:ico_stages][stage.name] << { message: "The stage start time does not match the end time of the previous period.", error_type: ERROR_TYPE_ERROR } if prev_stage.present? && prev_stage.date_end != stage.date_start
      end
      if IcoStage.count == 0
        @errors[:ico_stages]['ICO stage configuration'] = [ { message: "No stage found", error_type: ERROR_TYPE_WARNING } ]
      else
        @errors[:ico_stages]['ICO stage configuration'] = [] if IcoStage.ico_dates_valid?
      end
    rescue
      @errors[:ico_stages]['ICO stage configuration'] = [ { message: "No access to the database", error_type: ERROR_TYPE_ERROR } ]
    end
  end

  def check_available_currencies
    @errors[:ico_params]['Available currencies'] = []
    if @ico_params['available_currencies'].blank?
      @errors[:ico_params]['Available currencies'] << { message: 'The list of available cryptocurrencies is empty. Please check if you have executed: "rake currency:sync_available_currencies"', error_type: ERROR_TYPE_WARNING }
    else
      payment_currencies = Payment.where.not(currency_buyer: nil).distinct.pluck(:currency_buyer)
      available_currencies = Parameter.available_currencies.keys
      missed_currencies = payment_currencies - available_currencies
      @errors[:ico_params]['Available currencies'] << { message: "You have payments by currencies that does not enabled in the current payment system(systems). Please enable: #{missed_currencies}.", error_type: ERROR_TYPE_ERROR } if (missed_currencies).present?
    end
  end

  def check_exchange_rates
    @errors[:ico_params]['Exchange rates'] = []
    @errors[:ico_params]['Exchange rates'] << { message: 'The list of cryptocurrency rates is empty. Please check if you have executed: "rake currency:update_currency_rate"', error_type: ERROR_TYPE_WARNING } if ExchangeRate.count == 0
  end

  def check_invoiced_mode
    @errors[:env]['Invoiced mode'] = [ { message: 'The Invoices service is running in test mode. Please check the INVOICED_TEST_MODE parameter in the config.', error_type: ERROR_TYPE_WARNING } ] if ENV['INVOICED_TEST_MODE'] == '1'
  end

  def check_any_pay_coins_mode
    @errors[:env]['Any Pay Coins mode'] = [{ message: 'The Any Pay Coins service is running in test mode. Please check the ANY_PAY_COINS_TEST_MODE parameter in the config.', error_type: ERROR_TYPE_WARNING }] if ENV['ANY_PAY_COINS_TEST_MODE'] == '1'
    @errors[:env]['Any Pay Coins deposits'] = [{ message: 'Deposits disabled in Any Pay Coins service. Please check the ANY_PAY_COINS_DISABLE_DEPOSITS parameter in the config.', error_type: ERROR_TYPE_WARNING }] if ENV['ANY_PAY_COINS_DISABLE_DEPOSITS'] == '1'
  end

  def check_promo_tokens_contract
    @errors[:env]['PROMO_TOKENS_CONTRACT check'] = []
    begin
      check_contract = ApiWrappers::AnyPayCoins.new.check_contract(ENV['PROMO_TOKENS_CONTRACT'])
      @errors[:env]['PROMO_TOKENS_CONTRACT check'] << { message: check_contract[:message], error_type: ERROR_TYPE_ERROR } if check_contract[:error]
    rescue => e
      @errors[:env]['PROMO_TOKENS_CONTRACT check'] << { message: e.message, error_type: ERROR_TYPE_ERROR }
    end
  end

  def check_db_connection
    @errors[:env]['DB connection'] = []
    begin
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection
      @errors[:env]['DB connection'] << { message: "Bad connection", error_type: ERROR_TYPE_ERROR } unless ActiveRecord::Base.connected?
    rescue => e
      @errors[:env]['DB connection'] << { message: e.message, error_type: ERROR_TYPE_ERROR }
    end
  end

  def check_social_share
    @ico_params['referral.social_share_buttons'].gsub(' ', '').split(',').each do |site|
      @errors[:ico_params]["Social buton: #{site}"] = []
      unless %w(twitter facebook google_plus weibo qq douban google_bookmark delicious tumblr pinterest email linkedin wechat vkontakte xing reddit hacker_news telegram odnoklassniki).include? site
        @errors[:ico_params]["Social buton: #{site}"] << { message: "#{site} is not in the list of supported social network", error_type: ERROR_TYPE_ERROR }
      end
    end
  end

  def check_pdfkit
    @errors[:systems]['PDFKit configuration'] = []
    begin
      data = PDFKit.new('https://www.google.com/', quiet: true).to_pdf
    rescue => e
      @errors[:systems]['PDFKit configuration'] << { message: e.message, error_type: ERROR_TYPE_ERROR }
    end
  end

  def check_coin_payment
    @errors[:env]['COIN_PAYMENTS API check'] = []
    begin
      rates = Coinpayments.rates
      @errors[:env]['COIN_PAYMENTS API check'] << { message: rates, error_type: ERROR_TYPE_ERROR } if rates.class == String
      result = Coinpayments.get_callback_address('BTC', { ipn_url: Rails.application.routes.url_helpers.payment_notifications_url })
      unless result.kind_of?(Hash) && result[:address].present?
        error = "#{result} Please set checkboxes: 'get_callback_address', 'get_basic_info', 'rates' in Coin Payment"
        @errors[:env]['COIN_PAYMENTS API check'] << { message: error, error_type: ERROR_TYPE_ERROR }
      end
    rescue EOFError
      @errors[:env]['COIN_PAYMENTS API check'] << { message: "Payment service currently unavailable. Please try again.", error_type: ERROR_TYPE_ERROR }
    end
  end

  def check_any_pay_coins
    @errors[:env]['ANY_PAY_COINS API check'] = []
    begin
      check_api_key = ApiWrappers::AnyPayCoins.new.check_api_key
      @errors[:env]['ANY_PAY_COINS API check'] << { message: check_api_key[:message], error_type: ERROR_TYPE_ERROR } if check_api_key[:error]
    rescue => e
      @errors[:env]['ANY_PAY_COINS API check'] << { message: e.message, error_type: ERROR_TYPE_ERROR }
    end
  end

  def check_invoiced
    @errors[:env]['INVOICED API check'] = []
    begin
      Invoiced::Client.new(ENV['INVOICED_API_KEY'], ENV['INVOICED_TEST_MODE'].to_i == 1).Invoice.list(end_date: '2000-01-01 00:00:00 UTC'.to_time.to_i, per_page: 1)
    rescue Invoiced::ErrorBase => e
      error = e.message
      if error.include?("API Key: ")
        words = error.split('API Key: ')
        words[words.size-1] = protected_value(words[words.size-1])
        error = words.join('API Key: ')
      end
      @errors[:env]['INVOICED API check'] << { message: error, error_type: ERROR_TYPE_ERROR }
    end
  end

  def protected_value(value)
    if value.size > 6
      value[3..value.size-4] = '*' * (value.size-6) if value.size > 6
    else
      value[value.size/2..value.size/2] = '*'
    end
    value
  end


  def check_ga_cross_domains
    return if ENV['GOOGLE_ANALYTICS_CROSS_DOMAIN'].blank?
    @errors[:env]['GOOGLE_ANALYTICS_CROSS_DOMAIN'] = []
    domains = ENV['GOOGLE_ANALYTICS_CROSS_DOMAIN'].split(',').map(&:strip)
    is_ok = true
    domains.each do |d|
      @errors[:env]['GOOGLE_ANALYTICS_CROSS_DOMAIN'] = [ { message: 'Incorrect value format', error_type: ERROR_TYPE_ERROR } ] unless uri?(d)
    end
  end

  def check_jwt_secret
    @errors[:env]['JWT_SECRET'] = []

    if ENV['JWT_SECRET'].blank?
      @errors[:env]['JWT_SECRET'] << { message: 'Must be set, currently used default value from SECRET_KEY_BASE config variable', error_type: ERROR_TYPE_ERROR }
    end
  end

  def check_referral_user_bonus_percent
    return if @ico_params['user.referral_bonus_percent'].blank?
    @errors[:ico_params]['user.referral_bonus_percent'] = []
    @ico_params['user.referral_bonus_percent'].split(',').map(&:strip).each do |bonus|
      @errors[:ico_params]['user.referral_bonus_percent'] = [ { message: 'Incorrect value format', error_type: ERROR_TYPE_ERROR } ] unless check_param_type_float(bonus).blank?
    end
  end

  def check_user_show_identification
    @errors[:ico_params]['user.show_identification'] = []
    check_param_ico 'user.show_identification', :string
    @errors[:ico_params]['user.show_identification'] << { message: 'Incorrect value format', error_type: ERROR_TYPE_ERROR } unless [ Parameter::USER_SHOW_IDENTIFICATION_EMAIL, Parameter::USER_SHOW_IDENTIFICATION_ID ].include?(@ico_params['user.show_identification'])
  end

  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
  end
end
