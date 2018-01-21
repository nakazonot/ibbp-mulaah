class Services::PaymentSystem::CoinPaymentsCreator
  include Concerns::Log::Logger

  def initialize(params)
    @params             = params.deep_dup
    payment_address   = ::PaymentAddress.with_deleted.by_payment_system(::PaymentSystemType::COIN_PAYMENTS).by_dest_tag(@params['dest_tag']).find_by!(currency: @params['currency'], payment_address: @params['address'])
    @user             = payment_address.user
    raise "Payment user not found! params: #{@params.to_json}" if @user.blank?
  end

  def call
    return if @params['txn_id'].blank? 
    @payment = Payment.by_payment_system(PaymentSystemType::COIN_PAYMENTS).find_by(user_id: @user.id, transaction_id: @params['txn_id'])
    return if @payment.present? && @payment.completed?
    status = (@params['status'].to_i >= 100 || @params['status'].to_i == 2) ? Payment::PAYMENT_STATUS_COMPLETED : Payment::PAYMENT_STATUS_PENDING

    @payment = Services::Coin::BalancePaymentCreator.new(payment_data, payment: @payment, status: status).call

    if @payment.completed?
      send_email
      CoinAutoConvertWorker.perform_async(@user.id) if Parameter.auto_convert_balance_to_tokens_enabled?(@user)
      add_loyalty_program
    end
    true
  end

  private

  def payment_data
    {
      user:           @user,
      transaction_id: @params['txn_id'],
      payment_system: ::PaymentSystemType::COIN_PAYMENTS,
      currency:       @params['currency'],
      amount:         @params['amount'],
    }
  end

  def send_email
    PaymentsMailer.message_payment_notification(@payment.id).deliver_later
  end

  def add_loyalty_program
    log_info("AnyPayCoins get_eth_tx_info by tx_id: #{@params['txn_id']}")
    tx_info = ApiWrappers::AnyPayCoins.new.get_eth_tx_info(@params['txn_id'])
    Services::LoyaltyProgram::AddToUser.new(tx_info, @user, @payment).call if tx_info.present?
  end
end