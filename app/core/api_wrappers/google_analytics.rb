class ApiWrappers::GoogleAnalytics

  def initialize(user = nil)
    @analytics_id = ENV['GOOGLE_ANALYTICS']
    @user         = user
    @tracker      = create_tracker
  end

  def send_item_to_google_analytics(contract)
    return if @analytics_id.blank?

    config_parameters = Parameter.get_all
    @tracker.transaction_item(
      transaction_id: contract.id,
      name:           config_parameters['coin.name'],
      price:          Services::Coin::CurrencyToCurrencyConverter.new(contract.info['coin_rate'], contract.info['currency'], ExchangeRate::DEFAULT_CURRENCY).call,
      quantity:       contract.info['coin_amount'],
      currency:       ExchangeRate::DEFAULT_CURRENCY
    )
  end

  def send_transaction_to_google_analytics(contract)
    return if @analytics_id.blank? || contract.payment.blank?

    @tracker.transaction(
      transaction_id: contract.id,
      revenue: Services::Coin::CurrencyToCurrencyConverter.new(contract.payment.amount_buyer, contract.payment.currency_buyer, ExchangeRate::DEFAULT_CURRENCY).call,
      currency: ExchangeRate::DEFAULT_CURRENCY
    )
  end

  def send_event_registration_new(options)
    @tracker.event(options) if @analytics_id.present?
  end

  private

  def create_tracker
    Staccato.tracker(@analytics_id, @user&.ga_client_id)
  end

end