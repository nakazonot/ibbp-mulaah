class Services::Coin::ToCurrencyConverter
  def initialize(coins, to_currency, promocode_user = nil)
    @promocode_coin_rate           = promocode_user.nil? ? nil : promocode_user.fixed_price_from_promocode
    @coins                         = coins.to_f
    @to_currency                   = to_currency
    @config_parameters             = Parameter.get_all
    @currency_to_btc_rate          = ExchangeRate.to_btc_rate(@to_currency)
    @optional_currency_to_btc_rate = ExchangeRate.to_btc_rate(@config_parameters['coin.rate_currency'])
  end

  def call
    coin_rate = @promocode_coin_rate.present? ? @promocode_coin_rate : @config_parameters['coin.rate']
    @coins * coin_rate * @optional_currency_to_btc_rate * (1 / @currency_to_btc_rate)
  end

end
