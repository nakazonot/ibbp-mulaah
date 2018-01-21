class PaymentsMailer < ApplicationMailer
  helper ApplicationHelper

  def message_payment_notification(payment_id)
    @payment = Payment.includes(:user).find_by(id: payment_id)
    return if @payment.nil?
    mail(subject: t('message.payment_notification_subject'), to: @payment.user.email)
  end

  def message_coin_payment_notification(payment_id)
    @config_parameters = Parameter.get_all
    @payment = Payment.includes(:user).find_by(id: payment_id)
    return if @payment.nil?
    mail(subject: t('message.coin_payment_notification_subject'), to: @payment.user.email)
  end

  def message_invoice_paid_notification(invoice_id)
    @invoice = Invoice.find_by(id: invoice_id)
    return if @invoice.nil?
    @payment = @invoice.payment
    mail(subject: t('message.invoice_paid_notification_subject', invoice_number: @invoice.number), to: @invoice.invoice_customer.user.email)
  end

end