class Services::Dashboard::Statistics
  def initialize(starting_at = nil, ending_at = nil)
    @starting_at  = starting_at.blank? ? starting_at : starting_at.in_time_zone
    @ending_at    = ending_at.blank? ? ending_at : (ending_at.in_time_zone + 1.day)
    @parameters   = Parameter.get_all
    @balances     = Payment.balances(@starting_at, @ending_at)
  end

  def call
    {
      users: user_statistics,
      tokens: token_statistics,
      raised: raised_statistics,
      payment_addresses: ::PaymentAddress.statistics
    }
  end

  private

  def user_statistics
    {
      registered: User.count,
      token_holders: User.token_holders.length,
      deposited_only: User.deposited_only.count
    }
  end

  def token_statistics
    {
      purchased: {
        amount: @balances[:amount_of_purchased_tokens],
        worth: Payment.purchase_amount_in_system_currency(@starting_at, @ending_at)
      },
      bonus: {
        amount: @balances[:amount_of_bonus_tokens],
        worth: @balances[:amount_of_bonus_tokens] * @parameters['coin.rate']
      },
      referral: {
        amount: @balances[:amount_of_referral_tokens],
        worth: @balances[:amount_of_referral_tokens] * @parameters['coin.rate']
      },
      balance: {
        amount: @balances[:total_amount_tokens_on_balance],
        worth: @balances[:total_amount_tokens_on_balance] * @parameters['coin.rate']
      },
      refund: {
        amount: @balances[:amount_of_refund_tokens],
        worth: @balances[:amount_of_refund_tokens] * @parameters['coin.rate']
      },
      transfer: {
        amount: @balances[:amount_of_transfer_tokens],
        worth: @balances[:amount_of_transfer_tokens] * @parameters['coin.rate']
      }
    }
  end

  def raised_statistics
    raised         = {
      currencies: {},
      total: 0,
      total_referral: 0,
    }

    @balances[:currencies].each do |currency_symbol, value|
      raised[:currencies][currency_symbol] = {
        amount_in_currency: value[:balance],
        amount_in_system_currency: Services::Coin::CurrencyToCurrencyConverter.new(value[:balance], currency_symbol, @parameters['coin.rate_currency']).call,
        referral_amount_in_currency: value[:referral_balance],
        referral_amount_in_system_currency: Services::Coin::CurrencyToCurrencyConverter.new(value[:referral_balance], currency_symbol, @parameters['coin.rate_currency']).call,
      }

      raised[:total_referral] += raised[:currencies][currency_symbol][:referral_amount_in_system_currency]
      raised[:total]          += raised[:currencies][currency_symbol][:amount_in_system_currency]
    end

    raised
  end
end
