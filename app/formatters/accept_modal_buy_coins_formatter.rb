class AcceptModalBuyCoinsFormatter
  include Concerns::Currency

  def initialize(contracts)
    @contracts = contracts
    @config_parameters = Parameter.get_all
  end

  def view_data
    result = []
    @contracts.each do |contract|
      next if contract.payment.blank?
      result << {
        contract: contract,
        coin_name: @config_parameters['coin.name'],
        coin_price: Services::Coin::CurrencyToCurrencyConverter.new(contract.info['coin_rate'], contract.info['currency'], ExchangeRate::DEFAULT_CURRENCY).call,
        currency: ExchangeRate::DEFAULT_CURRENCY,
        revenue: Services::Coin::CurrencyToCurrencyConverter.new(contract.payment.amount_buyer, contract.payment.currency_buyer, ExchangeRate::DEFAULT_CURRENCY).call,
        quantity: contract.info['coin_amount']
      }
    end
    result
  end

end