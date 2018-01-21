class Services::Coin::ToCoinConverter
  def initialize(amount, currency, promocode_user = nil)
    @promocode_coin_rate           = promocode_user.nil? ? nil : promocode_user.fixed_price_from_promocode
    @amount                        = amount.to_f
    @currency                      = currency
    @config_parameters             = Parameter.get_all
    @currency_to_btc_rate          = ExchangeRate.to_btc_rate(@currency)
    @optional_currency_to_btc_rate = ExchangeRate.to_btc_rate(@config_parameters['coin.rate_currency'])
  end

  def call
    coin_rate = @promocode_coin_rate.present? ? @promocode_coin_rate : @config_parameters['coin.rate']
    result    = @amount * @currency_to_btc_rate * (1 / @optional_currency_to_btc_rate) * (1 / coin_rate)
  end
end
