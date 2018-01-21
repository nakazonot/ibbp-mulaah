class Services::Token::BalanceTransactionCreator

  def initialize(params, payment_address, status: nil, payment: nil)
    @params             = params.deep_dup
    @user               = params[:user]
    @payment_address    = payment_address
    @config_parameters = Parameter.get_all
    @status             = status.nil? ? TokenTransaction::TRANSACTION_STATUS_COMPLETED : status
    @payment            = payment
    raise "Payment user not found! params: #{@params.to_json}" if @user.blank?
  end

  def call
    return @payment if @payment.present? && (@payment.completed? || @status == TokenTransaction::TRANSACTION_STATUS_PENDING)
    ActiveRecord::Base.transaction do
      create_transaction
    end
    @payment
  end

  private

  def create_transaction
    return @payment.update_column(:status, @status) if @payment.present?
    @payment = TokenTransaction.create!({
      user_id:            @user.id,
      payment_address_id: @payment_address.id,
      transaction_id:     @params[:transaction_id],
      amount:             @params[:amount],
      currency:           @params[:currency],
      contract:           @params[:contract],
      status:             @status,
      transaction_type:   TokenTransaction::TRANSACTION_TYPE_BALANCE,
      payment_system:     @params[:payment_system],
    })
  end
end