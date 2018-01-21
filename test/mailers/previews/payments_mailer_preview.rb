class PaymentsMailerPreview < ActionMailer::Preview
  def message_payment_notification
    payment = Payment.by_type(Payment::PAYMENT_TYPE_BALANCE).not_system.last
    PaymentsMailer.message_payment_notification(payment.id) if payment.present?
  end

  def message_coin_payment_notification
    config_parameters = Parameter.get_all
    payment = Payment.by_type(Payment::PAYMENT_TYPE_PURCHASE).last
    PaymentsMailer.message_coin_payment_notification(payment.id) if payment.present?
  end

  def message_invoice_paid_notification
    invoice = Invoice.where.not(payment_id: nil).last
    PaymentsMailer.message_invoice_paid_notification(invoice.id) if invoice.present?
  end
end
