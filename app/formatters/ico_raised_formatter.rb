class IcoRaisedFormatter
  include Concerns::Currency
  include ApplicationHelper

  def initialize(balances, token_amount, token_total_amount, parameters)
    @balances           = balances
    @parameters         = parameters
    @token_amount       = token_amount
    @token_total_amount = token_total_amount
  end

  def view_data
    result = {
      deposit: {},
      referral_balance: {},
      tokens: {
        total:    coin_floor(@balances[:amount_of_purchased_tokens]),
        amount:   coin_floor(@token_amount),
        currency: @parameters['coin.rate_currency']
      },
      total_tokens_amount: coin_floor(@token_total_amount)
    }
    @balances[:currencies].each do |currency, value|
      result[:deposit][currency]          = currency_floor(value[:balance], currency)
      result[:referral_balance][currency] = currency_floor(value[:referral_balance], currency)
    end
    result[:deposit][:total]              = currency_floor(@balances[:balance_total], @parameters['coin.rate_currency'])
    result[:referral_balance][:total]     = currency_floor(@balances[:balance_referral_total], @parameters['coin.rate_currency'])
    result
  end

end