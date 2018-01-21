class Parameter < ApplicationRecord
  AVAILABLE_CURRENCIES_NAME = 'available_currencies'

  USER_SHOW_IDENTIFICATION_ID = 'id'
  USER_SHOW_IDENTIFICATION_EMAIL = 'email'

  scope :can_overloaded,          -> { where(can_overloaded: true) }

  after_commit :clear_cache

  def self.get_all
    Rails.cache.fetch(:config_parameters, expires_in: 30.seconds) do
      result                                       = self.order(:name).pluck(:name, :value).to_h
      ico_stage                                    = IcoStage.stage_by_date(Time.current)

      last_stage                                   = IcoStage.order(:date_start).last
      ico_stage                                    = last_stage if last_stage.present? && last_stage.date_end < Time.current

      result['coin.precision']                     = result['coin.precision'].to_i
      result['coin.currency_precision']            = result['coin.currency_precision'].to_i
      result['coin.usd_precision']                 = result['coin.usd_precision'].to_i

      result['coin.min_payment_amount']            = 0.0
      result['coin.rate']                          = 0.0
      result['bonuses_percent']                    = []


      if ico_stage.present?
        result['ico.stage_id']                     = ico_stage.id
        result['ico.stage_name']                   = ico_stage.name
        result['date_start']                       = ico_stage.date_start.in_time_zone
        result['date_end']                         = ico_stage.date_end.in_time_zone
        result['bonuses_percent']                  = ico_stage.bonuses
        result['coin.min_payment_amount']          = ico_stage.min_payment_amount if ico_stage.min_payment_amount.present?
        result['coin.rate']                        = ico_stage.coin_price
        result['coin.rate_back']                   = result['coin.rate'] > 0 ? (1 / result['coin.rate']).round : 0.0
        result['coin.min_payment_coins_amount']    = result['coin.rate'] > 0 ? (result['coin.min_payment_amount'] / result['coin.rate']).round(result['coin.precision']) : 0
      end

      result['system.skip_totals_block_date_to']   = result['system.skip_totals_block_date_to'].in_time_zone if result['system.skip_totals_block_date_to'].present?

      unless ExchangeRate.to_btc_rate(result['coin.rate_currency']).present?
        result['coin.rate_currency']               = ExchangeRate::DEFAULT_CURRENCY
      end

      result['user.referral_user_bonus_percent']   = result['user.referral_user_bonus_percent'].to_f
      result['user.referral_bonus_percent']        = result['user.referral_bonus_percent'].split(',').map(&:to_f) if result['user.referral_bonus_percent'].present?

      result['referral.social_share_buttons']      = result['referral.social_share_buttons'].gsub(' ', '').split(',') if result['referral.social_share_buttons'].present?

      result['system.skip_eth_wallet_input']       = 0 if result['system.skip_eth_wallet_input'].blank?
      
      result['invoiced.min_amount_for_transfer']   = 0.0 if result['invoiced.min_amount_for_transfer'].blank?
      result['invoiced.max_amount_for_transfer']   = 0.0 if result['invoiced.max_amount_for_transfer'].blank?
      result['invoiced.min_amount_for_transfer']   = result['invoiced.min_amount_for_transfer'].to_f
      result['invoiced.max_amount_for_transfer']   = result['invoiced.max_amount_for_transfer'].to_f

      result
    end
  end

  def clear_cache
    Rails.cache.delete(:config_parameters)
  end

  def self.precisions
    params = self.get_all
    {
      coin:     params['coin.precision'],
      currency: params['coin.currency_precision'],
      usd:      params['coin.usd_precision']
    }
  end

  def self.min_amount_for_transfer
    parameters = self.get_all
    parameters['invoiced.min_amount_for_transfer']
  end

  def self.max_amount_for_transfer
    parameters = self.get_all
    parameters['invoiced.max_amount_for_transfer']
  end

  def self.available_currencies
    result = {'USD' => { 'name' => 'USD'}}
    available_currencies = self.get_all[AVAILABLE_CURRENCIES_NAME]
    available_currencies.blank? ? result : JSON.parse(available_currencies).merge(result)
  end

  def self.sync_available_currencies(generate_payment_addresses: false)
    available_currencies = self.find_by(name: AVAILABLE_CURRENCIES_NAME)
    unless available_currencies.nil?
      synched_currencies = Services::PaymentSystem::MainWrapper.new.get_available_currencies
      available_currencies.value = synched_currencies.to_json
      available_currencies.save!
      if generate_payment_addresses
        synched_currencies.each do |currency_symbol, val|
          FreePaymentAddressGenerateJob.perform_later(currency_symbol)
        end
      end
    end
  end

  def self.ico_enabled
    params                 = self.get_all
    ico_tokens             = Payment.cached_total_amount_tokens
    ico_investments_volume = params['coin.investments_volume'].blank? || Payment.calc_total_ico_currency_amount < params['coin.investments_volume'].to_f
    ico_tokens_volume      = params['coin.ico_tokens_volume'].blank? || ico_tokens < params['coin.ico_tokens_volume'].to_f

    IcoStage.ico_enabled? && ico_investments_volume && ico_tokens_volume
  end

  def self.buy_token_enabled(user)
    return false unless self.ico_enabled
    ico_stage = IcoStage.stage_by_date(Time.current)
    return false if ico_stage.tokens_limit_reached?
    return true unless ico_stage.prohibit_purchase_tokens

    ico_stage.buy_token_promocode_id.present? && PromocodesUser.by_user(user.id).by_promocode(ico_stage.buy_token_promocode_id).exists?
  end

  def self.make_deposit_enabled?
    return false unless self.ico_enabled

    ico_stage = IcoStage.stage_by_date(Time.current)
    !ico_stage.prohibit_make_deposits
  end

  def self.btc_wallet_enabled?
    self.get_all['system.btc_wallet_enabled'].to_i == 1
  end

  def self.eth_wallet_enabled?
    self.get_all['system.skip_eth_wallet_input'].to_i.zero?
  end

  def self.buy_tokens_agreement_enabled?
    self.get_all['system.buy_tokens_agreement_enabled'].to_i > 0
  end

  def self.referral_system_enabled?
    self.get_all['referral.enabled'].to_i > 0
  end

  def self.auto_convert_balance_to_tokens_enabled?(user)
    self.get_all['system.auto_convert_balance_to_tokens'].to_i > 0 && self.buy_token_enabled(user)
  end

  def self.require_user_name_input_on_sign_up?
    (self.find_by(name: 'sign_up.require_user_name_input')&.value).to_i > 0
  end

  def self.min_payment_amount_by_currency
    params = self.get_all
    result = {}
    available_currencies.each do |currency, name|
      result[currency] = Services::Coin::CurrencyToCurrencyConverter.new(params['coin.min_payment_amount'], params['coin.rate_currency'], currency).call
    end
    result
  end

  def self.referral_system_type?(value)
    self.get_all['user.referral_bonus_type'] == value
  end

  def self.allowed_tracking_labels
    self.get_all['system.tracking_labels.whitelist'].split(',')
  end

  def self.user_confirmation_required?
    ENV['KYC_VERIFICATION_ENABLE'].to_b || !ENV['SKIP_USER_CONFIRMATION'].to_b
  end

  def self.kyc_verification_enabled?
    ENV['KYC_VERIFICATION_ENABLE'].to_b
  end

  def self.kyc_max_file_size
    ENV.fetch('KYC_VERIFICATION_MAX_FILE_SIZE', '1.0').to_f
  end
end
