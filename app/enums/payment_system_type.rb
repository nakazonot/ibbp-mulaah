class PaymentSystemType

  INVOICED = 'invoiced'
  COIN_PAYMENTS   = 'coin_payments'
  ANY_PAY_COINS   = 'any_pay_coins'

  def self.all
    {
      INVOICED        => 'Invoiced',
      COIN_PAYMENTS   => 'CoinPayments',
      ANY_PAY_COINS   => 'AnyPayCoins',
    }
  end

   def self.description(name)
    self.all[name]
  end
end