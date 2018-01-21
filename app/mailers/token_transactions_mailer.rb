class TokenTransactionsMailer < ApplicationMailer
  helper ApplicationHelper

  def message_promo_token_transaction_notification(transaction_id)
    @payment = TokenTransaction.includes(:user).find_by(id: transaction_id)
    return if @payment.nil?
    mail(subject: t('message.promo_token_transaction_notification_subject'), to: @payment.user.email)
  end

end