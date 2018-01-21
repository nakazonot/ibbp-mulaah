class PaymentAddressType

  DEPOSIT      = 'deposit'
  PROMO_TOKENS = 'promo_tokens'

  def self.all
    {
      DEPOSIT        => 'Deposit',
      PROMO_TOKENS   => 'Promo Tokens',
    }
  end

   def self.description(name)
    self.all[name]
  end
end