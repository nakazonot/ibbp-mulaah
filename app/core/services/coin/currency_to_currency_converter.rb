class Services::Coin::CurrencyToCurrencyConverter
  def initialize(amount, from_currency, to_currency)
    @from_currency = from_currency
    @to_currency   = to_currency
    @rate_currency = Parameter.get_all['coin.rate_currency']
    @amount        = amount
  end

  def call
    coins = coin_floor(Services::Coin::ToCoinConverter.new(@amount, @from_currency).call)
    currency_ceil(Services::Coin::ToCurrencyConverter.new(coins, @to_currency).call, @to_currency)
  end

end
