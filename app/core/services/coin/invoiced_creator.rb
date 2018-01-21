class Services::Coin::InvoicedCreator

  def initialize(event)
    @event = event
  end

  def call
    @invoice = Invoice.find_by(external_id: @event[:data][:object][:id])
    return if @invoice.blank? || @invoice.status == Invoice::STATUS_PAID
    @user = @invoice.invoice_customer.user
    raise "Payment user not found! event: #{@event.to_json}" if @user.blank?

    @payment = Services::Coin::BalancePaymentCreator.new(payment_data).call

    pay_invoice
    send_email
    CoinAutoConvertWorker.perform_async(@user.id) if Parameter.auto_convert_balance_to_tokens_enabled?(@user)
    true
  end

  private

  def payment_data
    {
      user:           @user,
      transaction_id: @invoice.external_id,
      payment_system: ::PaymentSystemType::INVOICED,
      currency:       @event[:data][:object][:currency].upcase,
      amount:         @event[:data][:object][:total],
    }
  end

  def pay_invoice
    @invoice.update_columns(status: Invoice::STATUS_PAID, payment_id: @payment.id)
  end

  def send_email
    PaymentsMailer.message_invoice_paid_notification(@invoice.id).deliver_later
  end
end