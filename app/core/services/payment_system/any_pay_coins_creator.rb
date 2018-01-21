class Services::PaymentSystem::AnyPayCoinsCreator

  def initialize(params)
    @params               = params.deep_dup
    @payment_address_type = @params['Contract'].present? ? PaymentAddressType::PROMO_TOKENS : PaymentAddressType::DEPOSIT
    @payment_address      = ::PaymentAddress.with_deleted.by_payment_system(PaymentSystemType::ANY_PAY_COINS).find_by!(currency: @params['Currency'].upcase, payment_address: @params['Address'])
    @user                 = @payment_address.user
    raise "AnyPayCoins user not found! params: #{@params.to_json}" if @user.blank?
  end

  def call
    return if @params['Txid'].blank?
    if PaymentAddressType::DEPOSIT == @payment_address_type
      create_crypto_payment
    elsif PaymentAddressType::PROMO_TOKENS == @payment_address_type
      create_promo_token_payment
    end
    true
  end

  private

  def create_crypto_payment
    @payment = Payment.by_payment_system(PaymentSystemType::ANY_PAY_COINS).find_by(user_id: @user.id, transaction_id: @params['Txid'])
    return if @payment.present? && @payment.completed?
    status = @params['Status'] == "done" ? Payment::PAYMENT_STATUS_COMPLETED : Payment::PAYMENT_STATUS_PENDING

    @payment = Services::Coin::BalancePaymentCreator.new(payment_data, payment: @payment, status: status).call

    if @payment.completed?
      PaymentsMailer.message_payment_notification(@payment.id).deliver_later
      CoinAutoConvertWorker.perform_async(@user.id) if Parameter.auto_convert_balance_to_tokens_enabled?(@user)
      add_loyalty_program
    end
  end

  def create_promo_token_payment
    raise "Contract is not associated with Promo Tokens! params: #{@params.to_json}" if @params['Contract'] != ENV['PROMO_TOKENS_CONTRACT']
    @payment = TokenTransaction.by_payment_system(PaymentSystemType::ANY_PAY_COINS).find_by(user_id: @user.id, transaction_id: @params['Txid'])
    return if @payment.present? && @payment.completed?
    status = @params['Status'] == "done" ? TokenTransaction::TRANSACTION_STATUS_COMPLETED : TokenTransaction::TRANSACTION_STATUS_PENDING

    @payment = Services::Token::BalanceTransactionCreator.new(payment_data, @payment_address, payment: @payment, status: status).call

    if @payment.completed?
      TokenTransactionsMailer.message_promo_token_transaction_notification(@payment.id).deliver_later
    end
  end

  def add_loyalty_program
    Services::LoyaltyProgram::AddToUser.new(@params, @user, @payment).call
  end

  def payment_data
    {
      user:           @user,
      transaction_id: @params['Txid'],
      contract:       @params['Contract'],
      payment_system: ::PaymentSystemType::ANY_PAY_COINS,
      currency:       @params['Currency'].upcase,
      amount:         decimal_amount,
    }
  end

  def decimal_amount
    @params['Amount'].to_d / 10**@params['Decimals'].to_i
  end

end