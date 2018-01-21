class Services::Token::PromoTokensPurchaseTransactionCreator

  def initialize(user, payment)
    @user = user
    @payment = payment
    @contract = ENV['PROMO_TOKENS_CONTRACT']
  end

  def call
    create_transaction
    nil
  end

  private

  def create_transaction
    @transaction = TokenTransaction.create!({
      user_id:            @user.id,
      payment_id:         @payment.id,
      amount:             1,
      contract:           @contract,
      transaction_type:   TokenTransaction::TRANSACTION_TYPE_PURCHASE,
    })
  end

end